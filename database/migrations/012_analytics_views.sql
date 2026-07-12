-- ============================================================================
-- Escape Heat — Analytics Views and Functions
-- ============================================================================
-- Description: Read-only views and aggregation functions for admin dashboards,
--              monitoring, and analytics. These do NOT modify data.
--
-- Usage:       Run AFTER all migrations (001-010).
--              Accessible by admins via RLS or by the service_role key.
-- ============================================================================

-- ==========================================================
-- 1. PLATFORM STATISTICS (Admin Dashboard)
-- ==========================================================

CREATE OR REPLACE VIEW public.platform_stats AS
SELECT
    (SELECT COUNT(*) FROM public.profiles)                                      AS total_users,
    (SELECT COUNT(*) FROM public.profiles WHERE role = 'citizen')               AS total_citizens,
    (SELECT COUNT(*) FROM public.profiles WHERE role = 'worker')                AS total_workers,
    (SELECT COUNT(*) FROM public.profiles WHERE role = 'authority')             AS total_authorities,
    (SELECT COUNT(*) FROM public.profiles
     WHERE created_at >= now() - interval '24 hours')                           AS new_users_24h,
    (SELECT COUNT(*) FROM public.profiles
     WHERE created_at >= now() - interval '7 days')                             AS new_users_7d,
    (SELECT COUNT(*) FROM public.recommendation_history)                        AS total_recommendations,
    (SELECT COUNT(*) FROM public.recommendation_history
     WHERE created_at >= now() - interval '24 hours')                           AS recommendations_24h,
    (SELECT COUNT(*) FROM public.ai_chat_history)                               AS total_chat_messages,
    (SELECT COUNT(DISTINCT session_id) FROM public.ai_chat_history)             AS total_chat_sessions,
    (SELECT COUNT(*) FROM public.ai_chat_history
     WHERE created_at >= now() - interval '24 hours')                           AS chat_messages_24h,
    (SELECT COUNT(*) FROM public.reports)                                       AS total_reports,
    (SELECT COUNT(*) FROM public.environmental_cache)                           AS cached_entries,
    (SELECT COUNT(*) FROM public.environmental_cache
     WHERE expires_at > now())                                                  AS active_cache_entries,
    (SELECT AVG(feedback_rating) FROM public.recommendation_history
     WHERE feedback_rating IS NOT NULL)                                         AS avg_recommendation_rating,
    now()                                                                       AS generated_at;

COMMENT ON VIEW public.platform_stats
    IS 'Aggregated platform statistics for the admin dashboard. Read via service_role key.';

-- ==========================================================
-- 2. RISK DISTRIBUTION
-- ==========================================================

CREATE OR REPLACE VIEW public.risk_distribution AS
SELECT
    risk_level,
    COUNT(*)                                                                    AS total_count,
    COUNT(*) FILTER (WHERE created_at >= now() - interval '24 hours')           AS count_24h,
    COUNT(*) FILTER (WHERE created_at >= now() - interval '7 days')             AS count_7d,
    ROUND(AVG(risk_score)::numeric, 1)                                          AS avg_risk_score,
    ROUND(MAX(risk_score)::numeric, 1)                                          AS max_risk_score,
    ROUND(
        (COUNT(*)::numeric / NULLIF((SELECT COUNT(*) FROM public.recommendation_history), 0) * 100),
        1
    )                                                                           AS percentage
FROM public.recommendation_history
GROUP BY risk_level
ORDER BY
    CASE risk_level
        WHEN 'low' THEN 1
        WHEN 'moderate' THEN 2
        WHEN 'high' THEN 3
        WHEN 'very_high' THEN 4
        WHEN 'extreme' THEN 5
    END;

COMMENT ON VIEW public.risk_distribution
    IS 'Distribution of risk levels across all recommendations with time-windowed counts';

-- ==========================================================
-- 3. CITY-WISE HEAT ANALYSIS
-- ==========================================================

CREATE OR REPLACE VIEW public.city_heat_summary AS
SELECT
    sl.city,
    sl.state,
    COUNT(DISTINCT rh.user_id)                                                  AS affected_users,
    COUNT(rh.id)                                                                AS total_recommendations,
    ROUND(AVG(rh.risk_score)::numeric, 1)                                       AS avg_risk_score,
    MAX(rh.risk_score)                                                          AS max_risk_score,
    mode() WITHIN GROUP (ORDER BY rh.risk_level)                                AS most_common_risk,
    MAX(rh.created_at)                                                          AS last_activity
FROM public.recommendation_history rh
JOIN public.saved_locations sl ON sl.id = rh.location_id
WHERE sl.city IS NOT NULL
GROUP BY sl.city, sl.state
ORDER BY avg_risk_score DESC;

COMMENT ON VIEW public.city_heat_summary
    IS 'City-level heat risk summary for identifying hotspot cities';

-- ==========================================================
-- 4. DAILY USAGE TRENDS (last 30 days)
-- ==========================================================

CREATE OR REPLACE FUNCTION public.get_daily_usage_trends(p_days INTEGER DEFAULT 30)
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
        'period_days', p_days,
        'generated_at', now(),
        'daily_data', COALESCE(jsonb_agg(
            jsonb_build_object(
                'date', day_date,
                'new_users', new_users,
                'recommendations', recommendations_count,
                'chat_messages', chat_count,
                'reports', reports_count,
                'avg_risk_score', avg_risk
            ) ORDER BY day_date ASC
        ), '[]'::jsonb)
    ) INTO result
    FROM (
        SELECT
            d.day_date,
            COALESCE(u.cnt, 0)    AS new_users,
            COALESCE(r.cnt, 0)    AS recommendations_count,
            COALESCE(c.cnt, 0)    AS chat_count,
            COALESCE(rp.cnt, 0)   AS reports_count,
            r.avg_score           AS avg_risk
        FROM generate_series(
            (now() - (p_days || ' days')::interval)::date,
            now()::date,
            '1 day'::interval
        ) AS d(day_date)
        LEFT JOIN (
            SELECT created_at::date AS dt, COUNT(*) AS cnt
            FROM public.profiles
            WHERE created_at >= now() - (p_days || ' days')::interval
            GROUP BY dt
        ) u ON u.dt = d.day_date
        LEFT JOIN (
            SELECT created_at::date AS dt, COUNT(*) AS cnt, ROUND(AVG(risk_score)::numeric, 1) AS avg_score
            FROM public.recommendation_history
            WHERE created_at >= now() - (p_days || ' days')::interval
            GROUP BY dt
        ) r ON r.dt = d.day_date
        LEFT JOIN (
            SELECT created_at::date AS dt, COUNT(*) AS cnt
            FROM public.ai_chat_history
            WHERE created_at >= now() - (p_days || ' days')::interval
            GROUP BY dt
        ) c ON c.dt = d.day_date
        LEFT JOIN (
            SELECT created_at::date AS dt, COUNT(*) AS cnt
            FROM public.reports
            WHERE created_at >= now() - (p_days || ' days')::interval
            GROUP BY dt
        ) rp ON rp.dt = d.day_date
    ) daily;

    RETURN result;
END;
$$;

COMMENT ON FUNCTION public.get_daily_usage_trends(INTEGER)
    IS 'Returns daily usage metrics (users, recommendations, chats, reports) for the last N days';

-- ==========================================================
-- 5. AI MODEL USAGE ANALYTICS
-- ==========================================================

CREATE OR REPLACE VIEW public.ai_model_usage AS
SELECT
    'recommendations' AS source,
    model_used,
    COUNT(*)                                                                    AS total_calls,
    ROUND(AVG(generation_time_ms)::numeric, 0)                                 AS avg_latency_ms,
    MAX(generation_time_ms)                                                     AS max_latency_ms,
    MIN(generation_time_ms)                                                     AS min_latency_ms,
    NULL::bigint                                                                AS total_tokens,
    MIN(created_at)                                                             AS first_used,
    MAX(created_at)                                                             AS last_used
FROM public.recommendation_history
WHERE model_used IS NOT NULL
GROUP BY model_used

UNION ALL

SELECT
    'chat' AS source,
    model_used,
    COUNT(*)                                                                    AS total_calls,
    ROUND(AVG(latency_ms)::numeric, 0)                                         AS avg_latency_ms,
    MAX(latency_ms)                                                             AS max_latency_ms,
    MIN(latency_ms)                                                             AS min_latency_ms,
    SUM(tokens_used)::bigint                                                    AS total_tokens,
    MIN(created_at)                                                             AS first_used,
    MAX(created_at)                                                             AS last_used
FROM public.ai_chat_history
WHERE model_used IS NOT NULL
GROUP BY model_used

ORDER BY source, total_calls DESC;

COMMENT ON VIEW public.ai_model_usage
    IS 'AI model usage analytics: call counts, latency stats, and token usage across recommendations and chat';

-- ==========================================================
-- 6. USER ENGAGEMENT SUMMARY
-- ==========================================================

CREATE OR REPLACE FUNCTION public.get_user_engagement(p_user_id UUID)
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
        'user_id', p_user_id,
        'member_since', p.created_at,
        'days_active', EXTRACT(DAY FROM now() - p.created_at)::integer,
        'saved_locations', (SELECT COUNT(*) FROM public.saved_locations WHERE user_id = p_user_id),
        'total_recommendations', (SELECT COUNT(*) FROM public.recommendation_history WHERE user_id = p_user_id),
        'recommendations_rated', (SELECT COUNT(*) FROM public.recommendation_history WHERE user_id = p_user_id AND feedback_rating IS NOT NULL),
        'avg_rating_given', (SELECT ROUND(AVG(feedback_rating)::numeric, 1) FROM public.recommendation_history WHERE user_id = p_user_id AND feedback_rating IS NOT NULL),
        'total_chat_sessions', (SELECT COUNT(DISTINCT session_id) FROM public.ai_chat_history WHERE user_id = p_user_id),
        'total_chat_messages', (SELECT COUNT(*) FROM public.ai_chat_history WHERE user_id = p_user_id),
        'total_reports', (SELECT COUNT(*) FROM public.reports WHERE user_id = p_user_id),
        'public_reports', (SELECT COUNT(*) FROM public.reports WHERE user_id = p_user_id AND is_public = true),
        'most_common_risk', (
            SELECT risk_level FROM public.recommendation_history
            WHERE user_id = p_user_id
            GROUP BY risk_level ORDER BY COUNT(*) DESC LIMIT 1
        ),
        'last_recommendation_at', (SELECT MAX(created_at) FROM public.recommendation_history WHERE user_id = p_user_id),
        'last_chat_at', (SELECT MAX(created_at) FROM public.ai_chat_history WHERE user_id = p_user_id)
    ) INTO result
    FROM public.profiles p
    WHERE p.id = p_user_id;

    IF result IS NULL THEN
        RAISE EXCEPTION 'User not found: %', p_user_id USING ERRCODE = 'no_data_found';
    END IF;

    RETURN result;
END;
$$;

COMMENT ON FUNCTION public.get_user_engagement(UUID)
    IS 'Comprehensive user engagement metrics for admin or profile pages';

-- ==========================================================
-- 7. FEEDBACK ANALYTICS
-- ==========================================================

CREATE OR REPLACE VIEW public.feedback_analytics AS
SELECT
    category,
    risk_level,
    COUNT(*) FILTER (WHERE feedback_rating IS NOT NULL)                          AS rated_count,
    COUNT(*) FILTER (WHERE feedback_rating IS NULL)                              AS unrated_count,
    ROUND(AVG(feedback_rating) FILTER (WHERE feedback_rating IS NOT NULL)::numeric, 2) AS avg_rating,
    COUNT(*) FILTER (WHERE feedback_rating = 5)                                 AS five_star,
    COUNT(*) FILTER (WHERE feedback_rating = 4)                                 AS four_star,
    COUNT(*) FILTER (WHERE feedback_rating = 3)                                 AS three_star,
    COUNT(*) FILTER (WHERE feedback_rating = 2)                                 AS two_star,
    COUNT(*) FILTER (WHERE feedback_rating = 1)                                 AS one_star
FROM public.recommendation_history
GROUP BY category, risk_level
ORDER BY category, risk_level;

COMMENT ON VIEW public.feedback_analytics
    IS 'Recommendation feedback breakdown by category and risk level. For improving AI quality.';

-- ==========================================================
-- 8. CACHE HEALTH MONITOR
-- ==========================================================

CREATE OR REPLACE VIEW public.cache_health AS
SELECT
    data_source,
    data_type,
    COUNT(*)                                                                    AS total_entries,
    COUNT(*) FILTER (WHERE expires_at > now())                                  AS active_entries,
    COUNT(*) FILTER (WHERE expires_at <= now())                                 AS expired_entries,
    MIN(fetched_at)                                                             AS oldest_fetch,
    MAX(fetched_at)                                                             AS newest_fetch,
    ROUND(AVG(EXTRACT(EPOCH FROM (expires_at - fetched_at)) / 60)::numeric, 1)  AS avg_ttl_minutes,
    pg_size_pretty(
        SUM(pg_column_size(data))
    )                                                                           AS data_size
FROM public.environmental_cache
GROUP BY data_source, data_type
ORDER BY data_source, data_type;

COMMENT ON VIEW public.cache_health
    IS 'Environmental cache health: active/expired counts, TTL stats, and data size per source';
