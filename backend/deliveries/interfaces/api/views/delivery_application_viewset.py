"""
ViewSet for delivery application service.

This module provides a ViewSet for the delivery application service, including
creating, retrieving, and updating deliveries, following Domain-Driven Design principles
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
)
from deliveries.infrastructure.factory import ApplicationServiceFactory

logger = logging.getLogger(__name__)


class DeliveryApplicationViewSet(BaseViewSet):
    """ViewSet for delivery application service
    
    This ViewSet follows the CQRS pattern with separate serializers for
    commands (inputs) and queries (outputs), and uses dependency injection
    for repositories and services through the ApplicationServiceFactory.
    """
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(
        request_body=DeliveryCreateInputSerializer,
        responses={
            201: openapi.Response('Created delivery', DeliveryOutputSerializer),
            400: openapi.Response('Invalid input'),
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
            delivery_service = ApplicationServiceFactory.create_delivery_application_service()
            delivery = delivery_service.create(order_uuid)
            
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
            delivery_service = ApplicationServiceFactory.create_delivery_application_service()
            delivery = delivery_service.get_delivery(pk)
            
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
            delivery_service = ApplicationServiceFactory.create_delivery_application_service()
            if status_filter == DeliveryStatus.PENDING:
                deliveries = delivery_service.get_all_pending_deliveries()
            else:
                # Placeholder for other filters
                deliveries = []
            
            # Serialize the results using query serializer
            serializer = DeliveryOutputSerializer(deliveries, many=True)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        request_body=DeliveryUpdateStatusInputSerializer,
        responses={
            200: openapi.Response('Updated delivery', DeliveryOutputSerializer),
            400: openapi.Response('Invalid input'),
            404: openapi.Response('Delivery not found'),
        }
    )
    @action(detail=True, methods=['post'], url_path='update-status')
    def update_status(self, request, pk=None):
        """Update the status of a delivery"""
        try:
            # Validate input using command serializer
            validated_data = self.validate_serializer(
                DeliveryUpdateStatusInputSerializer, 
                request.data
            )
            
            # Execute the command via application service
            delivery_service = ApplicationServiceFactory.create_delivery_application_service()
            success, message, delivery = delivery_service.update_status(
                delivery_id=UUID(pk),
                status=validated_data['status'],
                notes=validated_data.get('notes', '')
            )
            
            if not success:
                return Response(
                    {'error': message},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Serialize the result using query serializer
            serializer = DeliveryOutputSerializer(delivery)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        request_body=DeliveryAssignDriverInputSerializer,
        responses={
            200: openapi.Response('Updated delivery', DeliveryOutputSerializer),
            400: openapi.Response('Invalid input'),
            404: openapi.Response('Delivery not found'),
        }
    )
    @action(detail=True, methods=['post'], url_path='assign-driver')
    def assign_driver(self, request, pk=None):
        """Assign a driver to a delivery"""
        try:
            # Validate input using command serializer
            validated_data = self.validate_serializer(
                DeliveryAssignDriverInputSerializer, 
                request.data
            )
            
            # Execute the command via application service
            delivery_service = ApplicationServiceFactory.create_delivery_application_service()
            success, message, delivery = delivery_service.assign_driver(
                delivery_id=UUID(pk),
                driver_id=validated_data['driver_id']
            )
            
            if not success:
                return Response(
                    {'error': message},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Serialize the result using query serializer
            serializer = DeliveryOutputSerializer(delivery)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Driver accepted delivery', DeliveryOutputSerializer),
            400: openapi.Response('Invalid request'),
            404: openapi.Response('Delivery not found'),
        }
    )
    @action(detail=True, methods=['post'], url_path='accept')
    def accept(self, request, pk=None):
        """Accept a delivery as a driver"""
        try:
            # Get the driver ID from the authenticated user
            driver_id = request.user.id
            
            # Execute the command via application service
            delivery_service = ApplicationServiceFactory.create_delivery_application_service()
            success, message, delivery = delivery_service.handle_delivery_acceptance(
                delivery_id=UUID(pk),
                driver_id=driver_id
            )
            
            if not success:
                return Response(
                    {'error': message},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Serialize the result using query serializer
            serializer = DeliveryOutputSerializer(delivery)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
