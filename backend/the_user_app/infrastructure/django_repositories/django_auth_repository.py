from typing import Tuple
import uuid
from datetime import datetime

from rest_framework_simplejwt.tokens import RefreshToken

from the_user_app.domain.models.entities import LogoutEvent, BlacklistedToken
from the_user_app.domain.repositories.auth_repository_interfaces import AuthRepository
from the_user_app.domain.value_objects.value_objects import AuthTokens
from the_user_app.infrastructure.django_models.orm_models import CustomUserModel, LogoutEventModel, BlacklistedTokenModel

class DjangoAuthRepository(AuthRepository):
    """Django ORM implementation of AuthRepository"""   
    
    def create_tokens(self, user_id: uuid.UUID) -> AuthTokens:
        """Create access and refresh tokens for a user
        
        Args:
            user_id: UUID of the user to create tokens for
            
        Returns:
            AuthTokens value object containing token data and user information
        """
        try:
            user_model = CustomUserModel.objects.get(id=user_id)
            refresh = RefreshToken.for_user(user_model)
            
            # Add custom claims to the token
            refresh['user_id'] = str(user_model.id)
            refresh['email'] = user_model.email
            refresh['first_name'] = user_model.first_name
            refresh['last_name'] = user_model.last_name
            
            # Create and return the AuthTokens value object
            return AuthTokens(
                access_token=str(refresh.access_token),
                refresh_token=str(refresh),
                user_id=str(user_model.id),
                email=user_model.email,
                first_name=user_model.first_name,
                last_name=user_model.last_name
            )
        except CustomUserModel.DoesNotExist:
            raise ValueError(f"User with ID {user_id} not found")
    
    def blacklist_token(self, token: str, user_id: uuid.UUID, expires_at: str) -> BlacklistedToken:
        """Blacklist a refresh token
        
        Args:
            token: Token to blacklist
            user_id: UUID of the user
            expires_at: Expiration date of the token
            
        Returns:
            Created BlacklistedToken object
        """
        try:
            user_model = CustomUserModel.objects.get(id=user_id)
            
            # Convert expires_at string to datetime
            expires_datetime = datetime.fromisoformat(expires_at.replace('Z', '+00:00'))
            
            blacklisted_token_model = BlacklistedTokenModel.objects.create(
                token=token,
                user=user_model,
                expires_at=expires_datetime
            )
            
            return self._token_to_domain(blacklisted_token_model)
        except CustomUserModel.DoesNotExist:
            raise ValueError(f"User with ID {user_id} not found")
    
    def is_token_blacklisted(self, token: str) -> bool:
        """Check if a token is blacklisted
        
        Args:
            token: Token to check
            
        Returns:
            True if token is blacklisted, False otherwise
        """
        return BlacklistedTokenModel.objects.filter(token=token).exists()
    
    def record_logout(self, logout_event: LogoutEvent) -> LogoutEvent:
        """Record a logout event
        
        Args:
            logout_event: LogoutEvent object to record
            
        Returns:
            Created LogoutEvent object
        """
        try:
            user_model = CustomUserModel.objects.get(id=logout_event.user_id)
            user_model.last_login = logout_event.created_at
            user_model.save()
            
            logout_event_model = LogoutEventModel.objects.create(
                id=logout_event.id,
                user=user_model,
                device_info=logout_event.device_info,
                ip_address=logout_event.ip_address,
                created_at=logout_event.created_at
            )
            
            return self._logout_to_domain(logout_event_model)
        except CustomUserModel.DoesNotExist:
            raise ValueError(f"User with ID {logout_event.user_id} not found")
    
    def _logout_to_domain(self, model: LogoutEventModel) -> LogoutEvent:
        """Convert ORM model to domain model"""
        return LogoutEvent(
            id=model.id,
            user_id=model.user.id,
            device_info=model.device_info,
            ip_address=model.ip_address,
            created_at=model.created_at
        )
    
    def _token_to_domain(self, model: BlacklistedTokenModel) -> BlacklistedToken:
        """Convert ORM model to domain model"""
        return BlacklistedToken(
            id=model.id,
            token=model.token,
            user_id=model.user.id,
            blacklisted_at=model.blacklisted_at,
            expires_at=model.expires_at
        )
