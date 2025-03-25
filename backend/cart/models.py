"""
Bridge module that imports and re-exports Django ORM models from the infrastructure layer.
This allows Django to discover models in the standard location while maintaining DDD architecture.
"""

# Import models from infrastructure layer
from cart.infrastructure.django_models.orm_models import (
    CartModel as Cart,
    CartItemModel as CartItem
)

# Re-export models with simplified names for Django admin and migrations
__all__ = ['Cart', 'CartItem']
