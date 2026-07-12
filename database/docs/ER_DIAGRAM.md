# Escape Heat — ER Diagram

## Entity Relationship Diagram

```mermaid
erDiagram
    AUTH_USERS ||--|| PROFILES : "id (1:1)"
    PROFILES ||--|| USER_PREFERENCES : "user_id (1:1)"
    PROFILES ||--o{ SAVED_LOCATIONS : "user_id (1:N)"
    PROFILES ||--o{ RECOMMENDATION_HISTORY : "user_id (1:N)"
    PROFILES ||--o{ AI_CHAT_HISTORY : "user_id (1:N)"
    PROFILES ||--o{ REPORTS : "user_id (1:N)"
    SAVED_LOCATIONS ||--o{ RECOMMENDATION_HISTORY : "location_id (optional)"

    AUTH_USERS {
        uuid id PK
        text email
        jsonb raw_user_meta_data
        timestamptz created_at
    }

    PROFILES {
        uuid id PK,FK
        text full_name
        text avatar_url
        date date_of_birth
        gender_type gender
        text phone
        user_role role
        text_array health_conditions
        timestamptz created_at
        timestamptz updated_at
    }

    USER_PREFERENCES {
        uuid id PK
        uuid user_id FK,UK
        temp_unit temperature_unit
        text language
        text theme
        boolean notification_enabled
        alert_threshold heat_alert_threshold
        boolean email_alerts
        boolean push_alerts
        activity_level activity_level
        jsonb outdoor_work_hours
        boolean works_outdoors
        timestamptz created_at
        timestamptz updated_at
    }

    SAVED_LOCATIONS {
        uuid id PK
        uuid user_id FK
        text label
        double latitude
        double longitude
        text address
        text city
        text state
        text country
        boolean is_primary
        timestamptz created_at
    }

    ENVIRONMENTAL_CACHE {
        uuid id PK
        double latitude
        double longitude
        data_source_type data_source
        text data_type
        jsonb data
        double heat_index
        double uv_index
        integer aqi
        timestamptz fetched_at
        timestamptz expires_at
    }

    RECOMMENDATION_HISTORY {
        uuid id PK
        uuid user_id FK
        uuid location_id FK
        double latitude
        double longitude
        text location_label
        risk_level risk_level
        double risk_score
        jsonb environmental_snapshot
        jsonb recommendations
        recommendation_category category
        integer feedback_rating
        text feedback_comment
        text model_used
        integer generation_time_ms
        timestamptz created_at
    }

    AI_CHAT_HISTORY {
        uuid id PK
        uuid user_id FK
        uuid session_id
        chat_role role
        text message
        jsonb context
        text model_used
        integer tokens_used
        integer latency_ms
        timestamptz created_at
    }

    REPORTS {
        uuid id PK
        uuid user_id FK
        text title
        report_type report_type
        text location_label
        double latitude
        double longitude
        jsonb content
        text summary
        text file_url
        boolean is_public
        uuid shared_token UK
        timestamptz created_at
    }
```

## Relationship Summary

| Relationship | Type | Cascade | Notes |
|---|---|---|---|
| `auth.users` → `profiles` | 1:1 | ON DELETE CASCADE | Auto-created via trigger |
| `profiles` → `user_preferences` | 1:1 | ON DELETE CASCADE | Auto-created via trigger |
| `profiles` → `saved_locations` | 1:N | ON DELETE CASCADE | Max 25 per user |
| `profiles` → `recommendation_history` | 1:N | ON DELETE CASCADE | Retained indefinitely |
| `profiles` → `ai_chat_history` | 1:N | ON DELETE CASCADE | Retained indefinitely |
| `profiles` → `reports` | 1:N | ON DELETE CASCADE | Supports public sharing |
| `saved_locations` → `recommendation_history` | 1:N (optional) | ON DELETE SET NULL | Location reference preserved as lat/lng snapshot |
| `environmental_cache` | Standalone | N/A | Ephemeral, auto-cleaned hourly |

## Data Flow

```mermaid
flowchart TD
    A["User Signs Up<br/>(Supabase Auth)"] --> B["auth.users<br/>INSERT trigger"]
    B --> C["profiles<br/>(auto-created)"]
    B --> D["user_preferences<br/>(auto-created)"]
    
    C --> E["saved_locations<br/>(user adds)"]
    
    F["External APIs<br/>(Open-Meteo, NASA)"] --> G["environmental_cache<br/>(backend caches)"]
    
    G --> H["Heat Intelligence<br/>Engine"]
    C --> H
    D --> H
    E --> H
    
    H --> I["recommendation_history<br/>(stored)"]
    H --> J["ai_chat_history<br/>(stored)"]
    H --> K["reports<br/>(generated)"]
    
    style A fill:#4CAF50,color:#fff
    style G fill:#FF9800,color:#fff
    style H fill:#2196F3,color:#fff
    style I fill:#9C27B0,color:#fff
    style J fill:#9C27B0,color:#fff
    style K fill:#9C27B0,color:#fff
```
