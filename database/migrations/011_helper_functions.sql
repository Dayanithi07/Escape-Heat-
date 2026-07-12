-- ============================================================================
-- Escape Heat — Database Helper Functions
-- ============================================================================
-- Description: Server-callable RPC functions that the FastAPI backend can
--              invoke via supabase.rpc(). These encapsulate complex queries
--              so the backend doesn't need to compose raw SQL.
--
-- Usage:       Run this AFTER all migrations (001-010).
--              Call from FastAPI: supabase.rpc('function_name', {params})
-- ============================================================================

-- ==========================================================
-- 1. GET USER DASHBOARD DATA
-- ==========================================================
-- Returns everything needed to render the main dashboard in a single call.

CREATE OR REPLACE FUNCTION public.get_user_dashboard(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
DECLARE
    result JSONB;
    v_profile JSONB;
    v_preferences JSONB;
    v_primary_location JSONB;
    v_latest_recommendation JSONB;
    v_active_sessions INTEGER;
BEGIN
    -- Profile
    SELECT to_jsonb(p.*) INTO v_profile
    FROM public.profiles p
    WHERE p.id = p_user_id;

    IF v_profile IS NULL THEN
        RAISE EXCEPTION 'User not found: %', p_user_id
            USING ERRCODE = 'no_data_found';
    END IF;

    -- Preferences
    SELECT to_jsonb(up.*) INTO v_preferences
    FROM public.user_preferences up
    WHERE up.user_id = p_user_id;

    -- Primary location
    SELECT jsonb_build_object(
        'id', sl.id,
        'label', sl.label,
        'latitude', sl.latitude,
        'longitude', sl.longitude,
        'city', sl.city,
        'state', sl.state
    ) INTO v_primary_location
    FROM public.saved_locations sl
    WHERE sl.user_id = p_user_id AND sl.is_primary = true
    LIMIT 1;

    -- Latest recommendation
    SELECT jsonb_build_object(
        'id', rh.id,
        'risk_level', rh.risk_level,
        'risk_score', rh.risk_score,
        'category', rh.category,
        'environmental_snapshot', rh.environmental_snapshot,
        'recommendations', rh.recommendations,
        'created_at', rh.created_at
    ) INTO v_latest_recommendation
    FROM public.recommendation_history rh
    WHERE rh.user_id = p_user_id
    ORDER BY rh.created_at DESC
    LIMIT 1;

    -- Active chat sessions count
    SELECT COUNT(DISTINCT session_id) INTO v_active_sessions
    FROM public.ai_chat_history
    WHERE user_id = p_user_id;

    -- Assemble result
    result := jsonb_build_object(
        'profile', v_profile,
        'preferences', v_preferences,
        'primary_location', v_primary_location,
        'latest_recommendation', v_latest_recommendation,
        'chat_sessions_count', v_active_sessions
    );

    RETURN result;
END;
$$;

COMMENT ON FUNCTION public.get_user_dashboard(UUID)
    IS 'Returns profile, preferences, primary location, latest recommendation, and chat session count in a single call';

-- ==========================================================
-- 2. GET ENVIRONMENTAL DATA FOR LOCATION
-- ==========================================================
-- Fetches all non-expired cached data for a coordinate pair.

CREATE OR REPLACE FUNCTION public.get_cached_environment(
    p_latitude  DOUBLE PRECISION,
    p_longitude DOUBLE PRECISION
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
DECLARE
    result JSONB;
    rounded_lat DOUBLE PRECISION;
    rounded_lng DOUBLE PRECISION;
BEGIN
    rounded_lat := ROUND(p_latitude::numeric, 2)::double precision;
    rounded_lng := ROUND(p_longitude::numeric, 2)::double precision;

    SELECT jsonb_object_agg(
        ec.data_source || '.' || ec.data_type,
        jsonb_build_object(
            'data', ec.data,
            'heat_index', ec.heat_index,
            'uv_index', ec.uv_index,
            'aqi', ec.aqi,
            'fetched_at', ec.fetched_at,
            'expires_at', ec.expires_at,
            'is_fresh', ec.expires_at > now()
        )
    ) INTO result
    FROM public.environmental_cache ec
    WHERE ec.latitude = rounded_lat
      AND ec.longitude = rounded_lng
      AND ec.expires_at > now();

    RETURN COALESCE(result, '{}'::jsonb);
END;
$$;

COMMENT ON FUNCTION public.get_cached_environment(DOUBLE PRECISION, DOUBLE PRECISION)
    IS 'Returns all non-expired cached environmental data for a coordinate pair (rounded to 2 decimal places)';

-- ==========================================================
-- 3. GET RECOMMENDATION HISTORY (PAGINATED)
-- ==========================================================

CREATE OR REPLACE FUNCTION public.get_recommendation_history(
    p_user_id   UUID,
    p_limit     INTEGER DEFAULT 20,
    p_offset    INTEGER DEFAULT 0,
    p_risk_level public.risk_level DEFAULT NULL,
    p_category  public.recommendation_category DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
DECLARE
    result JSONB;
    total_count INTEGER;
BEGIN
    -- Get total count with filters
    SELECT COUNT(*) INTO total_count
    FROM public.recommendation_history rh
    WHERE rh.user_id = p_user_id
      AND (p_risk_level IS NULL OR rh.risk_level = p_risk_level)
      AND (p_category IS NULL OR rh.category = p_category);

    -- Get paginated results
    SELECT jsonb_build_object(
        'total', total_count,
        'limit', p_limit,
        'offset', p_offset,
        'items', COALESCE(jsonb_agg(item ORDER BY item->>'created_at' DESC), '[]'::jsonb)
    ) INTO result
    FROM (
        SELECT jsonb_build_object(
            'id', rh.id,
            'risk_level', rh.risk_level,
            'risk_score', rh.risk_score,
            'location_label', rh.location_label,
            'category', rh.category,
            'environmental_snapshot', rh.environmental_snapshot,
            'recommendations', rh.recommendations,
            'feedback_rating', rh.feedback_rating,
            'created_at', rh.created_at
        ) AS item
        FROM public.recommendation_history rh
        WHERE rh.user_id = p_user_id
          AND (p_risk_level IS NULL OR rh.risk_level = p_risk_level)
          AND (p_category IS NULL OR rh.category = p_category)
        ORDER BY rh.created_at DESC
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN result;
END;
$$;

COMMENT ON FUNCTION public.get_recommendation_history
    IS 'Paginated recommendation history with optional risk_level and category filters';

-- ==========================================================
-- 4. GET CHAT SESSION MESSAGES
-- ==========================================================

CREATE OR REPLACE FUNCTION public.get_chat_session(
    p_user_id    UUID,
    p_session_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'session_id', p_session_id,
        'message_count', COUNT(*),
        'messages', jsonb_agg(
            jsonb_build_object(
                'id', ch.id,
                'role', ch.role,
                'message', ch.message,
                'context', ch.context,
                'model_used', ch.model_used,
                'tokens_used', ch.tokens_used,
                'created_at', ch.created_at
            ) ORDER BY ch.created_at ASC
        )
    ) INTO result
    FROM public.ai_chat_history ch
    WHERE ch.user_id = p_user_id
      AND ch.session_id = p_session_id;

    RETURN COALESCE(result, jsonb_build_object('session_id', p_session_id, 'message_count', 0, 'messages', '[]'::jsonb));
END;
$$;

COMMENT ON FUNCTION public.get_chat_session(UUID, UUID)
    IS 'Returns all messages in a chat session, ordered chronologically';

-- ==========================================================
-- 5. GET USER CHAT SESSIONS LIST
-- ==========================================================

CREATE OR REPLACE FUNCTION public.get_user_chat_sessions(
    p_user_id UUID,
    p_limit   INTEGER DEFAULT 20,
    p_offset  INTEGER DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
DECLARE
    result JSONB;
    total_count INTEGER;
BEGIN
    -- Count distinct sessions
    SELECT COUNT(DISTINCT session_id) INTO total_count
    FROM public.ai_chat_history
    WHERE user_id = p_user_id;

    -- Get session summaries
    SELECT jsonb_build_object(
        'total', total_count,
        'limit', p_limit,
        'offset', p_offset,
        'sessions', COALESCE(jsonb_agg(session_data ORDER BY session_data->>'last_message_at' DESC), '[]'::jsonb)
    ) INTO result
    FROM (
        SELECT jsonb_build_object(
            'session_id', session_id,
            'first_message', (
                SELECT message FROM public.ai_chat_history sub
                WHERE sub.session_id = main.session_id AND sub.role = 'user'
                ORDER BY sub.created_at ASC LIMIT 1
            ),
            'last_message_at', MAX(created_at),
            'message_count', COUNT(*)
        ) AS session_data
        FROM public.ai_chat_history main
        WHERE user_id = p_user_id
        GROUP BY session_id
        ORDER BY MAX(created_at) DESC
        LIMIT p_limit OFFSET p_offset
    ) sub;

    RETURN result;
END;
$$;

COMMENT ON FUNCTION public.get_user_chat_sessions(UUID, INTEGER, INTEGER)
    IS 'Paginated list of chat sessions with first user message and message count';

-- ==========================================================
-- 6. SUBMIT RECOMMENDATION FEEDBACK
-- ==========================================================

CREATE OR REPLACE FUNCTION public.submit_recommendation_feedback(
    p_user_id           UUID,
    p_recommendation_id UUID,
    p_rating            INTEGER,
    p_comment           TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    -- Validate rating
    IF p_rating < 1 OR p_rating > 5 THEN
        RAISE EXCEPTION 'Rating must be between 1 and 5, got: %', p_rating
            USING ERRCODE = 'check_violation';
    END IF;

    UPDATE public.recommendation_history
    SET feedback_rating = p_rating,
        feedback_comment = p_comment
    WHERE id = p_recommendation_id
      AND user_id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Recommendation not found or access denied: %', p_recommendation_id
            USING ERRCODE = 'no_data_found';
    END IF;

    RETURN true;
END;
$$;

COMMENT ON FUNCTION public.submit_recommendation_feedback
    IS 'Allows a user to rate a recommendation 1-5 with optional comment. Enforces ownership.';

-- ==========================================================
-- 7. GET NEARBY CACHED LOCATIONS
-- ==========================================================
-- Returns cached environmental data within a bounding box.
-- Useful for heat map rendering.

CREATE OR REPLACE FUNCTION public.get_nearby_cache(
    p_latitude   DOUBLE PRECISION,
    p_longitude  DOUBLE PRECISION,
    p_radius_deg DOUBLE PRECISION DEFAULT 0.5
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'latitude', ec.latitude,
            'longitude', ec.longitude,
            'data_source', ec.data_source,
            'data_type', ec.data_type,
            'heat_index', ec.heat_index,
            'uv_index', ec.uv_index,
            'aqi', ec.aqi,
            'data', ec.data,
            'fetched_at', ec.fetched_at
        )
    ), '[]'::jsonb) INTO result
    FROM public.environmental_cache ec
    WHERE ec.latitude BETWEEN (p_latitude - p_radius_deg) AND (p_latitude + p_radius_deg)
      AND ec.longitude BETWEEN (p_longitude - p_radius_deg) AND (p_longitude + p_radius_deg)
      AND ec.expires_at > now();

    RETURN result;
END;
$$;

COMMENT ON FUNCTION public.get_nearby_cache
    IS 'Returns non-expired cached data within a bounding box around coordinates. Default radius 0.5 degrees (~55km).';

-- ==========================================================
-- 8. DELETE USER ACCOUNT (GDPR-COMPLIANT)
-- ==========================================================
-- Deletes user and all associated data. CASCADE handles related tables.

CREATE OR REPLACE FUNCTION public.delete_user_account(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    -- Verify the user exists
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = p_user_id) THEN
        RAISE EXCEPTION 'User not found: %', p_user_id
            USING ERRCODE = 'no_data_found';
    END IF;

    -- Delete storage objects (avatars)
    DELETE FROM storage.objects
    WHERE bucket_id = 'avatars'
      AND (storage.foldername(name))[1] = p_user_id::text;

    -- Delete storage objects (reports)
    DELETE FROM storage.objects
    WHERE bucket_id = 'reports'
      AND (storage.foldername(name))[1] = p_user_id::text;

    -- Delete the auth user (cascades to profiles → all related tables)
    DELETE FROM auth.users WHERE id = p_user_id;

    RETURN true;
END;
$$;

COMMENT ON FUNCTION public.delete_user_account(UUID)
    IS 'GDPR-compliant account deletion. Removes auth user, profile, all data, and storage files.';
