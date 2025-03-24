
"""
Bridge module that imports and re-exports Serializers from the interface layer.
This allows Django to discover serializers in the standard location while maintaining DDD architecture.
"""

# Import serializers from interface layer
from store.interfaces.api.serializers import (
    StoreBrandSerializer,
    ProductWithDetailsSerializer 
)

# Re-export serializers with simplified names for Django admin and migrations
__all__ = ['StoreBrandSerializer', 'ProductWithDetailsSerializer']
