from typing import List, Optional, Dict
from uuid import UUID

from deliveries.domain.models.entities import DeliveryTimelineEvent
from deliveries.domain.repositories.delivery_repo.delivery_timeline_repository_interfaces import DeliveryTimelineRepository
from deliveries.infrastructure.django_models.delivery_orm_models.delivery_models import DeliveryTimelineModel


class DjangoDeliveryTimelineRepository(DeliveryTimelineRepository):
    """Django ORM implementation of DeliveryTimelineRepository"""
    
    def get_by_id(self, event_id: UUID) -> Optional[DeliveryTimelineEvent]:
        """Get a timeline event by ID"""
        try:
            event_model = DeliveryTimelineModel.objects.get(id=event_id)
            return self._to_entity(event_model)
        except DeliveryTimelineModel.DoesNotExist:
            return None
    
    def list_by_delivery(self, delivery_id: UUID) -> List[DeliveryTimelineEvent]:
        """List all timeline events for a delivery"""
        event_models = DeliveryTimelineModel.objects.filter(delivery_id=delivery_id)
        return [self._to_entity(event_model) for event_model in event_models]
    
    def create(
        self, 
        delivery_id: UUID, 
        event_type: str, 
        notes: Optional[str] = None,
        location: Optional[Dict[str, float]] = None
    ) -> DeliveryTimelineEvent:
        """Create a new timeline event"""
        # Extract location data if provided
        latitude = None
        longitude = None
        if location:
            latitude = location.get('latitude')
            longitude = location.get('longitude')
        
        # Create the model
        event_model = DeliveryTimelineModel.objects.create(
            delivery_id=delivery_id,
            event_type=event_type,
            notes=notes,
            latitude=latitude,
            longitude=longitude
        )
        
        return self._to_entity(event_model)
    
    def _to_entity(self, event_model: DeliveryTimelineModel) -> DeliveryTimelineEvent:
        """Convert ORM model to domain entity"""
        location = None
        if event_model.latitude is not None and event_model.longitude is not None:
            location = {
                'latitude': event_model.latitude,
                'longitude': event_model.longitude
            }
        
        return DeliveryTimelineEvent(
            id=event_model.id,
            delivery_id=event_model.delivery_id,
            event_type=event_model.event_type,
            timestamp=event_model.timestamp,
            notes=event_model.notes,
            location=location
        )
