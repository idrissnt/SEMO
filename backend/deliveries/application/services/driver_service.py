from typing import Tuple
import uuid
import logging

from the_user_app.domain.models.entities import User
from the_user_app.domain.repositories.repository_interfaces import UserRepository
from deliveries.domain.repositories.repository_interfaces import DriverRepository

logger = logging.getLogger(__name__)

class DriverApplicationService:
    """Application service for driver-related use cases"""
    
    def __init__(self, user_repository: UserRepository, driver_repository: DriverRepository):
        self.user_repository = user_repository
        self.driver_repository = driver_repository
    
    def register_as_driver(self, user_id: uuid.UUID) -> Tuple[bool, str]:
        """Register a user as a driver
        
        Args:
            user_id: UUID of the user to register as driver
            
        Returns:
            Tuple of (success, error_message)
            success is True if registration is successful
            error_message is empty if registration is successful, otherwise contains the error
        """
        # Get existing user
        user = self.user_repository.get_by_id(user_id)
        if not user:
            return False, f"User with ID {user_id} not found"
        
        # Check if user already has driver role
        if user.role == 'driver':
            return False, "User is already registered as a driver"
        
        # Check if driver-specific fields are set
        if not user.has_vehicle:
            return False, "Vehicle is required for drivers"
        
        if not user.license_number:
            return False, "License number is required for drivers"
        
        try:
            # Check if driver record already exists
            existing_driver = self.driver_repository.get_by_user_id(user_id)
            if existing_driver:
                return False, "Driver record already exists"
            
            # Update user role in user repository
            updated_user = User(
                id=user.id,
                email=user.email,
                first_name=user.first_name,
                last_name=user.last_name,
                phone_number=user.phone_number,
                role='driver',  # Set role to driver
                has_vehicle=user.has_vehicle,
                license_number=user.license_number,
                is_available=user.is_available
            )
            
            # Update user in repository
            result_user = self.user_repository.update(updated_user)
            if not result_user:
                return False, "Failed to update user role"
            
            # Create driver record
            self.driver_repository.create(user_id)
            
            return True, ""
            
        except Exception as e:
            logger.error(f"Error registering user as driver: {str(e)}")
            return False, f"Error registering user as driver: {str(e)}"
    
    def unregister_as_driver(self, user_id: uuid.UUID) -> Tuple[bool, str]:
        """Unregister a user from being a driver
        
        Args:
            user_id: UUID of the user to unregister as driver
            
        Returns:
            Tuple of (success, error_message)
            success is True if unregistration is successful
            error_message is empty if unregistration is successful, otherwise contains the error
        """
        # Get existing user
        user = self.user_repository.get_by_id(user_id)
        if not user:
            return False, f"User with ID {user_id} not found"
        
        # Check if user has driver role
        if user.role != 'driver':
            return False, "User is not registered as a driver"
        
        try:
            # Get driver record
            driver = self.driver_repository.get_by_user_id(user_id)
            if not driver:
                return False, "Driver record not found"
            
            # Check if driver has active deliveries
            # This would require a delivery repository, but for now we'll use the ORM directly
            # In a complete DDD implementation, we would inject a delivery repository
            from deliveries.infrastructure.django_models.orm_models import DeliveryModel
            active_deliveries = DeliveryModel.objects.filter(
                driver_id=driver.id
            ).exclude(status='delivered').exists()
            
            if active_deliveries:
                return False, "Cannot unregister driver with active deliveries"
            
            # Update user role in user repository
            updated_user = User(
                id=user.id,
                email=user.email,
                first_name=user.first_name,
                last_name=user.last_name,
                phone_number=user.phone_number,
                role='customer',  # Set role back to customer
                has_vehicle=user.has_vehicle,
                license_number=user.license_number,
                is_available=user.is_available
            )
            
            # Update user in repository
            result_user = self.user_repository.update(updated_user)
            if not result_user:
                return False, "Failed to update user role"
            
            # We don't delete the driver record, just keep it for historical purposes
            # This maintains data integrity for past deliveries
            
            return True, ""
            
        except Exception as e:
            logger.error(f"Error unregistering user as driver: {str(e)}")
            return False, f"Error unregistering user as driver: {str(e)}"
