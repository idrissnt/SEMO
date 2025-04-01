from typing import Tuple, Optional
import logging
from uuid import UUID

from deliveries.domain.repositories.repository_interfaces import DriverRepository
from deliveries.domain.models.entities import Driver

logger = logging.getLogger(__name__)

class DriverApplicationService:
    """Application service for driver-related use cases"""
    
    def __init__(self, driver_repository: DriverRepository):
        self.driver_repository = driver_repository
    
    def register_as_driver(self, user_id: UUID) -> Tuple[bool, str]:
        """Register a user as a driver
        
        Args:
            user_id: UUID of the user to register as driver
            
        Returns:
            Tuple of (success, error_message)
            success is True if registration is successful
            error_message is empty if registration is successful, otherwise contains the error
        """
        try:
            # Check if driver record already exists
            existing_driver = self.driver_repository.get_by_user_id(user_id)
            if existing_driver:
                return False, "Driver record already exists"
            
            # Create driver record
            self.driver_repository.create(user_id)
            
            return True, ""
            
        except Exception as e:
            logger.error(f"Error registering user as driver: {str(e)}")
            return False, f"Error registering user as driver: {str(e)}"
    
    def get_by_user_id(self, user_id: UUID) -> Optional[Driver]:
        return self.driver_repository.get_by_user_id(user_id)
    
    def update_availability(self, driver_id: UUID, is_available: bool) -> Tuple[bool, str]:
        """Update the availability of a driver"""
        return self.driver_repository.update_availability(driver_id, is_available)

    def update_info(self, driver_id: UUID, license_number: str, 
                    has_vehicle: bool) -> Tuple[bool, str, Optional[Driver]]:
        """Update an existing driver
        
        Args:
            driver_id: ID of the driver to update
            license_number: New license number
            has_vehicle: New vehicle availability
            
        Returns:
            Tuple of (success, error_message, updated_driver)
            success is True if update is successful
            error_message is empty if update is successful, otherwise contains the error
            updated_driver is the updated driver object if update is successful, otherwise None
        """
        try:
            updated_driver = self.driver_repository.update_info(driver_id, 
                                                                license_number, 
                                                                has_vehicle)
            if not updated_driver:
                return False, "Failed to update driver", None
            return True, "", updated_driver
        except Exception as e:
            logger.error(f"Error updating driver: {str(e)}")
            return False, f"Error updating driver: {str(e)}", None

    def get_all_available(self) -> List[Driver]:
        return self.driver_repository.list_available()

    