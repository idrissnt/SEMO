"""
Payments app configuration.

This module configures the payments app, initializes Stripe, and sets up
event handlers for domain events.
"""

import logging
from django.apps import AppConfig
import stripe
from django.conf import settings


logger = logging.getLogger(__name__)


class PaymentsConfig(AppConfig):
    """Configuration for the payments app
    
    This class configures the payments app, initializes Stripe, and sets up
    event handlers for domain events.
    """
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'payments'
    
    def ready(self):
        """Called when the app is ready
        
        Initializes Stripe and sets up event handlers for domain events.
        """
        # Initialize Stripe with the API key from settings
        stripe.api_key = settings.STRIPE_SECRET_KEY
        logger.info("Stripe initialized")
        
        # Initialize event handlers for domain events
        self._init_event_handlers()
        logger.info("Payment event handlers initialized")
    
    def _init_event_handlers(self):
        """Initialize event handlers for domain events
        
        Sets up handlers for domain events from other bounded contexts,
        such as order creation and status changes.
        """
        # Import here to avoid circular imports
        from core.domain_events.event_bus import event_bus
        from orders.domain.events.orders_events import OrderCreatedEvent, OrderStatusChangedEvent, OrderPaidEvent
        from payments.infrastructure.factory import ServiceFactory
        
        # Create service using the factory
        payment_service = ServiceFactory.create_payment_service()
        
        # Handler for OrderCreatedEvent
        def handle_order_created(event):
            """Handle order created event
            
            Creates a payment for the new order.
            
            Args:
                event: The OrderCreatedEvent
            """
            logger.info(f"Handling OrderCreatedEvent for order {event.order_id}")
            try:
                # Create a payment for the order
                order_id = event.order_id
                amount = event.total_amount
                
                success, message, payment = payment_service.create_payment(
                    order_id=order_id,
                    amount=amount
                )
                
                if success:
                    logger.info(f"Payment created for order {order_id}: {payment.id}")
                else:
                    logger.error(f"Failed to create payment for order {order_id}: {message}")
            except Exception as e:
                logger.exception(f"Error handling OrderCreatedEvent: {str(e)}")
        
        # Handler for OrderStatusChangedEvent
        def handle_order_status_changed(event):
            """Handle order status changed event
            
            Updates payment status based on order status changes.
            
            Args:
                event: The OrderStatusChangedEvent
            """
            logger.info(f"Handling OrderStatusChangedEvent for order {event.order_id}: {event.old_status} -> {event.new_status}")
            # No action needed for now
            pass
        
        # Handler for OrderPaidEvent
        def handle_order_paid(event):
            """Handle order paid event
            
            Updates the payment status to completed when an order is marked as paid.
            
            Args:
                event: The OrderPaidEvent
            """
            logger.info(f"Handling OrderPaidEvent for order {event.order_id}")
            try:
                # Get the payment for the order
                payment = payment_service.payment_repository.get_by_order_id(event.order_id)
                if payment:
                    # Mark the payment as completed
                    payment.mark_as_completed()
                    payment_service.payment_repository.update(payment)
                    logger.info(f"Payment {payment.id} marked as completed due to OrderPaidEvent")
                else:
                    logger.error(f"No payment found for order {event.order_id}")
            except Exception as e:
                logger.exception(f"Error handling OrderPaidEvent: {str(e)}")
        
        # Subscribe to events
        event_bus.subscribe(OrderCreatedEvent, handle_order_created)
        event_bus.subscribe(OrderStatusChangedEvent, handle_order_status_changed)
        event_bus.subscribe(OrderPaidEvent, handle_order_paid)
        
        logger.info("Subscribed to order events")
