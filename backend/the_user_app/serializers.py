
"""
Bridge module that imports and re-exports Serializers from the interface layer.
This allows Django to discover serializers in the standard location while maintaining DDD architecture.
"""

# Import serializers from interface layer
from the_user_app.interfaces.api.serializers import (
    UserSerializer,
    AddressSerializer,
    UserProfileSerializer,
    PasswordChangeSerializer
)

# Re-export serializers with simplified names for Django admin and migrations
__all__ = ['UserSerializer', 'AddressSerializer', 'UserProfileSerializer', 'PasswordChangeSerializer']
