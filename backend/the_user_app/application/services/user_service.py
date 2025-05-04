from typing import Optional, Dict, Any, Tuple
import uuid
import logging

from the_user_app.domain.models.entities import User
from the_user_app.domain.repositories.user_repository_interfaces import UserRepository

logger = logging.getLogger(__name__)

class UserApplicationService:
    """Application service for user-related use cases"""
    
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository
    
    def get_user_by_id(self, user_id: uuid.UUID) -> Optional[User]:
        """Get a user by ID
        
        Args:
            user_id: UUID of the user
            
        Returns:
            User object if found, None otherwise
        """
        return self.user_repository.get_by_id(user_id)
    
    def get_user_by_email(self, email: str) -> Optional[User]:
        """Get a user by email
        
        Args:
            email: Email of the user
            
        Returns:
            User object if found, None otherwise
        """
        return self.user_repository.get_by_email(email)
    
    def update_user_profile(self, user_id: uuid.UUID, profile_data: Dict[str, Any]) -> Tuple[Optional[User], str]:
        """Update a user's profile
        
        Args:
            user_id: UUID of the user to update
            profile_data: Dictionary containing updated profile data
            
        Returns:
            Tuple of (user, error_message)
            user is a User object if update is successful
            error_message is empty if update is successful, otherwise contains the error
        """
        # Get existing user
        user = self.user_repository.get_by_id(user_id)
        if not user:
            return None, f"User with ID {user_id} not found"
        
        # Create updated user object with new values
        updated_user = User(
            id=user.id,
            email=user.email,
            first_name=profile_data.get('first_name', user.first_name),
            last_name=profile_data.get('last_name', user.last_name),
            phone_number=profile_data.get('phone_number', user.phone_number),
        )
        
        # Update user in repository
        try:
            result_user = self.user_repository.update(updated_user)
            return result_user, ""
        except Exception as e:
            logger.error(f"Error updating user: {str(e)}")
            return None, f"Error updating user: {str(e)}"
    
    def delete_user(self, user_id: uuid.UUID) -> Tuple[bool, str]:
        """Delete a user
        
        Args:
            user_id: UUID of the user to delete
            
        Returns:
            Tuple of (success, error_message)
            success is True if deletion is successful
            error_message is empty if deletion is successful, otherwise contains the error
        """
        # Check if user exists
        user = self.user_repository.get_by_id(user_id)
        if not user:
            return False, f"User with ID {user_id} not found"
        
        # Delete user
        try:
            success = self.user_repository.delete(user_id)
            if success:
                return True, ""
            else:
                return False, "Error deleting user"
        except Exception as e:
            logger.error(f"Error deleting user: {str(e)}")
            return False, f"Error deleting user: {str(e)}"
