from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiResponse
import logging
import uuid

from the_user_app.interfaces.api.serializers import (
    UserProfileSerializer,
    PasswordChangeSerializer
)
from the_user_app.infrastructure.factory import UserFactory

logger = logging.getLogger(__name__)

@extend_schema(tags=['User'])
class UserProfileViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer    

    def list(self, request):
        """
        Get user profile information including addresses
        url: /profiles/
        """
        return Response({})
    
    @action(detail=False, methods=['get'], url_path='me')
    @extend_schema(
        responses={
            200: UserProfileSerializer,
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Get current user profile information'
    )
    def me(self, request):
        """
        Get current user profile information
        url: /profiles/me/
        """
        user_service = UserFactory.create_user_service()
        
        # Get the current user's ID from the request
        user_id = request.user.id
        user = user_service.get_user_by_id(user_id)
        
        # Serialize and return
        serializer = UserProfileSerializer(user)
        return Response(serializer.data)
                
    @action(detail=False, methods=['patch'], url_path='update-profile')
    @extend_schema(
        request=UserProfileSerializer,
        responses={
            200: UserProfileSerializer,
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Update current user profile information'
    )
    def update_my_profile(self, request):
        """
        Update current user profile information
        url: /profiles/update-profile/
        """
        user_id = request.user.id
        serializer = UserProfileSerializer(data=request.data, partial=True)
        if serializer.is_valid():
            # Get user service from factory
            user_service = UserFactory.create_user_service()
            
            # Update user profile
            user, error = user_service.update_user_profile(
                user_id=user_id,
                profile_data=serializer.validated_data
            )
            
            if user:
                # Get user with addresses
                user = user_service.get_user_by_id(user_id)
                
                # Serialize and return
                return Response(UserProfileSerializer(user).data)
            else:
                # Return error
                return Response(
                    {'error': error or 'Failed to update profile'},
                    status=status.HTTP_400_BAD_REQUEST
                )
                
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            
    @action(detail=False, methods=['delete'], url_path='delete-account')
    @extend_schema(
        responses={
            204: OpenApiResponse(description='No Content'),
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Delete current user account'
    )
    def delete_my_account(self, request):
        """
        Delete current user account
        url: /profiles/delete-account/
        """
        user_id = request.user.id
        
        # Get user service from factory
        user_service = UserFactory.create_user_service()
        
        # Delete user account
        success, error = user_service.delete_user(user_id)
        
        if success:
            return Response(status=status.HTTP_204_NO_CONTENT)
        else:
            return Response(
                {'error': error or 'Failed to delete account'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
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