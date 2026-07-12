-- ============================================================================
-- Escape Heat — Migration 009: Row Level Security Policies
-- ============================================================================
-- Description: Enables RLS on ALL tables and defines granular access policies.
--              Supabase uses RLS to enforce data isolation between users.
--              The service_role key bypasses RLS (used by FastAPI backend).
-- Depends on:  All previous migrations (002-008)
-- Run order:   9 of 10
-- ============================================================================

-- ==========================================================
-- IMPORTANT NOTES FOR BACKEND DEVELOPERS
-- ==========================================================
-- 1. Supabase anon/authenticated requests go through RLS.
-- 2. The service_role key (used by FastAPI) BYPASSES RLS entirely.
-- 3. For direct client queries (e.g., from Next.js using supabase-js),
--    RLS ensures users can only access their own data.
-- 4. auth.uid() returns the authenticated user's ID from the JWT.
-- ==========================================================

-- ####################################################################
-- TABLE: profiles
-- ####################################################################

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Force RLS even for table owners (prevents accidental bypass)
ALTER TABLE public.profiles FORCE ROW LEVEL SECURITY;

-- SELECT: Users can read their own profile
CREATE POLICY profiles_select_own
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

-- SELECT: Admins can read all profiles
CREATE POLICY profiles_select_admin
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- UPDATE: Users can update their own profile
CREATE POLICY profiles_update_own
    ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- INSERT: Only via trigger (service role). No direct insert by users.
-- No INSERT policy = blocked for authenticated users.

-- DELETE: Users can delete their own profile (cascades to all related data)
CREATE POLICY profiles_delete_own
    ON public.profiles
    FOR DELETE
    TO authenticated
    USING (auth.uid() = id);

-- ####################################################################
-- TABLE: user_preferences
-- ####################################################################

ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences FORCE ROW LEVEL SECURITY;

-- SELECT: Own preferences only
CREATE POLICY user_preferences_select_own
    ON public.user_preferences
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- UPDATE: Own preferences only
CREATE POLICY user_preferences_update_own
    ON public.user_preferences
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- INSERT: Only via auth trigger. No direct insert.

-- DELETE: Own preferences only (rare, but allowed)
CREATE POLICY user_preferences_delete_own
    ON public.user_preferences
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- ####################################################################
-- TABLE: saved_locations
-- ####################################################################

ALTER TABLE public.saved_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_locations FORCE ROW LEVEL SECURITY;

-- SELECT: Own locations only
CREATE POLICY saved_locations_select_own
    ON public.saved_locations
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- INSERT: Own locations only
CREATE POLICY saved_locations_insert_own
    ON public.saved_locations
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: Own locations only
CREATE POLICY saved_locations_update_own
    ON public.saved_locations
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- DELETE: Own locations only
CREATE POLICY saved_locations_delete_own
    ON public.saved_locations
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- ####################################################################
-- TABLE: environmental_cache
-- ####################################################################

ALTER TABLE public.environmental_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.environmental_cache FORCE ROW LEVEL SECURITY;

-- SELECT: Any authenticated user can read cache (it's public data)
CREATE POLICY env_cache_select_authenticated
    ON public.environmental_cache
    FOR SELECT
    TO authenticated
    USING (true);

-- INSERT/UPDATE/DELETE: Service role only (backend).
-- No policies for anon/authenticated = blocked.
-- FastAPI uses service_role key which bypasses RLS.

-- ####################################################################
-- TABLE: recommendation_history
-- ####################################################################

ALTER TABLE public.recommendation_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_history FORCE ROW LEVEL SECURITY;

-- SELECT: Own recommendations only
CREATE POLICY rec_history_select_own
    ON public.recommendation_history
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- INSERT: Own recommendations only
CREATE POLICY rec_history_insert_own
    ON public.recommendation_history
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: Only feedback fields on own recommendations
-- Note: The backend should enforce that only feedback_rating and
-- feedback_comment are updated. RLS ensures row ownership.
CREATE POLICY rec_history_update_feedback
    ON public.recommendation_history
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- No DELETE policy: recommendations are retained indefinitely.

-- ####################################################################
-- TABLE: ai_chat_history
-- ####################################################################

ALTER TABLE public.ai_chat_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_chat_history FORCE ROW LEVEL SECURITY;

-- SELECT: Own messages only
CREATE POLICY chat_history_select_own
    ON public.ai_chat_history
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- INSERT: Own messages only
CREATE POLICY chat_history_insert_own
    ON public.ai_chat_history
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- No UPDATE policy: chat messages are immutable.
-- No DELETE policy: chat history is retained indefinitely.

-- ####################################################################
-- TABLE: reports
-- ####################################################################

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports FORCE ROW LEVEL SECURITY;

-- SELECT: Own reports
CREATE POLICY reports_select_own
    ON public.reports
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- SELECT: Public reports (any authenticated user)
CREATE POLICY reports_select_public
    ON public.reports
    FOR SELECT
    TO authenticated
    USING (is_public = true);

-- SELECT: Shared reports via token (even for anon users)
CREATE POLICY reports_select_shared_anon
    ON public.reports
    FOR SELECT
    TO anon
    USING (is_public = true AND shared_token IS NOT NULL);

-- INSERT: Own reports only
CREATE POLICY reports_insert_own
    ON public.reports
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: Own reports only
CREATE POLICY reports_update_own
    ON public.reports
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- DELETE: Own reports only
CREATE POLICY reports_delete_own
    ON public.reports
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- ####################################################################
-- VIEW: chat_sessions_summary
-- ####################################################################
-- Views inherit RLS from the underlying table (ai_chat_history).
-- No additional policies needed.

-- ####################################################################
-- ADMIN POLICIES (cross-cutting)
-- ####################################################################

-- Admin: Read all recommendation history (for analytics dashboards)
CREATE POLICY rec_history_select_admin
    ON public.recommendation_history
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admin: Read all reports (for moderation)
CREATE POLICY reports_select_admin
    ON public.reports
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admin: Read all chat history (for support/debugging)
CREATE POLICY chat_history_select_admin
    ON public.ai_chat_history
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );
