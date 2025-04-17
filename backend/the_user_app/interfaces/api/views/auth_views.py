from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from drf_spectacular.utils import extend_schema, OpenApiResponse
import logging
import uuid

from the_user_app.interfaces.api.serializers import (
    UserSerializer,
    LoginRequestSerializer,
    AuthTokensSerializer
)
from the_user_app.infrastructure.factory import UserFactory

logger = logging.getLogger(__name__)

@extend_schema(tags=['Authentication'])
class AuthViewSet(viewsets.ViewSet):
    """ViewSet for authentication operations
    
    This ViewSet provides endpoints for user authentication including registration,
    login, and logout. All endpoints return standardized error responses with the format:
    
    ```json
    {
        "error": "Error message",
        "code": "error_code",
        "request_id": "unique-request-id"
    }
    ```
    
    The request_id can be used for tracking and debugging issues.
    """
    
    def list(self, request):
        return Response({})

    @extend_schema(
        request=UserSerializer,
        responses={
            201: AuthTokensSerializer,
            400: OpenApiResponse(description='Validation error or server error'),
            409: OpenApiResponse(description='User already exists (code: user_already_exists)')
        },
        description='Register a new user',
        examples=[
            OpenApiExample(
                'Error: User already exists',
                value={
                    'error': 'User with this email already exists: user@example.com',
                    'code': 'user_already_exists',
                    'request_id': '123e4567-e89b-12d3-a456-426614174000'
                },
                status_codes=['409']
            ),
            OpenApiExample(
                'Error: Validation error',
                value={
                    'error': 'Invalid registration data',
                    'details': {'email': ['Enter a valid email address.']},
                    'code': 'validation_error',
                    'request_id': '123e4567-e89b-12d3-a456-426614174000'
                },
                status_codes=['400']
            )
        ]
    )
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def register(self, request):
        # Extract request ID or generate a new one
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Validate input data
        serializer = UserSerializer(data=request.data)
        if not serializer.is_valid():
            raise ValidationError(serializer.errors)
        
        # Get auth service from factory
        auth_service = UserFactory.create_auth_service()
        
        # Register user - domain exceptions will bubble up to global handler
        result = auth_service.register_user(serializer.validated_data)
        
        # On success, return the tokens
        serialized_data = AuthTokensSerializer(result.value).data
        serialized_data['request_id'] = request_id
        
        # Log success
        logger.info(
            'User registered successfully',
            {'email': serializer.validated_data.get('email')}
        )
        
        return Response(serialized_data, status=status.HTTP_201_CREATED)


    @extend_schema(
        request=LoginRequestSerializer,
        responses={
            200: AuthTokensSerializer,
            400: OpenApiResponse(description='Validation error or server error'),
            401: OpenApiResponse(description='Invalid credentials (code: invalid_credentials)')
        },
        description='Login with email and password',
        examples=[
            OpenApiExample(
                'Error: Invalid credentials',
                value={
                    'error': 'The email or password you entered is incorrect',
                    'code': 'invalid_credentials',
                    'request_id': '123e4567-e89b-12d3-a456-426614174000'
                },
                status_codes=['401']
            ),
            OpenApiExample(
                'Error: Validation error',
                value={
                    'error': 'Invalid input data',
                    'details': {'email': ['This field is required.']},
                    'code': 'validation_error',
                    'request_id': '123e4567-e89b-12d3-a456-426614174000'
                },
                status_codes=['400']
            )
        ]
    )
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def login(self, request):
        # Extract request ID or generate a new one
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Validate input data
        serializer = LoginRequestSerializer(data=request.data)
        if not serializer.is_valid():
            raise ValidationError(serializer.errors)
        
        # Extract credentials
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        
        # Get auth service from factory
        auth_service = UserFactory.create_auth_service()
        
        # Attempt login - domain exceptions will bubble up to global handler
        result = auth_service.login_user(email, password)
        
        # On success, return the tokens
        serialized_data = AuthTokensSerializer(result.value).data
        serialized_data['request_id'] = request_id
        
        # Log success
        logger.info(f"Login successful for user: {email}")
        
        return Response(serialized_data, status=status.HTTP_200_OK)


    @extend_schema(
        request={
            'type': 'object',
            'properties': {
                'refresh_token': {
                    'type': 'string',
                    'description': 'JWT refresh token to blacklist'
                }
            },
            'required': ['refresh_token']
        },
        responses={
            200: OpenApiResponse(
                description='Logout successful',
                response={
                    'type': 'object',
                    'properties': {
                        'message': {'type': 'string'},
                        'request_id': {'type': 'string'}
                    }
                }
            ),
            400: OpenApiResponse(description='Missing token or token already blacklisted'),
            401: OpenApiResponse(description='Authentication required or invalid token')
        },
        description='Logout and blacklist the refresh token',
        examples=[
            OpenApiExample(
                'Error: Missing token',
                value={
                    'error': 'Refresh token is required',
                    'code': 'missing_token',
                    'request_id': '123e4567-e89b-12d3-a456-426614174000'
                },
                status_codes=['400']
            ),
            OpenApiExample(
                'Error: Token blacklisted',
                value={
                    'error': 'Token is already blacklisted',
                    'code': 'token_blacklisted',
                    'request_id': '123e4567-e89b-12d3-a456-426614174000'
                },
                status_codes=['400']
            )
        ]
    )
    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
    def logout(self, request):
        # Extract request ID or generate a new one
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Extract required data
        refresh_token = request.data.get('refresh_token')
        device_info = request.META.get('HTTP_USER_AGENT', '')
        ip_address = request.META.get('REMOTE_ADDR', '')
        
        # Get user ID from authenticated user
        user_id = request.user.id  # Will raise 401 if not authenticated
        
        # Validate refresh token
        if not refresh_token:
            return Response({
                'error': 'Refresh token is required',
                'code': 'missing_token',
                'request_id': request_id
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Get auth service from factory
        auth_service = UserFactory.create_auth_service()
        
        # Logout user - domain exceptions will bubble up to global handler
        result = auth_service.logout_user(user_id, refresh_token, device_info, ip_address)
        
        # Log success
        logger.info(f"User {user_id} logged out successfully")
        
        # Return success response
        return Response({
            'message': 'Logout successful',
            'request_id': request_id
        })

