"""
Exception mapping configuration for the user app.

This module contains mappings between user domain exceptions and their corresponding
HTTP status codes, error codes, and logging levels.
"""
from rest_framework import status

from the_user_app.domain.user_exceptions import (
    UserAlreadyExistsException,
    InvalidCredentialsException,
    PasswordChangeException,
    MissingRefreshTokenException,
    InvalidInputException,
    UserNotFoundException,
    InvalidVerificationCodeException,
    EmailVerificationRequestFailedException,
    PhoneVerificationRequestFailedException,
    PasswordResetRequestFailedException,
    PasswordResetFailedException
)

def get_fully_qualified_name(cls):
    return f"{cls.__module__}.{cls.__name__}"

# Map exception classes to (status_code, error_code, log_level)
USER_EXCEPTION_MAPPING = {
    get_fully_qualified_name(UserAlreadyExistsException): 
        (status.HTTP_409_CONFLICT, 'user_already_exists', 'warning'),
    get_fully_qualified_name(InvalidCredentialsException): 
        (status.HTTP_401_UNAUTHORIZED, 'invalid_credentials', 'warning'),
    get_fully_qualified_name(PasswordChangeException): 
        (status.HTTP_400_BAD_REQUEST, 'password_change_error', 'warning'),
    get_fully_qualified_name(MissingRefreshTokenException): 
        (status.HTTP_400_BAD_REQUEST, 'missing_token', 'warning'),
    get_fully_qualified_name(InvalidInputException): 
        (status.HTTP_400_BAD_REQUEST, 'invalid_input', 'warning'),

    # Verification related exceptions
    get_fully_qualified_name(UserNotFoundException): 
        (status.HTTP_404_NOT_FOUND, 'user_not_found', 'warning'),
    get_fully_qualified_name(InvalidVerificationCodeException): 
        (status.HTTP_400_BAD_REQUEST, 'invalid_verification_code', 'warning'),
    get_fully_qualified_name(EmailVerificationRequestFailedException): 
        (status.HTTP_500_INTERNAL_SERVER_ERROR, 'email_verification_request_failed', 'error'),
    get_fully_qualified_name(PhoneVerificationRequestFailedException): 
        (status.HTTP_500_INTERNAL_SERVER_ERROR, 'phone_verification_request_failed', 'error'),
    get_fully_qualified_name(PasswordResetRequestFailedException): 
        (status.HTTP_500_INTERNAL_SERVER_ERROR, 'password_reset_request_failed', 'error'),
    get_fully_qualified_name(PasswordResetFailedException): 
        (status.HTTP_500_INTERNAL_SERVER_ERROR, 'password_reset_failed', 'error')
}

# Note: The base domain exception (CoreDomainException) is defined in the core app
# and its mapping is defined in core.interface.api.exception_mapping
