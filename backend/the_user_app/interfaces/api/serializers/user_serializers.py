from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
import logging

from the_user_app.domain.models.entities import User, Address, UserWithAddresses

logger = logging.getLogger(__name__)

class AddressSerializer(serializers.Serializer):
    """Serializer for Address domain model"""
    id = serializers.UUIDField(read_only=True)
    street_number = serializers.CharField(max_length=20)
    street_name = serializers.CharField(max_length=255)
    city = serializers.CharField(max_length=255)
    zip_code = serializers.CharField(max_length=20)
    country = serializers.CharField(max_length=255)

class UserSerializer(serializers.Serializer):
    """Serializer for User domain model"""
    id = serializers.UUIDField(read_only=True)
    email = serializers.EmailField()
    password = serializers.CharField(
        write_only=True, 
        required=True,
        validators=[validate_password]
    )
    profile_photo_url = serializers.URLField(required=False, allow_null=True)
    first_name = serializers.CharField(max_length=255)
    last_name = serializers.CharField(max_length=255, required=False, allow_null=True)
    phone_number = serializers.CharField(max_length=15, required=False, allow_null=True)

class UserProfileSerializer(serializers.Serializer):
    """Serializer for User with addresses"""
    id = serializers.UUIDField(read_only=True)
    email = serializers.EmailField(read_only=True)
    profile_photo_url = serializers.URLField(required=False, allow_null=True)
    first_name = serializers.CharField(max_length=255)
    last_name = serializers.CharField(max_length=255, required=False, allow_null=True)
    phone_number = serializers.CharField(max_length=15, required=False, allow_null=True)
    addresses = AddressSerializer(many=True, read_only=True)

class LoginRequestSerializer(serializers.Serializer):
    """Serializer for login request data"""
    email = serializers.EmailField(required=True)
    password = serializers.CharField(required=True)

class AuthTokensSerializer(serializers.Serializer):
    """Serializer for AuthTokens value object
    
    This serializer maps directly to the AuthTokens value object in the domain layer,
    ensuring consistent structure between domain objects and API responses.
    """
    access_token = serializers.CharField()
    refresh_token = serializers.CharField()
    user_id = serializers.CharField()
    email = serializers.EmailField()
    first_name = serializers.CharField()
    last_name = serializers.CharField(allow_null=True)

class PasswordChangeSerializer(serializers.Serializer):
    """Serializer for password change request data"""
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True, validators=[validate_password])
