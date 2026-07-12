"""Centralized exception handlers registered with the FastAPI app."""

import logging
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError

from app.core.exceptions import EscapeHeatException

logger = logging.getLogger(__name__)


async def escape_heat_exception_handler(
    request: Request, exc: EscapeHeatException
) -> JSONResponse:
    """Handle all custom EscapeHeat exceptions."""
    logger.error(f"EscapeHeatException: {exc.message} | Path: {request.url.path}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "message": exc.message,
                "status_code": exc.status_code,
            },
        },
    )


async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    """Handle Pydantic / request validation errors."""
    logger.warning(f"Validation error: {exc.errors()} | Path: {request.url.path}")
    return JSONResponse(
        status_code=422,
        content={
            "success": False,
            "error": {
                "message": "Validation error",
                "status_code": 422,
                "details": exc.errors(),
            },
        },
    )


async def generic_exception_handler(
    request: Request, exc: Exception
) -> JSONResponse:
    """Catch-all handler for unexpected errors."""
    logger.exception(f"Unhandled exception: {str(exc)} | Path: {request.url.path}")
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "error": {
                "message": "Internal server error",
                "status_code": 500,
            },
        },
    )
