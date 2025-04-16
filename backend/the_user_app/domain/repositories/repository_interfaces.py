from abc import ABC, abstractmethod
from typing import List, Optional
import uuid
from datetime import datetime
from the_user_app.domain.models.entities import User, Address, LogoutEvent, BlacklistedToken, TaskPerformerProfile
from the_user_app.domain.value_objects.value_objects import AuthTokens

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

class AuthRepository(ABC):
    """Repository interface for authentication operations"""
    
    @abstractmethod
    def create_tokens(self, user_id: uuid.UUID) -> AuthTokens:
        """Create access and refresh tokens for a user
        
        Args:
            user_id: UUID of the user to create tokens for
            
        Returns:
            AuthTokens value object containing token data and user information
        """
        pass
    
    @abstractmethod
    def blacklist_token(self, token: str, user_id: uuid.UUID, expires_at: str) -> BlacklistedToken:
        """Blacklist a refresh token
        
        Args:
            token: Token to blacklist
            user_id: UUID of the user
            expires_at: Expiration date of the token
            
        Returns:
            Created BlacklistedToken object
        """
        pass
    
    @abstractmethod
    def is_token_blacklisted(self, token: str) -> bool:
        """Check if a token is blacklisted
        
        Args:
            token: Token to check
            
        Returns:
            True if token is blacklisted, False otherwise
        """
        pass
    
    @abstractmethod
    def record_logout(self, logout_event: LogoutEvent, last_logout: Optional[datetime] = None) -> LogoutEvent:
        """Record a logout event
        
        Args:
            logout_event: LogoutEvent object to record
            last_logout: Last logout time
            
        Returns:
            Created LogoutEvent object
        """
        pass


class TaskPerformerProfileRepository(ABC):
    """Repository interface for TaskPerformerProfile domain model"""
    
    @abstractmethod
    def get_by_id(self, profile_id: uuid.UUID) -> Optional[TaskPerformerProfile]:
        """Get performer profile by ID
        
        Args:
            profile_id: UUID of the profile
            
        Returns:
            TaskPerformerProfile object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_user_id(self, user_id: uuid.UUID) -> Optional[TaskPerformerProfile]:
        """Get performer profile by user ID
        
        Args:
            user_id: UUID of the user
            
        Returns:
            TaskPerformerProfile object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def create(self, profile: TaskPerformerProfile) -> TaskPerformerProfile:
        """Create a new performer profile
        
        Args:
            profile: TaskPerformerProfile object to create
            
        Returns:
            Created TaskPerformerProfile object
        """
        pass
    
    @abstractmethod
    def update(self, profile: TaskPerformerProfile) -> TaskPerformerProfile:
        """Update an existing performer profile
        
        Args:
            profile: TaskPerformerProfile object with updated fields
            
        Returns:
            Updated TaskPerformerProfile object
        """
        pass
    
    @abstractmethod
    def delete(self, profile_id: uuid.UUID) -> bool:
        """Delete a performer profile
        
        Args:
            profile_id: UUID of the profile to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
    
    @abstractmethod
    def find_by_skills(self, skills: List[str]) -> List[TaskPerformerProfile]:
        """Find performer profiles by skills
        
        Args:
            skills: List of skills to search for
            
        Returns:
            List of TaskPerformerProfile objects matching the skills
        """
        pass
    
    @abstractmethod
    def find_by_location(self, latitude: float, longitude: float, radius_km: float) -> List[TaskPerformerProfile]:
        """Find performer profiles near a location
        
        Args:
            latitude: Latitude of the center point
            longitude: Longitude of the center point
            radius_km: Radius in kilometers
            
        Returns:
            List of TaskPerformerProfile objects within the radius
        """
        pass
