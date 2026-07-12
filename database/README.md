# Escape Heat — Database

Production-ready Supabase PostgreSQL database for the Escape Heat AI-Powered Urban Heat Decision Intelligence Platform.

## Quick Start

### Option A: One-Shot Install (Recommended)
1. Open your Supabase project's **SQL Editor**
2. Run `migrations/000_full_migration.sql` — creates all tables, RLS, storage
3. Run `migrations/011_helper_functions.sql` — backend RPC functions
4. Run `migrations/012_analytics_views.sql` — admin analytics
5. (Optional) Run `seed/seed_data.sql` for demo data
6. Run `verify.sql` to confirm everything is working

### Option B: Incremental Install
1. Run migrations `001` → `012` in order
2. (Optional) Run `seed/seed_data.sql` for demo data
3. Run `verify.sql` to confirm everything is working

### Reset Database
Run `reset.sql` to drop all objects and start fresh (dev/test only).

## Structure

```
database/
├── migrations/
│   ├── 000_full_migration.sql        # One-shot: all tables + RLS + storage
│   ├── 001_extensions_and_enums.sql   # Extensions, 10 custom enums
│   ├── 002_profiles_and_auth.sql      # Profiles + auth signup trigger
│   ├── 003_user_preferences.sql       # User preferences (1:1 with profile)
│   ├── 004_saved_locations.sql        # Saved locations (max 25 per user)
│   ├── 005_environmental_cache.sql    # API cache + auto-cleanup
│   ├── 006_recommendation_history.sql # AI recommendations + context
│   ├── 007_ai_chat_history.sql        # Chat history + sessions view
│   ├── 008_reports.sql                # Reports + sharing tokens
│   ├── 009_rls_policies.sql           # 22 Row Level Security policies
│   ├── 010_storage_buckets.sql        # Avatars + reports buckets
│   ├── 011_helper_functions.sql       # 8 backend RPC helper functions
│   └── 012_analytics_views.sql        # 6 analytics views + 2 functions
├── seed/
│   └── seed_data.sql                  # 3 demo users, 5 cities, sample data
├── docs/
│   ├── SCHEMA.md                      # Complete schema reference
│   ├── ER_DIAGRAM.md                  # Entity relationship diagrams
│   └── SETUP.md                       # Setup & connection guide
├── reset.sql                          # ⚠️ Drops everything (dev only)
├── verify.sql                         # Automated verification (25+ checks)
└── README.md                          # This file
```

## Tables

| Table | Purpose | RLS | Retention |
|---|---|---|---|
| `profiles` | User profiles (extends auth.users) | ✅ Own data | Permanent |
| `user_preferences` | Personalization settings | ✅ Own data | Permanent |
| `saved_locations` | Bookmarked locations (max 25) | ✅ Own data | Permanent |
| `environmental_cache` | Cached API responses | ✅ Read-only | Auto-cleaned hourly |
| `recommendation_history` | AI recommendations + context | ✅ Own data | Permanent |
| `ai_chat_history` | Chat with Escape AI | ✅ Own data | Permanent |
| `reports` | Heat analysis reports | ✅ Own + public | Permanent |

## RPC Functions (for FastAPI Backend)

| Function | Purpose |
|---|---|
| `get_user_dashboard(user_id)` | All dashboard data in one call |
| `get_cached_environment(lat, lng)` | Non-expired cache for a location |
| `get_recommendation_history(user_id, ...)` | Paginated + filtered history |
| `get_chat_session(user_id, session_id)` | Full conversation messages |
| `get_user_chat_sessions(user_id, ...)` | Paginated session list |
| `submit_recommendation_feedback(...)` | Rate a recommendation 1-5 |
| `get_nearby_cache(lat, lng, radius)` | Cache data for heat map |
| `delete_user_account(user_id)` | GDPR-compliant account deletion |
| `upsert_environmental_cache(...)` | Atomic cache insert/update |
| `generate_report_share_token(report_id)` | Create shareable report link |
| `cleanup_expired_cache()` | Manual cache cleanup |

## Analytics Views (for Admin Dashboard)

| View/Function | Purpose |
|---|---|
| `platform_stats` | Total users, recommendations, chats, cache stats |
| `risk_distribution` | Risk level breakdown with percentages |
| `city_heat_summary` | Per-city heat risk analysis |
| `ai_model_usage` | AI model performance and token tracking |
| `feedback_analytics` | Recommendation quality by category/risk |
| `cache_health` | Cache freshness and data size monitoring |
| `get_daily_usage_trends(days)` | Daily usage metrics for charts |
| `get_user_engagement(user_id)` | Per-user engagement metrics |

## Key Features

- **10 custom PostgreSQL enums** for type safety
- **Row Level Security** on all tables with admin overrides
- **Auth trigger** auto-creates profile + preferences on signup
- **Single primary location** enforced via partial unique index + trigger
- **25-location limit** per user via trigger
- **UPSERT helper** for environmental cache with coordinate rounding
- **Automatic cache cleanup** via pg_cron (with backend fallback)
- **Report sharing** via unique tokens
- **Chat sessions view** for session list UI
- **Storage buckets** for avatars (public) and reports (private)
- **GDPR-compliant** account deletion function
- **Automated verification** script with 25+ checks
- **One-shot migration** for fresh installs
- **Reset script** for dev/test environments

## Documentation

- **[Schema Reference](docs/SCHEMA.md)** — All tables, columns, types, indexes, triggers, functions
- **[ER Diagram](docs/ER_DIAGRAM.md)** — Visual entity relationships and data flow
- **[Setup Guide](docs/SETUP.md)** — Installation, connection, and troubleshooting
