"""
Domain exceptions for the user app.

This module contains all domain-specific exceptions used in the user app.
These exceptions represent business rule violations and other domain-specific errors.
"""

class DomainException(Exception):
    """Base exception for all domain exceptions"""
    def __init__(self, message="A domain error occurred", code=None):
        self.message = message
        self.code = code or self.__class__.__name__.lower()
        super().__init__(self.message)
    
    def __str__(self):
        return self.message


class UserAlreadyExistsException(DomainException):
    """Exception raised when trying to create a user with an email that already exists"""
    def __init__(self, email=None):
        message = f"User with this email already exists: {email}" if email else "User with this email already exists"
        super().__init__(message, "user_already_exists")


class InvalidCredentialsException(DomainException):
    """Exception raised when user credentials are invalid"""
    def __init__(self):
        super().__init__("The email or password you entered is incorrect", "invalid_credentials")


class TokenBlacklistedException(DomainException):
    """Exception raised when a token is already blacklisted"""
    def __init__(self):
        super().__init__("Token is already blacklisted", "token_blacklisted")


class TokenValidationException(DomainException):
    """Exception raised when a token is invalid or expired"""
    def __init__(self, message="Token is invalid or expired"):
        super().__init__(message, "token_validation_error")


class UserNotFoundException(DomainException):
    """Exception raised when a user is not found"""
    def __init__(self, user_id=None):
        message = f"User not found: {user_id}" if user_id else "User not found"
        super().__init__(message, "user_not_found")


class AuthenticationException(DomainException):
    """Exception raised when there's an authentication error"""
    def __init__(self, message="Authentication error"):
        super().__init__(message, "authentication_error")


class PasswordChangeException(DomainException):
    """Exception raised when there's an error changing password"""
    def __init__(self, message="Error changing password"):
        super().__init__(message, "password_change_error")
