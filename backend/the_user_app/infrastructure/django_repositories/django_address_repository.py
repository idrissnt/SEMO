from typing import List, Optional
import uuid

from the_user_app.domain.models.entities import Address
from the_user_app.domain.repositories.repository_interfaces import AddressRepository
from the_user_app.infrastructure.django_models.orm_models import AddressModel, CustomUserModel

class DjangoAddressRepository(AddressRepository):
    """Django ORM implementation of AddressRepository"""
    
    def get_by_id(self, address_id: uuid.UUID) -> Optional[Address]:
        """Get address by ID
        
        Args:
            address_id: UUID of the address
            
        Returns:
            Address object if found, None otherwise
        """
        try:
            address_model = AddressModel.objects.get(id=address_id)
            return self._to_domain(address_model)
        except AddressModel.DoesNotExist:
            return None
    
    def get_by_user_id(self, user_id: uuid.UUID) -> List[Address]:
        """Get all addresses for a user
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of Address objects
        """
        address_models = AddressModel.objects.filter(user_id=user_id)
        return [self._to_domain(model) for model in address_models]
    
    def create(self, address: Address) -> Address:
        """Create a new address
        
        Args:
            address: Address object to create
            
        Returns:
            Created Address object
        """
        try:
            user_model = CustomUserModel.objects.get(id=address.user_id)
            
            address_model = AddressModel.objects.create(
                id=address.id,
                user=user_model,
                street_number=address.street_number,
                street_name=address.street_name,
                city=address.city,
                zip_code=address.zip_code,
                country=address.country
            )
            
            return self._to_domain(address_model)
        except CustomUserModel.DoesNotExist:
            raise ValueError(f"User with ID {address.user_id} not found")
    
    def update(self, address: Address) -> Address:
        """Update an existing address
        
        Args:
            address: Address object with updated fields
            
        Returns:
            Updated Address object
        """
        try:
            address_model = AddressModel.objects.get(id=address.id)
            
            # Update fields
            address_model.street_number = address.street_number
            address_model.street_name = address.street_name
            address_model.city = address.city
            address_model.zip_code = address.zip_code
            address_model.country = address.country
            
            address_model.save()
            return self._to_domain(address_model)
        except AddressModel.DoesNotExist:
            raise ValueError(f"Address with ID {address.id} not found")
    
    def delete(self, address_id: uuid.UUID) -> bool:
        """Delete an address
        
        Args:
            address_id: UUID of the address to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            address_model = AddressModel.objects.get(id=address_id)
            address_model.delete()
            return True
        except AddressModel.DoesNotExist:
            return False
    
    def _to_domain(self, model: AddressModel) -> Address:
        """Convert ORM model to domain model"""
        return Address(
            id=model.id,
            user_id=model.user.id,
            street_number=model.street_number,
            street_name=model.street_name,
            city=model.city,
            zip_code=model.zip_code,
            country=model.country
        )
