from typing import Tuple, Dict, Any
import uuid
from datetime import datetime

from ..models.entities import LogoutEvent, AuthCredentials

class AuthDomainService:
    """Domain service for authentication-related operations"""
    
    @staticmethod
    def validate_credentials(email: str, password: str) -> Tuple[bool, str]:
        """Validate login credentials format
        
        Args:
            email: User email
            password: User password
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not email:
            return False, "Email is required"
        
        if not password:
            return False, "Password is required"
        
        return True, ""
    
    @staticmethod
    def validate_registration_data(user_data: Dict[str, Any]) -> Tuple[bool, str]:
        """Validate user registration data
        
        Args:
            user_data: Dictionary containing user registration data
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        if not user_data.get('email'):
            return False, "Email is required"
        
        if not user_data.get('password'):
            return False, "Password is required"
        
        if not user_data.get('first_name'):
            return False, "First name is required"
        
        # Validate driver-specific fields
        if user_data.get('role') == 'driver':
            if not user_data.get('has_vehicle'):
                return False, "Vehicle is required for drivers"
            
            if not user_data.get('license_number'):
                return False, "License number is required for drivers"
        
        return True, ""
    
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
