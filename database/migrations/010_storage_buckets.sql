-- ============================================================================
-- Escape Heat — Migration 010: Storage Buckets and Policies
-- ============================================================================
-- Description: Creates Supabase Storage buckets for avatars and reports,
--              with appropriate access policies.
-- Depends on:  002_profiles_and_auth.sql
-- Run order:   10 of 10
-- ============================================================================

-- ==========================================================
-- 1. STORAGE BUCKETS
-- ==========================================================

-- Avatars bucket (public read, authenticated write)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars',
    true,                                           -- Publicly readable
    2097152,                                        -- 2 MB max
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Reports bucket (private, authenticated users access own files)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'reports',
    'reports',
    false,                                          -- Private
    10485760,                                       -- 10 MB max
    ARRAY['application/pdf']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ==========================================================
-- 2. STORAGE POLICIES — AVATARS
-- ==========================================================
-- File path convention: avatars/{user_id}/{filename}

-- Public read access (anyone can view avatars)
CREATE POLICY storage_avatars_select_public
    ON storage.objects
    FOR SELECT
    TO public
    USING (bucket_id = 'avatars');

-- Authenticated users can upload their own avatar
CREATE POLICY storage_avatars_insert_own
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'avatars'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Authenticated users can update their own avatar
CREATE POLICY storage_avatars_update_own
    ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'avatars'
        AND (storage.foldername(name))[1] = auth.uid()::text
    )
    WITH CHECK (
        bucket_id = 'avatars'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Authenticated users can delete their own avatar
CREATE POLICY storage_avatars_delete_own
    ON storage.objects
    FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'avatars'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- ==========================================================
-- 3. STORAGE POLICIES — REPORTS
-- ==========================================================
-- File path convention: reports/{user_id}/{report_id}.pdf

-- Authenticated users can read their own reports
CREATE POLICY storage_reports_select_own
    ON storage.objects
    FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'reports'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Authenticated users can upload their own reports
CREATE POLICY storage_reports_insert_own
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'reports'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Authenticated users can update their own reports
CREATE POLICY storage_reports_update_own
    ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'reports'
        AND (storage.foldername(name))[1] = auth.uid()::text
    )
    WITH CHECK (
        bucket_id = 'reports'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Authenticated users can delete their own reports
CREATE POLICY storage_reports_delete_own
    ON storage.objects
    FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'reports'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );
