"""Mock user activity history data."""

MOCK_HISTORY = [
    {
        "id": "hist_001",
        "action": "heat_check",
        "description": "Checked heat analysis for Chennai Central",
        "location": "Chennai Central",
        "timestamp": "2024-06-15T14:30:00Z",
        "metadata": {"risk_score": 87, "temperature": 38.5},
    },
    {
        "id": "hist_002",
        "action": "ai_chat",
        "description": "Asked AI: 'Is it safe to go jogging today?'",
        "location": "Chennai",
        "timestamp": "2024-06-15T13:15:00Z",
        "metadata": {"query": "Is it safe to go jogging today?"},
    },
    {
        "id": "hist_003",
        "action": "report_generated",
        "description": "Generated Daily Heat Assessment report",
        "location": "Chennai Central",
        "timestamp": "2024-06-15T12:00:00Z",
        "metadata": {"report_id": "rpt_001"},
    },
    {
        "id": "hist_004",
        "action": "weather_check",
        "description": "Viewed current weather for T. Nagar",
        "location": "T. Nagar, Chennai",
        "timestamp": "2024-06-15T10:45:00Z",
        "metadata": {"temperature": 36.2},
    },
    {
        "id": "hist_005",
        "action": "map_view",
        "description": "Viewed heat map for Chennai metropolitan area",
        "location": "Chennai",
        "timestamp": "2024-06-15T09:30:00Z",
        "metadata": {"zoom_level": 12},
    },
    {
        "id": "hist_006",
        "action": "recommendation_viewed",
        "description": "Viewed personalized heat safety recommendations",
        "location": "Chennai",
        "timestamp": "2024-06-14T16:00:00Z",
        "metadata": {"recommendations_count": 6},
    },
]
