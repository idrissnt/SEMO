"""Celery-based event bus for domain events

This implementation uses Celery and RabbitMQ for reliable, distributed event processing.
It replaces the previous in-memory event bus implementation to provide better reliability,
persistence, and support for distributed systems.
"""
import logging
from typing import Type, Callable, Dict, Any

from .events import DomainEvent
from .event_registry import register_handler, unregister_handler
from .tasks import process_domain_event

logger = logging.getLogger(__name__)

class CeleryEventBus:
    """
    Event bus implementation using Celery for reliable message delivery
    
    This implementation provides:
    - Persistence of events (events survive application restarts)
    - Distributed processing (events can be processed by any application instance)
    - Automatic retries for failed event processing
    - Better scalability for high-volume systems
    """
    
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(CeleryEventBus, cls).__new__(cls)
        return cls._instance
    
    def register(self, event_type: Type[DomainEvent], handler: Callable):
        """
        Register a handler for a specific event type
        
        Args:
            event_type: The type of event to handle
            handler: The function to call when the event is published
        """
        event_type_name = event_type.__name__
        register_handler(event_type_name, handler)
        logger.debug(f"Registered handler {handler.__name__} for event {event_type_name}")
        
    def subscribe(self, event_type: Type[DomainEvent], handler: Callable):
        """
        Alias for register to maintain backward compatibility with existing code
        
        Args:
            event_type: The type of event to handle
            handler: The function to call when the event is published
        """
        return self.register(event_type, handler)
    
    def unregister(self, event_type: Type[DomainEvent], handler: Callable):
        """
        Unregister a handler for a specific event type
        
        Args:
            event_type: The type of event
            handler: The handler to unregister
        """
        event_type_name = event_type.__name__
        unregister_handler(event_type_name, handler)
        logger.debug(f"Unregistered handler {handler.__name__} for event {event_type_name}")
        
    def unsubscribe(self, event_type: Type[DomainEvent], handler: Callable):
        """
        Alias for unregister to maintain backward compatibility with existing code
        
        Args:
            event_type: The type of event
            handler: The handler to unregister
        """
        return self.unregister(event_type, handler)
    
    def publish(self, event: DomainEvent):
        """
        Publish an event to be processed asynchronously by Celery
        
        Args:
            event: The event to publish
        """
        event_type_name = type(event).__name__
        event_data = event.to_dict()
        
        logger.info(f"Publishing event {event_type_name} with ID {event.event_id}")
        
        # Send to Celery task for asynchronous processing
        process_domain_event.delay(event_type_name, event_data)


# Singleton instance
event_bus = CeleryEventBus()
