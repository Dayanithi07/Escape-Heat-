-- ============================================================================
-- Escape Heat — Seed Data
-- ============================================================================
-- Description: Populates the database with realistic demo data for
--              development and testing. Uses deterministic UUIDs for
--              reproducibility.
--
-- IMPORTANT:   This script should be run AFTER all migrations.
--              It does NOT create auth.users entries (those are created
--              via Supabase Auth). Instead, it directly inserts into
--              public tables using pre-defined UUIDs.
--
--              For testing, create these users in Supabase Auth first,
--              then update the UUIDs below to match.
-- ============================================================================

-- ==========================================================
-- 1. DEMO USER PROFILES
-- ==========================================================
-- Note: In production, profiles are auto-created by the auth trigger.
-- For seeding, we insert directly. Ensure matching auth.users exist.

-- Use deterministic UUIDs for reproducibility
-- User 1: Citizen (Priya)
-- User 2: Outdoor Worker (Rajan)
-- User 3: City Authority / Admin (Dr. Meera)

INSERT INTO public.profiles (id, full_name, date_of_birth, gender, phone, role, health_conditions)
VALUES
    (
        'd6d7082b-e295-44d3-8868-5e2a5712b006',
        'Priya Sharma',
        '1995-03-15',
        'female',
        '+91 9876543210',
        'citizen',
        '{}'
    ),
    (
        '27cfaaf8-f19e-42a3-8384-ab2f96fb312a',
        'Rajan Kumar',
        '1988-07-22',
        'male',
        '+91 9876543211',
        'worker',
        '{"hypertension"}'
    ),
    (
        '3f887730-007a-44f2-a1a7-b6068dcf0a9f',
        'Dr. Meera Iyer',
        '1980-11-05',
        'female',
        '+91 9876543212',
        'admin',
        '{}'
    )
ON CONFLICT (id) DO NOTHING;

-- ==========================================================
-- 2. USER PREFERENCES
-- ==========================================================

INSERT INTO public.user_preferences (user_id, temperature_unit, language, theme, notification_enabled, heat_alert_threshold, activity_level, works_outdoors, outdoor_work_hours)
VALUES
    (
        'd6d7082b-e295-44d3-8868-5e2a5712b006',
        'celsius',
        'en',
        'system',
        true,
        'high',
        'moderate',
        false,
        '{"start": "09:00", "end": "17:00"}'::jsonb
    ),
    (
        '27cfaaf8-f19e-42a3-8384-ab2f96fb312a',
        'celsius',
        'en',
        'dark',
        true,
        'moderate',
        'very_active',
        true,
        '{"start": "06:00", "end": "14:00"}'::jsonb
    ),
    (
        '3f887730-007a-44f2-a1a7-b6068dcf0a9f',
        'celsius',
        'en',
        'light',
        true,
        'low',
        'sedentary',
        false,
        '{"start": "09:00", "end": "18:00"}'::jsonb
    )
ON CONFLICT (user_id) DO NOTHING;

-- ==========================================================
-- 3. SAVED LOCATIONS (Indian Cities)
-- ==========================================================

INSERT INTO public.saved_locations (id, user_id, label, latitude, longitude, address, city, state, country, is_primary)
VALUES
    -- Priya's locations
    (
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'd6d7082b-e295-44d3-8868-5e2a5712b006',
        'Home',
        13.0827,
        80.2707,
        'T. Nagar, Chennai',
        'Chennai',
        'Tamil Nadu',
        'India',
        true
    ),
    (
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaab',
        'd6d7082b-e295-44d3-8868-5e2a5712b006',
        'Office',
        12.9716,
        77.5946,
        'Koramangala, Bangalore',
        'Bangalore',
        'Karnataka',
        'India',
        false
    ),
    -- Rajan's locations
    (
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        '27cfaaf8-f19e-42a3-8384-ab2f96fb312a',
        'Construction Site',
        28.6139,
        77.2090,
        'Connaught Place, New Delhi',
        'New Delhi',
        'Delhi',
        'India',
        true
    ),
    (
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbc',
        '27cfaaf8-f19e-42a3-8384-ab2f96fb312a',
        'Home',
        28.4595,
        77.0266,
        'Sector 56, Gurgaon',
        'Gurgaon',
        'Haryana',
        'India',
        false
    ),
    -- Dr. Meera's locations
    (
        'cccccccc-cccc-cccc-cccc-cccccccccccc',
        '3f887730-007a-44f2-a1a7-b6068dcf0a9f',
        'Municipal Office',
        17.3850,
        78.4867,
        'Hussain Sagar, Hyderabad',
        'Hyderabad',
        'Telangana',
        'India',
        true
    )
ON CONFLICT (id) DO NOTHING;

-- ==========================================================
-- 4. ENVIRONMENTAL CACHE (Sample entries)
-- ==========================================================

INSERT INTO public.environmental_cache (latitude, longitude, data_source, data_type, data, heat_index, uv_index, aqi, expires_at)
VALUES
    -- Chennai current weather
    (
        13.08,
        80.27,
        'open_meteo',
        'current_weather',
        '{
            "temperature_c": 42.5,
            "feels_like_c": 48.2,
            "humidity_pct": 55,
            "wind_speed_kmh": 12.3,
            "wind_direction_deg": 210,
            "precipitation_mm": 0,
            "cloud_cover_pct": 15,
            "pressure_hpa": 1008
        }'::jsonb,
        51.3,
        NULL,
        NULL,
        now() + interval '30 minutes'
    ),
    -- Chennai air quality
    (
        13.08,
        80.27,
        'open_meteo',
        'air_quality',
        '{
            "pm2_5": 45.2,
            "pm10": 78.6,
            "no2": 32.1,
            "o3": 85.4,
            "so2": 12.3,
            "co": 0.8
        }'::jsonb,
        NULL,
        NULL,
        156,
        now() + interval '1 hour'
    ),
    -- Delhi current weather
    (
        28.61,
        77.21,
        'open_meteo',
        'current_weather',
        '{
            "temperature_c": 44.8,
            "feels_like_c": 52.1,
            "humidity_pct": 30,
            "wind_speed_kmh": 8.5,
            "wind_direction_deg": 180,
            "precipitation_mm": 0,
            "cloud_cover_pct": 5,
            "pressure_hpa": 1005
        }'::jsonb,
        55.7,
        NULL,
        NULL,
        now() + interval '30 minutes'
    ),
    -- Chennai UV data
    (
        13.08,
        80.27,
        'open_meteo',
        'uv_index',
        '{
            "uv_index": 11.2,
            "uv_index_max": 12.8,
            "uv_category": "extreme"
        }'::jsonb,
        NULL,
        11.2,
        NULL,
        now() + interval '1 hour'
    )
ON CONFLICT (latitude, longitude, data_source, data_type)
DO UPDATE SET
    data = EXCLUDED.data,
    heat_index = EXCLUDED.heat_index,
    uv_index = EXCLUDED.uv_index,
    aqi = EXCLUDED.aqi,
    fetched_at = now(),
    expires_at = EXCLUDED.expires_at;

-- ==========================================================
-- 5. RECOMMENDATION HISTORY (Sample entries)
-- ==========================================================

INSERT INTO public.recommendation_history (user_id, location_id, latitude, longitude, location_label, risk_level, risk_score, environmental_snapshot, recommendations, category, model_used, generation_time_ms)
VALUES
    -- Priya: High risk in Chennai
    (
        'd6d7082b-e295-44d3-8868-5e2a5712b006',
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        13.0827,
        80.2707,
        'Home - Chennai',
        'high',
        78.5,
        '{
            "temperature_c": 42.5,
            "feels_like_c": 48.2,
            "humidity_pct": 55,
            "uv_index": 11,
            "wind_speed_kmh": 12,
            "aqi": 156,
            "heat_index": 51.3
        }'::jsonb,
        '[
            {"category": "hydration", "severity": "high", "title": "Increase Water Intake", "description": "Drink at least 3-4 liters of water today. Add electrolytes if spending time outdoors.", "icon": "💧"},
            {"category": "activity", "severity": "high", "title": "Avoid Outdoor Exercise", "description": "Current conditions are unsafe for outdoor physical activity. Consider indoor alternatives.", "icon": "🏃"},
            {"category": "clothing", "severity": "moderate", "title": "Wear Light Clothing", "description": "Opt for loose-fitting, light-colored cotton or moisture-wicking fabrics.", "icon": "👕"},
            {"category": "health", "severity": "high", "title": "Monitor for Heat Exhaustion", "description": "Watch for dizziness, nausea, or excessive sweating. Seek shade immediately if symptoms appear.", "icon": "🏥"}
        ]'::jsonb,
        'general',
        'gemini-2.0-flash',
        1250
    ),
    -- Rajan: Extreme risk in Delhi (outdoor worker)
    (
        '27cfaaf8-f19e-42a3-8384-ab2f96fb312a',
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        28.6139,
        77.2090,
        'Construction Site - New Delhi',
        'extreme',
        94.2,
        '{
            "temperature_c": 44.8,
            "feels_like_c": 52.1,
            "humidity_pct": 30,
            "uv_index": 12,
            "wind_speed_kmh": 8,
            "aqi": 210,
            "heat_index": 55.7
        }'::jsonb,
        '[
            {"category": "health", "severity": "extreme", "title": "CRITICAL: Heat Stroke Risk", "description": "Conditions are extremely dangerous for outdoor work. Take mandatory breaks every 20 minutes in shade.", "icon": "🚨"},
            {"category": "hydration", "severity": "extreme", "title": "Emergency Hydration Protocol", "description": "Drink 500ml water every 20 minutes. Use ORS (Oral Rehydration Salts). Avoid caffeinated drinks.", "icon": "💧"},
            {"category": "activity", "severity": "extreme", "title": "Reduce Work Intensity", "description": "Shift heavy tasks to early morning (before 10 AM) or evening (after 5 PM).", "icon": "⏰"},
            {"category": "travel", "severity": "high", "title": "Seek Air-Conditioned Transport", "description": "Use AC buses or metro when commuting. Avoid walking in direct sunlight.", "icon": "🚌"}
        ]'::jsonb,
        'general',
        'gemini-2.0-flash',
        980
    )
ON CONFLICT (id) DO NOTHING;

-- ==========================================================
-- 6. AI CHAT HISTORY (Sample conversation)
-- ==========================================================

DO $$
DECLARE
    session_uuid UUID := 'dddddddd-dddd-dddd-dddd-dddddddddddd';
BEGIN
    INSERT INTO public.ai_chat_history (user_id, session_id, role, message, context, model_used, tokens_used, latency_ms, created_at)
    VALUES
        -- Priya asks about jogging
        (
            'd6d7082b-e295-44d3-8868-5e2a5712b006',
            session_uuid,
            'user',
            'Is it safe to go jogging right now?',
            NULL,
            NULL,
            NULL,
            NULL,
            now() - interval '2 hours'
        ),
        (
            'd6d7082b-e295-44d3-8868-5e2a5712b006',
            session_uuid,
            'assistant',
            'Based on current conditions in Chennai, I strongly advise against outdoor jogging right now. Here''s why:

🌡️ **Temperature**: 42.5°C (feels like 48.2°C)
☀️ **UV Index**: 11 (Extreme)
💨 **Air Quality**: 156 AQI (Unhealthy)

**Risk Level: HIGH (78.5/100)**

The combination of extreme heat, high UV radiation, and poor air quality makes outdoor exercise dangerous. You could experience:
- Heat exhaustion or heat stroke
- Sunburn within 10-15 minutes
- Respiratory irritation from poor air quality

**Safer alternatives:**
1. 🏋️ Indoor gym or home workout
2. 🏊 Swimming pool (if available)
3. 🌅 Wait until after 6 PM when temperatures drop to ~35°C
4. 🌄 Early morning jog before 6 AM tomorrow

Stay safe! 💪',
            '{
                "location": {"lat": 13.0827, "lng": 80.2707, "label": "Chennai"},
                "weather": {"temperature_c": 42.5, "feels_like_c": 48.2, "humidity_pct": 55, "uv_index": 11},
                "air_quality": {"aqi": 156},
                "risk_level": "high",
                "risk_score": 78.5
            }'::jsonb,
            'gemini-2.0-flash',
            385,
            1450,
            now() - interval '2 hours' + interval '3 seconds'
        ),
        -- Follow-up question
        (
            'd6d7082b-e295-44d3-8868-5e2a5712b006',
            session_uuid,
            'user',
            'What time would be safest for outdoor exercise today?',
            NULL,
            NULL,
            NULL,
            NULL,
            now() - interval '1 hour 55 minutes'
        ),
        (
            'd6d7082b-e295-44d3-8868-5e2a5712b006',
            session_uuid,
            'assistant',
            'Looking at today''s hourly forecast for Chennai, here are the safest windows for outdoor exercise:

## ✅ Recommended Windows

### 🌅 Early Morning (5:30 AM - 7:00 AM)
- Temperature: ~30-32°C
- UV Index: 1-3 (Low)
- Risk Level: **Low to Moderate**
- Best option if you want a longer session

### 🌆 Evening (6:30 PM - 7:30 PM)
- Temperature: ~34-36°C
- UV Index: 1-2 (Low)
- Risk Level: **Moderate**
- Still warm but manageable

## ❌ Avoid
- 10:00 AM to 5:00 PM (Peak heat, UV index > 8)

## 💡 Tips for your workout:
1. Carry at least 1L water
2. Wear sunscreen (SPF 50+) even in the evening
3. Choose shaded routes (parks with tree cover)
4. Stop immediately if you feel dizzy or nauseous

Would you like me to suggest some shaded jogging routes near your location?',
            '{
                "location": {"lat": 13.0827, "lng": 80.2707, "label": "Chennai"},
                "weather": {"temperature_c": 42.5, "feels_like_c": 48.2, "humidity_pct": 55},
                "risk_level": "high",
                "risk_score": 78.5
            }'::jsonb,
            'gemini-2.0-flash',
            512,
            1820,
            now() - interval '1 hour 55 minutes' + interval '4 seconds'
        )
    ON CONFLICT (id) DO NOTHING;
END
$$;

-- ==========================================================
-- 7. SAMPLE REPORTS
-- ==========================================================

INSERT INTO public.reports (user_id, title, report_type, location_label, latitude, longitude, content, summary, is_public)
VALUES
    (
        '3f887730-007a-44f2-a1a7-b6068dcf0a9f',
        'Hyderabad Daily Heat Summary - July 6, 2026',
        'daily_summary',
        'Hyderabad',
        17.3850,
        78.4867,
        '{
            "date": "2026-07-06",
            "peak_temperature_c": 41.2,
            "min_temperature_c": 28.5,
            "avg_humidity_pct": 45,
            "avg_risk_level": "high",
            "peak_risk_score": 82,
            "total_alerts": 3,
            "recommendations_given": 127,
            "affected_zones": ["Old City", "Secunderabad", "Kukatpally"],
            "hourly_summary": [
                {"hour": "06:00", "temp_c": 29, "risk": "low"},
                {"hour": "09:00", "temp_c": 34, "risk": "moderate"},
                {"hour": "12:00", "temp_c": 40, "risk": "high"},
                {"hour": "15:00", "temp_c": 41, "risk": "very_high"},
                {"hour": "18:00", "temp_c": 37, "risk": "high"},
                {"hour": "21:00", "temp_c": 32, "risk": "moderate"}
            ]
        }'::jsonb,
        'Peak temperature reached 41.2°C in Hyderabad. Old City, Secunderabad, and Kukatpally identified as high-risk zones. 127 personalized recommendations were generated for citizens. 3 heat alerts issued between 11 AM and 4 PM.',
        true
    ),
    (
        '3f887730-007a-44f2-a1a7-b6068dcf0a9f',
        'HEAT ALERT: Extreme Conditions in Hyderabad',
        'heat_alert',
        'Hyderabad',
        17.3850,
        78.4867,
        '{
            "alert_level": "extreme",
            "affected_area": "Hyderabad Metropolitan",
            "duration_hours": 6,
            "start_time": "11:00",
            "end_time": "17:00",
            "peak_temperature_c": 44.5,
            "advisory": "All outdoor activities should be suspended. Municipal cooling centers activated at 12 locations.",
            "cooling_centers": [
                {"name": "Nampally Community Hall", "capacity": 200},
                {"name": "LB Nagar Public Library", "capacity": 100},
                {"name": "Kukatpally Indoor Stadium", "capacity": 500}
            ]
        }'::jsonb,
        'EXTREME heat alert for Hyderabad Metropolitan area. Temperatures expected to reach 44.5°C. All outdoor activities should be suspended for 6 hours (11 AM - 5 PM). 12 cooling centers activated.',
        true
    )
ON CONFLICT (id) DO NOTHING;

-- ==========================================================
-- VERIFICATION QUERIES
-- ==========================================================
-- Run these to verify seed data was inserted correctly:

-- SELECT count(*) AS profiles_count FROM public.profiles;
-- SELECT count(*) AS preferences_count FROM public.user_preferences;
-- SELECT count(*) AS locations_count FROM public.saved_locations;
-- SELECT count(*) AS cache_count FROM public.environmental_cache;
-- SELECT count(*) AS recommendations_count FROM public.recommendation_history;
-- SELECT count(*) AS chat_messages_count FROM public.ai_chat_history;
-- SELECT count(*) AS reports_count FROM public.reports;
