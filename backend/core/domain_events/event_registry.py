"""
Event registry for storing event type to handler mappings
"""
import logging
from typing import Dict, List, Callable, Any

logger = logging.getLogger(__name__)

# Global registry to store event handlers
# Maps event type names to list of handler functions
_event_handlers: Dict[str, List[Callable]] = {}

def register_handler(event_type_name: str, handler: Callable) -> None:
    """
    Register a handler for a specific event type
    
    Args:
        event_type_name: The name of the event type
        handler: The function to call when the event is published
    """
    if event_type_name not in _event_handlers:
        _event_handlers[event_type_name] = []
    
    if handler not in _event_handlers[event_type_name]:
        _event_handlers[event_type_name].append(handler)
        logger.debug(f"Registered handler {handler.__name__} for event {event_type_name}")

def unregister_handler(event_type_name: str, handler: Callable) -> None:
    """
    Unregister a handler for a specific event type
    
    Args:
        event_type_name: The name of the event type
        handler: The handler to unregister
    """
    if event_type_name in _event_handlers and handler in _event_handlers[event_type_name]:
        _event_handlers[event_type_name].remove(handler)
        logger.debug(f"Unregistered handler {handler.__name__} for event {event_type_name}")

def get_handlers_for_event(event_type_name: str) -> List[Callable]:
    """
    Get all handlers registered for an event type
    
    Args:
        event_type_name: The name of the event type
        
    Returns:
        List of handler functions
    """
    return _event_handlers.get(event_type_name, [])
