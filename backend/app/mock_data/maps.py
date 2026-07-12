"""Mock geospatial data for heat zones and points of interest."""

MOCK_HEAT_ZONES = {
    "type": "FeatureCollection",
    "features": [
        {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [
                    [
                        [80.25, 13.05],
                        [80.28, 13.05],
                        [80.28, 13.08],
                        [80.25, 13.08],
                        [80.25, 13.05],
                    ]
                ],
            },
            "properties": {
                "zone_id": "hz_001",
                "name": "Chennai Central",
                "risk_level": "extreme",
                "temperature": 40.2,
                "heat_index": 49.1,
                "color": "#DC2626",
            },
        },
        {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [
                    [
                        [80.22, 13.03],
                        [80.25, 13.03],
                        [80.25, 13.06],
                        [80.22, 13.06],
                        [80.22, 13.03],
                    ]
                ],
            },
            "properties": {
                "zone_id": "hz_002",
                "name": "T. Nagar",
                "risk_level": "high",
                "temperature": 38.1,
                "heat_index": 44.5,
                "color": "#F97316",
            },
        },
        {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [
                    [
                        [80.24, 13.00],
                        [80.27, 13.00],
                        [80.27, 13.03],
                        [80.24, 13.03],
                        [80.24, 13.00],
                    ]
                ],
            },
            "properties": {
                "zone_id": "hz_003",
                "name": "Adyar",
                "risk_level": "moderate",
                "temperature": 36.5,
                "heat_index": 40.2,
                "color": "#EAB308",
            },
        },
        {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [
                    [
                        [80.27, 13.08],
                        [80.30, 13.08],
                        [80.30, 13.11],
                        [80.27, 13.11],
                        [80.27, 13.08],
                    ]
                ],
            },
            "properties": {
                "zone_id": "hz_004",
                "name": "Tondiarpet",
                "risk_level": "extreme",
                "temperature": 41.0,
                "heat_index": 50.3,
                "color": "#DC2626",
            },
        },
        {
            "type": "Feature",
            "geometry": {
                "type": "Polygon",
                "coordinates": [
                    [
                        [80.18, 12.97],
                        [80.21, 12.97],
                        [80.21, 13.00],
                        [80.18, 13.00],
                        [80.18, 12.97],
                    ]
                ],
            },
            "properties": {
                "zone_id": "hz_005",
                "name": "Guindy National Park Area",
                "risk_level": "low",
                "temperature": 34.0,
                "heat_index": 36.8,
                "color": "#22C55E",
            },
        },
    ],
}

MOCK_POINTS_OF_INTEREST = [
    {
        "id": "poi_001",
        "name": "Semmozhi Poonga Botanical Garden",
        "type": "park",
        "lat": 13.0604,
        "lon": 80.2532,
        "address": "Cathedral Rd, Gopalapuram, Chennai",
        "distance_km": 1.2,
    },
    {
        "id": "poi_002",
        "name": "Apollo Hospitals",
        "type": "hospital",
        "lat": 13.0067,
        "lon": 80.2206,
        "address": "21, Greams Lane, Off Greams Rd, Chennai",
        "distance_km": 2.8,
    },
    {
        "id": "poi_003",
        "name": "Marina Beach Cooling Station",
        "type": "cooling_center",
        "lat": 13.0500,
        "lon": 80.2824,
        "address": "Marina Beach Road, Chennai",
        "distance_km": 1.5,
    },
    {
        "id": "poi_004",
        "name": "Corporation Water Station — Central",
        "type": "water_station",
        "lat": 13.0836,
        "lon": 80.2750,
        "address": "Near Central Railway Station, Chennai",
        "distance_km": 0.5,
    },
    {
        "id": "poi_005",
        "name": "Guindy National Park",
        "type": "park",
        "lat": 13.0040,
        "lon": 80.2218,
        "address": "Guindy, Chennai",
        "distance_km": 5.1,
    },
    {
        "id": "poi_006",
        "name": "Government General Hospital",
        "type": "hospital",
        "lat": 13.0774,
        "lon": 80.2744,
        "address": "Park Town, Chennai",
        "distance_km": 0.8,
    },
    {
        "id": "poi_007",
        "name": "Express Avenue Cooling Center",
        "type": "cooling_center",
        "lat": 13.0596,
        "lon": 80.2639,
        "address": "Express Avenue Mall, Royapettah, Chennai",
        "distance_km": 2.0,
    },
]
