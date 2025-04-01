"""
Event handlers for order events
"""
import logging

from core.domain_events.decorators import event_handler
from orders.domain.events.orders_events import OrderPaidEvent
from cart.application.services.cart_service import CartApplicationService

logger = logging.getLogger(__name__)

# Global instance of the cart service
# Will be set by the initialize function
_cart_service = None

def initialize(cart_service:CartApplicationService ):
    """Initialize the event handlers with the cart service"""
    global _cart_service
    _cart_service = cart_service
    logger.info("Order event handlers initialized for cart service")

@event_handler(OrderPaidEvent)
def handle_order_paid(event: OrderPaidEvent):
    """
    Handle order paid event
    If the order is already in 'processing' status, clear the cart
    
    Args:
        event: The order paid event
    """
    if _cart_service is None:
        logger.error("Cart service not initialized for order event handler")
        return
        
    success, error = _cart_service.clear_cart(event.cart_id)
    if not success:
        logger.error(f"Failed to clear cart after order payment: {error}")
