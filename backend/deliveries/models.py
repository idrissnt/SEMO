"""
Bridge module that imports and re-exports Django ORM models from the infrastructure layer.
This allows Django to discover models in the standard location while maintaining DDD architecture.
"""

# Import models from infrastructure layer
from deliveries.infrastructure.django_models.orm_models import (
    DeliveryModel as Delivery,
    DeliveryTimelineModel as DeliveryTimeline,
    DeliveryLocationModel as DeliveryLocation
)

# Re-export models with simplified names for Django admin and migrations
__all__ = ['Delivery', 'DeliveryTimeline', 'DeliveryLocation']
