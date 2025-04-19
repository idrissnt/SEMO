"""
Exception mapping configuration for the store app.

This module contains mappings between store domain exceptions and their corresponding
HTTP status codes, error codes, and logging levels.
"""
from rest_framework import status

from store.domain.exceptions import (
    StoreIdRequiredException,
    InvalidUuidException,
    QuerySearchRequiredException,
    AddressRequiredException,
)

def get_fully_qualified_name(cls):
    return f"{cls.__module__}.{cls.__name__}"

# Map exception classes to (status_code, error_code, log_level)
STORE_EXCEPTION_MAPPING = {
    get_fully_qualified_name(InvalidUuidException): 
        (status.HTTP_400_BAD_REQUEST, 'invalid_uuid', 'warning'),
    get_fully_qualified_name(StoreIdRequiredException): 
        (status.HTTP_400_BAD_REQUEST, 'store_id_required', 'warning'),
    get_fully_qualified_name(QuerySearchRequiredException): 
        (status.HTTP_400_BAD_REQUEST, 'query_search_required', 'warning'),
    get_fully_qualified_name(AddressRequiredException): 
        (status.HTTP_400_BAD_REQUEST, 'address_required', 'warning'),
}

# Note: global exception mapping is defined in core.interface.api.exception.exception_mapping
