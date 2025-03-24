"""
Bridge module that imports and re-exports Django ORM models from the infrastructure layer.
This allows Django to discover models in the standard location while maintaining DDD architecture.
"""

# Import models from infrastructure layer
from the_user_app.infrastructure.django_models.orm_models import (
    CustomUserModel as CustomUser,
    AddressModel as Address,
    LogoutEventModel as LogoutEvent,
    BlacklistedTokenModel as BlacklistedToken
)

# Re-export models with simplified names for Django admin and migrations
__all__ = ['CustomUser', 'Address', 'LogoutEvent', 'BlacklistedToken']
