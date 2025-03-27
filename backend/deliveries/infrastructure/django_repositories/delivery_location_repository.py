from typing import List, Optional
from uuid import UUID

from deliveries.domain.models.entities import DeliveryLocation
from deliveries.domain.repositories.repository_interfaces import DeliveryLocationRepository
from deliveries.infrastructure.django_models.orm_models import DeliveryLocationModel


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
        """Get the latest location for a delivery"""
        try:
            # The model has ordering = ['-timestamp'] so first() will get the latest
            location_model = DeliveryLocationModel.objects.filter(delivery_id=delivery_id).first()
            if location_model:
                return self._to_entity(location_model)
            return None
        except DeliveryLocationModel.DoesNotExist:
            return None
    
    def list_by_delivery(self, delivery_id: UUID) -> List[DeliveryLocation]:
        """List all locations for a delivery"""
        location_models = DeliveryLocationModel.objects.filter(delivery_id=delivery_id)
        return [self._to_entity(location_model) for location_model in location_models]
    
    def create(
        self,
        delivery_id: UUID,
        driver_id: int,
        latitude: float,
        longitude: float
    ) -> DeliveryLocation:
        """Create a new location record"""
        location_model = DeliveryLocationModel.objects.create(
            delivery_id=delivery_id,
            driver_id=driver_id,
            latitude=latitude,
            longitude=longitude
        )
        
        return self._to_entity(location_model)
    
    def _to_entity(self, location_model: DeliveryLocationModel) -> DeliveryLocation:
        """Convert ORM model to domain entity"""
        return DeliveryLocation(
            id=location_model.id,
            delivery_id=location_model.delivery_id,
            driver_id=location_model.driver_id,
            latitude=location_model.latitude,
            longitude=location_model.longitude,
            timestamp=location_model.timestamp
        )
