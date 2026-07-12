-- ============================================================================
-- Escape Heat — Migration 002: Profiles Table and Auth Integration
-- ============================================================================
-- Description: Creates the profiles table linked 1:1 with auth.users,
--              and a trigger that auto-creates a profile + preferences
--              whenever a new user signs up via Supabase Auth.
-- Depends on:  001_extensions_and_enums.sql
-- Run order:   2 of 10
-- ============================================================================

-- ==========================================================
-- 1. TABLE: profiles
-- ==========================================================

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

    -- Constraints
    CONSTRAINT chk_profiles_phone_format
        CHECK (phone IS NULL OR phone ~ '^\+?[0-9\s\-]{7,20}$'),
    CONSTRAINT chk_profiles_avatar_url_length
        CHECK (avatar_url IS NULL OR length(avatar_url) <= 2048),
    CONSTRAINT chk_profiles_full_name_length
        CHECK (length(full_name) <= 200)
);

-- ==========================================================
-- 2. INDEXES
-- ==========================================================

CREATE INDEX IF NOT EXISTS idx_profiles_role
    ON public.profiles (role);

CREATE INDEX IF NOT EXISTS idx_profiles_created_at
    ON public.profiles (created_at DESC);

-- ==========================================================
-- 3. TRIGGERS
-- ==========================================================

-- Auto-update updated_at on modification
DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- ==========================================================
-- 4. AUTH INTEGRATION — Auto-create profile on signup
-- ==========================================================

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

    -- Also create default user preferences (table created in migration 003)
    INSERT INTO public.user_preferences (user_id)
    VALUES (NEW.id);

    RETURN NEW;
EXCEPTION
    WHEN unique_violation THEN
        -- Profile already exists (e.g., re-triggered), skip silently
        RETURN NEW;
    WHEN undefined_table THEN
        -- user_preferences table not yet created (migration order issue)
        -- Profile is still created; preferences will need manual creation
        RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.handle_new_user()
    IS 'Creates a profiles row and user_preferences row when a new user signs up via Supabase Auth';

-- Drop existing trigger if any, then create
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ==========================================================
-- 5. TABLE COMMENTS
-- ==========================================================

COMMENT ON TABLE public.profiles
    IS 'User profile data extending auth.users. One row per authenticated user.';

COMMENT ON COLUMN public.profiles.id
    IS 'Matches auth.users.id — set automatically by the auth trigger';

COMMENT ON COLUMN public.profiles.health_conditions
    IS 'Array of health conditions relevant to heat risk: e.g., asthma, heart_disease, diabetes, hypertension';

COMMENT ON COLUMN public.profiles.role
    IS 'User type used for personalized recommendations and access control';
