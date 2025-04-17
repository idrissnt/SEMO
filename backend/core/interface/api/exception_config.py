"""
Exception mapping configuration for API error handling.

This module contains mappings between domain exceptions and their corresponding
HTTP status codes, error codes, and logging levels. This centralized configuration
allows for consistent error handling across the API while maintaining separation
of concerns according to clean architecture principles.
"""
from rest_framework import status

# Map exception classes to (status_code, error_code, log_level)
# Format: 'fully.qualified.ExceptionClass': (status_code, 'error_code', 'log_level')
EXCEPTION_MAPPING = {
    # User domain exceptions
    'the_user_app.domain.exceptions.UserAlreadyExistsException': 
        (status.HTTP_409_CONFLICT, 'user_already_exists', 'warning'),
    'the_user_app.domain.exceptions.InvalidCredentialsException': 
        (status.HTTP_401_UNAUTHORIZED, 'invalid_credentials', 'warning'),
    'the_user_app.domain.exceptions.TokenBlacklistedException': 
        (status.HTTP_400_BAD_REQUEST, 'token_blacklisted', 'warning'),
    'the_user_app.domain.exceptions.TokenValidationException': 
        (status.HTTP_401_UNAUTHORIZED, 'token_validation_error', 'warning'),
    'the_user_app.domain.exceptions.UserNotFoundException': 
        (status.HTTP_404_NOT_FOUND, 'user_not_found', 'warning'),
    'the_user_app.domain.exceptions.AuthenticationException': 
        (status.HTTP_401_UNAUTHORIZED, 'authentication_error', 'warning'),
    'the_user_app.domain.exceptions.PasswordChangeException': 
        (status.HTTP_400_BAD_REQUEST, 'password_change_error', 'warning'),
    
    # Base domain exceptions (fallback for inheritance)
    'the_user_app.domain.exceptions.DomainException': 
        (status.HTTP_400_BAD_REQUEST, 'domain_error', 'error'),
}

# Default mapping for unhandled exceptions
DEFAULT_EXCEPTION_MAPPING = (status.HTTP_500_INTERNAL_SERVER_ERROR, 'server_error', 'error')

def get_exception_mapping(exception):
    """
    Get the status code, error code, and log level for a given exception.
    
    Args:
        exception: The exception instance
        
    Returns:
        Tuple of (status_code, error_code, log_level)
    """
    # Try to find exact match by fully qualified class name
    exception_class_path = f"{exception.__class__.__module__}.{exception.__class__.__name__}"
    if exception_class_path in EXCEPTION_MAPPING:
        return EXCEPTION_MAPPING[exception_class_path]
    
    # Try to find match by parent class
    for class_path, mapping in EXCEPTION_MAPPING.items():
        module_path, class_name = class_path.rsplit('.', 1)
        try:
            module = __import__(module_path, fromlist=[class_name])
            parent_class = getattr(module, class_name)
            if isinstance(exception, parent_class):
                return mapping
        except (ImportError, AttributeError):
            continue
    
    # Return default mapping if no match found
    return DEFAULT_EXCEPTION_MAPPING
