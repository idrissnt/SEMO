from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiResponse
import logging
import uuid

from the_user_app.interfaces.api.serializers import (
    UserSerializer,
    PasswordChangeSerializer,
    LoginRequestSerializer,
    AuthTokensSerializer
)
from the_user_app.infrastructure.factory import UserFactory

logger = logging.getLogger(__name__)

@extend_schema(tags=['Authentication'])
class AuthViewSet(viewsets.ViewSet):
    """ViewSet for authentication operations"""
    
    def list(self, request):
        return Response({})

    @extend_schema(
        request=UserSerializer,
        responses={
            201: UserSerializer,
            400: OpenApiResponse(description='Bad Request')
        },
        description='Register a new user'
    )
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def register(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            # Get auth service from factory
            auth_service = UserFactory.create_auth_service()
            
            # Register user
            result, error = auth_service.register_user(serializer.validated_data)
            
            if result:
                # Serialize the AuthTokens value object and add success message
                serialized_data = AuthTokensSerializer(result).data
                return Response(serialized_data, status=status.HTTP_201_CREATED)
            else:
                # Return error
                return Response({'error': error, 'code': 'registration_error'}, status=status.HTTP_400_BAD_REQUEST)
                
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def login(self, request):
        # Extract request metadata for logging context
        client_ip = request.META.get('REMOTE_ADDR', 'unknown')
        user_agent = request.META.get('HTTP_USER_AGENT', 'unknown')
        request_id = request.META.get('HTTP_X_REQUEST_ID', str(uuid.uuid4()))
        
        # Create logging context
        log_context = {
            'client_ip': client_ip,
            'user_agent': user_agent,
            'request_id': request_id,
        }
        
        # Extract credentials from request
        serializer = LoginRequestSerializer(data=request.data)
        if not serializer.is_valid():
            # Get auth service for logging
            auth_service = UserFactory.create_auth_service()
            auth_service.logger.warning(
                "Login validation failed", 
                {**log_context, 'errors': str(serializer.errors)}
            )
            return Response(
                {
                    'error': 'Invalid input data',
                    'details': serializer.errors,
                    'code': 'validation_error'
                }, 
                status=status.HTTP_400_BAD_REQUEST
            )
            
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        
        log_context['email'] = email
        
        # Get auth service from factory
        auth_service = UserFactory.create_auth_service()
        
        # Attempt authentication
        result, error = auth_service.login_user(email, password)
        
        if result:
            # Serialize the AuthTokens value object and add success message
            serialized_data = AuthTokensSerializer(result).data
            return Response(serialized_data, status=status.HTTP_200_OK)
        
        # Handle different error cases with appropriate status codes and messages
        if error == "Invalid credentials":
            # Invalid credentials - return 401 with user-friendly message
            return Response({
                'error': 'The email or password you entered is incorrect',
                'code': 'invalid_credentials',
                'request_id': request_id  # Include request ID for support reference
            }, status=status.HTTP_401_UNAUTHORIZED)
        else:
            # Other errors - return 500 with generic message
            auth_service.logger.error(
                f"Unexpected login error: {error}", 
                log_context
            )
            return Response({
                'error': 'An unexpected error occurred during login',
                'code': 'server_error',
                'request_id': request_id  # For tracking in logs
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
    def logout(self, request):
        # Extract refresh token from request data
        refresh_token = request.data.get('refresh_token')
        
        # Extract metadata from request
        device_info = request.META.get('HTTP_USER_AGENT', '')
        ip_address = request.META.get('REMOTE_ADDR', '')
        
        # Get user ID from authenticated user
        try:
            user_id = request.user.id  # Assuming user.id is a UUID field
        except AttributeError:
            return Response(
                {'error': 'User not authenticated properly'}, 
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        # Validate refresh token
        if not refresh_token:
            return Response(
                {'error': 'Refresh token is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # Get auth service from factory
        auth_service = UserFactory.create_auth_service()
        
        # Logout user
        success, error = auth_service.logout_user(user_id, refresh_token, device_info, ip_address)
        
        if success:
            return Response({'message': 'Logout successful'})
        else:
            return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        request=PasswordChangeSerializer,
        responses={
            200: OpenApiResponse(description='Success'),
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Change user password'
    )
    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated], url_path='change-password')
    def change_password(self, request):
        serializer = PasswordChangeSerializer(data=request.data)
        if serializer.is_valid():
            # Get user service from factory
            user_service = UserFactory.create_user_service()
            
            # Change password
            success, error = user_service.change_password(
                user_id=uuid.UUID(request.user_id),
                old_password=serializer.validated_data['old_password'],
                new_password=serializer.validated_data['new_password']
            )
            
            if success:
                return Response({'message': 'Password changed successfully'})
            else:
                return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
                
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
