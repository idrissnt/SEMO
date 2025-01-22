# Django and DRF Imports
from django.contrib.auth import authenticate, get_user_model
from django.core.exceptions import ValidationError
from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from django.utils import timezone
from .models import LogoutEvent
from .serializers import (
    UserSerializer,
    UserProfileSerializer,
    CustomTokenObtainPairSerializer
)

# Python standard library
import logging
import socket

# Local imports

# Configure logger
logger = logging.getLogger(__name__)
User = get_user_model()

# Function to log network details
def log_network_details(request):
    logger.debug(f"Server Hostname: {socket.gethostname()}")
    logger.debug(f"Server IP Addresses:")
    for ip in socket.gethostbyname_ex(socket.gethostname())[2]:
        logger.debug(f" - {ip}")
    logger.debug(f"Received request from IP: {request.META.get('REMOTE_ADDR')}")
    logger.debug(f"Request headers: {request.headers}")

# Create your views here.
class RegisterView(generics.CreateAPIView):
    permission_classes = [AllowAny]
    serializer_class = UserSerializer

    def post(self, request, *args, **kwargs):
        log_network_details(request)
        logger.debug(f"Received registration request with data: {request.data}")
        try:
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            user = serializer.save()
            
            # Generate tokens for the new user
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'user': serializer.data,
                'refresh': str(refresh),
                'access': str(refresh.access_token)
            }, status=status.HTTP_201_CREATED)
        except ValidationError as e:
            logger.error(f"Registration validation error: {e}")
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        logger.debug(f"Received login POST request from IP: {request.META.get('REMOTE_ADDR')}")
        logger.debug(f"Request data: {request.data}")
        
        email = request.data.get('email')
        password = request.data.get('password')
        
        if not email or not password:
            return Response({
                'error': 'Both email and password are required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        user = authenticate(request, username=email, password=password)
        
        if user is not None:
            refresh = RefreshToken.for_user(user)
            return Response({
                'refresh': str(refresh),
                'access': str(refresh.access_token),
                'user_id': user.id,
                'email': user.email
            }, status=status.HTTP_200_OK)
        else:
            logger.warning(f"Failed login attempt for email: {email}")
            return Response({
                'error': 'Invalid credentials'
            }, status=status.HTTP_401_UNAUTHORIZED)

    def get(self, request):
        # Helpful debug method for testing connectivity
        logger.debug("Received login GET request")
        return Response({
            'message': 'Login endpoint. Use POST method for authentication.',
            'allowed_methods': ['POST']
        }, status=status.HTTP_405_METHOD_NOT_ALLOWED)

class UserProfileView(generics.RetrieveUpdateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer

    def get_object(self):
        log_network_details(self.request)
        logger.debug(f"Fetching profile for user: {self.request.user.email}")
        return self.request.user

    def get(self, request, *args, **kwargs):
        log_network_details(request)
        logger.debug(f"Fetching profile for user: {request.user.email}")
        try:
            instance = self.get_object()
            serializer = self.get_serializer(instance)
            logger.info(f"Profile fetched successfully for user: {request.user.email}")
            return Response(serializer.data)
        except Exception as e:
            logger.exception("Error fetching user profile")
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    def put(self, request, *args, **kwargs):
        log_network_details(request)
        logger.debug(f"Updating profile for user: {request.user.email}")
        try:
            instance = self.get_object()
            serializer = self.get_serializer(instance, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                logger.info(f"Profile updated successfully for user: {request.user.email}")
                return Response(serializer.data)
            logger.error(f"Profile update validation failed: {serializer.errors}")
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            logger.exception("Error updating user profile")
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get('refresh_token')
            if refresh_token:
                # Blacklist the refresh token
                token = RefreshToken(refresh_token)
                token.blacklist()
            
            # Log the logout event
            LogoutEvent.objects.create(
                user=request.user,
                device_info=request.META.get('HTTP_USER_AGENT', ''),
                ip_address=request.META.get('REMOTE_ADDR', '')
            )

            return Response({
                "detail": "Successfully logged out",
                "logout_time": timezone.now()
            }, status=status.HTTP_200_OK)

        except TokenError as e:
            return Response({
                "detail": str(e)
            }, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            logger.error(f"Logout error: {e}")
            return Response({
                "detail": "Error processing logout"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
