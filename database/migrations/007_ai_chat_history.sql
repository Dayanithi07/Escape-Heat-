-- ============================================================================
-- Escape Heat — Migration 007: AI Chat History Table
-- ============================================================================
-- Description: Stores conversation history with the Escape AI Assistant.
--              Messages are grouped by session_id for multi-turn context.
--              Retained indefinitely per project requirements.
-- Depends on:  001_extensions_and_enums.sql, 002_profiles_and_auth.sql
-- Run order:   7 of 10
-- ============================================================================

-- ==========================================================
-- 1. TABLE: ai_chat_history
-- ==========================================================

CREATE TABLE IF NOT EXISTS public.ai_chat_history (
    id              UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID                NOT NULL
                                        REFERENCES public.profiles(id) ON DELETE CASCADE,
    session_id      UUID                NOT NULL DEFAULT gen_random_uuid(),

    -- Message content
    role            public.chat_role    NOT NULL,
    message         TEXT                NOT NULL
                                        CHECK (length(message) BETWEEN 1 AND 50000),

    -- Environmental context used by AI to answer
    context         JSONB,
    -- Expected schema:
    -- {
    --   "location": {"lat": 13.08, "lng": 80.27, "label": "Chennai"},
    --   "weather": {"temperature_c": 42, "humidity_pct": 60, ...},
    --   "risk_level": "high",
    --   "risk_score": 78
    -- }

    -- AI model metadata
    model_used      TEXT,
    tokens_used     INTEGER             CHECK (tokens_used IS NULL OR tokens_used >= 0),
    latency_ms      INTEGER             CHECK (latency_ms IS NULL OR latency_ms >= 0),

    -- Timestamps
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT now()
);

-- ==========================================================
-- 2. INDEXES
-- ==========================================================

-- Retrieve a full conversation session in order
CREATE INDEX IF NOT EXISTS idx_chat_history_session
    ON public.ai_chat_history (session_id, created_at ASC);

-- User's chat sessions (most recent first)
CREATE INDEX IF NOT EXISTS idx_chat_history_user_created
    ON public.ai_chat_history (user_id, created_at DESC);

-- List all sessions for a user (for session picker UI)
CREATE INDEX IF NOT EXISTS idx_chat_history_user_session
    ON public.ai_chat_history (user_id, session_id);

-- Filter by role (e.g., count user messages for analytics)
CREATE INDEX IF NOT EXISTS idx_chat_history_role
    ON public.ai_chat_history (role);

-- ==========================================================
-- 3. VIEWS
-- ==========================================================

-- Convenient view: latest message per session (for session list UI)
CREATE OR REPLACE VIEW public.chat_sessions_summary AS
SELECT DISTINCT ON (user_id, session_id)
    user_id,
    session_id,
    message         AS last_message,
    role            AS last_role,
    created_at      AS last_message_at,
    (
        SELECT COUNT(*)
        FROM public.ai_chat_history sub
        WHERE sub.session_id = main.session_id
    )               AS message_count
FROM public.ai_chat_history main
ORDER BY user_id, session_id, created_at DESC;

COMMENT ON VIEW public.chat_sessions_summary
    IS 'Provides the latest message and message count for each chat session. Useful for session list UI.';

-- ==========================================================
-- 4. TABLE COMMENTS
-- ==========================================================

COMMENT ON TABLE public.ai_chat_history
    IS 'Escape AI Assistant conversation history. Grouped by session_id. Retained indefinitely.';

COMMENT ON COLUMN public.ai_chat_history.session_id
    IS 'Groups messages into a single conversation. A new session_id starts a new conversation.';

COMMENT ON COLUMN public.ai_chat_history.context
    IS 'Environmental context provided to the AI when generating the response';

COMMENT ON COLUMN public.ai_chat_history.tokens_used
    IS 'Token count for AI-generated responses (assistant role). Null for user messages.';

COMMENT ON COLUMN public.ai_chat_history.latency_ms
    IS 'Response generation time in milliseconds. Null for user messages.';
