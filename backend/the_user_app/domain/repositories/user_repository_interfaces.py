
from abc import ABC, abstractmethod
from typing import Optional
import uuid
from datetime import datetime
from the_user_app.domain.models.entities import User



class UserRepository(ABC):
    """Repository interface for User domain model"""
    
    @abstractmethod
    def get_by_id(self, user_id: uuid.UUID) -> Optional[User]:
        """Get user by ID
        
        Args:
            user_id: UUID of the user
            
        Returns:
            User object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email
        
        Args:
            email: Email of the user
            
        Returns:
            User object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_phone_number(self, phone_number: str) -> Optional[User]:
        """Get user by phone number
        
        Args:
            phone_number: Phone number of the user
            
        Returns:
            User object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def create(self, user: User, password: str) -> User:
        """Create a new user
        
        Args:
            user: User object to create
            password: Password for the user
            
        Returns:
            Created User object
        """
        pass
    
    @abstractmethod
    def update(self, user: User) -> User:
        """Update an existing user
        
        Args:
            user: User object with updated fields
            
        Returns:
            Updated User object
        """
        pass
    
    @abstractmethod
    def set_password(self, user_id: uuid.UUID, password: str) -> bool:
        """Set password for a user
        
        Args:
            user_id: UUID of the user
            password: New password
            
        Returns:
            True if successful, False otherwise
        """
        pass
    
    @abstractmethod
    def check_password(self, 
        user_id: uuid.UUID, 
        password: str, 
        last_login: Optional[datetime] = None
    ) -> bool:
        """Check if password is correct for a user
        
        Args:
            user_id: UUID of the user
            password: Password to check
            last_login: Last login time
            
        Returns:
            True if password is correct, False otherwise
        """
        pass
    
    @abstractmethod
    def delete(self, user_id: uuid.UUID) -> bool:
        """Delete a user
        
        Args:
            user_id: UUID of the user to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
    
    @abstractmethod
    def mark_email_verified(self, user_id: uuid.UUID) -> bool:
        """Mark user's email as verified
        
        Args:
            user_id: UUID of the user
            
        Returns:
            True if successful, False otherwise
        """
        pass
    
    @abstractmethod
    def mark_phone_verified(self, user_id: uuid.UUID) -> bool:
        """Mark user's phone as verified
        
        Args:
            user_id: UUID of the user
            
        Returns:
            True if successful, False otherwise
        """
        pass