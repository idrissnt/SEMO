"""
Bridge module that imports and re-exports Django ORM models from the infrastructure layer.
This allows Django to discover models in the standard location while maintaining DDD architecture.
"""

# Import the models from infrastructure layer
from the_user_app.infrastructure.django_models.orm_models import (
    CustomUserModel,
    AddressModel,
    LogoutEventModel,
    BlacklistedTokenModel,
    TaskPerformerProfileModel
)

# Re-export the models with the names Django expects
CustomUser = CustomUserModel
Address = AddressModel
LogoutEvent = LogoutEventModel
BlacklistedToken = BlacklistedTokenModel
TaskPerformerProfile = TaskPerformerProfileModel

# Define which models should be available for Django
__all__ = ['CustomUser', 'Address', 'LogoutEvent', 'BlacklistedToken', 'TaskPerformerProfile']
