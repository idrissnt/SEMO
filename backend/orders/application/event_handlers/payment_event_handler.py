"""
Event handlers for payment events
"""
import logging
from core.domain_events.decorators import event_handler
from payments.domain.events.payment_events import PaymentCompletedEvent, PaymentFailedEvent
from orders.application.services.order_service import OrderApplicationService

logger = logging.getLogger(__name__)

# Global instance of the order service
# Will be set by the initialize function
_order_service = None

def initialize(order_service: OrderApplicationService):
    """Initialize the event handlers with the order service"""
    global _order_service
    _order_service = order_service
    logger.info("Payment event handlers initialized")

@event_handler(PaymentCompletedEvent)
def handle_payment_completed(event: PaymentCompletedEvent):
    """
    Handle payment completed event
    
    Args:
        event: The payment completed event
    """
    if _order_service is None:
        logger.error("Order service not initialized for payment event handler")
        return
        
    # Set payment for the order
    success, message, order = _order_service.set_order_payment(
        order_id=event.order_id,
        payment_id=event.payment_id
    )
    
    if not success:
        logger.error(f"Failed to update order after payment: {message}")

@event_handler(PaymentFailedEvent)
def handle_payment_failed(event: PaymentFailedEvent):
    """
    Handle payment failed event
    
    Args:
        event: The payment failed event
    """
    if _order_service is None:
        logger.error("Order service not initialized for payment event handler")
        return
        
    # Get the order
    order = _order_service.get_order_with_items(event.order_id)
    if not order:
        logger.error(f"Order {event.order_id} not found for failed payment")
        return
        
    # Add a timeline entry about the failed payment
    _order_service.order_timeline_repository.create(
        order.id,
        'payment_failed',
        f"Payment failed: {event.error_message}"
    )
