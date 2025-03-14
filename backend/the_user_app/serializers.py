from rest_framework import serializers
from django.contrib.auth import get_user_model # got AUTH_USER_MODEL (CustomUser) from the settings
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
import logging

logger = logging.getLogger(__name__)

User = get_user_model()

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Custom JWT token serializer that adds user information to the token payload
    """
    username_field = User.EMAIL_FIELD # the TokenObtainPairSerializer to use email as username

    @classmethod
    def get_token(cls, user):
        """
        Overrides get_token() to include extra claims.
        """
        token = super().get_token(user)
        
        # Include user details in the token
        token['user_id'] = user.id
        token['email'] = user.email
        token['first_name'] = user.first_name
        token['last_name'] = user.last_name
        
        return token

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True, 
        required=True,
        validators=[validate_password]
    )

    class Meta:
        model = User
        fields = [
            'id', 'email', 'password', 
            'first_name', 'last_name', 'phone_number',
            'role', 'vehicle_type', 'license_number', 'is_available'
        ]
        extra_kwargs = {
            'license_number': {'required': False},
            'phone_number': {'required': False},
            'role': {'required': False},
            'vehicle_type': {'required': False},
            'is_available': {'read_only': True}
        }

    def validate(self, attrs):
        # Validate driver-specific fields
        if attrs.get('role') == 'driver':
            if not attrs.get('vehicle_type'):
                raise serializers.ValidationError(
                    "Vehicle type is required for drivers"
                )
            if not attrs.get('license_number'):
                raise serializers.ValidationError(
                    "License number is required for drivers"
                )
        return attrs

    def create(self, validated_data):
        try:
            # Set default role if not provided
            if 'role' not in validated_data:
                validated_data['role'] = 'customer'
                
            return User.objects.create_user(**validated_data)
        except Exception as e:
            logger.error(f"User creation failed: {str(e)}")
            raise serializers.ValidationError(
                "Error creating user. Please check input data."
            )



class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = User.addresses.field.related_model
        fields = [
            'id', 'street_number', 'street_name', 'city', 
            'zip_code', 'country', 'latitude', 'longitude'
        ]

class UserProfileSerializer(serializers.ModelSerializer):
    addresses = AddressSerializer(many=True, read_only=True)
    
    class Meta:
        model = User
        fields = [
            'id', 'email', 'first_name', 'last_name', 'phone_number',
            'role', 'vehicle_type', 'license_number', 'is_available', 'addresses'
        ]
        read_only_fields = ('email', 'id')
        
    def update(self, instance, validated_data):
        # Update user fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance

class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True, validators=[validate_password])
    
    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError("Current password is incorrect")
        return value
