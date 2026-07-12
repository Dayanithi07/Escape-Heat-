"""Mock authentication and security utilities."""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from app.config import settings
from app.mock_data.users import MOCK_USERS

security_scheme = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security_scheme),
) -> dict:
    """Validate the bearer token and return the current mock user.

    Use the token: Bearer mock-jwt-token-escape-heat-2024
    """
    token = credentials.credentials
    if token != settings.MOCK_JWT_TOKEN:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    # Return the first mock user as the authenticated user
    return MOCK_USERS[0]
