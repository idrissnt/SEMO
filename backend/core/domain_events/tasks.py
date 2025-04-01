"""
Celery tasks for processing domain events
"""
import logging
from celery import shared_task

from .event_registry import get_handlers_for_event
from .event_factory import create_event_from_data

logger = logging.getLogger(__name__)

# The Reliable Processor
# The Celery task processes events asynchronously:

# Key features:
# - Supports automatic retries with exponential backoff
# - Recreates event objects from serialized data
# - Calls all registered handlers for the event type
# - Handles errors gracefully without affecting other handlers

@shared_task(bind=True, max_retries=3)
def process_domain_event(self, event_type_name: str, event_data: dict):
    """
    Process a domain event asynchronously
    
    Args:
        event_type_name: The name of the event class
        event_data: The serialized event data
    """
    try:
        logger.info(f"Processing event {event_type_name} with ID {event_data.get('event_id')}")
        
        # Recreate the event from data
        event = create_event_from_data(event_type_name, event_data)
        
        # Get handlers for this event type
        handlers = get_handlers_for_event(event_type_name)
        
        if not handlers:
            logger.warning(f"No handlers registered for event {event_type_name}")
            return
        
        # Process with each handler
        for handler in handlers:
            try:
                handler(event)
                logger.debug(f"Handler {handler.__name__} processed event {event_type_name}")
            except Exception as e:
                logger.error(f"Error in handler {handler.__name__} for event {event_type_name}: {e}")
                # Don't retry for handler-specific errors, just log them
                
    except Exception as e:
        logger.error(f"Error processing event {event_type_name}: {e}")
        # Retry the task with exponential backoff
        retry_countdown = 2 ** self.request.retries
        self.retry(exc=e, countdown=retry_countdown)
