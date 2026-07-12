-- ============================================================================
-- Escape Heat — Migration 003: User Preferences Table
-- ============================================================================
-- Description: Stores per-user personalization settings. One row per user.
--              Auto-created by the auth trigger in migration 002.
-- Depends on:  001_extensions_and_enums.sql, 002_profiles_and_auth.sql
-- Run order:   3 of 10
-- ============================================================================

-- ==========================================================
-- 1. TABLE: user_preferences
-- ==========================================================

CREATE TABLE IF NOT EXISTS public.user_preferences (
    id                      UUID                    PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID                    NOT NULL UNIQUE
                                                    REFERENCES public.profiles(id) ON DELETE CASCADE,

    -- Display preferences
    temperature_unit        public.temp_unit        NOT NULL DEFAULT 'celsius',
    language                TEXT                    NOT NULL DEFAULT 'en',
    theme                   TEXT                    NOT NULL DEFAULT 'system'
                                                    CHECK (theme IN ('light', 'dark', 'system')),

    -- Notification preferences
    notification_enabled    BOOLEAN                 NOT NULL DEFAULT true,
    heat_alert_threshold    public.alert_threshold  NOT NULL DEFAULT 'high',
    email_alerts            BOOLEAN                 NOT NULL DEFAULT false,
    push_alerts             BOOLEAN                 NOT NULL DEFAULT true,

    -- Activity & work context
    activity_level          public.activity_level   NOT NULL DEFAULT 'moderate',
    outdoor_work_hours      JSONB                   DEFAULT '{"start": "09:00", "end": "17:00"}'::jsonb,
    works_outdoors          BOOLEAN                 NOT NULL DEFAULT false,

    -- Timestamps
    created_at              TIMESTAMPTZ             NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ             NOT NULL DEFAULT now(),

    -- Constraints
    CONSTRAINT chk_user_preferences_language_format
        CHECK (language ~ '^[a-z]{2}(-[A-Z]{2})?$'),
    CONSTRAINT chk_user_preferences_outdoor_hours_schema
        CHECK (
            outdoor_work_hours IS NULL
            OR (
                outdoor_work_hours ? 'start'
                AND outdoor_work_hours ? 'end'
            )
        )
);

-- ==========================================================
-- 2. INDEXES
-- ==========================================================

-- Primary lookup is via user_id (already has UNIQUE index)
-- No additional indexes needed for this table size

-- ==========================================================
-- 3. TRIGGERS
-- ==========================================================

DROP TRIGGER IF EXISTS trg_user_preferences_updated_at ON public.user_preferences;
CREATE TRIGGER trg_user_preferences_updated_at
    BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- ==========================================================
-- 4. TABLE COMMENTS
-- ==========================================================

COMMENT ON TABLE public.user_preferences
    IS 'Per-user personalization settings. One row per user, auto-created on signup.';

COMMENT ON COLUMN public.user_preferences.outdoor_work_hours
    IS 'JSON object with "start" and "end" keys in HH:MM format, e.g., {"start": "09:00", "end": "17:00"}';

COMMENT ON COLUMN public.user_preferences.heat_alert_threshold
    IS 'Minimum risk level that triggers a heat alert notification for the user';

COMMENT ON COLUMN public.user_preferences.works_outdoors
    IS 'Whether the user primarily works outdoors — affects recommendation intensity';
