-- ============================================================================
-- Escape Heat — Migration 001: Extensions and Utility Functions
-- ============================================================================
-- Description: Enables required PostgreSQL extensions and creates shared
--              utility functions used across multiple tables.
-- Run order:   1 of 10
-- ============================================================================

-- ==========================================================
-- 1. EXTENSIONS
-- ==========================================================

-- UUID generation (usually pre-enabled in Supabase, but safe to ensure)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- pg_cron for scheduled cache cleanup (Supabase has this enabled on paid plans)
-- If not available, the cleanup function can be called from a backend cron job.
CREATE EXTENSION IF NOT EXISTS "pg_cron" SCHEMA "extensions";

-- ==========================================================
-- 2. CUSTOM TYPES (ENUMS)
-- ==========================================================

-- User roles within the platform
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE public.user_role AS ENUM (
            'citizen',
            'worker',
            'authority',
            'admin'
        );
    END IF;
END
$$;

-- Gender options
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'gender_type') THEN
        CREATE TYPE public.gender_type AS ENUM (
            'male',
            'female',
            'other',
            'prefer_not_to_say'
        );
    END IF;
END
$$;

-- Temperature unit preference
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'temp_unit') THEN
        CREATE TYPE public.temp_unit AS ENUM (
            'celsius',
            'fahrenheit'
        );
    END IF;
END
$$;

-- Heat alert severity threshold
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'alert_threshold') THEN
        CREATE TYPE public.alert_threshold AS ENUM (
            'low',
            'moderate',
            'high',
            'extreme'
        );
    END IF;
END
$$;

-- Physical activity level
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'activity_level') THEN
        CREATE TYPE public.activity_level AS ENUM (
            'sedentary',
            'light',
            'moderate',
            'active',
            'very_active'
        );
    END IF;
END
$$;

-- External data source identifiers
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'data_source_type') THEN
        CREATE TYPE public.data_source_type AS ENUM (
            'open_meteo',
            'nasa_power',
            'imd',
            'isro',
            'osm'
        );
    END IF;
END
$$;

-- Heat risk classification
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'risk_level') THEN
        CREATE TYPE public.risk_level AS ENUM (
            'low',
            'moderate',
            'high',
            'very_high',
            'extreme'
        );
    END IF;
END
$$;

-- Recommendation category
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'recommendation_category') THEN
        CREATE TYPE public.recommendation_category AS ENUM (
            'general',
            'hydration',
            'activity',
            'clothing',
            'travel',
            'health'
        );
    END IF;
END
$$;

-- Chat message role
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'chat_role') THEN
        CREATE TYPE public.chat_role AS ENUM (
            'user',
            'assistant',
            'system'
        );
    END IF;
END
$$;

-- Report type
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'report_type') THEN
        CREATE TYPE public.report_type AS ENUM (
            'daily_summary',
            'weekly_summary',
            'heat_alert',
            'custom'
        );
    END IF;
END
$$;

-- ==========================================================
-- 3. UTILITY FUNCTIONS
-- ==========================================================

-- Auto-update `updated_at` timestamp on row modification
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
