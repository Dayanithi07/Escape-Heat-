"""Mock reports data."""

MOCK_REPORTS = [
    {
        "id": "rpt_001",
        "title": "Daily Heat Assessment — Chennai Central",
        "report_type": "daily_assessment",
        "location": {
            "name": "Chennai Central",
            "lat": 13.0827,
            "lon": 80.2707,
        },
        "content": {
            "summary": "Chennai Central experienced extreme heat conditions today with temperatures reaching 38.5°C and a heat index of 48.5°C.",
            "sections": [
                {
                    "title": "Temperature Analysis",
                    "body": "Maximum temperature recorded was 38.5°C, which is 3.5°C above the seasonal average. The urban heat island effect contributed an additional 3.2°C.",
                },
                {
                    "title": "Health Impact",
                    "body": "Risk of heat-related illness is very high. Vulnerable populations including elderly, children, and outdoor workers are at significant risk.",
                },
                {
                    "title": "Recommendations",
                    "body": "Authorities should consider opening additional cooling centers and issuing heat wave advisories for the next 48 hours.",
                },
            ],
        },
        "metrics": {
            "max_temperature": 38.5,
            "heat_index": 48.5,
            "risk_score": 87,
            "aqi": 142,
            "uv_index": 9.2,
        },
        "created_at": "2024-06-15T18:00:00Z",
        "status": "completed",
    },
    {
        "id": "rpt_002",
        "title": "Weekly Heat Trend — T. Nagar",
        "report_type": "weekly_trend",
        "location": {
            "name": "T. Nagar, Chennai",
            "lat": 13.0418,
            "lon": 80.2341,
        },
        "content": {
            "summary": "T. Nagar saw a consistent upward trend in daytime temperatures over the past week, with heat index values exceeding danger thresholds on 5 of 7 days.",
            "sections": [
                {
                    "title": "Trend Summary",
                    "body": "Average daily maximum temperature increased from 36.2°C to 39.1°C over the reporting period.",
                },
            ],
        },
        "metrics": {
            "avg_temperature": 37.8,
            "max_heat_index": 46.2,
            "avg_risk_score": 78,
            "days_above_threshold": 5,
        },
        "created_at": "2024-06-14T09:00:00Z",
        "status": "completed",
    },
]
