from dataclasses import dataclass
from enum import Enum
from typing import List, Optional, Dict, Any


class ExperienceLevel(str, Enum):
    """Experience level value object for task performer profiles"""
    BEGINNER = 'beginner'
    INTERMEDIATE = 'intermediate'
    EXPERT = 'expert'   
    
    @classmethod
    def choices(cls) -> List[tuple]:
        """Return choices for Django model field"""
        return [(level.value, level.name.capitalize()) for level in cls]
    
    @classmethod
    def values(cls) -> List[str]:
        """Return all possible values"""
        return [level.value for level in cls]
    
    @classmethod
    def from_string(cls, value: str) -> Optional['ExperienceLevel']:
        """Create an ExperienceLevel from a string value
        
        Args:
            value: String value to convert
            
        Returns:
            ExperienceLevel instance or None if invalid
        """
        try:
            return cls(value.lower())
        except ValueError:
            return None
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary representation
        
        Returns:
            Dictionary with value and display_name
        """
        return {
            'value': self.value,
            'display_name': self.name.capitalize()
        }


@dataclass(frozen=True)
class AuthTokens:
    """Value object representing authentication tokens
    
    This value object encapsulates the structure of authentication tokens
    returned by the authentication system. It ensures that all token-related
    data is consistently structured throughout the application.
    
    Attributes:
        access_token: JWT access token for API authentication
        refresh_token: JWT refresh token for obtaining new access tokens
        user_id: UUID of the authenticated user
        email: Email of the authenticated user
        first_name: First name of the authenticated user
        last_name: Last name of the authenticated user
    """
    access_token: str
    refresh_token: str
    user_id: str
    email: str
    first_name: str
    last_name: Optional[str] = None
