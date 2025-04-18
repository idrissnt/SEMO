"""
Domain exceptions for the user app.

This module contains all domain-specific exceptions used in the user app.
These exceptions represent business rule violations and other domain-specific errors.
"""

from core.domain.exceptions import CoreDomainException

# For backward compatibility


class UserAlreadyExistsException(CoreDomainException):
    """Exception raised when trying to create a user with an email that already exists"""
    def __init__(self, email=None):
        message = f"User with this email already exists: {email}" if email else "User with this email already exists"
        super().__init__(message, "user_already_exists")


class InvalidCredentialsException(CoreDomainException):
    """Exception raised when user credentials are invalid"""
    def __init__(self):
        super().__init__("The email or password you entered is incorrect", "invalid_credentials")

class UserNotFoundException(CoreDomainException):
    """Exception raised when a user is not found"""
    def __init__(self, user_id=None):
        message = f"User not found: {user_id}" if user_id else "User not found"
        super().__init__(message, "user_not_found")


class AuthenticationException(CoreDomainException):
    """Exception raised when there's an authentication error"""
    def __init__(self, message="Authentication error"):
        super().__init__(message, "authentication_error")


class PasswordChangeException(CoreDomainException):
    """Exception raised when there's an error changing password"""
    def __init__(self, message="Error changing password"):
        super().__init__(message, "password_change_error")

class TokenValidationException(CoreDomainException):
    """Exception raised when a token is invalid or expired"""
    def __init__(self, message="Token is invalid or expired"):
        super().__init__(message, "token_validation_error")

class TokenBlacklistedException(CoreDomainException):
    """Exception raised when a token is already blacklisted"""
    def __init__(self, message="Token is already blacklisted"):
        super().__init__(message, "token_blacklisted")


class MissingRefreshTokenException(CoreDomainException):
    """Exception raised when a refresh token is required but not provided"""
    def __init__(self):
        super().__init__("Refresh token is required", "missing_token")
