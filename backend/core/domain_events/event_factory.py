"""
Factory for creating domain events from serialized data
"""
import logging
import importlib
import inspect
from typing import Dict, Any

from .events import DomainEvent

logger = logging.getLogger(__name__)

def create_event_from_data(event_type_name: str, event_data: Dict[str, Any]) -> DomainEvent:
    """
    Create a domain event instance from serialized data
    
    Args:
        event_type_name: The name of the event class
        event_data: The serialized event data
        
    Returns:
        An instance of the specified domain event
    
    Raises:
        ImportError: If the event type cannot be imported
        ValueError: If the event type is not a subclass of DomainEvent
    """
    try:
        # First try to find the event class in the events module
        module = importlib.import_module('core.domain_events.events')
        event_classes = {
            name: cls for name, cls in inspect.getmembers(module, inspect.isclass)
            if issubclass(cls, DomainEvent) and cls != DomainEvent
        }
        
        if event_type_name in event_classes:
            event_class = event_classes[event_type_name]
            return event_class.from_dict(event_data)
        else:
            # If not found, try to dynamically import it
            # This assumes the event_type_name includes the full path
            # e.g., "orders.events.OrderCreatedEvent"
            module_path, class_name = event_type_name.rsplit('.', 1)
            module = importlib.import_module(module_path)
            event_class = getattr(module, class_name)
            
            if not issubclass(event_class, DomainEvent):
                raise ValueError(f"{event_type_name} is not a subclass of DomainEvent")
                
            return event_class.from_dict(event_data)
            
    except (ImportError, AttributeError) as e:
        logger.error(f"Failed to import event type {event_type_name}: {str(e)}")
        raise ImportError(f"Could not import event type {event_type_name}")
    except Exception as e:
        logger.error(f"Error creating event of type {event_type_name}: {str(e)}")
        raise
