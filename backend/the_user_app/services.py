from django.contrib.auth import authenticate, get_user_model
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.utils import timezone
from .models import LogoutEvent, BlacklistedToken
import logging
from datetime import timedelta

logger = logging.getLogger(__name__)
User = get_user_model()

class TokenService:
    """
    Service class for handling JWT token operations
    """
    @staticmethod
    def create_tokens_for_user(user):
        """
        Create access and refresh tokens for a user
        """
        try:
            refresh = RefreshToken.for_user(user)
            return {
                'access': str(refresh.access_token),
                'refresh': str(refresh)
            }, None
        except Exception as e:
            logger.error(f"Error creating tokens: {str(e)}")
            return None, f"Token generation failed: {str(e)}"
    
    @staticmethod
    def blacklist_token(user, refresh_token):
        """
        Blacklist a refresh token and record it in the database
        """
        try:
            if not refresh_token:
                return False, 'Refresh token is required'
            
            token = RefreshToken(refresh_token)
            # Get token expiry time
            token_exp = timezone.now() + timedelta(days=1)  # Default expiry, adjust as needed
            if hasattr(token, 'payload') and 'exp' in token.payload:
                token_exp = timezone.datetime.fromtimestamp(token.payload['exp'])
            
            # Blacklist the token in Simple JWT's system
            token.blacklist()
            
            # Also record in our custom model for additional tracking
            BlacklistedToken.objects.create(
                token=refresh_token,
                user=user,
                expires_at=token_exp
            )
            
            return True, None
        except TokenError:
            return False, 'Invalid token'
        except Exception as e:
            logger.error(f"Error blacklisting token: {str(e)}")
            return False, f"Token blacklisting failed: {str(e)}"

class AuthService:
    """
    Service class for authentication operations
    """
    @staticmethod
    def login_user(email, password):
        """
        Authenticate a user and return JWT tokens
        
        Args:
            email: User's email address
            password: User's password
            
        Returns:
            tuple: (tokens_dict, error_message)
                If successful, tokens_dict contains 'access' and 'refresh' tokens
                If failed, tokens_dict is None and error_message contains the error
        """
        try:
            # Check for empty credentials
            if not email or not password:
                return None, 'Email and password are required'
                
            user = authenticate(email=email, password=password)
            if not user:
                logger.warning(f"Failed login attempt for email: {email}")
                return None, 'Invalid credentials'
                
            # Use TokenService to generate tokens
            return TokenService.create_tokens_for_user(user)
            
        except Exception as e:
            logger.error(f"Error in login_user: {str(e)}")
            return None, f"Authentication failed: {str(e)}"

    @staticmethod
    def logout_user(user, refresh_token):
        """
        Logout a user and blacklist their refresh token
        
        Args:
            user: The user to log out
            refresh_token: The refresh token to blacklist
            
        Returns:
            tuple: (success, error_message)
                If successful, success is True and error_message is None
                If failed, success is False and error_message contains the error
        """
        try:
            if not refresh_token:
                return False, 'Refresh token is required'
            
            # Use TokenService to blacklist the token
            success, error = TokenService.blacklist_token(user, refresh_token)
            if not success:
                return False, error
                
            # Create logout event record
            LogoutEvent.objects.create(
                user=user,
                device_info="",  # This will be filled by the view
                ip_address="127.0.0.1"  # This will be filled by the view
            )
            
            return True, None
            
        except Exception as e:
            logger.error(f"Error in logout_user: {str(e)}")
            return False, f"Logout failed: {str(e)}"

class UserService:
    """
    Service class for user management operations
    """
    @staticmethod
    def update_profile(user, data):
        """Handle user profile update business logic"""
        try:
            for field, value in data.items():
                if hasattr(user, field) and field != 'password':
                    setattr(user, field, value)
            user.save()
            return user, None
        except Exception as e:
            logger.error(f"Error updating user profile: {str(e)}")
            return None, f"Profile update failed: {str(e)}"
