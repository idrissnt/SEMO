from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from drf_spectacular.utils import extend_schema, OpenApiResponse
from django.contrib.auth import get_user_model
from .serializers import (
    UserSerializer, 
    UserProfileSerializer,
    CustomTokenObtainPairSerializer
)
from .services import AuthService, UserService
from .models import LogoutEvent
from django.utils import timezone
import logging
import socket

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
@extend_schema(tags=['Authentication'])
class RegisterView(APIView):
    permission_classes = [AllowAny]
    serializer_class = UserSerializer

    @extend_schema(
        request=UserSerializer,
        responses={201: UserSerializer, 400: OpenApiResponse(description='Bad Request')},
        description='Register a new user'
    )
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@extend_schema(tags=['Authentication'])
class LoginView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(
        request={"application/json": {"example": {"email": "string", "password": "string"}}},
        responses={200: {"example": {"access": "string", "refresh": "string"}}, 401: OpenApiResponse(description='Unauthorized')},
        description='Login user and obtain JWT token'
    )
    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        
        result, error = AuthService.login_user(email, password)
        if result:
            return Response({
                'access': result['access'],
                'refresh': result['refresh']
            })
        return Response({'error': error}, status=status.HTTP_401_UNAUTHORIZED)

    def get(self, request):
        # Helpful debug method for testing connectivity
        logger.debug("Received login GET request")
        return Response({
            'message': 'Login endpoint. Use POST method for authentication.',
            'allowed_methods': ['POST']
        }, status=status.HTTP_405_METHOD_NOT_ALLOWED)

@extend_schema(tags=['User'])
class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer

    @extend_schema(
        responses={200: UserProfileSerializer},
        description='Get user profile'
    )
    def get(self, request):
        serializer = UserProfileSerializer(request.user)
        return Response(serializer.data)

    @extend_schema(
        request=UserProfileSerializer,
        responses={200: UserProfileSerializer, 400: OpenApiResponse(description='Bad Request')},
        description='Update user profile'
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
        responses={200: OpenApiResponse(description='Successfully logged out'), 
                  400: OpenApiResponse(description='Bad Request')},
        description='Logout user and blacklist refresh token'
    )
    def post(self, request):
        refresh_token = request.data.get('refresh_token')
        success, error = AuthService.logout_user(request.user, refresh_token)
        
        if success:
            # Log the logout event
            LogoutEvent.objects.create(
                user=request.user,
                device_info=request.META.get('HTTP_USER_AGENT', ''),
                ip_address=request.META.get('REMOTE_ADDR', '127.0.0.1')
            )
            return Response({'message': 'Successfully logged out'})
        return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)

@extend_schema(tags=['Authentication'])
class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer
