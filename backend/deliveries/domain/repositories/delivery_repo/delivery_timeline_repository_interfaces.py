from abc import ABC, abstractmethod
from typing import List, Optional, Dict
from uuid import UUID

from deliveries.domain.models.entities.delivery_entities import DeliveryTimelineEvent

class DeliveryTimelineRepository(ABC):
    """Interface for delivery timeline repository"""
    
    @abstractmethod
    def get_by_id(self, event_id: UUID) -> Optional[DeliveryTimelineEvent]:
        """Get a timeline event by ID"""
        pass
    
    @abstractmethod
    def list_by_delivery(self, delivery_id: UUID) -> List[DeliveryTimelineEvent]:
        """List all timeline events for a delivery"""
        pass
    
    @abstractmethod
    def create(
        self, 
        delivery_id: UUID, 
        event_type: str, 
        notes: Optional[str] = None,
        location: Optional[Dict[str, float]] = None
    ) -> DeliveryTimelineEvent:
        """Create a new timeline event"""
        pass
