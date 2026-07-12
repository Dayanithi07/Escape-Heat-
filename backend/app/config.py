from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    APP_NAME: str = "Escape Heat"
    APP_VERSION: str = "1.0.0"
    APP_DESCRIPTION: str = "AI-Powered Urban Heat Decision Intelligence Platform"
    DEBUG: bool = True
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:5173"]
    API_V1_PREFIX: str = "/api/v1"

    # External service placeholders (mock — not connected)
    SUPABASE_URL: str = "https://mock.supabase.co"
    SUPABASE_KEY: str = "mock-supabase-key"
    GEMINI_API_KEY: str = "mock-gemini-key"
    WEATHER_API_URL: str = "https://api.open-meteo.com"

    # Mock authentication
    MOCK_JWT_TOKEN: str = "mock-jwt-token-escape-heat-2024"

    model_config = {"env_file": ".env", "case_sensitive": True, "extra": "ignore"}


settings = Settings()
