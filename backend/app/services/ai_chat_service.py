"""AI Chat service with live Google Gemini API integration (google-genai SDK)."""

import asyncio
import json
import logging
from datetime import datetime
from typing import Any, Dict, Optional

from google import genai
from google.genai import types

from app.config import settings

logger = logging.getLogger(__name__)


class AIChatService:
    """Conversational AI assistant powered by Google Gemini 2.0 Flash."""

    def __init__(self) -> None:
        self.api_key = settings.GEMINI_API_KEY
        self.client: Optional[genai.Client] = None

        if not self.api_key or self.api_key == "mock-gemini-key":
            logger.warning("GEMINI_API_KEY is not set — falling back to simulated responses.")
        else:
            try:
                self.client = genai.Client(api_key=self.api_key)
                logger.info("Gemini AI service (google-genai SDK) successfully initialized.")
            except Exception as exc:
                logger.error(f"Failed to initialize Gemini AI client: {exc}")
                self.client = None

    # ──────────────────────────────────────────────────────────────────────────
    # Public API
    # ──────────────────────────────────────────────────────────────────────────

    async def chat(
        self,
        message: str,
        context: Optional[Dict[str, Any]] = None,
        user: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """Process a user query using live Gemini, with full environmental context."""
        if not self.client:
            return self._fallback_response(message, context)

        # Build context strings
        weather_ctx = self._build_weather_context(context)
        risk_ctx = self._build_risk_context(context)
        profile_ctx = self._build_user_context(user)

        # System instruction — passed separately
        system_instruction = (
            "You are Escape AI, the intelligent heat-safety advisor inside the Escape Heat platform. "
            "Help citizens make safer daily decisions under heatwave conditions. "
            "Be empathetic, concise, and science-grounded. "
            "RULES:\n"
            "1. Only advise on heat safety, hydration, cooling strategies, and heat-illness prevention.\n"
            "2. Never predict future weather — only interpret current live readings.\n"
            "3. Tailor advice for vulnerable profiles (elderly, asthma, diabetes, children) when stated.\n"
            "4. Write in clean markdown with headings and short bullet points.\n"
            "5. Return ONLY valid JSON in this exact schema:\n"
            '{"response": "<markdown text>", '
            '"suggested_questions": ["<q1>", "<q2>", "<q3>"]}'
        )

        # User-visible prompt (includes injected context)
        user_prompt = (
            "--- LIVE ENVIRONMENTAL CONDITIONS ---\n"
            f"{weather_ctx}\n"
            "--- HEAT RISK ASSESSMENT ---\n"
            f"{risk_ctx}\n"
            "--- USER PROFILE ---\n"
            f"{profile_ctx}\n"
            "--- USER QUERY ---\n"
            f"{message}"
        )

        try:
            loop = asyncio.get_event_loop()
            response = await loop.run_in_executor(
                None,
                lambda: self.client.models.generate_content(
                    model="gemini-2.0-flash-lite",
                    contents=user_prompt,
                    config=types.GenerateContentConfig(
                        system_instruction=system_instruction,
                        response_mime_type="application/json",
                        temperature=0.35,
                        max_output_tokens=1024,
                    ),
                ),
            )

            raw = response.text.strip()
            # Strip markdown code fences if model wraps the JSON
            if raw.startswith("```"):
                raw = raw.split("```")[1]
                if raw.startswith("json"):
                    raw = raw[4:]
            parsed = json.loads(raw)

            return {
                "response": parsed.get("response", ""),
                "sources": [
                    "Open-Meteo live meteorology",
                    "US EPA Air Quality Index",
                    "WHO / NDMA Heat-Health Guidelines",
                    "Escape Heat Risk Engine",
                ],
                "suggested_questions": parsed.get("suggested_questions", []),
                "timestamp": datetime.utcnow().isoformat() + "Z",
            }

        except Exception as exc:
            logger.error(f"Gemini API call failed: {exc!r} — using fallback response.")
            return self._fallback_response(message, context)

    # ──────────────────────────────────────────────────────────────────────────
    # Private helpers
    # ──────────────────────────────────────────────────────────────────────────

    @staticmethod
    def _build_weather_context(context: Optional[Dict[str, Any]]) -> str:
        if not context:
            return "No live weather data available."
        w = context.get("weather", {})
        if not w:
            return "No live weather data available."
        return (
            f"- Temperature: {w.get('temperature')}°C\n"
            f"- Feels-Like: {w.get('feels_like')}°C\n"
            f"- Humidity: {w.get('humidity')}%\n"
            f"- UV Index: {w.get('uv_index')}\n"
            f"- AQI: {w.get('air_quality_index')} ({w.get('air_quality_label')})\n"
            f"- Condition: {w.get('description')}"
        )

    @staticmethod
    def _build_risk_context(context: Optional[Dict[str, Any]]) -> str:
        if not context:
            return "No risk assessment available."
        r = context.get("risk", {})
        if not r:
            return "No risk assessment available."
        return (
            f"- Risk Score: {r.get('score')}/100\n"
            f"- Risk Level: {str(r.get('level', '')).upper()} ({r.get('category')})\n"
            f"- Heat Index Label: {r.get('label')}"
        )

    @staticmethod
    def _build_user_context(user: Optional[Dict[str, Any]]) -> str:
        if not user:
            return "Anonymous user — apply general-population guidelines."
        prefs = user.get("preferences", {})
        return (
            f"- Name: {user.get('full_name', 'Citizen')}\n"
            f"- Health Conditions: {prefs.get('health_conditions', 'None reported')}\n"
            f"- Age Group: {prefs.get('age_group', 'General Adult')}"
        )

    @staticmethod
    def _fallback_response(
        message: str, context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Return a safe, rule-based response when Gemini is offline."""
        temp = 35.0
        risk_level = "moderate"
        if context:
            temp = context.get("weather", {}).get("temperature", 35.0)
            risk_level = context.get("risk", {}).get("level", "moderate")

        advice = {
            "low": "Conditions are safe. Stay hydrated and apply sunscreen if outdoors.",
            "moderate": (
                "## Moderate Heat Advisory\n"
                "- Drink **2+ litres** of water today.\n"
                "- Rest in the shade regularly.\n"
                "- Avoid peak sun hours (11 AM – 3 PM) for strenuous activity."
            ),
            "high": (
                "## High Heat Warning\n"
                "- Limit outdoor exertion — move heavy work to early morning.\n"
                "- Drink **250 ml of water every 30 minutes**.\n"
                "- Wear light, loose-fitting cotton clothing.\n"
                "- Seek air-conditioned or shaded spaces."
            ),
            "extreme": (
                "## Extreme Heat Danger\n"
                "- **Stay indoors** between 10 AM and 5 PM.\n"
                "- Drink **3–4 litres** of water throughout the day.\n"
                "- Never leave children or pets in parked vehicles.\n"
                "- Check on elderly neighbours and vulnerable individuals."
            ),
        }.get(risk_level, "Stay hydrated and avoid direct sun exposure.")

        return {
            "response": (
                f"> **Escape AI is in offline mode.** Live temperature: **{temp}°C** | "
                f"Risk: **{risk_level.upper()}**\n\n{advice}"
            ),
            "sources": ["Escape Heat Local Safety Rules"],
            "suggested_questions": [
                "What are symptoms of heat exhaustion?",
                "How does high humidity affect my risk?",
                "Where can I find cooling centers nearby?",
            ],
            "timestamp": datetime.utcnow().isoformat() + "Z",
        }
