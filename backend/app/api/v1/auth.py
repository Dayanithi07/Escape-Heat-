"""Authentication endpoints."""

from fastapi import APIRouter, Depends, status

from app.api.deps import get_auth_service
from app.core.security import get_current_user
from app.schemas.auth import (
    AuthResponse,
    LogoutResponse,
    UserLoginRequest,
    UserRegisterRequest,
    UserResponse,
)
from app.schemas.common import ApiResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/register",
    response_model=ApiResponse[AuthResponse],
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user",
)
async def register(
    payload: UserRegisterRequest,
    auth_service: AuthService = Depends(get_auth_service),
):
    result = await auth_service.register(payload.model_dump())
    return ApiResponse(success=True, message="User registered successfully", data=result)


@router.post(
    "/login",
    response_model=ApiResponse[AuthResponse],
    summary="Login with email and password",
)
async def login(
    payload: UserLoginRequest,
    auth_service: AuthService = Depends(get_auth_service),
):
    result = await auth_service.login(payload.model_dump())
    return ApiResponse(success=True, message="Login successful", data=result)


@router.post(
    "/logout",
    response_model=ApiResponse[LogoutResponse],
    summary="Logout the current user",
)
async def logout(
    current_user: dict = Depends(get_current_user),
    auth_service: AuthService = Depends(get_auth_service),
):
    result = await auth_service.logout(current_user["id"])
    return ApiResponse(success=True, message="Logged out", data=result)


@router.get(
    "/me",
    response_model=ApiResponse[UserResponse],
    summary="Get current user profile",
)
async def get_me(
    current_user: dict = Depends(get_current_user),
    auth_service: AuthService = Depends(get_auth_service),
):
    result = await auth_service.get_current_user(current_user)
    return ApiResponse(success=True, message="User profile retrieved", data=result)
