"""Mock heat analysis data."""

MOCK_HEAT_ANALYSIS = {
    "location": {
        "name": "Chennai",
        "state": "Tamil Nadu",
        "country": "India",
        "lat": 13.0827,
        "lon": 80.2707,
    },
    "heat_index": 48.5,
    "risk_level": "extreme",
    "risk_category": "Danger",
    "risk_score": 87,
    "contributing_factors": [
        {
            "factor": "Temperature",
            "value": "38.5°C",
            "impact": "high",
            "description": "Well above comfort threshold of 35°C",
        },
        {
            "factor": "Humidity",
            "value": "65%",
            "impact": "high",
            "description": "High humidity reduces body's ability to cool through sweating",
        },
        {
            "factor": "UV Index",
            "value": "9.2",
            "impact": "very_high",
            "description": "Very high UV radiation — sunburn possible in 15 minutes",
        },
        {
            "factor": "Air Quality",
            "value": "AQI 142",
            "impact": "moderate",
            "description": "Unhealthy for sensitive groups",
        },
        {
            "factor": "Urban Heat Island",
            "value": "+3.2°C",
            "impact": "moderate",
            "description": "Dense urban area amplifies ambient temperature",
        },
    ],
    "analysis_summary": "Current conditions pose an EXTREME heat risk. The combination of high temperature (38.5°C), elevated humidity (65%), and very high UV index (9.2) creates dangerous heat stress conditions. The effective heat index of 48.5°C significantly exceeds safe exposure thresholds.",
    "recommendations_summary": [
        "Avoid outdoor activities between 11 AM and 4 PM",
        "Stay in air-conditioned spaces when possible",
        "Drink at least 3-4 liters of water throughout the day",
        "Wear light-colored, loose-fitting clothing",
        "Check on elderly neighbors and vulnerable individuals",
    ],
    "timestamp": "2024-06-15T14:30:00Z",
}

MOCK_RISK_SCORE = {
    "location": {
        "name": "Chennai",
        "state": "Tamil Nadu",
        "country": "India",
        "lat": 13.0827,
        "lon": 80.2707,
    },
    "score": 87,
    "level": "extreme",
    "category": "Danger",
    "color": "#DC2626",
    "label": "Extreme Heat Risk",
    "factors": {
        "temperature_score": 85,
        "humidity_score": 70,
        "uv_score": 92,
        "air_quality_score": 60,
        "urban_heat_island_score": 65,
    },
    "scale": {
        "min": 0,
        "max": 100,
        "thresholds": {
            "low": {"min": 0, "max": 25, "color": "#22C55E"},
            "moderate": {"min": 26, "max": 50, "color": "#EAB308"},
            "high": {"min": 51, "max": 75, "color": "#F97316"},
            "extreme": {"min": 76, "max": 100, "color": "#DC2626"},
        },
    },
    "timestamp": "2024-06-15T14:30:00Z",
}
