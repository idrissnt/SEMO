from typing import Optional
import uuid

from django.contrib.auth import get_user_model

from the_user_app.domain.models.entities import User
from the_user_app.domain.repositories.repository_interfaces import UserRepository
from the_user_app.infrastructure.django_models.orm_models import CustomUserModel

class DjangoUserRepository(UserRepository):
    """Django ORM implementation of UserRepository"""
    
    def get_by_id(self, user_id: uuid.UUID) -> Optional[User]:
        """Get user by ID
        
        Args:
            user_id: UUID of the user
            
        Returns:
            User object if found, None otherwise
        """
        try:
            user_model = CustomUserModel.objects.get(id=user_id)
            return self._to_domain(user_model)
        except CustomUserModel.DoesNotExist:
            return None
    
    def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email
        
        Args:
            email: Email of the user
            
        Returns:
            User object if found, None otherwise
        """
        try:
            user_model = CustomUserModel.objects.get(email=email)
            return self._to_domain(user_model)
        except CustomUserModel.DoesNotExist:
            return None
    
    def create(self, user: User, password: str) -> User:
        """Create a new user
        
        Args:
            user: User object to create
            password: Password for the user
            
        Returns:
            Created User object
        """
        user_model = CustomUserModel.objects.create_user(
            email=user.email,
            password=password,
            first_name=user.first_name,
            last_name=user.last_name,
            phone_number=user.phone_number,
            role=user.role,
            has_vehicle=user.has_vehicle,
            license_number=user.license_number,
            is_available=user.is_available
        )
        return self._to_domain(user_model)
    
    def update(self, user: User) -> User:
        """Update an existing user
        
        Args:
            user: User object with updated fields
            
        Returns:
            Updated User object
        """
        try:
            user_model = CustomUserModel.objects.get(id=user.id)
            
            # Update fields
            user_model.first_name = user.first_name
            user_model.last_name = user.last_name
            user_model.phone_number = user.phone_number
            user_model.role = user.role
            user_model.has_vehicle = user.has_vehicle
            user_model.license_number = user.license_number
            user_model.is_available = user.is_available
            
            user_model.save()
            return self._to_domain(user_model)
        except CustomUserModel.DoesNotExist:
            raise ValueError(f"User with ID {user.id} not found")
    
    def set_password(self, user_id: uuid.UUID, password: str) -> bool:
        """Set password for a user
        
        Args:
            user_id: UUID of the user
            password: New password
            
        Returns:
            True if successful, False otherwise
        """
        try:
            user_model = CustomUserModel.objects.get(id=user_id)
            user_model.set_password(password)
            user_model.save()
            return True
        except CustomUserModel.DoesNotExist:
            return False
    
    def check_password(self, user_id: uuid.UUID, password: str) -> bool:
        """Check if password is correct for a user
        
        Args:
            user_id: UUID of the user
            password: Password to check
            
        Returns:
            True if password is correct, False otherwise
        """
        try:
            user_model = CustomUserModel.objects.get(id=user_id)
            return user_model.check_password(password)
        except CustomUserModel.DoesNotExist:
            return False
    
    def _to_domain(self, model: CustomUserModel) -> User:
        """Convert ORM model to domain model"""
        return User(
            id=model.id,
            email=model.email,
            first_name=model.first_name,
            last_name=model.last_name,
            phone_number=model.phone_number,
            role=model.role,
            has_vehicle=model.has_vehicle,
            license_number=model.license_number,
            is_available=model.is_available,
            is_active=model.is_active
        )
