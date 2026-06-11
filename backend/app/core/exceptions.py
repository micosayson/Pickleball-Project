class AppError(Exception):
    """Base application error."""


class NotFoundError(AppError):
    """Raised when a resource cannot be found."""


class PermissionDeniedError(AppError):
    """Raised when the current principal lacks permission."""


class ConflictError(AppError):
    """Raised when an operation conflicts with current state."""
