"""
Core exception mapping configuration.

This module contains base mappings between core domain exceptions and their corresponding
HTTP status codes, error codes, and logging levels.
"""
from rest_framework import status

from core.domain.exceptions import CoreDomainException

def get_fully_qualified_name(cls):
    return f"{cls.__module__}.{cls.__name__}"

# Map exception classes to (status_code, error_code, log_level)
CORE_EXCEPTION_MAPPING = {
    get_fully_qualified_name(CoreDomainException): 
        (status.HTTP_400_BAD_REQUEST, 'domain_error', 'error'),
}

# Default mapping for unhandled exceptions
DEFAULT_EXCEPTION_MAPPING = (status.HTTP_500_INTERNAL_SERVER_ERROR, 'server_error', 'error')
