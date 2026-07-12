-- ============================================================================
-- Escape Heat — Migration 004: Saved Locations Table
-- ============================================================================
-- Description: User-bookmarked locations for quick access. Supports a primary
--              location per user and enforces a 25-location limit.
-- Depends on:  001_extensions_and_enums.sql, 002_profiles_and_auth.sql
-- Run order:   4 of 10
-- ============================================================================

-- ==========================================================
-- 1. TABLE: saved_locations
-- ==========================================================

CREATE TABLE IF NOT EXISTS public.saved_locations (
    id              UUID                PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID                NOT NULL
                                        REFERENCES public.profiles(id) ON DELETE CASCADE,

    -- Location metadata
    label           TEXT                NOT NULL
                                        CHECK (length(label) BETWEEN 1 AND 100),
    latitude        DOUBLE PRECISION    NOT NULL
                                        CHECK (latitude BETWEEN -90 AND 90),
    longitude       DOUBLE PRECISION    NOT NULL
                                        CHECK (longitude BETWEEN -180 AND 180),
    address         TEXT                CHECK (address IS NULL OR length(address) <= 500),
    city            TEXT                CHECK (city IS NULL OR length(city) <= 100),
    state           TEXT                CHECK (state IS NULL OR length(state) <= 100),
    country         TEXT                NOT NULL DEFAULT 'India'
                                        CHECK (length(country) <= 100),
    is_primary      BOOLEAN             NOT NULL DEFAULT false,

    -- Timestamps
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT now()
);

-- ==========================================================
-- 2. INDEXES
-- ==========================================================

-- Fast lookup of a user's locations
CREATE INDEX IF NOT EXISTS idx_saved_locations_user_id
    ON public.saved_locations (user_id);

-- Ensure only ONE primary location per user (partial unique index)
CREATE UNIQUE INDEX IF NOT EXISTS idx_saved_locations_single_primary
    ON public.saved_locations (user_id)
    WHERE is_primary = true;

-- Geospatial lookup (composite on coordinates)
CREATE INDEX IF NOT EXISTS idx_saved_locations_coords
    ON public.saved_locations (latitude, longitude);

-- ==========================================================
-- 3. TRIGGER: Enforce max 25 locations per user
-- ==========================================================

CREATE OR REPLACE FUNCTION public.check_saved_locations_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
    location_count INTEGER;
    max_locations  CONSTANT INTEGER := 25;
BEGIN
    SELECT COUNT(*) INTO location_count
    FROM public.saved_locations
    WHERE user_id = NEW.user_id;

    IF location_count >= max_locations THEN
        RAISE EXCEPTION 'Location limit reached: maximum % saved locations per user', max_locations
            USING HINT = 'Delete an existing location before adding a new one',
                  ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_saved_locations_limit ON public.saved_locations;
CREATE TRIGGER trg_check_saved_locations_limit
    BEFORE INSERT ON public.saved_locations
    FOR EACH ROW
    EXECUTE FUNCTION public.check_saved_locations_limit();

-- ==========================================================
-- 4. TRIGGER: Ensure single primary location
-- ==========================================================
-- When a location is set as primary, unset all other primary locations
-- for that user. This works alongside the partial unique index as a
-- belt-and-suspenders approach.

CREATE OR REPLACE FUNCTION public.ensure_single_primary_location()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN
    IF NEW.is_primary = true THEN
        UPDATE public.saved_locations
        SET is_primary = false
        WHERE user_id = NEW.user_id
          AND id != NEW.id
          AND is_primary = true;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_ensure_single_primary ON public.saved_locations;
CREATE TRIGGER trg_ensure_single_primary
    BEFORE INSERT OR UPDATE OF is_primary ON public.saved_locations
    FOR EACH ROW
    WHEN (NEW.is_primary = true)
    EXECUTE FUNCTION public.ensure_single_primary_location();

-- ==========================================================
-- 5. TABLE COMMENTS
-- ==========================================================

COMMENT ON TABLE public.saved_locations
    IS 'User-bookmarked locations. Max 25 per user. One can be marked as primary.';

COMMENT ON COLUMN public.saved_locations.is_primary
    IS 'Only one location per user can be primary. Used as default location for dashboard.';

COMMENT ON COLUMN public.saved_locations.label
    IS 'User-defined label, e.g., "Home", "Office", "Gym"';
