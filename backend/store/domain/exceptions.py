# domain/exceptions.py
class StoreNotFoundError(Exception):
    """Raised when a referenced store doesn't exist"""

class LocationNotFoundError(Exception):
    """Raised when a location operation fails"""

class InvalidCoordinatesError(Exception):
    """Raised for invalid geographic coordinates"""