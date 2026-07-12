# Escape Heat — Schema Documentation

> Complete reference for all database tables, columns, types, indexes, triggers, and functions.

---

## Table of Contents

- [Custom Types (Enums)](#custom-types-enums)
- [Tables](#tables)
  - [profiles](#profiles)
  - [user_preferences](#user_preferences)
  - [saved_locations](#saved_locations)
  - [environmental_cache](#environmental_cache)
  - [recommendation_history](#recommendation_history)
  - [ai_chat_history](#ai_chat_history)
  - [reports](#reports)
- [Views](#views)
- [Functions](#functions)
- [Triggers](#triggers)
- [Indexes](#indexes)
- [Storage Buckets](#storage-buckets)

---

## Custom Types (Enums)

| Type Name | Values | Used In |
|---|---|---|
| `user_role` | citizen, worker, authority, admin | profiles.role |
| `gender_type` | male, female, other, prefer_not_to_say | profiles.gender |
| `temp_unit` | celsius, fahrenheit | user_preferences.temperature_unit |
| `alert_threshold` | low, moderate, high, extreme | user_preferences.heat_alert_threshold |
| `activity_level` | sedentary, light, moderate, active, very_active | user_preferences.activity_level |
| `data_source_type` | open_meteo, nasa_power, imd, isro, osm | environmental_cache.data_source |
| `risk_level` | low, moderate, high, very_high, extreme | recommendation_history.risk_level |
| `recommendation_category` | general, hydration, activity, clothing, travel, health | recommendation_history.category |
| `chat_role` | user, assistant, system | ai_chat_history.role |
| `report_type` | daily_summary, weekly_summary, heat_alert, custom | reports.report_type |

---

## Tables

### profiles

Extends `auth.users` with application-specific user data. **Auto-created** on signup via trigger.

| Column | Type | Nullable | Default | Constraints |
|---|---|---|---|---|
| `id` | UUID | NO | — | PK, FK → auth.users(id) CASCADE |
| `full_name` | TEXT | NO | `''` | length ≤ 200 |
| `avatar_url` | TEXT | YES | — | length ≤ 2048 |
| `date_of_birth` | DATE | YES | — | |
| `gender` | gender_type | YES | — | |
| `phone` | TEXT | YES | — | Regex: `^\+?[0-9\s\-]{7,20}$` |
| `role` | user_role | NO | `'citizen'` | |
| `health_conditions` | TEXT[] | YES | `'{}'` | |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | Auto-updated via trigger |

---

### user_preferences

Per-user personalization settings. **Auto-created** on signup via trigger. One row per user.

| Column | Type | Nullable | Default | Constraints |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK |
| `user_id` | UUID | NO | — | FK → profiles(id) CASCADE, UNIQUE |
| `temperature_unit` | temp_unit | NO | `'celsius'` | |
| `language` | TEXT | NO | `'en'` | Regex: `^[a-z]{2}(-[A-Z]{2})?$` |
| `theme` | TEXT | NO | `'system'` | IN ('light', 'dark', 'system') |
| `notification_enabled` | BOOLEAN | NO | `true` | |
| `heat_alert_threshold` | alert_threshold | NO | `'high'` | |
| `email_alerts` | BOOLEAN | NO | `false` | |
| `push_alerts` | BOOLEAN | NO | `true` | |
| `activity_level` | activity_level | NO | `'moderate'` | |
| `outdoor_work_hours` | JSONB | YES | `{"start":"09:00","end":"17:00"}` | Must contain `start` and `end` keys |
| `works_outdoors` | BOOLEAN | NO | `false` | |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | Auto-updated via trigger |

---

### saved_locations

User-bookmarked locations. Max **25 per user**. One can be marked as primary.

| Column | Type | Nullable | Default | Constraints |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK |
| `user_id` | UUID | NO | — | FK → profiles(id) CASCADE |
| `label` | TEXT | NO | — | length 1–100 |
| `latitude` | DOUBLE PRECISION | NO | — | -90 to 90 |
| `longitude` | DOUBLE PRECISION | NO | — | -180 to 180 |
| `address` | TEXT | YES | — | length ≤ 500 |
| `city` | TEXT | YES | — | length ≤ 100 |
| `state` | TEXT | YES | — | length ≤ 100 |
| `country` | TEXT | NO | `'India'` | length ≤ 100 |
| `is_primary` | BOOLEAN | NO | `false` | Partial unique per user |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |

**Special Behavior:**
- Only ONE location per user can have `is_primary = true` (enforced by partial unique index + trigger)
- Setting a new primary automatically unsets the previous primary
- Maximum 25 locations per user (enforced by trigger)

---

### environmental_cache

Ephemeral cache for external API responses. **Auto-cleaned hourly.** Not retained for insights.

| Column | Type | Nullable | Default | Constraints |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK |
| `latitude` | DOUBLE PRECISION | NO | — | -90 to 90 |
| `longitude` | DOUBLE PRECISION | NO | — | -180 to 180 |
| `data_source` | data_source_type | NO | — | |
| `data_type` | TEXT | NO | — | length 1–100 |
| `data` | JSONB | NO | `'{}'` | |
| `heat_index` | DOUBLE PRECISION | YES | — | |
| `uv_index` | DOUBLE PRECISION | YES | — | |
| `aqi` | INTEGER | YES | — | 0–500 |
| `fetched_at` | TIMESTAMPTZ | NO | `now()` | |
| `expires_at` | TIMESTAMPTZ | NO | — | |

**Unique Constraint:** `(latitude, longitude, data_source, data_type)` — prevents duplicate cache entries.

**Valid `data_type` values:** `current_weather`, `air_quality`, `lst`, `uv_index`, `forecast_hourly`

---

### recommendation_history

AI-generated heat recommendations with full context. **Retained indefinitely** for insights.

| Column | Type | Nullable | Default | Constraints |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK |
| `user_id` | UUID | NO | — | FK → profiles(id) CASCADE |
| `location_id` | UUID | YES | — | FK → saved_locations(id) SET NULL |
| `latitude` | DOUBLE PRECISION | NO | — | -90 to 90 |
| `longitude` | DOUBLE PRECISION | NO | — | -180 to 180 |
| `location_label` | TEXT | YES | — | |
| `risk_level` | risk_level | NO | — | |
| `risk_score` | DOUBLE PRECISION | NO | — | 0–100 |
| `environmental_snapshot` | JSONB | NO | `'{}'` | See schema below |
| `recommendations` | JSONB | NO | `'[]'` | See schema below |
| `category` | recommendation_category | NO | `'general'` | |
| `feedback_rating` | INTEGER | YES | — | 1–5 |
| `feedback_comment` | TEXT | YES | — | length ≤ 1000 |
| `model_used` | TEXT | YES | — | |
| `generation_time_ms` | INTEGER | YES | — | ≥ 0 |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |

**`environmental_snapshot` schema:**
```json
{
  "temperature_c": 42.5,
  "feels_like_c": 48.2,
  "humidity_pct": 55,
  "uv_index": 11,
  "wind_speed_kmh": 12,
  "aqi": 156,
  "heat_index": 51.3
}
```

**`recommendations` schema:**
```json
[
  {
    "category": "hydration",
    "severity": "high",
    "title": "Increase Water Intake",
    "description": "Drink at least 3L of water...",
    "icon": "💧"
  }
]
```

---

### ai_chat_history

Escape AI Assistant conversation history. **Retained indefinitely.**

| Column | Type | Nullable | Default | Constraints |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK |
| `user_id` | UUID | NO | — | FK → profiles(id) CASCADE |
| `session_id` | UUID | NO | `gen_random_uuid()` | Groups conversation messages |
| `role` | chat_role | NO | — | |
| `message` | TEXT | NO | — | length 1–50,000 |
| `context` | JSONB | YES | — | Environmental context for AI |
| `model_used` | TEXT | YES | — | |
| `tokens_used` | INTEGER | YES | — | ≥ 0 |
| `latency_ms` | INTEGER | YES | — | ≥ 0 |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |

**`context` schema:**
```json
{
  "location": {"lat": 13.08, "lng": 80.27, "label": "Chennai"},
  "weather": {"temperature_c": 42, "humidity_pct": 60},
  "risk_level": "high",
  "risk_score": 78
}
```

---

### reports

Generated heat analysis reports. Supports PDF storage and public sharing.

| Column | Type | Nullable | Default | Constraints |
|---|---|---|---|---|
| `id` | UUID | NO | `gen_random_uuid()` | PK |
| `user_id` | UUID | NO | — | FK → profiles(id) CASCADE |
| `title` | TEXT | NO | — | length 1–300 |
| `report_type` | report_type | NO | — | |
| `location_label` | TEXT | YES | — | |
| `latitude` | DOUBLE PRECISION | YES | — | -90 to 90, paired with longitude |
| `longitude` | DOUBLE PRECISION | YES | — | -180 to 180, paired with latitude |
| `content` | JSONB | NO | `'{}'` | Schema varies by report_type |
| `summary` | TEXT | YES | — | length ≤ 5000 |
| `file_url` | TEXT | YES | — | Supabase Storage URL, length ≤ 2048 |
| `is_public` | BOOLEAN | NO | `false` | |
| `shared_token` | UUID | YES | — | UNIQUE, for sharing via URL |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |

**Constraint:** `latitude` and `longitude` must both be NULL or both be NOT NULL.

---

## Views

### chat_sessions_summary

Provides the latest message and message count for each chat session. Useful for building a session list UI.

| Column | Source |
|---|---|
| `user_id` | ai_chat_history.user_id |
| `session_id` | ai_chat_history.session_id |
| `last_message` | Latest message text |
| `last_role` | Role of the latest message |
| `last_message_at` | Timestamp of latest message |
| `message_count` | Total messages in session |

---

## Functions

| Function | Returns | Purpose | Security |
|---|---|---|---|
| `handle_updated_at()` | TRIGGER | Auto-sets `updated_at = now()` on UPDATE | INVOKER |
| `handle_new_user()` | TRIGGER | Creates profile + preferences on auth signup | DEFINER |
| `check_saved_locations_limit()` | TRIGGER | Enforces 25-location limit per user | INVOKER |
| `ensure_single_primary_location()` | TRIGGER | Unsets previous primary when new primary is set | INVOKER |
| `cleanup_expired_cache()` | INTEGER | Deletes expired environmental_cache rows | DEFINER |
| `upsert_environmental_cache(...)` | UUID | Atomically inserts/updates cache with TTL | DEFINER |
| `generate_report_share_token(UUID)` | UUID | Generates share URL token for a report | INVOKER |

---

## Triggers

| Trigger | Table | Event | Function |
|---|---|---|---|
| `trg_profiles_updated_at` | profiles | BEFORE UPDATE | handle_updated_at() |
| `trg_user_preferences_updated_at` | user_preferences | BEFORE UPDATE | handle_updated_at() |
| `on_auth_user_created` | auth.users | AFTER INSERT | handle_new_user() |
| `trg_check_saved_locations_limit` | saved_locations | BEFORE INSERT | check_saved_locations_limit() |
| `trg_ensure_single_primary` | saved_locations | BEFORE INSERT/UPDATE | ensure_single_primary_location() |

---

## Indexes

| Table | Index | Columns | Type | Notes |
|---|---|---|---|---|
| profiles | PK | id | btree | Primary key |
| profiles | idx_profiles_role | role | btree | Filter by user type |
| profiles | idx_profiles_created_at | created_at DESC | btree | Recent users |
| user_preferences | PK | id | btree | Primary key |
| user_preferences | UNIQUE | user_id | btree | One per user |
| saved_locations | PK | id | btree | Primary key |
| saved_locations | idx_saved_locations_user_id | user_id | btree | User's locations |
| saved_locations | idx_saved_locations_single_primary | user_id WHERE is_primary | btree partial unique | Single primary |
| saved_locations | idx_saved_locations_coords | latitude, longitude | btree | Geo lookup |
| environmental_cache | PK | id | btree | Primary key |
| environmental_cache | UNIQUE | lat, lng, source, type | btree | Dedup |
| environmental_cache | idx_env_cache_location_source | lat, lng, source, type | btree | Fast lookup |
| environmental_cache | idx_env_cache_expires_at | expires_at WHERE < now() | btree partial | Cleanup |
| environmental_cache | idx_env_cache_data_gin | data | GIN | JSONB queries |
| recommendation_history | PK | id | btree | Primary key |
| recommendation_history | idx_rec_history_user_created | user_id, created_at DESC | btree | User timeline |
| recommendation_history | idx_rec_history_risk_level | risk_level | btree | Analytics |
| recommendation_history | idx_rec_history_category | category | btree | Filter |
| recommendation_history | idx_rec_history_coords | latitude, longitude | btree | Geo queries |
| recommendation_history | idx_rec_history_env_snapshot_gin | environmental_snapshot | GIN | JSONB queries |
| ai_chat_history | PK | id | btree | Primary key |
| ai_chat_history | idx_chat_history_session | session_id, created_at ASC | btree | Conversation order |
| ai_chat_history | idx_chat_history_user_created | user_id, created_at DESC | btree | User timeline |
| ai_chat_history | idx_chat_history_user_session | user_id, session_id | btree | Session list |
| reports | PK | id | btree | Primary key |
| reports | idx_reports_user_created | user_id, created_at DESC | btree | User's reports |
| reports | idx_reports_type | report_type | btree | Filter |
| reports | idx_reports_public | is_public, created_at WHERE public | btree partial | Public listing |
| reports | idx_reports_shared_token | shared_token WHERE NOT NULL | btree partial | Share URL lookup |

---

## Storage Buckets

| Bucket | Public | Max Size | Allowed Types | Path Convention |
|---|---|---|---|---|
| `avatars` | Yes (read) | 2 MB | JPEG, PNG, WebP | `avatars/{user_id}/{filename}` |
| `reports` | No | 10 MB | PDF | `reports/{user_id}/{report_id}.pdf` |
