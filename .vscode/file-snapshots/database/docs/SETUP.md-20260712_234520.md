# Escape Heat — Database Setup Guide

## Prerequisites

- A Supabase project (free tier or paid)
- Access to the Supabase SQL Editor (Dashboard → SQL Editor)
- Optionally, `psql` CLI for local execution

---

## Setup Steps

### Step 1: Open Supabase SQL Editor

1. Go to [supabase.com/dashboard](https://supabase.com/dashboard)
2. Select your project
3. Navigate to **SQL Editor** in the left sidebar

### Step 2: Run Migrations in Order

Execute each migration file **sequentially** in the SQL Editor. Run them one at a time and verify each completes without errors before proceeding.

| Order | File | Description |
|---|---|---|
| 0 | `migrations/000_full_migration.sql` | One-shot setup for all tables, RLS, and storage |
| 1 | `migrations/001_extensions_and_enums.sql` | Extensions, custom types, utility functions |
| 2 | `migrations/002_profiles_and_auth.sql` | Profiles table + auth signup trigger |
| 3 | `migrations/003_user_preferences.sql` | User preferences table |
| 4 | `migrations/004_saved_locations.sql` | Saved locations + limit triggers |
| 5 | `migrations/005_environmental_cache.sql` | Environmental cache + auto-cleanup |
| 6 | `migrations/006_recommendation_history.sql` | Recommendation history table |
| 7 | `migrations/007_ai_chat_history.sql` | AI chat history table |
| 8 | `migrations/008_reports.sql` | Reports table |
| 9 | `migrations/009_rls_policies.sql` | Row Level Security policies |
| 10 | `migrations/010_storage_buckets.sql` | Storage buckets + policies |
| 11 | `migrations/011_helper_functions.sql` | Backend RPC helper functions |
| 12 | `migrations/012_analytics_views.sql` | Analytics views and reporting helpers |

> [!IMPORTANT]
> The one-shot migration (`000_full_migration.sql`) covers migrations `001` through `010` only. It does **not** include `011_helper_functions.sql` or `012_analytics_views.sql`.

> [!IMPORTANT]
> You can use either the one-shot migration (`000_full_migration.sql`) plus the two remaining files, or the incremental sequence (`001` through `012`). Do not run `000` and then rerun migrations `001` through `010` unless you intentionally want to rebuild the database from scratch.

> [!IMPORTANT]
> If you choose the incremental path, migration **001** must run first and migration **009** (RLS) must run after all table migrations (002-008). The recommended order is `001` → `012`.

### Step 3: Run Seed Data (Optional)

For development/testing, run the seed data script:

```
seed/seed_data.sql
```

> [!WARNING]
> The seed data inserts profiles with hardcoded UUIDs. In production, profiles are auto-created by the auth trigger when users sign up. **Do NOT run seed data in production.**

> [!NOTE]
> If you want to test with the seed data against RLS, you need to create matching users in Supabase Auth first (Authentication → Users → Add User) with the same UUIDs, or temporarily disable RLS during seeding.

### Step 4: Verify Installation

Run these queries in the SQL Editor to verify everything was created:

```sql
-- Check all tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Expected: ai_chat_history, environmental_cache, profiles,
--           recommendation_history, reports, saved_locations, user_preferences

-- Check all custom types exist
SELECT typname
FROM pg_type
WHERE typnamespace = 'public'::regnamespace
  AND typtype = 'e'
ORDER BY typname;

-- Expected: activity_level, alert_threshold, chat_role, data_source_type,
--           gender_type, recommendation_category, report_type, risk_level,
--           temp_unit, user_role

-- Check RLS is enabled on all tables
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Expected: All tables should show rowsecurity = true

-- Check storage buckets
SELECT id, name, public, file_size_limit
FROM storage.buckets
WHERE id IN ('avatars', 'reports');

-- Check triggers
SELECT trigger_name, event_object_table, action_timing, event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- Check pg_cron job (if available)
SELECT jobid, schedule, command
FROM cron.job
WHERE jobname = 'cleanup-expired-env-cache';
```

### Step 5: Test Auth Integration

1. Go to **Authentication** → **Users** → **Add User**
2. Create a test user with email and password
3. Verify that a row was auto-created in:
   - `profiles` table
   - `user_preferences` table

```sql
-- After creating a test user, check:
SELECT id, full_name, role FROM public.profiles ORDER BY created_at DESC LIMIT 1;
SELECT user_id, temperature_unit, activity_level FROM public.user_preferences ORDER BY created_at DESC LIMIT 1;
```

---

## Connecting from FastAPI

### Environment Variables

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=

SUPABASE_SERVICE_ROLE_KEY=

SUPABASE_DB_URL=

```

### Python (supabase-py)

```python
from supabase import create_client

# For client-side operations (respects RLS)
supabase = create_client(
    supabase_url="https://your-project-ref.supabase.co",
    supabase_key="your-anon-key"  # or user's JWT
)

# For server-side operations (bypasses RLS)
supabase_admin = create_client(
    supabase_url="https://your-project-ref.supabase.co",
    supabase_key="your-service-role-key"
)
```

### Direct PostgreSQL (SQLAlchemy / asyncpg)

```python
# For direct SQL queries (bypasses RLS)
DATABASE_URL = "postgresql://postgres:[password]@db.your-project-ref.supabase.co:5432/postgres"
```

---

## Key Notes for Backend Developers

### RLS Behavior

| Key | RLS |
|---|---|
| `anon` key | ✅ Enforced — only policies for `anon` role apply |
| `authenticated` key + JWT | ✅ Enforced — policies use `auth.uid()` from JWT |
| `service_role` key | ❌ Bypassed — full access to all data |
| Direct PostgreSQL | ❌ Bypassed — full access |

### Helper Functions Available

The database provides these server-callable functions:

```sql
-- Upsert environmental cache (rounds coords, handles TTL)
SELECT public.upsert_environmental_cache(
    p_latitude := 13.08,
    p_longitude := 80.27,
    p_data_source := 'open_meteo',
    p_data_type := 'current_weather',
    p_data := '{"temperature_c": 42}'::jsonb,
    p_heat_index := 51.3,
    p_ttl_minutes := 30
);

-- Generate a shareable report link
SELECT public.generate_report_share_token('report-uuid-here');

-- Manual cache cleanup (if pg_cron is unavailable)
SELECT public.cleanup_expired_cache();
```

### Storage Upload Conventions

```
avatars/{user_id}/avatar.jpg
reports/{user_id}/{report_id}.pdf
```

---

## Troubleshooting

| Issue | Solution |
|---|---|
| `permission denied for table profiles` | Ensure RLS policies are created (migration 009) |
| `relation "auth.users" does not exist` | You're running outside Supabase. Use Supabase SQL Editor. |
| `function cron.schedule does not exist` | pg_cron not available on free tier. Use backend cron instead. |
| Auth trigger not firing | Check trigger exists: `SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created'` |
| Duplicate key on seed data | Seed data already exists. Use `ON CONFLICT DO NOTHING` (already included). |
| `new row violates check constraint` | Check data format matches constraints (phone regex, coordinate ranges, etc.) |
