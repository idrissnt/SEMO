from abc import ABC, abstractmethod
from typing import List, Optional
import uuid
from the_user_app.domain.models.entities import Address



class AddressRepository(ABC):
    """Repository interface for Address domain model"""
    
    @abstractmethod
    def get_by_id(self, address_id: uuid.UUID) -> Optional[Address]:
        """Get address by ID
        
        Args:
            address_id: UUID of the address
            
        Returns:
            Address object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_user_id(self, user_id: uuid.UUID) -> List[Address]:
        """Get all addresses for a user
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of Address objects
        """
        pass
    
    @abstractmethod
    def create(self, address: Address) -> Address:
        """Create a new address
        
        Args:
            address: Address object to create
            
        Returns:
            Created Address object
        """
        pass
    
    @abstractmethod
    def update(self, address: Address) -> Address:
        """Update an existing address
        
        Args:
            address: Address object with updated fields
            
        Returns:
            Updated Address object
        """
        pass
    
    @abstractmethod
    def delete(self, address_id: uuid.UUID) -> bool:
        """Delete an address
        
        Args:
            address_id: UUID of the address to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass