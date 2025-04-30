from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiResponse
import uuid

from core.infrastructure.factories.logging_factory import CoreLoggingFactory
from the_user_app.domain.user_exceptions import InvalidInputException
from the_user_app.infrastructure.factory import UserFactory

# Create a logger using our custom logging service
logger = CoreLoggingFactory.create_logger("verification_views")

# Serializers for verification endpoints
from the_user_app.interfaces.api.serializers.verification_serializers import (
    EmailVerificationRequestSerializer,
    PhoneVerificationRequestSerializer,
    VerificationCodeSerializer,
    PasswordResetRequestSerializer,
    PasswordResetConfirmSerializer
)

class VerificationViewSet(viewsets.ViewSet):
    """ViewSet for verification operations"""
    
    @extend_schema(
        request=EmailVerificationRequestSerializer,
        responses={
            200: OpenApiResponse(description='Verification code sent successfully'),
            400: OpenApiResponse(description='Invalid input'),
            500: OpenApiResponse(description='Verification failed')
        },
        description='Request an email verification code'
    )
    @action(detail=False, methods=['post'], permission_classes=[AllowAny], url_path='request-email-verification')
    def request_email_verification(self, request):
        # Extract request ID or generate a new one
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Validate input data format
        serializer = EmailVerificationRequestSerializer(data=request.data)
        if not serializer.is_valid():
            raise InvalidInputException(serializer.errors)
        
        email = serializer.validated_data['email']
        
        # Get verification application service
        verification_service = UserFactory.create_verification_application_service()
        
        # Request email verification
        result = verification_service.request_email_verification(email)
        
        if result.is_success():
            # Always return success for security reasons
            return Response({
                'message': 'If the email exists, a verification code has been sent',
                'request_id': request_id
            })
        else:
            # If there's an error, raise it directly
            raise result.error
    
    @extend_schema(
        request=PhoneVerificationRequestSerializer,
        responses={
            200: OpenApiResponse(description='Verification code sent successfully'),
            400: OpenApiResponse(description='Invalid input'),
            500: OpenApiResponse(description='Verification failed')
        },
        description='Request a phone verification code'
    )
    @action(detail=False, methods=['post'], permission_classes=[AllowAny], url_path='request-phone-verification')
    def request_phone_verification(self, request):
        # Extract request ID or generate a new one
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Validate input data format
        serializer = PhoneVerificationRequestSerializer(data=request.data)
        if not serializer.is_valid():
            raise InvalidInputException(serializer.errors)
        
        phone_number = serializer.validated_data['phone_number']
        
        # Get verification application service
        verification_service = UserFactory.create_verification_application_service()
        
        # Request phone verification
        result = verification_service.request_phone_verification(phone_number)
        
        if result.is_success():
            # Always return success for security reasons
            return Response({
                'message': 'If the phone number exists, a verification code has been sent',
                'request_id': request_id
            })
        else:
            # If there's an error, raise it directly
            raise result.error
    
    @extend_schema(
        request=VerificationCodeSerializer,
        responses={
            200: OpenApiResponse(description='Verification successful'),
            400: OpenApiResponse(description='Invalid or expired code'),
            404: OpenApiResponse(description='User not found')
        },
        description='Verify a code'
    )
    @action(detail=False, methods=['post'], permission_classes=[AllowAny], url_path='verify-code')
    def verify_code(self, request):
        # Extract request ID or generate a new one
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Validate input data format
        serializer = VerificationCodeSerializer(data=request.data)
        if not serializer.is_valid():
            raise InvalidInputException(serializer.errors)
        
        user_id = serializer.validated_data['user_id']
        code = serializer.validated_data['code']
        verification_type = serializer.validated_data['verification_type']
        
        # Get verification application service
        verification_service = UserFactory.create_verification_application_service()
        
        # Verify code
        result = verification_service.verify_code(user_id, code, verification_type)
        
        if result.is_success():
            return Response({
                'message': 'Verification successful',
                'request_id': request_id
            })
        else:
            # If there's an error, raise it directly
            raise result.error
    
    @extend_schema(
        request=PasswordResetRequestSerializer,
        responses={
            200: OpenApiResponse(description='Password reset code sent successfully'),
            400: OpenApiResponse(description='Invalid input'),
            500: OpenApiResponse(description='Password reset failed')
        },
        description='Request a password reset code'
    )
    @action(detail=False, methods=['post'], permission_classes=[AllowAny], url_path='request-password-reset')
    def request_password_reset(self, request):
        # Extract request ID or generate a new one
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Validate input data format
        serializer = PasswordResetRequestSerializer(data=request.data)
        if not serializer.is_valid():
            raise InvalidInputException(serializer.errors)
        
        email = serializer.validated_data.get('email')
        phone_number = serializer.validated_data.get('phone_number')
        
        # Get verification application service
        verification_service = UserFactory.create_verification_application_service()
        
        # Request password reset
        result = verification_service.request_password_reset(email, phone_number)
        
        if result.is_success():
            # Always return success for security reasons
            return Response({
                'message': 'If the account exists, a password reset code has been sent',
                'request_id': request_id
            })
        else:
            # If there's an error, raise it directly
            raise result.error
    
    @extend_schema(
        request=PasswordResetConfirmSerializer,
        responses={
            200: OpenApiResponse(description='Password reset successful'),
            400: OpenApiResponse(description='Invalid or expired code'),
            404: OpenApiResponse(description='User not found'),
            500: OpenApiResponse(description='Password reset failed')
        },
        description='Reset password with a verification code'
    )
    @action(detail=False, methods=['post'], permission_classes=[AllowAny], url_path='reset-password')
    def reset_password(self, request):
        # Extract request ID or generate a new one
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Validate input data format
        serializer = PasswordResetConfirmSerializer(data=request.data)
        if not serializer.is_valid():
            raise InvalidInputException(serializer.errors)
        
        user_id = serializer.validated_data['user_id']
        code = serializer.validated_data['code']
        new_password = serializer.validated_data['new_password']
        
        # Get verification application service
        verification_service = UserFactory.create_verification_application_service()
        
        # Reset password
        result = verification_service.reset_password(user_id, code, new_password)
        
        if result.is_success():
            return Response({
                'message': 'Password reset successful',
                'request_id': request_id
            })
        else:
            # If there's an error, raise it directly
            raise result.error
