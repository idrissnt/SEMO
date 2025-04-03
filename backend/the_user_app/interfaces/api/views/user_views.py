from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiResponse
import logging

from the_user_app.interfaces.api.serializers.user_serializers import UserProfileSerializer
from the_user_app.infrastructure.factory import UserFactory

logger = logging.getLogger(__name__)

@extend_schema(tags=['User'])
class UserProfileViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = UserProfileSerializer    

    @extend_schema(
        responses={
            200: UserProfileSerializer,
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Get user profile information including addresses'
    )
    @action(detail=False, methods=['get'])
    def me(self, request):
        # Get user with addresses
        user_with_addresses = self._get_user_with_addresses(request.user.id)
        
        # Serialize and return
        serializer = UserProfileSerializer(user_with_addresses)
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
    @action(detail=False, methods=['put', 'patch'])
    def update_me(self, request):
        serializer = UserProfileSerializer(data=request.data, partial=True)
        if serializer.is_valid():
            # Get user service from factory
            user_service = UserFactory.create_user_service()
            
            # Update user profile
            user, error = user_service.update_user_profile(
                user_id=request.user.id,
                profile_data=serializer.validated_data
            )
            
            if user:
                # Get user with addresses
                user_with_addresses = self._get_user_with_addresses(request.user.id)
                
                # Serialize and return
                return Response(UserProfileSerializer(user_with_addresses).data)
            else:
                # Return error
                return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
                
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
    @extend_schema(
        responses={
            204: OpenApiResponse(description='No Content - Account deleted successfully'),
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Delete user account'
    )
    @action(detail=False, methods=['delete'])
    def delete_account(self, request):
        # Get user service from factory
        user_service = UserFactory.create_user_service()
        
        # Delete user
        success, error = user_service.delete_user(request.user.id)
        
        if success:
            return Response(status=status.HTTP_204_NO_CONTENT)
        else:
            return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)

    def _get_user_with_addresses(self, user_id):
        """Helper method to get user with addresses"""
        # Get user service from factory
        user_service = UserFactory.create_user_service()
        
        # Get address service from factory
        address_service = UserFactory.create_address_service()
            
        # Get user by ID
        user = user_service.get_user_by_id(user_id)
            
        # Get addresses for user
        addresses = address_service.get_user_addresses(user_id)
            
        # Create user with addresses object
        user_with_addresses = {
            'id': user.id,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'phone_number': user.phone_number,
            'addresses': addresses
        }
            
        return user_with_addresses