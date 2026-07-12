-- ============================================================================
-- Escape Heat — Migration 008: Reports Table
-- ============================================================================
-- Description: Stores generated heat analysis reports. Supports both
--              structured JSONB content and PDF file references via
--              Supabase Storage. Reports can be made public for sharing.
-- Depends on:  001_extensions_and_enums.sql, 002_profiles_and_auth.sql
-- Run order:   8 of 10
-- ============================================================================

-- ==========================================================
-- 1. TABLE: reports
-- ==========================================================

CREATE TABLE IF NOT EXISTS public.reports (
    id              UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID                NOT NULL
                                        REFERENCES public.profiles(id) ON DELETE CASCADE,

    -- Report metadata
    title           TEXT                NOT NULL
                                        CHECK (length(title) BETWEEN 1 AND 300),
    report_type     public.report_type  NOT NULL,

    -- Location context
    location_label  TEXT,
    latitude        DOUBLE PRECISION    CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    longitude       DOUBLE PRECISION    CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),

    -- Report content
    content         JSONB               NOT NULL DEFAULT '{}'::jsonb,
    -- Expected schema varies by report_type:
    -- daily_summary: {
    --   "date": "2026-07-06",
    --   "peak_temperature_c": 44,
    --   "avg_risk_level": "high",
    --   "total_alerts": 3,
    --   "hourly_data": [...],
    --   "recommendations_given": 5
    -- }
    -- heat_alert: {
    --   "alert_level": "extreme",
    --   "affected_area": "Chennai Central",
    --   "duration_hours": 6,
    --   "advisory": "..."
    -- }

    summary         TEXT                CHECK (summary IS NULL OR length(summary) <= 5000),
    file_url        TEXT                CHECK (file_url IS NULL OR length(file_url) <= 2048),

    -- Sharing
    is_public       BOOLEAN             NOT NULL DEFAULT false,
    shared_token    UUID                UNIQUE,

    -- Timestamps
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT now(),

    -- Ensure coordinates are provided together
    CONSTRAINT chk_reports_coordinates_pair
        CHECK (
            (latitude IS NULL AND longitude IS NULL) OR
            (latitude IS NOT NULL AND longitude IS NOT NULL)
        )
);

-- ==========================================================
-- 2. INDEXES
-- ==========================================================

-- User's reports (most recent first)
CREATE INDEX IF NOT EXISTS idx_reports_user_created
    ON public.reports (user_id, created_at DESC);

-- Filter by report type
CREATE INDEX IF NOT EXISTS idx_reports_type
    ON public.reports (report_type);

-- Public reports listing
CREATE INDEX IF NOT EXISTS idx_reports_public
    ON public.reports (is_public, created_at DESC)
    WHERE is_public = true;

-- Shared report lookup by token
CREATE INDEX IF NOT EXISTS idx_reports_shared_token
    ON public.reports (shared_token)
    WHERE shared_token IS NOT NULL;

-- ==========================================================
-- 3. FUNCTION: Generate share token
-- ==========================================================

CREATE OR REPLACE FUNCTION public.generate_report_share_token(p_report_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    new_token UUID;
BEGIN
    new_token := gen_random_uuid();

    UPDATE public.reports
    SET shared_token = new_token,
        is_public = true
    WHERE id = p_report_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Report not found: %', p_report_id
            USING ERRCODE = 'no_data_found';
    END IF;

    RETURN new_token;
END;
$$;

COMMENT ON FUNCTION public.generate_report_share_token
    IS 'Generates a unique share token for a report and marks it as public';

-- ==========================================================
-- 4. TABLE COMMENTS
-- ==========================================================

COMMENT ON TABLE public.reports
    IS 'Heat analysis reports generated for users. Supports PDF storage and public sharing via tokens.';

COMMENT ON COLUMN public.reports.content
    IS 'Structured report data in JSONB. Schema varies by report_type.';

COMMENT ON COLUMN public.reports.shared_token
    IS 'Unique token for sharing reports via URL. Null if not shared.';

COMMENT ON COLUMN public.reports.file_url
    IS 'Supabase Storage URL for the generated PDF file. Null if no PDF.';
