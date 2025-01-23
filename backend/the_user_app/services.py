from django.contrib.auth import authenticate, get_user_model
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.utils import timezone
from .models import LogoutEvent
import logging

logger = logging.getLogger(__name__)
User = get_user_model()

class AuthService:
    @staticmethod
    def register_user(data):
        """Handle user registration business logic"""
        try:
            user = User.objects.create_user(
                username=data['username'],
                email=data['email'],
                password=data['password']
            )
            return user, None
        except Exception as e:
            logger.error(f"Error in user registration: {str(e)}")
            return None, str(e)

    @staticmethod
    def login_user(email, password):
        """
        Authenticate a user and return JWT tokens
        """
        try:
            user = authenticate(email=email, password=password)
            if user:
                refresh = RefreshToken.for_user(user)
                return {
                    'access': str(refresh.access_token),
                    'refresh': str(refresh)
                }, None
            return None, 'Invalid credentials'
        except Exception as e:
            logger.error(f"Error in login_user: {str(e)}")
            return None, str(e)

    @staticmethod
    def logout_user(user, refresh_token):
        """
        Logout a user and blacklist their refresh token
        """
        try:
            if not refresh_token:
                return False, 'Refresh token is required'
            
            token = RefreshToken(refresh_token)
            token.blacklist()
            LogoutEvent.objects.create(user=user, timestamp=timezone.now())
            return True, None
        except TokenError as e:
            return False, 'Invalid token'
        except Exception as e:
            logger.error(f"Error in logout_user: {str(e)}")
            return False, str(e)

class UserService:
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
            return None, str(e)
