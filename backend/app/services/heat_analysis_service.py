"""Heat analysis service — live calculations, single weather fetch per call."""

import logging
from datetime import datetime
from typing import Any, Dict

from app.core.exceptions import EscapeHeatException
from app.services.weather_service import WeatherService

logger = logging.getLogger(__name__)


# ── NOAA Rothfusz Heat Index ──────────────────────────────────────────────────

def calculate_heat_index(temp_c: float, humidity: float) -> float:
    """Return NOAA Heat Index in °C given ambient temperature (°C) and RH (%)."""
    t = temp_c * 1.8 + 32.0        # convert to °F
    rh = humidity

    if t < 80.0:
        # Simple Steadman formula below 80 °F
        hi = 0.5 * (t + 61.0 + ((t - 68.0) * 1.2) + (rh * 0.094))
    else:
        # Full Rothfusz regression
        hi = (
            -42.379
            + 2.04901523   * t
            + 10.14333127  * rh
            - 0.22475541   * t  * rh
            - 0.00683783   * t  * t
            - 0.05481717   * rh * rh
            + 0.00122874   * t  * t  * rh
            + 0.00085282   * t  * rh * rh   # ← correct coefficient (not 0.0085282)
            - 0.00000199   * t  * t  * rh * rh
        )
        # Adjustment: low-humidity dry air
        if rh < 13.0 and 80.0 <= t <= 112.0:
            adj = ((13.0 - rh) / 4.0) * ((17.0 - abs(t - 95.0)) / 17.0) ** 0.5
            hi -= adj
        # Adjustment: high-humidity moist air
        elif rh > 85.0 and 80.0 <= t <= 87.0:
            adj = ((rh - 85.0) / 10.0) * ((87.0 - t) / 5.0)
            hi += adj

    hi_c = (hi - 32.0) / 1.8      # back to °C
    return round(max(hi_c, temp_c), 1)


# ── Risk score from pre-fetched weather dict ──────────────────────────────────

def _risk_from_weather(weather: Dict[str, Any], lat: float) -> Dict[str, Any]:
    """Pure function — derive risk score from a weather dict (no network calls)."""
    temp = weather["temperature"]
    rh   = weather["humidity"]
    uv   = weather["uv_index"]
    aqi  = weather["air_quality_index"]

    # Sub-scores (0–100)
    temp_score    = int(min(max((temp - 25.0) / 20.0 * 100.0, 0.0), 100.0))
    humidity_score = int(min(rh, 100))
    uv_score      = int(min(uv * 10.0, 100.0))
    aqi_score     = int(min(aqi / 3.0, 100.0))

    # Urban Heat Island heuristic (lat-based rough urban detection for India)
    is_urban = (
        (12.9 <= abs(lat) <= 13.2)   # Chennai
        or (28.4 <= abs(lat) <= 28.8) # Delhi/Gurgaon
        or (17.3 <= abs(lat) <= 17.5) # Hyderabad
        or (12.9 <= abs(lat) <= 13.1) # Bangalore
        or (18.9 <= abs(lat) <= 19.2) # Mumbai
    )
    uhi_score = 75 if is_urban else 35

    # Weighted composite: Temperature 40 %, Humidity 25 %, UV 15 %, AQI 10 %, UHI 10 %
    score = int(
        temp_score     * 0.40
        + humidity_score * 0.25
        + uv_score       * 0.15
        + aqi_score      * 0.10
        + uhi_score      * 0.10
    )
    score = min(max(score, 0), 100)

    if score <= 25:
        level, category, color, label = "low",      "Safe",           "#22C55E", "Low Heat Risk"
    elif score <= 50:
        level, category, color, label = "moderate", "Caution",        "#EAB308", "Moderate Heat Risk"
    elif score <= 75:
        level, category, color, label = "high",     "Extreme Caution","#F97316", "High Heat Risk"
    else:
        level, category, color, label = "extreme",  "Danger",         "#DC2626", "Extreme Heat Risk"

    return {
        "location": weather["location"],
        "score": score,
        "level": level,
        "category": category,
        "color": color,
        "label": label,
        "factors": {
            "temperature_score":      temp_score,
            "humidity_score":         humidity_score,
            "uv_score":               uv_score,
            "air_quality_score":      aqi_score,
            "urban_heat_island_score": uhi_score,
        },
        "scale": {
            "min": 0,
            "max": 100,
            "thresholds": {
                "low":      {"min": 0,  "max": 25,  "color": "#22C55E"},
                "moderate": {"min": 26, "max": 50,  "color": "#EAB308"},
                "high":     {"min": 51, "max": 75,  "color": "#F97316"},
                "extreme":  {"min": 76, "max": 100, "color": "#DC2626"},
            },
        },
        "timestamp": weather["timestamp"],
    }


# ── Service class ─────────────────────────────────────────────────────────────

class HeatAnalysisService:
    """Deterministic heat risk calculations powered by live Open-Meteo weather."""

    def __init__(self) -> None:
        self._weather_service = WeatherService()

    async def _fetch_weather(self, lat: float, lon: float) -> Dict[str, Any]:
        """Fetch live weather with a user-friendly error wrapper."""
        try:
            return await self._weather_service.get_current_weather(lat, lon)
        except Exception as exc:
            logger.error(f"Weather fetch failed: {exc}")
            raise EscapeHeatException(
                "Cannot retrieve weather data — upstream service unavailable.",
                status_code=503,
            ) from exc

    async def get_risk_score(self, lat: float, lon: float) -> Dict[str, Any]:
        """Fetch live weather then compute the heat risk score."""
        weather = await self._fetch_weather(lat, lon)
        return _risk_from_weather(weather, lat)

    async def get_analysis(self, lat: float, lon: float) -> Dict[str, Any]:
        """Fetch live weather ONCE then produce the full heat analysis report."""
        weather = await self._fetch_weather(lat, lon)   # single network call
        risk    = _risk_from_weather(weather, lat)       # pure math, no HTTP

        temp = weather["temperature"]
        rh   = weather["humidity"]
        uv   = weather["uv_index"]
        aqi  = weather["air_quality_index"]
        hi   = calculate_heat_index(temp, rh)

        factors_raw = risk["factors"]

        # Impact labels
        def temp_impact(t):
            return "low" if t < 28 else "moderate" if t < 35 else "high" if t < 40 else "very_high"
        def rh_impact(h):
            return "low" if h < 40 else "moderate" if h < 65 else "high"
        def uv_impact(u):
            return "low" if u < 3 else "moderate" if u < 6 else "high" if u < 8 else "very_high"
        def aqi_impact(a):
            return "low" if a <= 50 else "moderate" if a <= 100 else "high"

        uv_text = (
            "minimal" if uv < 3 else
            "moderate — wear SPF 30+" if uv < 6 else
            "high — protection required" if uv < 8 else
            "extremely high — sunburn in ~15 min"
        )

        contributing_factors = [
            {
                "factor": "Temperature",
                "value": f"{temp}°C",
                "impact": temp_impact(temp),
                "description": (
                    f"Ambient temperature is {'comfortable' if temp < 26 else 'warm' if temp < 33 else 'high' if temp < 39 else 'extremely high'} "
                    f"(safe threshold ≤ 25°C)."
                ),
            },
            {
                "factor": "Humidity",
                "value": f"{rh}%",
                "impact": rh_impact(rh),
                "description": (
                    "High humidity suppresses evaporative sweat-cooling." if rh >= 60
                    else "Humidity levels allow effective perspiration."
                ),
            },
            {
                "factor": "UV Index",
                "value": str(uv),
                "impact": uv_impact(uv),
                "description": f"UV exposure risk is {uv_text}.",
            },
            {
                "factor": "Air Quality",
                "value": f"AQI {aqi}",
                "impact": aqi_impact(aqi),
                "description": f"Air quality is {weather['air_quality_label'].lower()}.",
            },
            {
                "factor": "Urban Heat Island",
                "value": "+3°C" if factors_raw["urban_heat_island_score"] > 50 else "+1°C",
                "impact": "moderate" if factors_raw["urban_heat_island_score"] > 50 else "low",
                "description": (
                    "Dense urban surface materials trap and re-emit solar radiation, raising local temperature."
                    if factors_raw["urban_heat_island_score"] > 50
                    else "Vegetation cover moderates local thermal amplification."
                ),
            },
        ]

        rec_map = {
            "low":      ["Stay hydrated.", "Apply SPF 15+ if outdoors.", "Enjoy outdoor activities safely."],
            "moderate": ["Drink 2+ litres of water today.", "Rest in the shade regularly.", "Avoid peak sun 11 AM–3 PM for strenuous activity."],
            "high":     ["Limit strenuous outdoor work to early morning.", "Drink 250 ml water every 30 min.", "Wear light, loose-fitting cotton clothing.", "Seek shade or air-conditioned spaces."],
            "extreme":  ["Stay indoors between 10 AM and 5 PM.", "Drink 3–4 litres of water throughout the day.", "Never leave children or pets in parked vehicles.", "Check on elderly and vulnerable neighbours."],
        }

        summary = (
            f"Current conditions pose a {risk['level'].upper()} heat risk. "
            f"Temperature is {temp}°C with relative humidity at {rh}%, producing a calculated "
            f"Heat Index of {hi}°C. UV exposure is {uv_impact(uv)} and air quality is "
            f"{weather['air_quality_label'].lower()} (AQI {aqi}). "
        )
        summary += (
            "Immediate precautions are advised to prevent heat exhaustion or stroke."
            if risk["level"] in ("high", "extreme")
            else "Conditions are manageable with standard outdoor safety precautions."
        )

        return {
            "location":              risk["location"],
            "heat_index":            hi,
            "risk_level":            risk["level"],
            "risk_category":         risk["category"],
            "risk_score":            risk["score"],
            "contributing_factors":  contributing_factors,
            "analysis_summary":      summary,
            "recommendations_summary": rec_map.get(risk["level"], rec_map["moderate"]),
            "timestamp":             risk["timestamp"],
        }
