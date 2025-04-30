"""
Domain exceptions for the user app.

This module contains all domain-specific exceptions used in the user app.
These exceptions represent business rule violations and other domain-specific errors.

For each Exception class, don't forget to add a mapping to USER_EXCEPTION_MAPPING 
in exception_mapping.py. At the time writing this code, the file is located in 
the_user_app/interfaces/api/exception_mapping.py. It may have been moved or renamed.

"""

from core.domain.exceptions import CoreDomainException

class InvalidInputException(CoreDomainException):
    """Exception raised when invalid input is provided"""
    def __init__(self, message="Invalid input provided"):
        self.errors = None
        
        # If message is a dictionary (like serializer.errors), store it separately
        if isinstance(message, dict):
            self.errors = message
            message = "Invalid input provided"
            
        super().__init__(message, "invalid_input")
        
    def __str__(self):
        if self.errors:
            return "Invalid input provided"
        return super().__str__()

# login related exceptions
class InvalidCredentialsException(CoreDomainException):
    """Exception raised when user credentials are invalid"""
    def __init__(self, message="The email or password you entered is incorrect"):
        super().__init__(message, "invalid_credentials")

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
    def __init__(self, message="Refresh token is required"):
        super().__init__(message, "missing_token")

#### verification related exceptions

# user not found
class UserNotFoundException(CoreDomainException):
    """Exception raised when a user is not found"""
    def __init__(self, message="User not found"):
        super().__init__(message, "user_not_found")

# invalid verification code
class InvalidVerificationCodeException(CoreDomainException):
    """Exception raised when a verification code is invalid or expired"""
    def __init__(self, message="Invalid or expired verification code"):
        super().__init__(message, "invalid_verification_code")

# email verification request failed
class EmailVerificationRequestFailedException(CoreDomainException):
    """Exception raised when email verification request fails for any reason"""
    def __init__(self, message="Email verification request failed"):
        super().__init__(message, "email_verification_request_failed")

# phone verification request failed
class PhoneVerificationRequestFailedException(CoreDomainException):
    """Exception raised when phone verification request fails for any reason"""
    def __init__(self, message="Phone verification request failed"):
        super().__init__(message, "phone_verification_request_failed")

# password reset request failed
class PasswordResetRequestFailedException(CoreDomainException):
    """Exception raised when password reset request fails for any reason"""
    def __init__(self, message="Password reset request failed"):
        super().__init__(message, "password_reset_request_failed")

# password reset failed
class PasswordResetFailedException(CoreDomainException):
    """Exception raised when password reset fails for any reason"""
    def __init__(self, message="Password reset failed"):
        super().__init__(message, "password_reset_failed")


