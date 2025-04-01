"""
Bridge module that imports and re-exports Django ORM models from the infrastructure layer.
This allows Django to discover models in the standard location while maintaining DDD architecture.
"""

# Import models from infrastructure layer
from orders.infrastructure.django_models.orm_models import (
    OrderModel as Order,
    OrderItemModel as OrderItem,
    OrderTimelineModel as OrderTimeline
)

# Re-export models with simplified names for Django admin and migrations
__all__ = ['Order', 'OrderItem', 'OrderTimeline']
