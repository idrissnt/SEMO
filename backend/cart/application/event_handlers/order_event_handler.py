"""
Event handlers for order events
"""
import logging
from uuid import UUID

from core.domain_events.decorators import event_handler
from core.domain_events.events import OrderStatusChangedEvent, OrderPaidEvent

logger = logging.getLogger(__name__)

# Global instance of the cart service
# Will be set by the initialize function
_cart_service = None

def initialize(cart_service):
    """Initialize the event handlers with the cart service"""
    global _cart_service
    _cart_service = cart_service
    logger.info("Order event handlers initialized for cart service")

@event_handler(OrderStatusChangedEvent)
def handle_order_status_changed(event: OrderStatusChangedEvent):
    """
    Handle order status changed event
    Clear the cart when an order transitions to 'processing'
    
    Args:
        event: The order status changed event
    """
    if _cart_service is None:
        logger.error("Cart service not initialized for order event handler")
        return
        
    # Only clear cart when order transitions to 'processing'
    if event.new_status == 'processing':
        # Get order repository to check if the order is paid
        from orders.infrastructure.factory import RepositoryFactory
        order_repository = RepositoryFactory.create_order_repository()
        
        # Get the order
        order = order_repository.get_by_id(event.order_id)
        
        # Only clear the cart if the order is paid and has a cart_id
        if order and order.is_paid() and order.cart_id:
            logger.info(f"Clearing cart {order.cart_id} as order {order.id} is now processing and paid")
            success, error = _cart_service.clear_cart(order.cart_id)
            
            if not success:
                logger.error(f"Failed to clear cart after order processing: {error}")

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
        
    # Get order repository
    from orders.infrastructure.factory import RepositoryFactory
    order_repository = RepositoryFactory.create_order_repository()
    
    # Get the order
    order = order_repository.get_by_id(event.order_id)
    
    # Only clear the cart if the order is in processing status and has a cart_id
    if order and order.status == 'processing' and order.cart_id:
        logger.info(f"Clearing cart {order.cart_id} as order {order.id} is paid and in processing status")
        success, error = _cart_service.clear_cart(order.cart_id)
        
        if not success:
            logger.error(f"Failed to clear cart after order payment: {error}")
