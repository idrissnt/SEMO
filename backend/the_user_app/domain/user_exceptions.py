"""
Domain exceptions for the user app.

This module contains all domain-specific exceptions used in the user app.
These exceptions represent business rule violations and other domain-specific errors.
"""

from core.domain.exceptions import CoreDomainException

# login related exceptions
class InvalidCredentialsException(CoreDomainException):
    """Exception raised when user credentials are invalid"""
    def __init__(self):
        super().__init__("The email or password you entered is incorrect", "invalid_credentials")

class PasswordChangeException(CoreDomainException):
    """Exception raised when there's an error changing password"""
    def __init__(self, message="Error changing password"):
        super().__init__(message, "password_change_error")

# registration related exceptions
class UserAlreadyExistsException(CoreDomainException):
    """Exception raised when trying to create a user with an email that already exists"""
    def __init__(self, email=None):
        message = f"User with this email already exists: {email}" if email else "User with this email already exists"
        super().__init__(message, "user_already_exists")

# token related exceptions
class MissingRefreshTokenException(CoreDomainException):
    """Exception raised when a refresh token is required but not provided"""
    def __init__(self):
        super().__init__("Refresh token is required", "missing_token")
