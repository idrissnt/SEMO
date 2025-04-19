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
}

# Note: The base domain exception (CoreDomainException) is defined in the core app
# and its mapping is defined in core.interface.api.exception_mapping
