"""
Decorators for working with domain events
"""
import logging
from functools import wraps
from typing import Type, Callable

from .events import DomainEvent
from .event_bus import event_bus

logger = logging.getLogger(__name__)

def event_handler(event_type: Type[DomainEvent]):
    """
    Decorator for registering event handlers
    
    Example:
        @event_handler(OrderCreatedEvent)
        def handle_order_created(event: OrderCreatedEvent):
            # Handle the event
            pass
    
    Args:
        event_type: The type of event to handle
        
    Returns:
        Decorator function
    """
    def decorator(handler: Callable):
        @wraps(handler)
        def wrapper(*args, **kwargs):
            return handler(*args, **kwargs)
        
        # Register the handler with the event bus
        event_bus.register(event_type, handler)
        logger.debug(f"Registered handler {handler.__name__} for event {event_type.__name__}")
        
        return wrapper
    return decorator
