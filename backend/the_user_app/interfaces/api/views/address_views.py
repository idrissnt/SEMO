from rest_framework import status, viewsets
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.http import Http404
from drf_spectacular.utils import extend_schema, OpenApiResponse
import logging
import uuid

from the_user_app.interfaces.api.serializers.user_serializers import AddressSerializer
from the_user_app.infrastructure.factory import UserFactory

logger = logging.getLogger(__name__)

@extend_schema(tags=['Address'])
class AddressViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = AddressSerializer
    
    @extend_schema(
        responses={
            200: AddressSerializer(many=True),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Get all addresses for the authenticated user'
    )
    def list(self, request):
        'url : /addresses/'
        # Get address service from factory
        address_service = UserFactory.create_address_service()
        
        # Get addresses for user
        addresses = address_service.get_user_addresses(request.user.id)
        
        # Serialize and return
        serializer = AddressSerializer(addresses, many=True)
        return Response(serializer.data)
    
    @extend_schema(
        request=AddressSerializer,
        responses={
            201: AddressSerializer,
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Create a new address for the authenticated user'
    )
    def create(self, request):
        'url : /addresses/'
        serializer = AddressSerializer(data=request.data)
        if serializer.is_valid():
            # Get address service from factory
            address_service = UserFactory.create_address_service()
            
            # Create address
            address, error = address_service.create_address(
                user_id=request.user.id,
                address_data=serializer.validated_data
            )
            
            if address:
                # Return serialized address data
                return Response(AddressSerializer(address).data, status=status.HTTP_201_CREATED)
            else:
                # Return error
                return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
                
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @extend_schema(
        responses={
            200: AddressSerializer,
            401: OpenApiResponse(description='Unauthorized'),
            404: OpenApiResponse(description='Not Found')
        },
        description='Get address details by ID'
    )
    def retrieve(self, request, pk=None):
        'url : /addresses/{id}/'
        # Get address
        address = self._get_address(pk, request.user.id)
        
        # Serialize and return
        serializer = AddressSerializer(address)
        return Response(serializer.data)
    
    @extend_schema(
        request=AddressSerializer,
        responses={
            200: AddressSerializer,
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized'),
            404: OpenApiResponse(description='Not Found')
        },
        description='Update address by ID'
    )
    @action(detail=True, methods=['put'], url_path='update-address')
    def update(self, request, pk=None):
        'url : /addresses/{id}/update-address/'
        # Verify address exists and belongs to user
        self._get_address(pk, request.user.id)
        
        # Validate request data
        serializer = AddressSerializer(data=request.data, partial=True)
        if serializer.is_valid():
            # Get address service from factory
            address_service = UserFactory.create_address_service()
            
            # Update address
            address, error = address_service.update_address(
                address_id=uuid.UUID(pk),
                user_id=request.user.id,
                address_data=serializer.validated_data
            )
            
            if address:
                # Return serialized address data
                return Response(AddressSerializer(address).data)
            else:
                # Return error
                return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
                
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @extend_schema(
        responses={
            204: OpenApiResponse(description='No Content'),
            401: OpenApiResponse(description='Unauthorized'),
            404: OpenApiResponse(description='Not Found')
        },
        description='Delete address by ID'
    )
    @action(detail=True, methods=['delete'], url_path='delete-address')
    def destroy(self, request, pk=None):
        'url : /addresses/{id}/delete-address/'
        # Verify address exists and belongs to user
        self._get_address(pk, request.user.id)
        
        # Get address service from factory
        address_service = UserFactory.create_address_service()
        
        # Delete address
        success, error = address_service.delete_address(
            address_id=uuid.UUID(pk),
            user_id=request.user.id
        )
        
        if success:
            return Response(status=status.HTTP_204_NO_CONTENT)
        else:
            return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)
    
    def _get_address(self, pk, user_id):
        """Helper method to get address by ID and verify ownership"""
        try:
            # Convert string to UUID
            address_id = uuid.UUID(pk)
            
            # Get address service from factory
            address_service = UserFactory.create_address_service()
            
            # Get address by ID and verify ownership
            address, error = address_service.get_address_by_id(address_id, user_id)
            
            if error:
                raise Http404(error)
                
            return address
            
        except ValueError:
            raise Http404("Invalid address ID format")