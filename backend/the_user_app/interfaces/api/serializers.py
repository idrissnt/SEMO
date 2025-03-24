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
    first_name = serializers.CharField(max_length=255)
    last_name = serializers.CharField(max_length=255, required=False, allow_null=True)
    phone_number = serializers.CharField(max_length=15, required=False, allow_null=True)
    role = serializers.ChoiceField(choices=['customer', 'driver'], default='customer', required=False)
    has_vehicle = serializers.BooleanField(required=False, default=False)
    license_number = serializers.CharField(max_length=100, required=False, allow_null=True)
    is_available = serializers.BooleanField(read_only=True, default=True)
    
    def validate(self, attrs):
        # Validate driver-specific fields
        if attrs.get('role') == 'driver':
            if not attrs.get('has_vehicle'):
                raise serializers.ValidationError(
                    "Vehicle is required for drivers"
                )
            if not attrs.get('license_number'):
                raise serializers.ValidationError(
                    "License number is required for drivers"
                )
        return attrs

class UserProfileSerializer(serializers.Serializer):
    """Serializer for User with addresses"""
    id = serializers.UUIDField(read_only=True)
    email = serializers.EmailField(read_only=True)
    first_name = serializers.CharField(max_length=255)
    last_name = serializers.CharField(max_length=255, required=False, allow_null=True)
    phone_number = serializers.CharField(max_length=15, required=False, allow_null=True)
    role = serializers.ChoiceField(choices=['customer', 'driver'], required=False)
    has_vehicle = serializers.BooleanField(required=False)
    license_number = serializers.CharField(max_length=100, required=False, allow_null=True)
    is_available = serializers.BooleanField(required=False)
    addresses = AddressSerializer(many=True, read_only=True)

class LoginRequestSerializer(serializers.Serializer):
    """Serializer for login request data"""
    email = serializers.EmailField(required=True)
    password = serializers.CharField(required=True)

class LoginResponseSerializer(serializers.Serializer):
    """Serializer for login response data"""
    access = serializers.CharField()
    refresh = serializers.CharField()
    message = serializers.CharField()

class PasswordChangeSerializer(serializers.Serializer):
    """Serializer for password change request data"""
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True, validators=[validate_password])
