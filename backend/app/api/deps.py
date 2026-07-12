"""Dependency injection factories for FastAPI."""

from app.repositories.user_repository import UserRepository
from app.repositories.report_repository import ReportRepository
from app.repositories.history_repository import HistoryRepository
from app.services.auth_service import AuthService
from app.services.weather_service import WeatherService
from app.services.heat_analysis_service import HeatAnalysisService
from app.services.recommendation_service import RecommendationService
from app.services.ai_chat_service import AIChatService
from app.services.report_service import ReportService
from app.services.history_service import HistoryService
from app.services.map_service import MapService


# ── Repository singletons ──────────────────────────────────────────
_user_repo = UserRepository()
_report_repo = ReportRepository()
_history_repo = HistoryRepository()


# ── Repository providers ───────────────────────────────────────────
def get_user_repository() -> UserRepository:
    return _user_repo


def get_report_repository() -> ReportRepository:
    return _report_repo


def get_history_repository() -> HistoryRepository:
    return _history_repo


# ── Service providers ──────────────────────────────────────────────
def get_auth_service() -> AuthService:
    return AuthService(user_repository=_user_repo)


def get_weather_service() -> WeatherService:
    return WeatherService()


def get_heat_analysis_service() -> HeatAnalysisService:
    return HeatAnalysisService()


def get_recommendation_service() -> RecommendationService:
    return RecommendationService()


def get_ai_chat_service() -> AIChatService:
    return AIChatService()


def get_report_service() -> ReportService:
    return ReportService(report_repository=_report_repo)


def get_history_service() -> HistoryService:
    return HistoryService(history_repository=_history_repo)


def get_map_service() -> MapService:
    return MapService()
