"""
Serializers package for the deliveries domain.

This package provides serializers for domain entities and value objects,
following Domain-Driven Design principles and Clean Architecture.
"""
# Value objects
from .base_serializers import (
    GeoPointSerializer,
    RouteInfoSerializer,
)

# Delivery serializers
from .delivery_serializers import (
    DeliveryOutputSerializer,
    DeliveryCreateInputSerializer,
    DeliveryUpdateStatusInputSerializer,
    DeliveryAssignDriverInputSerializer,
    DeliveryUpdateLocationInputSerializer,
    DeliveryUpdateETAInputSerializer,
)

# Location serializers
from .location_serializers import (
    DeliveryLocationOutputSerializer,
    DeliveryLocationCreateInputSerializer,
    NearbyLocationsInputSerializer,
)

# Driver serializers
from .driver_serializers import (
    DriverOutputSerializer,
    DriverCreateInputSerializer,
    DriverUpdateInfoInputSerializer,
    DriverUpdateAvailabilityInputSerializer,
)

# Timeline serializers
from .timeline_serializers import (
    DeliveryTimelineEventOutputSerializer,
    DeliveryTimelineEventCreateInputSerializer,
)

__all__ = [
    'GeoPointSerializer',
    'RouteInfoSerializer',
    'DeliveryOutputSerializer',
    'DeliveryCreateInputSerializer',
    'DeliveryUpdateStatusInputSerializer',
    'DeliveryAssignDriverInputSerializer',
    'DeliveryUpdateLocationInputSerializer',
    'DeliveryUpdateETAInputSerializer',
    'DeliveryLocationOutputSerializer',
    'DeliveryLocationCreateInputSerializer',
    'NearbyLocationsInputSerializer',
    'DriverOutputSerializer',
    'DriverCreateInputSerializer',
    'DriverUpdateInfoInputSerializer',
    'DriverUpdateAvailabilityInputSerializer',
    'DeliveryTimelineEventOutputSerializer',
    'DeliveryTimelineEventCreateInputSerializer',
]