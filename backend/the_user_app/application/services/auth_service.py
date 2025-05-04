from typing import Dict, Any
from datetime import datetime
from django.utils.timezone import now
import uuid

from core.domain.services.logging_service_interface import LoggingServiceInterface
from core.domain.value_objects.result import Result

from the_user_app.domain.value_objects.value_objects import AuthTokens
from the_user_app.domain.user_exceptions import (
    UserAlreadyExistsException,
    InvalidCredentialsException,
    MissingRefreshTokenException,
)

from the_user_app.domain.models.entities import User
from the_user_app.domain.repositories.user_repository_interfaces import UserRepository
from the_user_app.domain.repositories.auth_repository_interfaces import AuthRepository
from the_user_app.domain.services.auth_service import AuthDomainService
from the_user_app.domain.models.events.user_events import UserRegisteredEvent
from core.domain_events.event_bus import event_bus

class AuthApplicationService:
    """Application service for authentication-related use cases"""
    
    def __init__(self, user_repository: UserRepository, auth_repository: AuthRepository, logger: LoggingServiceInterface):
        self.user_repository = user_repository
        self.auth_repository = auth_repository
        self.domain_service = AuthDomainService()
        self.logger = logger
    
    def login_user(self, email: str, password: str, last_login: datetime = now()) -> Result[AuthTokens, str]:
        """Login a user with email and password
        
        Args:
            email: User email
            password: User password
            last_login: Last login time
            
        Returns:
            Result containing AuthTokens on success or error message on failure
        """
        # Log login attempt
        self.logger.info(f"Login attempt for user: {email}", {"email": email})
        
        try:
            # Get user by email
            user = self.user_repository.get_by_email(email)
            if not user:
                self.logger.warning("User not found", {"email": email})
                return Result.failure(InvalidCredentialsException())
            
            # Check password
            if not self.user_repository.check_password(user.id, password, last_login):
                self.logger.warning("Invalid password", {"email": email, "user_id": str(user.id)})
                return Result.failure(InvalidCredentialsException())
            
            # Create tokens
            auth_tokens = self.auth_repository.create_tokens(user.id)
            self.logger.info("Login successful", {"email": email, "user_id": str(user.id)})
            return Result.success(auth_tokens)
            
        except Exception as e:
            self.logger.error("Error during login", {"email": email, "exception": str(e)})
            return Result.failure(e)
    
    def register_user(self, user_data: Dict[str, Any]) -> Result[AuthTokens, str]:
        """Register a new user
        
        Args:
            user_data: Dictionary containing user registration data
            
        Returns:
            Result containing AuthTokens on success or error message on failure
        """
        try:
            self.logger.info("Starting user registration", {"email": user_data['email']})
            # Check if user with this email already exists
            existing_user = self.user_repository.get_by_email(user_data['email'])
            if existing_user:
                self.logger.warning("User already exists", {"email": user_data['email']})
                return Result.failure(UserAlreadyExistsException(user_data['email']))
            
            # Create user domain entity
            user = User(
                email=user_data['email'],
                first_name=user_data['first_name'],
                last_name=user_data.get('last_name'),
                phone_number=user_data.get('phone_number'),
                profile_photo_url=user_data.get('profile_photo_url'),
            )
            
            # Create user in repository
            created_user = self.user_repository.create(user, user_data['password'])

            # Generate authentication tokens
            auth_tokens = self.auth_repository.create_tokens(created_user.id)

            # Publish user registered event
            event_bus.publish(UserRegisteredEvent.create(
                user_id=created_user.id))
            
            self.logger.info("User registered successfully", {"email": user_data['email'], "user_id": str(created_user.id)})
            return Result.success(auth_tokens)
            
        except Exception as e:
            self.logger.error("Error creating user", {
                'email': user_data.get('email'),
                'exception': str(e)
            })
            return Result.failure(e)
    
    def logout_user(self, user_id: uuid.UUID, refresh_token: str, device_info: str = "", ip_address: str = "") -> Result[bool, str]:
        """Logout a user and blacklist their refresh token
        
        Args:
            user_id: ID of the user to logout
            refresh_token: Refresh token to blacklist
            device_info: User device information
            ip_address: User IP address
            
        Returns:
            Result containing True on success or error message on failure
        """
        if not refresh_token:
            self.logger.warning("Missing refresh token", {"user_id": str(user_id)})
            return Result.failure(MissingRefreshTokenException())
        
        try:
            # Create logout event
            logout_event = self.domain_service.prepare_logout_event(
                user_id=user_id,
                device_info=device_info,
                ip_address=ip_address
            )
            
            # Record logout event
            self.auth_repository.record_logout(logout_event)
            
            # Check if token is already blacklisted
            if self.auth_repository.is_token_blacklisted(refresh_token):
                self.logger.warning("Token already blacklisted", {"user_id": str(user_id)})
                self.logger.info("User logged out successfully", {
                    'user_id': str(user_id),
                    'ip_address': ip_address
                })
                return Result.success(True)
            
            # Blacklist token
            # In a real implementation, we would decode the token to get the expiration time
            # For simplicity, we'll use a placeholder expiration time
            expiration = datetime.now().isoformat()
            self.auth_repository.blacklist_token(refresh_token, user_id, expiration)
            
            self.logger.info("User logged out successfully", {
                'user_id': str(user_id),
                'ip_address': ip_address
            })
            
            return Result.success(True)
            
        except Exception as e:
            self.logger.error("Error during logout", {
                'user_id': str(user_id),
                'exception': str(e)
            })
            return Result.failure(e)
