from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiResponse
import logging

from the_user_app.interfaces.api.serializers.user_serializers import (
    UserSerializer,
    PasswordChangeSerializer,
    LoginRequestSerializer,
    LoginResponseSerializer
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
            user, error = auth_service.register_user(serializer.validated_data)
            
            if user:
                # Return serialized user data
                return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)
            else:
                # Return error
                return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
                
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @extend_schema(
        request=LoginRequestSerializer,
        responses={
            200: LoginResponseSerializer,
            401: OpenApiResponse(description='Unauthorized'),
            400: OpenApiResponse(description='Bad Request')
        },
        description='Login user and obtain JWT token'
    )
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def login(self, request):
        # Extract credentials from request
        serializer = LoginRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        
        # Log authentication attempt (without password)
        logger.info(f"Login attempt for email: {email}")
        
        # Get auth service from factory
        auth_service = UserFactory.create_auth_service()
        
        # Attempt to authenticate user
        result, error = auth_service.login_user(email, password)
        
        if result:
            # Authentication successful
            logger.info(f"Successful login for user: {email}")
            return Response({
                'access': result['access'],
                'refresh': result['refresh'],
                'message': 'Login successful'
            })
        
        # Authentication failed
        if 'required' in error.lower():
            # Missing credentials
            return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
        else:
            # Invalid credentials or other errors
            return Response({'error': error}, status=status.HTTP_401_UNAUTHORIZED)

    @extend_schema(
        request={"application/json": {"example": {"refresh_token": "string"}}},
        responses={
            200: OpenApiResponse(description='Success'),
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Logout user and invalidate refresh token'
    )
    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
    def logout(self, request):
        refresh_token = request.data.get('refresh_token')
        if not refresh_token:
            return Response(
                {'error': 'Refresh token is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get auth service from factory
        auth_service = UserFactory.create_auth_service()
        
        # Logout user
        success, error = auth_service.logout_user(refresh_token)
        
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
    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
    def change_password(self, request):
        serializer = PasswordChangeSerializer(data=request.data)
        if serializer.is_valid():
            # Get user service from factory
            user_service = UserFactory.create_user_service()
            
            # Change password
            success, error = user_service.change_password(
                user_id=request.user.id,
                old_password=serializer.validated_data['old_password'],
                new_password=serializer.validated_data['new_password']
            )
            
            if success:
                return Response({'message': 'Password changed successfully'})
            else:
                return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
                
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
