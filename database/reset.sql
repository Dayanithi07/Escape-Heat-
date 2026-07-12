-- ============================================================================
-- Escape Heat — Database Reset Script
-- ============================================================================
-- ⚠️  WARNING: This script DESTROYS ALL DATA and DROPS ALL OBJECTS.
--     Use ONLY for development/testing. NEVER run in production.
--
-- Usage: Paste into Supabase SQL Editor and run.
-- After running, re-execute the migrations to rebuild the database.
-- ============================================================================

-- ==========================================================
-- SAFETY CHECK
-- ==========================================================
-- Uncomment the next line to enable the reset. This is a safety gate.
-- SET session_replication_role = 'replica';

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'ESCAPE HEAT DATABASE RESET';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'This will DROP all Escape Heat tables, functions, types, triggers, and storage buckets.';
    RAISE NOTICE 'Starting reset...';
END
$$;

-- ==========================================================
-- 1. DROP STORAGE POLICIES (before dropping buckets)
-- ==========================================================

DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT policyname
        FROM pg_policies
        WHERE schemaname = 'storage'
          AND tablename = 'objects'
          AND policyname LIKE 'storage_%'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', pol.policyname);
        RAISE NOTICE 'Dropped storage policy: %', pol.policyname;
    END LOOP;
END
$$;

-- ==========================================================
-- 2. DROP STORAGE BUCKETS
-- ==========================================================

DELETE FROM storage.objects WHERE bucket_id IN ('avatars', 'reports');
DELETE FROM storage.buckets WHERE id IN ('avatars', 'reports');

-- ==========================================================
-- 3. DROP pg_cron JOBS
-- ==========================================================

DO $$
BEGIN
    PERFORM cron.unschedule('cleanup-expired-env-cache');
    RAISE NOTICE 'Unscheduled pg_cron job: cleanup-expired-env-cache';
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'No pg_cron job to remove (or pg_cron not available)';
END
$$;

-- ==========================================================
-- 4. DROP VIEWS
-- ==========================================================

DROP VIEW IF EXISTS public.chat_sessions_summary CASCADE;
DROP VIEW IF EXISTS public.platform_stats CASCADE;
DROP VIEW IF EXISTS public.risk_distribution CASCADE;
DROP VIEW IF EXISTS public.city_heat_summary CASCADE;
DROP VIEW IF EXISTS public.ai_model_usage CASCADE;
DROP VIEW IF EXISTS public.feedback_analytics CASCADE;
DROP VIEW IF EXISTS public.cache_health CASCADE;

-- ==========================================================
-- 5. DROP AUTH TRIGGER (before dropping functions)
-- ==========================================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- ==========================================================
-- 6. DROP TABLES (order matters due to FK constraints)
-- ==========================================================

DROP TABLE IF EXISTS public.reports CASCADE;
DROP TABLE IF EXISTS public.ai_chat_history CASCADE;
DROP TABLE IF EXISTS public.recommendation_history CASCADE;
DROP TABLE IF EXISTS public.environmental_cache CASCADE;
DROP TABLE IF EXISTS public.saved_locations CASCADE;
DROP TABLE IF EXISTS public.user_preferences CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- ==========================================================
-- 7. DROP FUNCTIONS
-- ==========================================================

DROP FUNCTION IF EXISTS public.handle_updated_at() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.check_saved_locations_limit() CASCADE;
DROP FUNCTION IF EXISTS public.ensure_single_primary_location() CASCADE;
DROP FUNCTION IF EXISTS public.cleanup_expired_cache() CASCADE;
DROP FUNCTION IF EXISTS public.upsert_environmental_cache(DOUBLE PRECISION, DOUBLE PRECISION, public.data_source_type, TEXT, JSONB, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS public.generate_report_share_token(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.get_user_dashboard(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.get_cached_environment(DOUBLE PRECISION, DOUBLE PRECISION) CASCADE;
DROP FUNCTION IF EXISTS public.get_recommendation_history(UUID, INTEGER, INTEGER, public.risk_level, public.recommendation_category) CASCADE;
DROP FUNCTION IF EXISTS public.get_chat_session(UUID, UUID) CASCADE;
DROP FUNCTION IF EXISTS public.get_user_chat_sessions(UUID, INTEGER, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS public.submit_recommendation_feedback(UUID, UUID, INTEGER, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.get_nearby_cache(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION) CASCADE;
DROP FUNCTION IF EXISTS public.delete_user_account(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.get_daily_usage_trends(INTEGER) CASCADE;
DROP FUNCTION IF EXISTS public.get_user_engagement(UUID) CASCADE;

-- ==========================================================
-- 8. DROP CUSTOM TYPES
-- ==========================================================

DROP TYPE IF EXISTS public.user_role CASCADE;
DROP TYPE IF EXISTS public.gender_type CASCADE;
DROP TYPE IF EXISTS public.temp_unit CASCADE;
DROP TYPE IF EXISTS public.alert_threshold CASCADE;
DROP TYPE IF EXISTS public.activity_level CASCADE;
DROP TYPE IF EXISTS public.data_source_type CASCADE;
DROP TYPE IF EXISTS public.risk_level CASCADE;
DROP TYPE IF EXISTS public.recommendation_category CASCADE;
DROP TYPE IF EXISTS public.chat_role CASCADE;
DROP TYPE IF EXISTS public.report_type CASCADE;

-- ==========================================================
-- DONE
-- ==========================================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RESET COMPLETE';
    RAISE NOTICE 'All Escape Heat database objects removed.';
    RAISE NOTICE 'Run migrations 001-012 to rebuild.';
    RAISE NOTICE '========================================';
END
$$;
