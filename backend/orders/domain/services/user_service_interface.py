from abc import ABC, abstractmethod
from typing import Optional
from uuid import UUID
from dataclasses import dataclass


@dataclass
class UserInfo:
    """Minimal user information needed by the orders domain"""
    id: UUID
    address: Optional[str] = None


class UserServiceInterface(ABC):
    """Interface for user-related operations needed by the orders domain"""
    
    @abstractmethod
    def get_user_by_id(self, user_id: UUID) -> Optional[UserInfo]:
        """Get minimal user information by ID
        
        Args:
            user_id: ID of the user
            
        Returns:
            UserInfo if found, None otherwise
        """
        pass
