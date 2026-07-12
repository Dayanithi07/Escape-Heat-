-- ============================================================================
-- Escape Heat — Combined Migration Runner
-- ============================================================================
-- Description: Single-file migration that runs ALL migrations in order.
--              Use this for fresh installations instead of running 10
--              separate files. NOT for incremental updates.
--
-- Usage:       Paste this entire file into Supabase SQL Editor and run.
-- ============================================================================

-- ============================================================================
-- MIGRATION 001: Extensions and Enums
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS "pg_cron" SCHEMA "extensions";
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'pg_cron not available: %. Cache cleanup must be scheduled from backend.', SQLERRM;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE public.user_role AS ENUM ('citizen','worker','authority','admin');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'gender_type') THEN
        CREATE TYPE public.gender_type AS ENUM ('male','female','other','prefer_not_to_say');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'temp_unit') THEN
        CREATE TYPE public.temp_unit AS ENUM ('celsius','fahrenheit');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'alert_threshold') THEN
        CREATE TYPE public.alert_threshold AS ENUM ('low','moderate','high','extreme');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'activity_level') THEN
        CREATE TYPE public.activity_level AS ENUM ('sedentary','light','moderate','active','very_active');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'data_source_type') THEN
        CREATE TYPE public.data_source_type AS ENUM ('open_meteo','nasa_power','imd','isro','osm');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'risk_level') THEN
        CREATE TYPE public.risk_level AS ENUM ('low','moderate','high','very_high','extreme');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'recommendation_category') THEN
        CREATE TYPE public.recommendation_category AS ENUM ('general','hydration','activity','clothing','travel','health');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'chat_role') THEN
        CREATE TYPE public.chat_role AS ENUM ('user','assistant','system');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'report_type') THEN
        CREATE TYPE public.report_type AS ENUM ('daily_summary','weekly_summary','heat_alert','custom');
    END IF;
END
$$;

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.handle_updated_at()
    IS 'Automatically sets updated_at to current timestamp on UPDATE';

-- ============================================================================
-- MIGRATION 002: Profiles and Auth
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id              UUID            PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name       TEXT            NOT NULL DEFAULT '',
    avatar_url      TEXT,
    date_of_birth   DATE,
    gender          public.gender_type,
    phone           TEXT,
    role            public.user_role NOT NULL DEFAULT 'citizen',
    health_conditions TEXT[]        DEFAULT '{}',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    CONSTRAINT chk_profiles_phone_format
        CHECK (phone IS NULL OR phone ~ '^\+?[0-9\s\-]{7,20}$'),
    CONSTRAINT chk_profiles_avatar_url_length
        CHECK (avatar_url IS NULL OR length(avatar_url) <= 2048),
    CONSTRAINT chk_profiles_full_name_length
        CHECK (length(full_name) <= 200)
);

CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles (role);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles (created_at DESC);

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
        NEW.raw_user_meta_data ->> 'avatar_url'
    );
    INSERT INTO public.user_preferences (user_id) VALUES (NEW.id);
    RETURN NEW;
EXCEPTION
    WHEN unique_violation THEN RETURN NEW;
    WHEN undefined_table THEN RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- MIGRATION 003: User Preferences
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.user_preferences (
    id                      UUID                    PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID                    NOT NULL UNIQUE
                                                    REFERENCES public.profiles(id) ON DELETE CASCADE,
    temperature_unit        public.temp_unit        NOT NULL DEFAULT 'celsius',
    language                TEXT                    NOT NULL DEFAULT 'en',
    theme                   TEXT                    NOT NULL DEFAULT 'system'
                                                    CHECK (theme IN ('light', 'dark', 'system')),
    notification_enabled    BOOLEAN                 NOT NULL DEFAULT true,
    heat_alert_threshold    public.alert_threshold  NOT NULL DEFAULT 'high',
    email_alerts            BOOLEAN                 NOT NULL DEFAULT false,
    push_alerts             BOOLEAN                 NOT NULL DEFAULT true,
    activity_level          public.activity_level   NOT NULL DEFAULT 'moderate',
    outdoor_work_hours      JSONB                   DEFAULT '{"start": "09:00", "end": "17:00"}'::jsonb,
    works_outdoors          BOOLEAN                 NOT NULL DEFAULT false,
    created_at              TIMESTAMPTZ             NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ             NOT NULL DEFAULT now(),
    CONSTRAINT chk_user_preferences_language_format
        CHECK (language ~ '^[a-z]{2}(-[A-Z]{2})?$'),
    CONSTRAINT chk_user_preferences_outdoor_hours_schema
        CHECK (outdoor_work_hours IS NULL OR (outdoor_work_hours ? 'start' AND outdoor_work_hours ? 'end'))
);

DROP TRIGGER IF EXISTS trg_user_preferences_updated_at ON public.user_preferences;
CREATE TRIGGER trg_user_preferences_updated_at
    BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================================
-- MIGRATION 004: Saved Locations
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.saved_locations (
    id              UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID                NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    label           TEXT                NOT NULL CHECK (length(label) BETWEEN 1 AND 100),
    latitude        DOUBLE PRECISION    NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude       DOUBLE PRECISION    NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    address         TEXT                CHECK (address IS NULL OR length(address) <= 500),
    city            TEXT                CHECK (city IS NULL OR length(city) <= 100),
    state           TEXT                CHECK (state IS NULL OR length(state) <= 100),
    country         TEXT                NOT NULL DEFAULT 'India' CHECK (length(country) <= 100),
    is_primary      BOOLEAN             NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_saved_locations_user_id ON public.saved_locations (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_saved_locations_single_primary
    ON public.saved_locations (user_id) WHERE is_primary = true;
CREATE INDEX IF NOT EXISTS idx_saved_locations_coords ON public.saved_locations (latitude, longitude);

CREATE OR REPLACE FUNCTION public.check_saved_locations_limit()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE
    location_count INTEGER;
    max_locations  CONSTANT INTEGER := 25;
BEGIN
    SELECT COUNT(*) INTO location_count FROM public.saved_locations WHERE user_id = NEW.user_id;
    IF location_count >= max_locations THEN
        RAISE EXCEPTION 'Location limit reached: maximum % saved locations per user', max_locations
            USING HINT = 'Delete an existing location before adding a new one', ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_saved_locations_limit ON public.saved_locations;
CREATE TRIGGER trg_check_saved_locations_limit
    BEFORE INSERT ON public.saved_locations FOR EACH ROW EXECUTE FUNCTION public.check_saved_locations_limit();

CREATE OR REPLACE FUNCTION public.ensure_single_primary_location()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
    IF NEW.is_primary = true THEN
        UPDATE public.saved_locations SET is_primary = false
        WHERE user_id = NEW.user_id AND id != NEW.id AND is_primary = true;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_ensure_single_primary ON public.saved_locations;
CREATE TRIGGER trg_ensure_single_primary
    BEFORE INSERT OR UPDATE OF is_primary ON public.saved_locations
    FOR EACH ROW WHEN (NEW.is_primary = true) EXECUTE FUNCTION public.ensure_single_primary_location();

-- ============================================================================
-- MIGRATION 005: Environmental Cache
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.environmental_cache (
    id              UUID                    PRIMARY KEY DEFAULT gen_random_uuid(),
    latitude        DOUBLE PRECISION        NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude       DOUBLE PRECISION        NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    data_source     public.data_source_type NOT NULL,
    data_type       TEXT                    NOT NULL CHECK (length(data_type) BETWEEN 1 AND 100),
    data            JSONB                   NOT NULL DEFAULT '{}'::jsonb,
    heat_index      DOUBLE PRECISION,
    uv_index        DOUBLE PRECISION,
    aqi             INTEGER                 CHECK (aqi IS NULL OR aqi BETWEEN 0 AND 500),
    fetched_at      TIMESTAMPTZ             NOT NULL DEFAULT now(),
    expires_at      TIMESTAMPTZ             NOT NULL,
    CONSTRAINT uq_environmental_cache_location_source
        UNIQUE (latitude, longitude, data_source, data_type)
);

CREATE INDEX IF NOT EXISTS idx_env_cache_location_source
    ON public.environmental_cache (latitude, longitude, data_source, data_type);
CREATE INDEX IF NOT EXISTS idx_env_cache_expires_at
    ON public.environmental_cache (expires_at);
CREATE INDEX IF NOT EXISTS idx_env_cache_data_source
    ON public.environmental_cache (data_source);
CREATE INDEX IF NOT EXISTS idx_env_cache_data_gin
    ON public.environmental_cache USING GIN (data);

CREATE OR REPLACE FUNCTION public.cleanup_expired_cache()
RETURNS INTEGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE deleted_count INTEGER;
BEGIN
    DELETE FROM public.environmental_cache WHERE expires_at < now();
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$;

DO $$
BEGIN
    PERFORM cron.schedule('cleanup-expired-env-cache', '0 * * * *', 'SELECT public.cleanup_expired_cache()');
EXCEPTION WHEN others THEN
    RAISE NOTICE 'pg_cron not available. Schedule cleanup_expired_cache() from your backend.';
END
$$;

CREATE OR REPLACE FUNCTION public.upsert_environmental_cache(
    p_latitude DOUBLE PRECISION, p_longitude DOUBLE PRECISION,
    p_data_source public.data_source_type, p_data_type TEXT, p_data JSONB,
    p_heat_index DOUBLE PRECISION DEFAULT NULL, p_uv_index DOUBLE PRECISION DEFAULT NULL,
    p_aqi INTEGER DEFAULT NULL, p_ttl_minutes INTEGER DEFAULT 30
) RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE result_id UUID;
BEGIN
    INSERT INTO public.environmental_cache (
        latitude, longitude, data_source, data_type, data, heat_index, uv_index, aqi, fetched_at, expires_at
    ) VALUES (
        ROUND(p_latitude::numeric, 2)::double precision,
        ROUND(p_longitude::numeric, 2)::double precision,
        p_data_source, p_data_type, p_data, p_heat_index, p_uv_index, p_aqi,
        now(), now() + (p_ttl_minutes || ' minutes')::interval
    )
    ON CONFLICT (latitude, longitude, data_source, data_type)
    DO UPDATE SET data = EXCLUDED.data, heat_index = EXCLUDED.heat_index,
        uv_index = EXCLUDED.uv_index, aqi = EXCLUDED.aqi,
        fetched_at = EXCLUDED.fetched_at, expires_at = EXCLUDED.expires_at
    RETURNING id INTO result_id;
    RETURN result_id;
END;
$$;

-- ============================================================================
-- MIGRATION 006: Recommendation History
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.recommendation_history (
    id                      UUID                            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID                            NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    location_id             UUID                            REFERENCES public.saved_locations(id) ON DELETE SET NULL,
    latitude                DOUBLE PRECISION                NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude               DOUBLE PRECISION                NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    location_label          TEXT,
    risk_level              public.risk_level               NOT NULL,
    risk_score              DOUBLE PRECISION                NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
    environmental_snapshot   JSONB                          NOT NULL DEFAULT '{}'::jsonb,
    recommendations         JSONB                           NOT NULL DEFAULT '[]'::jsonb,
    category                public.recommendation_category  NOT NULL DEFAULT 'general',
    feedback_rating         INTEGER                         CHECK (feedback_rating IS NULL OR feedback_rating BETWEEN 1 AND 5),
    feedback_comment        TEXT                            CHECK (feedback_comment IS NULL OR length(feedback_comment) <= 1000),
    model_used              TEXT,
    generation_time_ms      INTEGER                         CHECK (generation_time_ms IS NULL OR generation_time_ms >= 0),
    created_at              TIMESTAMPTZ                     NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_rec_history_user_created ON public.recommendation_history (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_rec_history_risk_level ON public.recommendation_history (risk_level);
CREATE INDEX IF NOT EXISTS idx_rec_history_category ON public.recommendation_history (category);
CREATE INDEX IF NOT EXISTS idx_rec_history_created_at ON public.recommendation_history (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_rec_history_coords ON public.recommendation_history (latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_rec_history_env_snapshot_gin ON public.recommendation_history USING GIN (environmental_snapshot);

-- ============================================================================
-- MIGRATION 007: AI Chat History
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.ai_chat_history (
    id              UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID                NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    session_id      UUID                NOT NULL DEFAULT gen_random_uuid(),
    role            public.chat_role    NOT NULL,
    message         TEXT                NOT NULL CHECK (length(message) BETWEEN 1 AND 50000),
    context         JSONB,
    model_used      TEXT,
    tokens_used     INTEGER             CHECK (tokens_used IS NULL OR tokens_used >= 0),
    latency_ms      INTEGER             CHECK (latency_ms IS NULL OR latency_ms >= 0),
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_chat_history_session ON public.ai_chat_history (session_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_chat_history_user_created ON public.ai_chat_history (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_history_user_session ON public.ai_chat_history (user_id, session_id);
CREATE INDEX IF NOT EXISTS idx_chat_history_role ON public.ai_chat_history (role);

CREATE OR REPLACE VIEW public.chat_sessions_summary AS
SELECT DISTINCT ON (user_id, session_id)
    user_id, session_id,
    message AS last_message, role AS last_role, created_at AS last_message_at,
    (SELECT COUNT(*) FROM public.ai_chat_history sub WHERE sub.session_id = main.session_id) AS message_count
FROM public.ai_chat_history main
ORDER BY user_id, session_id, created_at DESC;

-- ============================================================================
-- MIGRATION 008: Reports
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.reports (
    id              UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID                NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title           TEXT                NOT NULL CHECK (length(title) BETWEEN 1 AND 300),
    report_type     public.report_type  NOT NULL,
    location_label  TEXT,
    latitude        DOUBLE PRECISION    CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    longitude       DOUBLE PRECISION    CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
    content         JSONB               NOT NULL DEFAULT '{}'::jsonb,
    summary         TEXT                CHECK (summary IS NULL OR length(summary) <= 5000),
    file_url        TEXT                CHECK (file_url IS NULL OR length(file_url) <= 2048),
    is_public       BOOLEAN             NOT NULL DEFAULT false,
    shared_token    UUID                UNIQUE,
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT now(),
    CONSTRAINT chk_reports_coordinates_pair
        CHECK ((latitude IS NULL AND longitude IS NULL) OR (latitude IS NOT NULL AND longitude IS NOT NULL))
);

CREATE INDEX IF NOT EXISTS idx_reports_user_created ON public.reports (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_type ON public.reports (report_type);
CREATE INDEX IF NOT EXISTS idx_reports_public ON public.reports (is_public, created_at DESC) WHERE is_public = true;
CREATE INDEX IF NOT EXISTS idx_reports_shared_token ON public.reports (shared_token) WHERE shared_token IS NOT NULL;

CREATE OR REPLACE FUNCTION public.generate_report_share_token(p_report_id UUID)
RETURNS UUID LANGUAGE plpgsql SECURITY INVOKER AS $$
DECLARE new_token UUID;
BEGIN
    new_token := gen_random_uuid();
    UPDATE public.reports SET shared_token = new_token, is_public = true WHERE id = p_report_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Report not found: %', p_report_id USING ERRCODE = 'no_data_found'; END IF;
    RETURN new_token;
END;
$$;

-- ============================================================================
-- MIGRATION 009: Row Level Security
-- ============================================================================

-- profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles FORCE ROW LEVEL SECURITY;

CREATE POLICY profiles_select_own ON public.profiles FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY profiles_select_admin ON public.profiles FOR SELECT TO authenticated
    USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY profiles_update_own ON public.profiles FOR UPDATE TO authenticated
    USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY profiles_delete_own ON public.profiles FOR DELETE TO authenticated USING (auth.uid() = id);

-- user_preferences
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences FORCE ROW LEVEL SECURITY;

CREATE POLICY user_preferences_select_own ON public.user_preferences FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY user_preferences_update_own ON public.user_preferences FOR UPDATE TO authenticated
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY user_preferences_delete_own ON public.user_preferences FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- saved_locations
ALTER TABLE public.saved_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_locations FORCE ROW LEVEL SECURITY;

CREATE POLICY saved_locations_select_own ON public.saved_locations FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY saved_locations_insert_own ON public.saved_locations FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY saved_locations_update_own ON public.saved_locations FOR UPDATE TO authenticated
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY saved_locations_delete_own ON public.saved_locations FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- environmental_cache
ALTER TABLE public.environmental_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.environmental_cache FORCE ROW LEVEL SECURITY;

CREATE POLICY env_cache_select_authenticated ON public.environmental_cache FOR SELECT TO authenticated USING (true);

-- recommendation_history
ALTER TABLE public.recommendation_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_history FORCE ROW LEVEL SECURITY;

CREATE POLICY rec_history_select_own ON public.recommendation_history FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY rec_history_insert_own ON public.recommendation_history FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY rec_history_update_feedback ON public.recommendation_history FOR UPDATE TO authenticated
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY rec_history_select_admin ON public.recommendation_history FOR SELECT TO authenticated
    USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- ai_chat_history
ALTER TABLE public.ai_chat_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_chat_history FORCE ROW LEVEL SECURITY;

CREATE POLICY chat_history_select_own ON public.ai_chat_history FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY chat_history_insert_own ON public.ai_chat_history FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY chat_history_select_admin ON public.ai_chat_history FOR SELECT TO authenticated
    USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- reports
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports FORCE ROW LEVEL SECURITY;

CREATE POLICY reports_select_own ON public.reports FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY reports_select_public ON public.reports FOR SELECT TO authenticated USING (is_public = true);
CREATE POLICY reports_select_shared_anon ON public.reports FOR SELECT TO anon
    USING (is_public = true AND shared_token IS NOT NULL);
CREATE POLICY reports_insert_own ON public.reports FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY reports_update_own ON public.reports FOR UPDATE TO authenticated
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY reports_delete_own ON public.reports FOR DELETE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY reports_select_admin ON public.reports FOR SELECT TO authenticated
    USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

-- ============================================================================
-- MIGRATION 010: Storage Buckets
-- ============================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public, file_size_limit = EXCLUDED.file_size_limit, allowed_mime_types = EXCLUDED.allowed_mime_types;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('reports', 'reports', false, 10485760, ARRAY['application/pdf'])
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public, file_size_limit = EXCLUDED.file_size_limit, allowed_mime_types = EXCLUDED.allowed_mime_types;

CREATE POLICY storage_avatars_select_public ON storage.objects FOR SELECT TO public USING (bucket_id = 'avatars');
CREATE POLICY storage_avatars_insert_own ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY storage_avatars_update_own ON storage.objects FOR UPDATE TO authenticated
    USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text)
    WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY storage_avatars_delete_own ON storage.objects FOR DELETE TO authenticated
    USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY storage_reports_select_own ON storage.objects FOR SELECT TO authenticated
    USING (bucket_id = 'reports' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY storage_reports_insert_own ON storage.objects FOR INSERT TO authenticated
    WITH CHECK (bucket_id = 'reports' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY storage_reports_update_own ON storage.objects FOR UPDATE TO authenticated
    USING (bucket_id = 'reports' AND (storage.foldername(name))[1] = auth.uid()::text)
    WITH CHECK (bucket_id = 'reports' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY storage_reports_delete_own ON storage.objects FOR DELETE TO authenticated
    USING (bucket_id = 'reports' AND (storage.foldername(name))[1] = auth.uid()::text);

-- ============================================================================
-- DONE
-- ============================================================================
-- All tables, indexes, triggers, functions, RLS policies, and storage buckets
-- have been created. Run seed_data.sql next for demo data.
