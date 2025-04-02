from typing import List, Optional
from uuid import UUID

from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from django.contrib.gis.db.models.functions import Distance

from deliveries.domain.models.entities import DeliveryLocation
from deliveries.domain.models.value_objects import GeoPoint
from deliveries.domain.repositories.delivery_location_repository_interfaces import DeliveryLocationRepository
from deliveries.infrastructure.django_models.delivery_orm_models.delivery_models import DeliveryLocationModel


class DjangoDeliveryLocationRepository(DeliveryLocationRepository):
    """Django ORM implementation of DeliveryLocationRepository"""
    
    def get_by_id(self, location_id: UUID) -> Optional[DeliveryLocation]:
        """Get a location by ID"""
        try:
            location_model = DeliveryLocationModel.objects.get(id=location_id)
            return self._to_entity(location_model)
        except DeliveryLocationModel.DoesNotExist:
            return None
    
    def get_latest_by_delivery(self, delivery_id: UUID) -> Optional[DeliveryLocation]:
        """Get the latest location for a delivery : use to track the driver's current location"""
        try:
            # The model has ordering = ['-timestamp'] so first() will get the latest
            location_model = DeliveryLocationModel.objects.filter(delivery_id=delivery_id).first()
            if location_model:
                return self._to_entity(location_model)
            return None
        except DeliveryLocationModel.DoesNotExist:
            return None
    
    def list_by_delivery(self, delivery_id: UUID) -> List[DeliveryLocation]:
        """List all locations for a delivery : use to track the driver's journey"""
        location_models = DeliveryLocationModel.objects.filter(delivery_id=delivery_id)
        return [self._to_entity(location_model) for location_model in location_models]
    
    def create(
        self,
        delivery_id: UUID,
        driver_id: UUID,
        location: GeoPoint
    ) -> DeliveryLocation:
        """Create a new location record
        
        Args:
            delivery_id: ID of the delivery
            driver_id: ID of the driver
            location: GeoPoint with latitude and longitude
            
        Returns:
            Created DeliveryLocation entity
        """
        # Create a Point object for the location field
        point = Point(location.longitude, location.latitude, srid=4326)
        
        location_model = DeliveryLocationModel.objects.create(
            delivery_id=delivery_id,
            driver_id=driver_id,
            latitude=location.latitude,
            longitude=location.longitude,
            location=point
        )
        
        return self._to_entity(location_model)
    
    def list_by_proximity(self, location: GeoPoint, 
                         max_distance_km: float = 2.0) -> List[DeliveryLocation]:
        """List delivery locations within a specified distance from the given coordinates
        
        Uses PostGIS's spatial capabilities to efficiently find locations within the specified radius.
        The distance calculation uses the geography type which accounts for the Earth's curvature.
        
        Args:
            location: Current location point
            max_distance_km: Maximum distance in kilometers (default 2km)
            
        Returns:
            List of delivery locations within the specified distance
        """
        # Create a Point object for the query
        point = Point(location.longitude, location.latitude, srid=4326)
        
        # Query locations within the specified distance
        location_models = DeliveryLocationModel.objects.filter(
            location__distance_lte=(point, D(km=max_distance_km))
        ).annotate(
            # Add distance as an annotation
            distance=Distance('location', point)
        ).order_by('distance')
        
        # Convert to domain entities
        return [self._to_entity(location_model) for location_model in location_models]
    
    def _to_entity(self, location_model: DeliveryLocationModel) -> DeliveryLocation:
        """Convert ORM model to domain entity"""
        # Create a GeoPoint from the location field
        geo_point = GeoPoint(
            latitude=location_model.latitude,
            longitude=location_model.longitude
        )
        
        return DeliveryLocation(
            id=location_model.id,
            delivery_id=location_model.delivery_id,
            driver_id=location_model.driver_id,
            location=geo_point,
            timestamp=location_model.timestamp
        )
