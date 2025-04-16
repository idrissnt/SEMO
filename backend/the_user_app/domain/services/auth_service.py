import uuid
from datetime import datetime

from ..models.entities import LogoutEvent, AuthCredentials

class AuthDomainService:
    """Domain service for authentication-related operations"""
    
    @staticmethod
    def prepare_logout_event(user_id: uuid.UUID, device_info: str, ip_address: str) -> LogoutEvent:
        """Create a logout event object
        
        Args:
            user_id: UUID of the user
            device_info: User device information
            ip_address: User IP address
            
        Returns:
            LogoutEvent object
        """
        return LogoutEvent(
            user_id=user_id,
            device_info=device_info,
            ip_address=ip_address,
            created_at=datetime.now()
        )
    
    @staticmethod
    def format_auth_response(access_token: str, refresh_token: str) -> AuthCredentials:
        """Format authentication response
        
        Args:
            access_token: JWT access token
            refresh_token: JWT refresh token
            
        Returns:
            AuthCredentials object
        """
        return AuthCredentials(
            access_token=access_token,
            refresh_token=refresh_token
        )
