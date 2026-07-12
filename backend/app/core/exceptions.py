"""Custom exception classes for centralized error handling."""


class EscapeHeatException(Exception):
    """Base exception for the Escape Heat application."""

    def __init__(self, message: str = "An error occurred", status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)


class NotFoundException(EscapeHeatException):
    """Raised when a requested resource is not found."""

    def __init__(self, message: str = "Resource not found"):
        super().__init__(message=message, status_code=404)


class UnauthorizedException(EscapeHeatException):
    """Raised when authentication fails."""

    def __init__(self, message: str = "Unauthorized"):
        super().__init__(message=message, status_code=401)


class ForbiddenException(EscapeHeatException):
    """Raised when user lacks permission."""

    def __init__(self, message: str = "Forbidden"):
        super().__init__(message=message, status_code=403)


class BadRequestException(EscapeHeatException):
    """Raised when the request payload is invalid."""

    def __init__(self, message: str = "Bad request"):
        super().__init__(message=message, status_code=400)


class ConflictException(EscapeHeatException):
    """Raised when there is a resource conflict (e.g., duplicate email)."""

    def __init__(self, message: str = "Conflict"):
        super().__init__(message=message, status_code=409)
