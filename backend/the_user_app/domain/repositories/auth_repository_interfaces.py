from abc import ABC, abstractmethod
from typing import Optional
import uuid
from datetime import datetime
from the_user_app.domain.models.entities import LogoutEvent, BlacklistedToken
from the_user_app.domain.value_objects.value_objects import AuthTokens


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
