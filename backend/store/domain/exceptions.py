# domain/exceptions.py
# class StoreNotFoundError(Exception):
#     """Raised when a referenced store doesn't exist"""

# class LocationNotFoundError(Exception):
#     """Raised when a location operation fails"""

# class InvalidCoordinatesError(Exception):
#     """Raised for invalid geographic coordinates"""


from core.domain.exceptions import CoreDomainException

class InvalidUuidException(CoreDomainException):
    """Raised when an invalid UUID is provided"""
    def __init__(self, message="Invalid UUID provided"):
        super().__init__(message, "invalid_uuid")

# store brand related exceptions
class StoreIdRequiredException(CoreDomainException):
    """Raised when a store id is required"""
    def __init__(self, message="Store id is required"):
        super().__init__(message, "store_id_required")

class AddressRequiredException(CoreDomainException):
    """Raised when an address is required"""
    def __init__(self, message="Address is required"):
        super().__init__(message, "address_required")

# search related exceptions 
class QuerySearchRequiredException(CoreDomainException):
    """Raised when a required query search is missing"""
    def __init__(self, message="Required query search is missing"):
        super().__init__(message, "query_search_required")
    
    