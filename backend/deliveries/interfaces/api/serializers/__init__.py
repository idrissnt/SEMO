"""
Serializers package for the deliveries domain.

This package provides serializers for domain entities and value objects,
following Domain-Driven Design principles and Clean Architecture.
"""
# Value objects
from deliveries.interfaces.api.serializers.base_serializers import (
    GeoPointSerializer,
    RouteInfoSerializer,
)

# Delivery serializers
from deliveries.interfaces.api.serializers.delivery_serializers import (
    DeliveryOutputSerializer,
    DeliveryCreateInputSerializer,
    DeliveryUpdateStatusInputSerializer,
    DeliveryAssignDriverInputSerializer,
    DeliveryUpdateLocationInputSerializer,
    DeliveryUpdateETAInputSerializer,
)

# Location serializers
from deliveries.interfaces.api.serializers.location_serializers import (
    DeliveryLocationOutputSerializer,
    DeliveryLocationCreateInputSerializer,
    NearbyLocationsInputSerializer,
)

# Driver serializers
from deliveries.interfaces.api.serializers.driver_serializers import (
    DriverOutputSerializer,
    DriverCreateInputSerializer,
    DriverUpdateInfoInputSerializer,
    DriverUpdateAvailabilityInputSerializer,
)

# Timeline serializers
from deliveries.interfaces.api.serializers.timeline_serializers import (
    DeliveryTimelineEventOutputSerializer,
    DeliveryTimelineEventCreateInputSerializer,
)
