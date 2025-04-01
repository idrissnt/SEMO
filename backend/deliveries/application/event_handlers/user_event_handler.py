"""
Event handlers for user events
"""
import logging
from core.domain_events.decorators import event_handler

from the_user_app.domain.models.events.user_events import UserRegisteredEvent
from deliveries.application.services.driver_service import DriverApplicationService

logger = logging.getLogger(__name__)

# Global instance of the driver service
# Will be set by the initialize function
_driver_service = None

def initialize(driver_service: DriverApplicationService):
    """Initialize the event handlers with the driver service"""
    global _driver_service
    _driver_service = driver_service
    logger.info("User event handlers initialized for driver service")

@event_handler(UserRegisteredEvent)
def handle_user_registered(event: UserRegisteredEvent):
    """Handle UserRegisteredEvent by creating a driver"""
    # Create a driver for the user
    success, error = _driver_service.register_as_driver(
            user_id=event.user_id
        )
    
    if not success:
        logger.error(f"Failed to register user as driver: {error}")
        return