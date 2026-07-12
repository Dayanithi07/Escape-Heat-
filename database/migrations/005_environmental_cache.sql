-- ============================================================================
-- Escape Heat — Migration 005: Environmental Cache Table
-- ============================================================================
-- Description: Caches external API responses (Open-Meteo, NASA POWER, etc.)
--              to reduce API calls and improve response times. Includes
--              automatic cleanup of expired cache entries via pg_cron.
--              This data is ephemeral and NOT retained for insights.
-- Depends on:  001_extensions_and_enums.sql
-- Run order:   5 of 10
-- ============================================================================

-- ==========================================================
-- 1. TABLE: environmental_cache
-- ==========================================================

CREATE TABLE IF NOT EXISTS public.environmental_cache (
    id              UUID                    PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Location (rounded to 2 decimal places by the backend for dedup)
    latitude        DOUBLE PRECISION        NOT NULL
                                            CHECK (latitude BETWEEN -90 AND 90),
    longitude       DOUBLE PRECISION        NOT NULL
                                            CHECK (longitude BETWEEN -180 AND 180),

    -- Data classification
    data_source     public.data_source_type NOT NULL,
    data_type       TEXT                    NOT NULL
                                            CHECK (length(data_type) BETWEEN 1 AND 100),

    -- Cached payload
    data            JSONB                   NOT NULL DEFAULT '{}'::jsonb,
    heat_index      DOUBLE PRECISION,
    uv_index        DOUBLE PRECISION,
    aqi             INTEGER                 CHECK (aqi IS NULL OR aqi BETWEEN 0 AND 500),

    -- Cache lifecycle
    fetched_at      TIMESTAMPTZ             NOT NULL DEFAULT now(),
    expires_at      TIMESTAMPTZ             NOT NULL,

    -- Prevent duplicate cache entries for the same location + source + type
    CONSTRAINT uq_environmental_cache_location_source
        UNIQUE (latitude, longitude, data_source, data_type)
);

-- ==========================================================
-- 2. INDEXES
-- ==========================================================

-- Primary lookup: find cache for a specific location + source
CREATE INDEX IF NOT EXISTS idx_env_cache_location_source
    ON public.environmental_cache (latitude, longitude, data_source, data_type);

-- Cleanup: index by expiration time for efficient stale-cache queries
CREATE INDEX IF NOT EXISTS idx_env_cache_expires_at
    ON public.environmental_cache (expires_at)
;

-- Lookup by data source (for monitoring/debugging)
CREATE INDEX IF NOT EXISTS idx_env_cache_data_source
    ON public.environmental_cache (data_source);

-- GIN index for JSONB queries on the cached data
CREATE INDEX IF NOT EXISTS idx_env_cache_data_gin
    ON public.environmental_cache USING GIN (data);

-- ==========================================================
-- 3. CACHE CLEANUP FUNCTION
-- ==========================================================

CREATE OR REPLACE FUNCTION public.cleanup_expired_cache()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.environmental_cache
    WHERE expires_at < now();

    GET DIAGNOSTICS deleted_count = ROW_COUNT;

    RAISE NOTICE 'Cleaned up % expired cache entries', deleted_count;
    RETURN deleted_count;
END;
$$;

COMMENT ON FUNCTION public.cleanup_expired_cache()
    IS 'Deletes expired environmental_cache rows. Called by pg_cron hourly.';

-- ==========================================================
-- 4. SCHEDULE AUTOMATIC CLEANUP (pg_cron)
-- ==========================================================
-- Runs every hour. If pg_cron is not available, call
-- cleanup_expired_cache() from a backend cron job instead.

DO $$
BEGIN
    -- Attempt to schedule via pg_cron
    PERFORM cron.schedule(
        'cleanup-expired-env-cache',        -- job name
        '0 * * * *',                        -- every hour at minute 0
        'SELECT public.cleanup_expired_cache()'
    );
    RAISE NOTICE 'pg_cron job scheduled: cleanup-expired-env-cache (hourly)';
EXCEPTION
    WHEN undefined_function THEN
        RAISE NOTICE 'pg_cron not available. Schedule cleanup_expired_cache() from your backend cron.';
    WHEN others THEN
        RAISE NOTICE 'Could not schedule pg_cron job: %. Schedule cleanup_expired_cache() from your backend cron.', SQLERRM;
END
$$;

-- ==========================================================
-- 5. UPSERT HELPER FUNCTION
-- ==========================================================
-- Backend can call this to insert or update cache entries atomically.

CREATE OR REPLACE FUNCTION public.upsert_environmental_cache(
    p_latitude      DOUBLE PRECISION,
    p_longitude     DOUBLE PRECISION,
    p_data_source   public.data_source_type,
    p_data_type     TEXT,
    p_data          JSONB,
    p_heat_index    DOUBLE PRECISION DEFAULT NULL,
    p_uv_index      DOUBLE PRECISION DEFAULT NULL,
    p_aqi           INTEGER DEFAULT NULL,
    p_ttl_minutes   INTEGER DEFAULT 30
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    result_id UUID;
BEGIN
    INSERT INTO public.environmental_cache (
        latitude, longitude, data_source, data_type,
        data, heat_index, uv_index, aqi,
        fetched_at, expires_at
    )
    VALUES (
        ROUND(p_latitude::numeric, 2)::double precision,
        ROUND(p_longitude::numeric, 2)::double precision,
        p_data_source, p_data_type,
        p_data, p_heat_index, p_uv_index, p_aqi,
        now(), now() + (p_ttl_minutes || ' minutes')::interval
    )
    ON CONFLICT (latitude, longitude, data_source, data_type)
    DO UPDATE SET
        data       = EXCLUDED.data,
        heat_index = EXCLUDED.heat_index,
        uv_index   = EXCLUDED.uv_index,
        aqi        = EXCLUDED.aqi,
        fetched_at = EXCLUDED.fetched_at,
        expires_at = EXCLUDED.expires_at
    RETURNING id INTO result_id;

    RETURN result_id;
END;
$$;

COMMENT ON FUNCTION public.upsert_environmental_cache
    IS 'Atomically inserts or updates a cache entry. Rounds coordinates to 2 decimal places. Default TTL is 30 minutes.';

-- ==========================================================
-- 6. TABLE COMMENTS
-- ==========================================================

COMMENT ON TABLE public.environmental_cache
    IS 'Ephemeral cache for external API responses. Auto-cleaned hourly. NOT retained for analytics.';

COMMENT ON COLUMN public.environmental_cache.data_type
    IS 'Describes the kind of data: current_weather, air_quality, lst (land surface temp), uv, forecast_hourly';

COMMENT ON COLUMN public.environmental_cache.expires_at
    IS 'Cache entries with expires_at < now() are considered stale and will be auto-deleted';
