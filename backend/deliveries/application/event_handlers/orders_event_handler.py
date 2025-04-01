"""
Event handlers for order events
"""
import logging
from core.domain_events.decorators import event_handler
from core.domain_events.event_bus import event_bus

from orders.domain.events.orders_events import OrderPaidEvent
from deliveries.domain.models.events.deliveries_events import DeliveryCreatedEvent
from deliveries.application.services.delivery_service import DeliveryApplicationService

logger = logging.getLogger(__name__)

# Global instance of the delivery service
# Will be set by the initialize function
_delivery_service = None

def initialize(delivery_service: DeliveryApplicationService):
    """Initialize the event handlers with the delivery service"""
    global _delivery_service
    _delivery_service = delivery_service
    logger.info("Order event handlers initialized for delivery service")

@event_handler(OrderPaidEvent)
def handle_order_paid(event: OrderPaidEvent):
    """Handle OrderPaidEvent by creating a delivery"""
    # Create a delivery for the order
    delivery = _delivery_service.create(
            order_id=event.order_id
        )

    
