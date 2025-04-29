from typing import Optional
import uuid
from datetime import datetime

from the_user_app.domain.models.entities import User
from the_user_app.domain.repositories.user_repository_interfaces import UserRepository
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
            
    def get_by_phone_number(self, phone_number: str) -> Optional[User]:
        """Get user by phone number
        
        Args:
            phone_number: Phone number of the user
            
        Returns:
            User object if found, None otherwise
        """
        try:
            user_model = CustomUserModel.objects.get(phone_number=phone_number)
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
            profile_photo_url=user.profile_photo_url,
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
    
    def check_password(self, 
        user_id: uuid.UUID, 
        password: str,
        last_login: Optional[datetime] = None
    ) -> bool:
        """Check if password is correct for a user
        
        Args:
            user_id: UUID of the user
            password: Password to check
            
        Returns:
            True if password is correct, False otherwise
        """
        try:
            user_model = CustomUserModel.objects.get(id=user_id)
            if user_model.check_password(password):
                if last_login:
                    user_model.last_login = last_login
                    user_model.save()
                return True
            return False
        except CustomUserModel.DoesNotExist:
            return False

    def delete(self, user_id: uuid.UUID) -> bool:
        """Delete a user
        
        Args:
            user_id: UUID of the user to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            user_model = CustomUserModel.objects.get(id=user_id)
            user_model.delete()
            return True
        except CustomUserModel.DoesNotExist:
            return False
            
    def mark_email_verified(self, user_id: uuid.UUID) -> bool:
        """Mark user's email as verified
        
        Args:
            user_id: UUID of the user
            
        Returns:
            True if successful, False otherwise
        """
        # Use direct update for better performance
        updated = CustomUserModel.objects.filter(id=user_id).update(email_verified=True)
        return updated > 0
            
    def mark_phone_verified(self, user_id: uuid.UUID) -> bool:
        """Mark user's phone as verified
        
        Args:
            user_id: UUID of the user
            
        Returns:
            True if successful, False otherwise
        """
        # Use direct update for better performance
        updated = CustomUserModel.objects.filter(id=user_id).update(phone_verified=True)
        return updated > 0
    
    def _to_domain(self, model: CustomUserModel) -> User:
        """Convert ORM model to domain model"""
        return User(
            id=model.id,
            email=model.email,
            first_name=model.first_name,
            last_name=model.last_name,
            phone_number=model.phone_number,
            profile_photo_url=model.profile_photo_url,
            last_login=model.last_login,
            created_at=model.created_at,
            updated_at=model.updated_at,
            email_verified=model.email_verified,
            phone_verified=model.phone_verified
        )
