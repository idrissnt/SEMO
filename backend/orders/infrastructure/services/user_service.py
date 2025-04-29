from typing import Optional
from uuid import UUID

from orders.domain.services.user_service_interface import UserServiceInterface, UserInfo
from the_user_app.domain.repositories.user_repository_interfaces import UserRepository


class UserService(UserServiceInterface):
    """Implementation of UserServiceInterface that uses the actual UserRepository"""
    
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository
    
    def get_user_by_id(self, user_id: UUID) -> Optional[UserInfo]:
        """Get minimal user information by ID
        
        Args:
            user_id: ID of the user
            
        Returns:
            UserInfo if found, None otherwise
        """
        user = self.user_repository.get_by_id(user_id)
        if not user:
            return None
            
        return UserInfo(
            id=user.id,
            address=user.address
        )
