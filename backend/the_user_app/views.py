from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from django.http import Http404
from rest_framework_simplejwt.views import TokenObtainPairView
from drf_spectacular.utils import extend_schema, OpenApiResponse
from django.contrib.auth import get_user_model
from .serializers import (
    UserSerializer, 
    UserProfileSerializer,
    CustomTokenObtainPairSerializer,
    AddressSerializer,
    PasswordChangeSerializer
)
from .services import AuthService
import logging

logger = logging.getLogger(__name__)
User = get_user_model()

# Create views
@extend_schema(tags=['Authentication'])
class RegisterView(APIView):
    permission_classes = [AllowAny]
    serializer_class = UserSerializer

    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@extend_schema(tags=['Authentication'])
class LoginView(APIView):
    permission_classes = [AllowAny]

    # documentation
    @extend_schema(
        request={"application/json": {"example": {"email": "string", "password": "string"}}},
        responses={
            200: {"example": {"access": "string", "refresh": "string", "user": {"email": "string", "first_name": "string", "last_name": "string"}}},
            401: OpenApiResponse(description='Unauthorized'),
            400: OpenApiResponse(description='Bad Request')
        },
        description='Login user and obtain JWT token'
    )
    def post(self, request):
        # Extract credentials from request
        email = request.data.get('email')
        password = request.data.get('password')
        
        # Log authentication attempt (without password)
        logger.info(f"Login attempt for email: {email}")
        
        # Attempt to authenticate user
        result, error = AuthService.login_user(email, password)
        
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

@extend_schema(tags=['User'])
class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer

    @extend_schema(
        responses={
            200: UserProfileSerializer,
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Get user profile information including addresses'
    )
    def get(self, request):
        serializer = UserProfileSerializer(request.user)
        return Response(serializer.data)

    @extend_schema(
        request=UserProfileSerializer,
        responses={
            200: UserProfileSerializer,
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Update user profile information'
    )
    def put(self, request):
        serializer = UserProfileSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            user = serializer.save()
            return Response(UserProfileSerializer(user).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@extend_schema(tags=['Authentication'])
class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        request={"application/json": {"example": {"refresh_token": "string"}}},
        responses={
            200: OpenApiResponse(description='Successfully logged out'), 
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Logout user and blacklist refresh token'
    )
    def post(self, request):
        # Extract refresh token from request
        refresh_token = request.data.get('refresh_token')
        
        # Get client information for logging
        device_info = request.META.get('HTTP_USER_AGENT', '')
        ip_address = request.META.get('REMOTE_ADDR', '127.0.0.1')
        
        # Log logout attempt
        logger.info(f"Logout attempt for user: {request.user.email} from IP: {ip_address}")
        
        # Attempt to logout user and blacklist token
        success, error = AuthService.logout_user(request.user, refresh_token)
        
        if success:
            # Logout successful - we don't need to create LogoutEvent here as it's now handled in the service
            logger.info(f"Successful logout for user: {request.user.email}")
            return Response({'message': 'Successfully logged out'})
        
        # Logout failed
        logger.warning(f"Logout failed for user: {request.user.email} - Error: {error}")
        
        if 'required' in error.lower():
            # Missing refresh token
            return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
        elif 'invalid' in error.lower():
            # Invalid token
            return Response({'error': error}, status=status.HTTP_401_UNAUTHORIZED)
        else:
            # Other errors
            return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)

@extend_schema(tags=['Authentication'])
class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

@extend_schema(tags=['User'])
class PasswordChangeView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = PasswordChangeSerializer
    
    @extend_schema(
        request=PasswordChangeSerializer,
        responses={
            200: {"example": {"message": "Password changed successfully"}},
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Change user password'
    )
    def post(self, request):
        serializer = PasswordChangeSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            # Set the new password
            user = request.user
            user.set_password(serializer.validated_data['new_password'])
            user.save()
            return Response({'message': 'Password changed successfully'})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@extend_schema(tags=['User'])
class AddressView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = AddressSerializer
    
    @extend_schema(
        responses={
            200: AddressSerializer(many=True),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Get all addresses for the current user'
    )
    def get(self, request):
        addresses = request.user.addresses.all()
        serializer = AddressSerializer(addresses, many=True)
        return Response(serializer.data)
    
    @extend_schema(
        request=AddressSerializer,
        responses={
            201: AddressSerializer,
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Create a new address for the current user'
    )
    def post(self, request):
        serializer = AddressSerializer(data=request.data)
        if serializer.is_valid():
            address = serializer.save(user=request.user)
            return Response(AddressSerializer(address).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@extend_schema(tags=['User'])
class AddressDetailView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = AddressSerializer
    
    def get_object(self, pk, user):
        try:
            return user.addresses.get(pk=pk)
        except User.addresses.field.related_model.DoesNotExist:
            raise Http404
    
    @extend_schema(
        responses={
            200: AddressSerializer,
            404: OpenApiResponse(description='Not Found'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Get a specific address by ID'
    )
    def get(self, request, pk):
        address = self.get_object(pk, request.user)
        serializer = AddressSerializer(address)
        return Response(serializer.data)
    
    @extend_schema(
        request=AddressSerializer,
        responses={
            200: AddressSerializer,
            400: OpenApiResponse(description='Bad Request'),
            404: OpenApiResponse(description='Not Found'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Update a specific address'
    )
    def put(self, request, pk):
        address = self.get_object(pk, request.user)
        serializer = AddressSerializer(address, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @extend_schema(
        responses={
            204: OpenApiResponse(description='No Content'),
            404: OpenApiResponse(description='Not Found'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Delete a specific address'
    )
    def delete(self, request, pk):
        address = self.get_object(pk, request.user)
        address.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
