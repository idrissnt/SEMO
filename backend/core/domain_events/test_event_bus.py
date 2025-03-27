"""
Script to test the Celery-based event bus
"""
import logging
import uuid
from datetime import datetime

from core.domain_events.events import OrderCreatedEvent
from core.domain_events.event_bus import event_bus
from core.domain_events.decorators import event_handler

logger = logging.getLogger(__name__)

# Example event handler using the decorator
@event_handler(OrderCreatedEvent)
def handle_order_created(event):
    logger.info(f"Handling OrderCreatedEvent with ID {event.event_id}")
    logger.info(f"Order ID: {event.order_id}, User ID: {event.user_id}")
    logger.info(f"Store Brand ID: {event.store_brand_id}, Total Amount: {event.total_amount}")
    logger.info(f"Delivery Address: {event.delivery_address}")

def test_event_bus():
    """Test the Celery-based event bus by publishing an event"""
    # Create a test event
    event = OrderCreatedEvent(
        event_id=uuid.uuid4(),
        timestamp=datetime.now(),
        order_id=uuid.uuid4(),
        user_id=uuid.uuid4(),
        store_brand_id=uuid.uuid4(),
        total_amount=100.0,
        delivery_address="123 Test Street, Test City"
    )
    
    # Publish the event
    logger.info(f"Publishing test event with ID {event.event_id}")
    event_bus.publish(event)
    logger.info("Event published successfully")
    
    # Note: In a real application, the event will be processed asynchronously by Celery
    # For testing, you can run this script and then check the Celery worker logs
    
if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # Run the test
    test_event_bus()
