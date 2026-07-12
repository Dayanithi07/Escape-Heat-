-- ============================================================================
-- Escape Heat — Database Verification Script
-- ============================================================================
-- Description: Run this after all migrations to verify the database is
--              correctly set up. Returns PASS/FAIL for each check.
--
-- Usage:       Paste into Supabase SQL Editor and run.
-- ============================================================================

DO $$
DECLARE
    v_count INTEGER;
    v_pass  INTEGER := 0;
    v_fail  INTEGER := 0;
    v_total INTEGER := 0;

BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'ESCAPE HEAT — DATABASE VERIFICATION';
    RAISE NOTICE '==========================================';
    RAISE NOTICE '';

    -- ===== TABLES =====
    RAISE NOTICE '--- Tables ---';

    SELECT COUNT(*) INTO v_count FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'profiles';
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Table: profiles exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Table: profiles exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'user_preferences';
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Table: user_preferences exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Table: user_preferences exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'saved_locations';
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Table: saved_locations exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Table: saved_locations exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'environmental_cache';
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Table: environmental_cache exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Table: environmental_cache exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'recommendation_history';
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Table: recommendation_history exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Table: recommendation_history exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'ai_chat_history';
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Table: ai_chat_history exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Table: ai_chat_history exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'reports';
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Table: reports exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Table: reports exists'; END IF;

    -- ===== ENUMS =====
    RAISE NOTICE '';
    RAISE NOTICE '--- Custom Types (Enums) ---';

    SELECT COUNT(*) INTO v_count FROM pg_type
    WHERE typnamespace = 'public'::regnamespace AND typtype = 'e';
    v_total := v_total + 1;
    IF v_count = 10 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Custom enums: % found (expected 10)', v_count; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Custom enums: % found (expected 10)', v_count; END IF;

    -- ===== RLS =====
    RAISE NOTICE '';
    RAISE NOTICE '--- Row Level Security ---';

    SELECT COUNT(*) INTO v_count FROM pg_tables
    WHERE schemaname = 'public' AND rowsecurity = true;
    v_total := v_total + 1;
    IF v_count = 7 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: RLS enabled on % tables (expected 7)', v_count; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: RLS enabled on % tables (expected 7)', v_count; END IF;

    -- Check specific policies exist
    SELECT COUNT(*) INTO v_count FROM pg_policies
    WHERE schemaname = 'public';
    v_total := v_total + 1;
    IF v_count >= 20 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: RLS policies: % found (expected ≥ 20)', v_count; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: RLS policies: % found (expected ≥ 20)', v_count; END IF;

    -- ===== TRIGGERS =====
    RAISE NOTICE '';
    RAISE NOTICE '--- Triggers ---';

    SELECT COUNT(*) INTO v_count FROM information_schema.triggers
    WHERE trigger_schema = 'public';
    v_total := v_total + 1;
    IF v_count >= 4 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Public schema triggers: % found (expected ≥ 4)', v_count; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Public schema triggers: % found (expected ≥ 4)', v_count; END IF;

    SELECT COUNT(*) INTO v_count FROM pg_trigger
    WHERE tgname = 'on_auth_user_created';
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Auth signup trigger exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Auth signup trigger exists'; END IF;

    -- ===== FUNCTIONS =====
    RAISE NOTICE '';
    RAISE NOTICE '--- Functions ---';

    SELECT COUNT(*) INTO v_count FROM information_schema.routines
    WHERE routine_schema = 'public' AND routine_type = 'FUNCTION';
    v_total := v_total + 1;
    IF v_count >= 14 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Public functions: % found (expected ≥ 14)', v_count; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Public functions: % found (expected ≥ 14)', v_count; END IF;

    -- Check critical functions
    SELECT COUNT(*) INTO v_count FROM pg_proc
    WHERE proname = 'handle_new_user' AND pronamespace = 'public'::regnamespace;
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Function: handle_new_user exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Function: handle_new_user exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM pg_proc
    WHERE proname = 'upsert_environmental_cache' AND pronamespace = 'public'::regnamespace;
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Function: upsert_environmental_cache exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Function: upsert_environmental_cache exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM pg_proc
    WHERE proname = 'get_user_dashboard' AND pronamespace = 'public'::regnamespace;
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Function: get_user_dashboard exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Function: get_user_dashboard exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM pg_proc
    WHERE proname = 'delete_user_account' AND pronamespace = 'public'::regnamespace;
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Function: delete_user_account exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Function: delete_user_account exists'; END IF;

    -- ===== VIEWS =====
    RAISE NOTICE '';
    RAISE NOTICE '--- Views ---';

    SELECT COUNT(*) INTO v_count FROM information_schema.views
    WHERE table_schema = 'public';
    v_total := v_total + 1;
    IF v_count >= 6 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Public views: % found (expected ≥ 6)', v_count; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Public views: % found (expected ≥ 6)', v_count; END IF;

    -- ===== STORAGE =====
    RAISE NOTICE '';
    RAISE NOTICE '--- Storage Buckets ---';

    SELECT COUNT(*) INTO v_count FROM storage.buckets WHERE id = 'avatars';
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Storage bucket: avatars exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Storage bucket: avatars exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM storage.buckets WHERE id = 'reports';
    v_total := v_total + 1;
    IF v_count = 1 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Storage bucket: reports exists'; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Storage bucket: reports exists'; END IF;

    SELECT COUNT(*) INTO v_count FROM pg_policies
    WHERE schemaname = 'storage' AND tablename = 'objects';
    v_total := v_total + 1;
    IF v_count >= 8 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Storage policies: % found (expected ≥ 8)', v_count; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Storage policies: % found (expected ≥ 8)', v_count; END IF;

    -- ===== INDEXES =====
    RAISE NOTICE '';
    RAISE NOTICE '--- Indexes ---';

    SELECT COUNT(*) INTO v_count FROM pg_indexes
    WHERE schemaname = 'public';
    v_total := v_total + 1;
    IF v_count >= 20 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: Public indexes: % found (expected ≥ 20)', v_count; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: Public indexes: % found (expected ≥ 20)', v_count; END IF;

    -- ===== CONSTRAINTS =====
    RAISE NOTICE '';
    RAISE NOTICE '--- Constraints ---';

    SELECT COUNT(*) INTO v_count FROM information_schema.table_constraints
    WHERE constraint_schema = 'public' AND constraint_type = 'CHECK';
    v_total := v_total + 1;
    IF v_count >= 15 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: CHECK constraints: % found (expected ≥ 15)', v_count; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: CHECK constraints: % found (expected ≥ 15)', v_count; END IF;

    SELECT COUNT(*) INTO v_count FROM information_schema.table_constraints
    WHERE constraint_schema = 'public' AND constraint_type = 'FOREIGN KEY';
    v_total := v_total + 1;
    IF v_count >= 7 THEN v_pass := v_pass + 1; RAISE NOTICE '  ✅ PASS: FOREIGN KEY constraints: % found (expected ≥ 7)', v_count; ELSE v_fail := v_fail + 1; RAISE NOTICE '  ❌ FAIL: FOREIGN KEY constraints: % found (expected ≥ 7)', v_count; END IF;

    -- ===== SUMMARY =====
    RAISE NOTICE '';
    RAISE NOTICE '==========================================';
    RAISE NOTICE 'RESULTS: % / % passed, % failed', v_pass, v_total, v_fail;
    IF v_fail = 0 THEN
        RAISE NOTICE '✅ ALL CHECKS PASSED — Database is ready!';
    ELSE
        RAISE NOTICE '❌ SOME CHECKS FAILED — Review the failures above.';
    END IF;
    RAISE NOTICE '==========================================';
    RAISE NOTICE '';
END
$$;
