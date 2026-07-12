"""Weather service with live Open-Meteo API integration."""

import asyncio
import logging
from datetime import datetime
from typing import Any, Dict

import httpx

from app.core.exceptions import EscapeHeatException

logger = logging.getLogger(__name__)



def get_wind_direction_compass(deg: float) -> str:
    """Convert wind direction in degrees to a compass label."""
    directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    val = int((deg / 22.5) + 0.5)
    return directions[val % 16]


def get_aqi_label(aqi: int) -> str:
    """Get the air quality health label from US EPA AQI values."""
    if aqi <= 50:
        return "Good"
    elif aqi <= 100:
        return "Moderate"
    elif aqi <= 150:
        return "Unhealthy for Sensitive Groups"
    elif aqi <= 200:
        return "Unhealthy"
    elif aqi <= 300:
        return "Very Unhealthy"
    else:
        return "Hazardous"


def map_wmo_code(code: int) -> Dict[str, str]:
    """Map WMO weather code to standard icon names and descriptions."""
    # Maps WMO codes from Open-Meteo to app-specific icons and descriptions
    mapping = {
        0: {"icon": "sunny", "desc": "Clear Sky"},
        1: {"icon": "sunny", "desc": "Mainly Clear"},
        2: {"icon": "partly-cloudy", "desc": "Partly Cloudy"},
        3: {"icon": "cloudy", "desc": "Overcast"},
        45: {"icon": "hazy", "desc": "Foggy"},
        48: {"icon": "hazy", "desc": "Depositing Rime Fog"},
        51: {"icon": "cloudy-rain", "desc": "Light Drizzle"},
        53: {"icon": "cloudy-rain", "desc": "Moderate Drizzle"},
        55: {"icon": "cloudy-rain", "desc": "Dense Drizzle"},
        61: {"icon": "cloudy-rain", "desc": "Slight Rain"},
        63: {"icon": "cloudy-rain", "desc": "Moderate Rain"},
        65: {"icon": "cloudy-rain", "desc": "Heavy Rain"},
        80: {"icon": "cloudy-rain", "desc": "Slight Rain Showers"},
        81: {"icon": "cloudy-rain", "desc": "Moderate Rain Showers"},
        82: {"icon": "cloudy-rain", "desc": "Violent Rain Showers"},
        95: {"icon": "thunderstorm", "desc": "Thunderstorm"},
        96: {"icon": "thunderstorm", "desc": "Thunderstorm with Slight Hail"},
        99: {"icon": "thunderstorm", "desc": "Thunderstorm with Heavy Hail"},
    }
    return mapping.get(code, {"icon": "partly-cloudy", "desc": "Partly Cloudy"})


class WeatherService:
    """Retrieves live weather data from Open-Meteo APIs with retry resilience."""

    # Separate connect vs. read timeouts: TLS handshake gets 20 s, reads 15 s
    _TIMEOUT = httpx.Timeout(connect=20.0, read=15.0, write=5.0, pool=5.0)
    _MAX_RETRIES = 3

    def __init__(self) -> None:
        self.weather_url = "https://api.open-meteo.com/v1/forecast"
        self.aqi_url     = "https://air-quality-api.open-meteo.com/v1/air-quality"

    @staticmethod
    async def _get_with_retry(
        client: httpx.AsyncClient, url: str, params: dict, label: str = ""
    ) -> httpx.Response:
        """GET with up to _MAX_RETRIES attempts and exponential back-off."""
        last_exc: Exception = RuntimeError("No attempts made")
        for attempt in range(1, WeatherService._MAX_RETRIES + 1):
            try:
                resp = await client.get(url, params=params)
                resp.raise_for_status()
                return resp
            except Exception as exc:
                last_exc = exc
                wait = 2 ** (attempt - 1)   # 1 s, 2 s, 4 s
                logger.warning(
                    f"{label} attempt {attempt}/{WeatherService._MAX_RETRIES} failed "
                    f"({type(exc).__name__}) — retrying in {wait}s"
                )
                await asyncio.sleep(wait)
        raise last_exc

    async def get_current_weather(self, lat: float, lon: float) -> Dict[str, Any]:
        """Get current live weather and AQI conditions for a location."""
        # Round coordinates to 3 decimals to improve cache hits and normalise
        r_lat, r_lon = round(lat, 3), round(lon, 3)
        logger.info(f"Fetching current weather for lat={r_lat}, lon={r_lon}")

        weather_params = {
            "latitude": r_lat,
            "longitude": r_lon,
            "current": ",".join([
                "temperature_2m",
                "relative_humidity_2m",
                "apparent_temperature",
                "wind_speed_10m",
                "wind_direction_10m",
                "uv_index",
                "surface_pressure",
                "visibility",
                "dew_point_2m",
                "weather_code",
            ]),
            "timezone": "auto",
        }

        aqi_params = {
            "latitude": r_lat,
            "longitude": r_lon,
            "current": "us_aqi",
            "timezone": "auto",
        }

        async with httpx.AsyncClient(timeout=self._TIMEOUT) as client:
            # ── Primary: weather fetch (required, retried) ───────────────────
            try:
                weather_res = await self._get_with_retry(
                    client, self.weather_url, weather_params, label="Weather"
                )
                w_data = weather_res.json()
            except Exception as e:
                logger.error(f"Weather fetch failed after {self._MAX_RETRIES} attempts: {e}")
                raise EscapeHeatException("Weather service unavailable", status_code=503) from e

            # ── Secondary: AQI fetch (optional, retried, graceful fallback) ──
            aqi_val = 50   # default: "Moderate" if AQI endpoint is unreachable
            try:
                aqi_res = await self._get_with_retry(
                    client, self.aqi_url, aqi_params, label="AQI"
                )
                a_data  = aqi_res.json()
                aqi_val = int(a_data.get("current", {}).get("us_aqi", 50))
            except Exception as e:
                logger.warning(f"AQI fetch failed after retries (defaulting AQI=50): {e}")

        current_w = w_data.get("current", {})

        wmo_mapping = map_wmo_code(current_w.get("weather_code", 0))

        return {
            "location": {
                "name": f"Location ({r_lat}, {r_lon})",
                "state": "Live",
                "country": w_data.get("timezone", "Global"),
                "lat": r_lat,
                "lon": r_lon,
            },
            "temperature": current_w.get("temperature_2m", 0.0),
            "feels_like": current_w.get("apparent_temperature", 0.0),
            "humidity": int(current_w.get("relative_humidity_2m", 0)),
            "wind_speed": current_w.get("wind_speed_10m", 0.0),
            "wind_direction": get_wind_direction_compass(current_w.get("wind_direction_10m", 0.0)),
            "uv_index": current_w.get("uv_index", 0.0),
            "air_quality_index": aqi_val,
            "air_quality_label": get_aqi_label(aqi_val),
            "description": wmo_mapping["desc"],
            "icon": wmo_mapping["icon"],
            "pressure": current_w.get("surface_pressure"),
            "visibility": current_w.get("visibility", 0.0) / 1000.0 if current_w.get("visibility") else None,  # Convert m to km
            "dew_point": current_w.get("dew_point_2m"),
            "timestamp": current_w.get("time", datetime.utcnow().isoformat()) + "Z",
        }

    async def get_forecast(self, lat: float, lon: float, days: int = 5) -> Dict[str, Any]:
        """Get multi-day forecast from Open-Meteo API."""
        r_lat, r_lon = round(lat, 3), round(lon, 3)
        logger.info(f"Fetching {days}-day forecast for lat={r_lat}, lon={r_lon}")

        params = {
            "latitude": r_lat,
            "longitude": r_lon,
            "daily": ",".join([
                "temperature_2m_max",
                "temperature_2m_min",
                "relative_humidity_2m_mean",
                "uv_index_max",
                "wind_speed_10m_max",
                "precipitation_probability_max",
                "weather_code",
            ]),
            "timezone": "auto",
        }

        async with httpx.AsyncClient(timeout=10.0) as client:
            try:
                res = await client.get(self.weather_url, params=params)
                res.raise_for_status()
                data = res.json()
            except Exception as e:
                logger.error(f"Failed to fetch forecast: {e}")
                raise

        daily = data.get("daily", {})
        forecast_days = []

        # Parse daily lists into sequential objects
        for i in range(min(days, len(daily.get("time", [])))):
            wmo_mapping = map_wmo_code(daily.get("weather_code", [0])[i])
            forecast_days.append(
                {
                    "date": daily.get("time", [])[i],
                    "temp_max": daily.get("temperature_2m_max", [0.0])[i],
                    "temp_min": daily.get("temperature_2m_min", [0.0])[i],
                    "humidity": int(daily.get("relative_humidity_2m_mean", [0])[i]),
                    "uv_index": daily.get("uv_index_max", [0.0])[i],
                    "wind_speed": daily.get("wind_speed_10m_max", [0.0])[i],
                    "description": wmo_mapping["desc"],
                    "icon": wmo_mapping["icon"],
                    "precipitation_chance": int(daily.get("precipitation_probability_max", [0])[i]),
                }
            )

        return {
            "location": {
                "name": f"Location ({r_lat}, {r_lon})",
                "state": "Live",
                "country": data.get("timezone", "Global"),
                "lat": r_lat,
                "lon": r_lon,
            },
            "days": forecast_days,
        }
