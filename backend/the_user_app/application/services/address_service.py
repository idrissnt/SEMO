from typing import List, Optional, Tuple, Dict, Any
import uuid
import logging

from the_user_app.domain.models.entities import Address, User
from the_user_app.domain.repositories.repository_interfaces import AddressRepository, UserRepository

logger = logging.getLogger(__name__)

class AddressApplicationService:
    """Application service for address-related use cases"""
    
    def __init__(self, address_repository: AddressRepository, user_repository: UserRepository):
        self.address_repository = address_repository
        self.user_repository = user_repository
    
    def get_user_addresses(self, user_id: uuid.UUID) -> List[Address]:
        """Get all addresses for a user
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of Address objects
        """
        return self.address_repository.get_by_user_id(user_id)
    
    def get_address_by_id(self, address_id: uuid.UUID, user_id: uuid.UUID) -> Tuple[Optional[Address], str]:
        """Get an address by ID and verify it belongs to the user
        
        Args:
            address_id: UUID of the address
            user_id: UUID of the user
            
        Returns:
            Tuple of (address, error_message)
            address is an Address object if found and belongs to the user
            error_message is empty if address is found, otherwise contains the error
        """
        address = self.address_repository.get_by_id(address_id)
        
        if not address:
            return None, f"Address with ID {address_id} not found"
        
        if address.user_id != user_id:
            return None, "Address does not belong to the user"
        
        return address, ""
    
    def create_address(self, user_id: uuid.UUID, address_data: Dict[str, Any]) -> Tuple[Optional[Address], str]:
        """Create a new address for a user
        
        Args:
            user_id: UUID of the user
            address_data: Dictionary containing address data
            
        Returns:
            Tuple of (address, error_message)
            address is an Address object if creation is successful
            error_message is empty if creation is successful, otherwise contains the error
        """
        # Verify user exists
        user = self.user_repository.get_by_id(user_id)
        if not user:
            return None, f"User with ID {user_id} not found"
        
        # Create address domain entity
        try:
            address = Address(
                user_id=user_id,
                street_number=address_data['street_number'],
                street_name=address_data['street_name'],
                city=address_data['city'],
                zip_code=address_data['zip_code'],
                country=address_data['country']
            )
            
            # Create address in repository
            created_address = self.address_repository.create(address)
            return created_address, ""
        except KeyError as e:
            return None, f"Missing required field: {str(e)}"
        except Exception as e:
            logger.error(f"Error creating address: {str(e)}")
            return None, f"Error creating address: {str(e)}"
    
    def update_address(self, address_id: uuid.UUID, user_id: uuid.UUID, address_data: Dict[str, Any]) -> Tuple[Optional[Address], str]:
        """Update an existing address
        
        Args:
            address_id: UUID of the address to update
            user_id: UUID of the user
            address_data: Dictionary containing updated address data
            
        Returns:
            Tuple of (address, error_message)
            address is an Address object if update is successful
            error_message is empty if update is successful, otherwise contains the error
        """
        # Get existing address and verify ownership
        address_result = self.get_address_by_id(address_id, user_id)
        if address_result[1]:  # Error message exists
            return None, address_result[1]
        
        existing_address = address_result[0]
        
        # Create updated address object with new values
        updated_address = Address(
            id=existing_address.id,
            user_id=existing_address.user_id,
            street_number=address_data.get('street_number', existing_address.street_number),
            street_name=address_data.get('street_name', existing_address.street_name),
            city=address_data.get('city', existing_address.city),
            zip_code=address_data.get('zip_code', existing_address.zip_code),
            country=address_data.get('country', existing_address.country)
        )
        
        # Update address in repository
        try:
            result_address = self.address_repository.update(updated_address)
            return result_address, ""
        except Exception as e:
            logger.error(f"Error updating address: {str(e)}")
            return None, f"Error updating address: {str(e)}"
    
    def delete_address(self, address_id: uuid.UUID, user_id: uuid.UUID) -> Tuple[bool, str]:
        """Delete an address
        
        Args:
            address_id: UUID of the address to delete
            user_id: UUID of the user
            
        Returns:
            Tuple of (success, error_message)
            success is True if deletion is successful
            error_message is empty if deletion is successful, otherwise contains the error
        """
        # Get existing address and verify ownership
        address_result = self.get_address_by_id(address_id, user_id)
        if address_result[1]:  # Error message exists
            return False, address_result[1]
        
        # Delete address in repository
        try:
            success = self.address_repository.delete(address_id)
            if success:
                return True, ""
            else:
                return False, f"Error deleting address with ID {address_id}"
        except Exception as e:
            logger.error(f"Error deleting address: {str(e)}")
            return False, f"Error deleting address: {str(e)}"
