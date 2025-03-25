from abc import ABC, abstractmethod
from typing import List, Optional, Tuple
import uuid
from ..models.entities import User, Address, UserWithAddresses, LogoutEvent, BlacklistedToken

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
    def check_password(self, user_id: uuid.UUID, password: str) -> bool:
        """Check if password is correct for a user
        
        Args:
            user_id: UUID of the user
            password: Password to check
            
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
    def create_tokens(self, user: User) -> Tuple[str, str]:
        """Create access and refresh tokens for a user
        
        Args:
            user: User to create tokens for
            
        Returns:
            Tuple of (access_token, refresh_token)
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
    def record_logout(self, logout_event: LogoutEvent) -> LogoutEvent:
        """Record a logout event
        
        Args:
            logout_event: LogoutEvent object to record
            
        Returns:
            Created LogoutEvent object
        """
        pass
