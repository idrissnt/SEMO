from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiResponse
from drf_spectacular.utils import OpenApiExample
import uuid

from core.infrastructure.factories.logging_factory import CoreLoggingFactory
from the_user_app.domain.user_exceptions import InvalidInputException

from the_user_app.interfaces.api.serializers import (
    UserSerializer,
    LoginRequestSerializer,
    AuthTokensSerializer,
)
from the_user_app.infrastructure.factory import UserFactory

# Create a logger using our custom logging service
logger = CoreLoggingFactory.create_logger("auth_views")

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
            )
        ]
    )
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def register(self, request):
        # Extract request ID or generate a new one
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Validate input data format (not business rules)
        serializer = UserSerializer(data=request.data)
        if not serializer.is_valid():
            raise InvalidInputException(serializer.errors)
        
        # Get auth service from factory
        auth_service = UserFactory.create_auth_service()
        
        # Register user and get Result object
        # The domain layer will handle business rules like checking for existing users
        result = auth_service.register_user(serializer.validated_data)
        
        # Check if registration was successful
        if result.is_success():
            # On success, return the tokens
            serialized_data = AuthTokensSerializer(result.value).data
            serialized_data['request_id'] = request_id
            
            # Log success
            logger.info(
                'User registered successfully',
                {'email': serializer.validated_data.get('email'), 'request_id': request_id}
            )
            
            return Response(serialized_data, status=status.HTTP_201_CREATED)
        else:
            # If registration failed, raise the exception from the Result
            # This will be caught by the global exception handler
            if hasattr(result.error, '__call__'):
                # If it's a callable (like a function), call it
                raise result.error
            else:
                # Otherwise, raise it directly
                raise result.error

    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def login(self, request):
        # Extract request ID or generate a new one
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Validate input data
        serializer = LoginRequestSerializer(data=request.data)
        if not serializer.is_valid():
            error_message = "; ".join([f"{field}: {', '.join(errors)}" for field, errors in serializer.errors.items()])
            raise InvalidInputException(error_message)
        
        # Extract credentials
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        
        # Get auth service from factory
        auth_service = UserFactory.create_auth_service()
        
        # Attempt login - get Result object
        result = auth_service.login_user(email, password)
        
        # Check if login was successful
        if result.is_success():
            # On success, return the tokens
            serialized_data = AuthTokensSerializer(result.value).data
            serialized_data['request_id'] = request_id
            
            # Log success
            logger.info("Login successful", {"user_email": email, "request_id": request_id})
            
            return Response(serialized_data, status=status.HTTP_200_OK)
        else:
            # If login failed, raise the exception from the Result
            # This will be caught by the global exception handler
            if hasattr(result.error, '__call__'):
                # If it's a callable (like a function), call it
                raise result.error
            else:
                # Otherwise, raise it directly
                raise result.error
    


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
        
        # Get auth service from factory
        auth_service = UserFactory.create_auth_service()
        
        # Logout user and get Result object
        result = auth_service.logout_user(user_id, refresh_token, device_info, ip_address)
        
        # Check if logout was successful
        if result.is_success():
            # Log success
            logger.info("User logged out successfully", 
                {"user_id": str(user_id), 
                "request_id": request_id})
            
            # Return success response
            return Response({
                'message': 'Logout successful',
                'request_id': request_id
            })
        else:
            # If logout failed, raise the exception from the Result
            # This will be caught by the global exception handler
            if hasattr(result.error, '__call__'):
                # If it's a callable (like a function), call it
                raise result.error
            else:
                # Otherwise, raise it directly
                raise result.error

