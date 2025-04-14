from typing import Tuple, Dict, Any, Optional
import logging
from datetime import datetime
from django.utils.timezone import now
import uuid

from the_user_app.domain.models.entities import User
from the_user_app.domain.repositories.repository_interfaces import UserRepository, AuthRepository
from the_user_app.domain.services.auth_service import AuthDomainService
from the_user_app.domain.models.events.user_events import UserRegisteredEvent
from core.domain_events.event_bus import event_bus

logger = logging.getLogger(__name__)

class AuthApplicationService:
    """Application service for authentication-related use cases"""
    
    def __init__(self, user_repository: UserRepository, auth_repository: AuthRepository):
        self.user_repository = user_repository
        self.auth_repository = auth_repository
        self.domain_service = AuthDomainService()
    
    def login_user(self, email: str, password: str, last_login: datetime = now()) -> Tuple[Optional[Dict[str, str]], str]:
        """Login a user with email and password
        
        Args:
            email: User email
            password: User password
            last_login: Last login time
            
        Returns:
            Tuple of (auth_data, error_message)
            auth_data is a dictionary with access and refresh tokens if login is successful
            error_message is empty if login is successful, otherwise contains the error
        """
        # Validate credentials format
        is_valid, error = self.domain_service.validate_credentials(email, password)
        if not is_valid:
            return None, error
        
        # Get user by email
        user = self.user_repository.get_by_email(email)
        if not user:
            return None, "Invalid credentials"
        
        # Check password
        if not self.user_repository.check_password(user.id, password, last_login):
            return None, "Invalid credentials"
        
        # Create tokens
        try:
            access_token, refresh_token = self.auth_repository.create_tokens(user)
            
            # Return tokens and user data
            return {
                'access_token': access_token,
                'refresh_token': refresh_token,
                'user': user
            }, "login success"
        except Exception as e:
            logger.error(f"Error creating tokens: {str(e)}")
            return None, "Error creating authentication tokens"
    
    def register_user(self, user_data: Dict[str, Any]) -> Tuple[Optional[User], str]:
        """Register a new user
        
        Args:
            user_data: Dictionary containing user registration data
            
        Returns:
            Tuple of (user, error_message)
            user is a User object if registration is successful
            error_message is empty if registration is successful, otherwise contains the error
        """
        # Validate registration data
        is_valid, error = self.domain_service.validate_registration_data(user_data)
        if not is_valid:
            return None, error
        
        # Check if user with this email already exists
        existing_user = self.user_repository.get_by_email(user_data['email'])
        if existing_user:
            return None, "User with this email already exists"
        
        # Create user domain entity
        user = User(
            email=user_data['email'],
            first_name=user_data['first_name'],
            last_name=user_data.get('last_name'),
            phone_number=user_data.get('phone_number'),
            profile_photo_url=user_data.get('profile_photo_url'),
        )
        
        # Create user in repository
        try:
            created_user = self.user_repository.create(user, user_data['password'])

            access_token, refresh_token = self.auth_repository.create_tokens(user)

            # Publish user registered event
            event_bus.publish(UserRegisteredEvent.create(
                user_id=created_user.id))
            
            return {'access_token': access_token, 
                    'refresh_token': refresh_token, 
                    'user': created_user}, ""
        except Exception as e:
            logger.error(f"Error creating user: {str(e)}")
            return None, "Error creating user"
    
    def logout_user(self, user_id: uuid.UUID, refresh_token: str, device_info: str = "", ip_address: str = "") -> Tuple[bool, str]:
        """Logout a user and blacklist their refresh token
        
        Args:
            user: User to logout
            refresh_token: Refresh token to blacklist
            device_info: User device information
            ip_address: User IP address
            
        Returns:
            Tuple of (success, error_message)
            success is True if logout is successful
            error_message is empty if logout is successful, otherwise contains the error
        """
        if not refresh_token:
            return False, "Refresh token is required"
        
        try:
            # Check if token is already blacklisted
            if self.auth_repository.is_token_blacklisted(refresh_token):
                return False, "Token is already blacklisted"
            
            # Create logout event
            logout_event = self.domain_service.prepare_logout_event(
                user_id=user_id,
                device_info=device_info,
                ip_address=ip_address
            )
            
            # Record logout event
            self.auth_repository.record_logout(logout_event)
            
            # Blacklist token
            # In a real implementation, we would decode the token to get the expiration time
            # For simplicity, we'll use a placeholder expiration time
            expiration = datetime.now().isoformat()
            self.auth_repository.blacklist_token(refresh_token, user_id, expiration)
            
            return True, ""
        except Exception as e:
            logger.error(f"Error during logout: {str(e)}")
            return False, "Error during logout"
