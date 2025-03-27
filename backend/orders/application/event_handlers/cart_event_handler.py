import logging

from core.domain_events.decorators import event_handler
from core.domain_events.events import CartCheckedOutEvent
from orders.application.services.order_service import OrderApplicationService

logger = logging.getLogger(__name__)

# Global instance of the order service
# Will be set by the initialize function
_order_service = None

def initialize(order_service: OrderApplicationService):
    """Initialize the event handlers with the order service"""
    global _order_service
    _order_service = order_service
    logger.info("Cart event handlers initialized")

@event_handler(CartCheckedOutEvent)
def handle_cart_checkout(event: CartCheckedOutEvent):
    """
    Handle cart checkout event
    
    Args:
        event: The cart checkout event
    """
    if _order_service is None:
        logger.error("Order service not initialized for cart event handler")
        return
        
    logger.info(f"Processing checkout for cart {event.cart_id}")
    
    # Create order from cart - this is just for tracking
    # The actual order creation happens in the API view
    # This is a fallback in case the order wasn't created
    success, message, order = _order_service.create_order_from_cart(event.cart_id)
    
    if not success:
        logger.error(f"Failed to create order from cart: {message}")
