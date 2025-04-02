"""
ViewSet for delivery management.

This module provides a ViewSet for managing deliveries, including creating,
retrieving, and updating deliveries, following Domain-Driven Design principles
and Clean Architecture with CQRS pattern.
"""
import logging
from uuid import UUID
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from deliveries.domain.models.constants import DeliveryStatus
from deliveries.interfaces.api.views.base_viewset import BaseViewSet
from deliveries.interfaces.api.serializers import (
    DeliveryOutputSerializer,
    DeliveryCreateInputSerializer,
    DeliveryUpdateStatusInputSerializer,
    DeliveryAssignDriverInputSerializer,
    DeliveryUpdateLocationInputSerializer,
    DeliveryUpdateETAInputSerializer,
)

logger = logging.getLogger(__name__)


class DeliveryViewSet(BaseViewSet):
    """ViewSet for managing deliveries
    
    This ViewSet follows the CQRS pattern with separate serializers for
    commands (inputs) and queries (outputs), and uses dependency injection
    for repositories and services.
    """
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(
        request_body=DeliveryCreateInputSerializer,
        responses={
            201: openapi.Response('Delivery created successfully', DeliveryOutputSerializer),
            400: openapi.Response('Invalid request parameters'),
        }
    )
    def create(self, request):
        """Create a new delivery for an order"""
        try:
            # Validate input using command serializer
            validated_data = self.validate_serializer(
                DeliveryCreateInputSerializer, 
                request.data
            )
            
            # Convert to UUID
            order_uuid = validated_data['order_id']
            
            # Execute the command via application service
            delivery = self.delivery_service.create(order_uuid)
            
            # Serialize the result using query serializer
            serializer = DeliveryOutputSerializer(delivery)
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Delivery details', DeliveryOutputSerializer),
            404: openapi.Response('Delivery not found'),
        }
    )
    def retrieve(self, request, pk=None):
        """Get details for a specific delivery"""
        try:
            # Execute the query via application service
            delivery = self.delivery_service.get_delivery(pk)
            
            if not delivery:
                return Response(
                    {'error': 'Delivery not found'},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Serialize the result using query serializer
            serializer = DeliveryOutputSerializer(delivery)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('status', openapi.IN_QUERY, description="Filter by delivery status", type=openapi.TYPE_STRING),
        ],
        responses={
            200: openapi.Response('List of deliveries', DeliveryOutputSerializer(many=True)),
        }
    )
    def list(self, request):
        """Get a list of all deliveries, optionally filtered by status"""
        try:
            # Get query parameters
            status_filter = request.query_params.get('status')
            
            # Execute the query via application service
            if status_filter == DeliveryStatus.PENDING:
                deliveries = self.delivery_service.get_all_pending_deliveries()
            else:
                # Placeholder for other filters
                deliveries = []
            
            # Serialize the results using query serializer
            serializer = DeliveryOutputSerializer(deliveries, many=True)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
