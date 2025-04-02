"""
Bridge module that imports and re-exports Django ORM models from the infrastructure layer.
This allows Django to discover models in the standard location while maintaining DDD architecture.
"""

# Import delivery models from infrastructure layer
from deliveries.infrastructure.django_models.delivery_orm_models.delivery_models import (
    DeliveryModel as Delivery,
    DeliveryTimelineModel as DeliveryTimeline,
    DeliveryLocationModel as DeliveryLocation
)

# Import driver models from infrastructure layer
from deliveries.infrastructure.django_models.driver_orm_models.driver_model import (
    DriverModel as Driver,
    DriverDeviceModel as DriverDevice,
    DriverLocationModel as DriverLocation
)

# Re-export models with simplified names for Django admin and migrations
__all__ = ['Delivery', 'DeliveryTimeline', 'DeliveryLocation', 'Driver', 'DriverDevice', 'DriverLocation']
