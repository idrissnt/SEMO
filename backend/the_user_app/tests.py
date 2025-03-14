from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import Address, LogoutEvent, BlacklistedToken
import logging

logger = logging.getLogger(__name__)
User = get_user_model()

# ------ Authentication Serializers ------
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = User.EMAIL_FIELD  # Email-based authentication

    @classmethod
    def get_token(cls, user):
        """Add custom claims to JWT tokens"""
        token = super().get_token(user)
        token.update({
            'id': str(user.id),
            'email': user.email,
            'role': user.role,
            'vehicle_type': user.vehicle_type
        })
        return token

    def validate(self, attrs):
        """Secure validation with error sanitization"""
        try:
            return super().validate(attrs)
        except Exception as e:
            logger.error(f"Auth failure for {attrs.get('email')}: {str(e)}")
            raise serializers.ValidationError(
                {'detail': 'Invalid credentials'},
                code='authorization'
            )

# ------ User Serializers ------
class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password],
        style={'input_type': 'password'}
    )

    class Meta:
        model = User
        fields = [
            'id', 'email', 'password', 
            'first_name', 'last_name', 'phone_number',
            'license_number', 'role', 'vehicle_type'
        ]
        extra_kwargs = {
            'license_number': {'required': True},
            'phone_number': {'required': True},
            'role': {'required': False},  # Defaults to 'customer'
            'vehicle_type': {'required': False}  # Defaults to 'car'
        }

    def validate(self, attrs):
        """Business logic validation"""
        if attrs.get('role', 'customer') == 'driver':
            if not attrs.get('vehicle_type'):
                raise serializers.ValidationError(
                    "Vehicle type required for driver role"
                )
            
            if not attrs.get('license_number'):
                raise serializers.ValidationError(
                    "License number required for driver role"
                )
        return attrs

    def create(self, validated_data):
        """Secure user creation with UUID"""
        try:
            user = User.objects.create_user(**validated_data)
            logger.info(f"User {user.email} created successfully")
            return user
        except Exception as e:
            logger.error(f"User creation failed: {str(e)}")
            raise serializers.ValidationError(
                {'detail': 'User creation failed. Verify input data.'}
            )

class UserProfileSerializer(serializers.ModelSerializer):
    addresses = serializers.PrimaryKeyRelatedField(
        many=True,
        read_only=True,
        help_text="List of user addresses"
    )

    class Meta:
        model = User
        fields = [
            'id', 'email', 'first_name', 'last_name',
            'phone_number', 'role', 'vehicle_type',
            'license_number', 'is_available', 'addresses'
        ]
        read_only_fields = [
            'email', 'role', 'vehicle_type',
            'license_number', 'is_available'
        ]

# ------ Address Serializer ------
class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = [
            'id', 'street_number', 'street_name',
            'city', 'zip_code', 'country', 
            'latitude', 'longitude'
        ]
        read_only_fields = ['id']
        extra_kwargs = {
            'user': {'write_only': True}  # Handle user assignment in view
        }

# ------ Security Serializers ------
class LogoutEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = LogoutEvent
        fields = ['id', 'device_info', 'ip_address', 'created_at']
        read_only_fields = ['created_at']

class BlacklistedTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlacklistedToken
        fields = ['id', 'token', 'expires_at']
        read_only_fields = ['blacklisted_at']