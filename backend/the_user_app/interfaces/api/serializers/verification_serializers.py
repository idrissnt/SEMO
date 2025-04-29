from rest_framework import serializers
from the_user_app.domain.models.verification_code import VerificationCodeType, VerificationCode

class EmailVerificationRequestSerializer(serializers.Serializer):
    """Serializer for requesting email verification"""
    email = serializers.EmailField(required=True)

class PhoneVerificationRequestSerializer(serializers.Serializer):
    """Serializer for requesting phone verification"""
    phone_number = serializers.CharField(required=True, max_length=15)

class VerificationCodeSerializer(serializers.Serializer):

    """Serializer for verifying a code"""
    user_id = serializers.UUIDField(required=True)
    code = serializers.CharField(required=True, min_length=VerificationCode.min_length_code_validation())
    verification_type = serializers.ChoiceField(
        required=True,
        choices=VerificationCodeType.values()
    )

class PasswordResetRequestSerializer(serializers.Serializer):
    """Serializer for requesting a password reset"""
    email = serializers.EmailField(required=False)
    phone_number = serializers.CharField(required=False, max_length=15)
    
    def validate(self, data):
        """Validate that either email or phone_number is provided"""
        if not data.get('email') and not data.get('phone_number'):
            raise serializers.ValidationError("Either email or phone_number must be provided")
        return data

class PasswordResetConfirmSerializer(serializers.Serializer):
    """Serializer for confirming a password reset"""
    user_id = serializers.UUIDField(required=True)
    code = serializers.CharField(required=True, min_length=VerificationCode.min_length_code_validation())
    new_password = serializers.CharField(required=True, min_length=VerificationCode.min_length_password_reset())