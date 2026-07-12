-- ============================================================================
-- Escape Heat — Migration 006: Recommendation History Table
-- ============================================================================
-- Description: Stores AI-generated heat recommendations with full
--              environmental context for audit trail and user history.
--              Retained indefinitely for insights and analytics.
-- Depends on:  001_extensions_and_enums.sql, 002_profiles_and_auth.sql,
--              004_saved_locations.sql
-- Run order:   6 of 10
-- ============================================================================

-- ==========================================================
-- 1. TABLE: recommendation_history
-- ==========================================================

CREATE TABLE IF NOT EXISTS public.recommendation_history (
    id                      UUID                            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID                            NOT NULL
                                                            REFERENCES public.profiles(id) ON DELETE CASCADE,
    location_id             UUID                            REFERENCES public.saved_locations(id) ON DELETE SET NULL,

    -- Location snapshot at time of request
    latitude                DOUBLE PRECISION                NOT NULL
                                                            CHECK (latitude BETWEEN -90 AND 90),
    longitude               DOUBLE PRECISION                NOT NULL
                                                            CHECK (longitude BETWEEN -180 AND 180),
    location_label          TEXT,

    -- Risk assessment
    risk_level              public.risk_level               NOT NULL,
    risk_score              DOUBLE PRECISION                NOT NULL
                                                            CHECK (risk_score BETWEEN 0 AND 100),

    -- Environmental context at time of recommendation
    environmental_snapshot   JSONB                          NOT NULL DEFAULT '{}'::jsonb,
    -- Expected schema:
    -- {
    --   "temperature_c": 42.5,
    --   "feels_like_c": 48.2,
    --   "humidity_pct": 35,
    --   "uv_index": 11,
    --   "wind_speed_kmh": 12,
    --   "aqi": 156,
    --   "heat_index": 51.3
    -- }

    -- AI-generated recommendations
    recommendations         JSONB                           NOT NULL DEFAULT '[]'::jsonb,
    -- Expected schema:
    -- [
    --   {
    --     "category": "hydration",
    --     "severity": "high",
    --     "title": "Increase water intake",
    --     "description": "Drink at least 3L of water...",
    --     "icon": "💧"
    --   }
    -- ]

    category                public.recommendation_category  NOT NULL DEFAULT 'general',

    -- User feedback
    feedback_rating         INTEGER                         CHECK (feedback_rating IS NULL OR feedback_rating BETWEEN 1 AND 5),
    feedback_comment        TEXT                            CHECK (feedback_comment IS NULL OR length(feedback_comment) <= 1000),

    -- Metadata
    model_used              TEXT,
    generation_time_ms      INTEGER                         CHECK (generation_time_ms IS NULL OR generation_time_ms >= 0),

    -- Timestamps
    created_at              TIMESTAMPTZ                     NOT NULL DEFAULT now()
);

-- ==========================================================
-- 2. INDEXES
-- ==========================================================

-- User's recommendation history (most recent first)
CREATE INDEX IF NOT EXISTS idx_rec_history_user_created
    ON public.recommendation_history (user_id, created_at DESC);

-- Filter by risk level (for analytics/dashboards)
CREATE INDEX IF NOT EXISTS idx_rec_history_risk_level
    ON public.recommendation_history (risk_level);

-- Filter by category
CREATE INDEX IF NOT EXISTS idx_rec_history_category
    ON public.recommendation_history (category);

-- Date-range queries for analytics
CREATE INDEX IF NOT EXISTS idx_rec_history_created_at
    ON public.recommendation_history (created_at DESC);

-- Location-based queries
CREATE INDEX IF NOT EXISTS idx_rec_history_coords
    ON public.recommendation_history (latitude, longitude);

-- GIN index for JSONB environmental snapshot queries
CREATE INDEX IF NOT EXISTS idx_rec_history_env_snapshot_gin
    ON public.recommendation_history USING GIN (environmental_snapshot);

-- ==========================================================
-- 3. TABLE COMMENTS
-- ==========================================================

COMMENT ON TABLE public.recommendation_history
    IS 'AI-generated heat recommendations with full environmental context. Retained indefinitely for insights.';

COMMENT ON COLUMN public.recommendation_history.environmental_snapshot
    IS 'Full environmental conditions at time of recommendation (temp, humidity, UV, AQI, wind, heat index)';

COMMENT ON COLUMN public.recommendation_history.recommendations
    IS 'Array of recommendation objects with category, severity, title, description, and icon';

COMMENT ON COLUMN public.recommendation_history.risk_score
    IS 'Numeric risk score 0-100 calculated by the Heat Intelligence Engine';

COMMENT ON COLUMN public.recommendation_history.generation_time_ms
    IS 'Time taken by the AI model to generate recommendations, in milliseconds';

COMMENT ON COLUMN public.recommendation_history.feedback_rating
    IS 'User satisfaction rating 1-5. Null if not yet rated.';
