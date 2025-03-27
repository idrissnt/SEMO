from typing import List, Optional
from uuid import UUID

from orders.domain.models.entities import OrderTimeline
from orders.domain.repositories.repository_interfaces import OrderTimelineRepository
from orders.infrastructure.django_models.orm_models import OrderTimelineModel


class DjangoOrderTimelineRepository(OrderTimelineRepository):
    """Django ORM implementation of OrderTimelineRepository"""
    
    def get_by_id(self, timeline_id: UUID) -> Optional[OrderTimeline]:
        """Get a timeline event by ID"""
        try:
            timeline_model = OrderTimelineModel.objects.get(id=timeline_id)
            return self._to_entity(timeline_model)
        except OrderTimelineModel.DoesNotExist:
            return None
    
    def list_by_order(self, order_id: UUID) -> List[OrderTimeline]:
        """List all timeline events for an order"""
        timeline_models = OrderTimelineModel.objects.filter(order_id=order_id)
        return [self._to_entity(timeline_model) for timeline_model in timeline_models]
    
    def create(self, order_id: UUID, event_type: str, notes: Optional[str] = None) -> OrderTimeline:
        """Create a new timeline event"""
        timeline_model = OrderTimelineModel.objects.create(
            order_id=order_id,
            event_type=event_type,
            notes=notes
        )
        return self._to_entity(timeline_model)
    
    def _to_entity(self, timeline_model: OrderTimelineModel) -> OrderTimeline:
        """Convert ORM model to domain entity"""
        return OrderTimeline(
            id=timeline_model.id,
            order_id=timeline_model.order_id,
            event_type=timeline_model.event_type,
            timestamp=timeline_model.timestamp,
            notes=timeline_model.notes
        )
