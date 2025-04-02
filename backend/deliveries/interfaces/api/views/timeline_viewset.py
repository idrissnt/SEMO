"""
ViewSet for delivery timeline events.

This module provides a ViewSet for managing delivery timeline events, including creating
and retrieving timeline events, following Domain-Driven Design principles and Clean Architecture
with CQRS pattern.
"""
import logging
from uuid import UUID
from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from deliveries.interfaces.api.views.base_viewset import BaseViewSet
from deliveries.interfaces.api.serializers import (
    DeliveryTimelineEventOutputSerializer,
    DeliveryTimelineEventCreateInputSerializer,
)

logger = logging.getLogger(__name__)


class TimelineViewSet(BaseViewSet):
    """ViewSet for managing delivery timeline events
    
    This ViewSet follows the CQRS pattern with separate serializers for
    commands (inputs) and queries (outputs), and uses dependency injection
    for repositories and services.
    """
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(
        request_body=DeliveryTimelineEventCreateInputSerializer,
        responses={
            201: openapi.Response('Timeline event created successfully', DeliveryTimelineEventOutputSerializer),
            400: openapi.Response('Invalid request parameters'),
            404: openapi.Response('Delivery not found'),
        }
    )
    def create(self, request):
        """Create a new timeline event for a delivery"""
        try:
            # Validate input using command serializer
            serializer = DeliveryTimelineEventCreateInputSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            
            # Create entity from validated data
            timeline_event = serializer.create(serializer.validated_data)
            
            # Execute the command via application service
            success, message, saved_event = self.delivery_service.add_timeline_event(
                delivery_id=timeline_event.delivery_id,
                event_type=timeline_event.event_type,
                notes=timeline_event.notes,
                location=timeline_event.location
            )
            
            if success:
                # Serialize the result using query serializer
                output_serializer = DeliveryTimelineEventOutputSerializer(saved_event)
                return Response(output_serializer.data, status=status.HTTP_201_CREATED)
            else:
                return Response(
                    {'error': message},
                    status=status.HTTP_404_NOT_FOUND if 'not found' in message.lower() else status.HTTP_400_BAD_REQUEST
                )
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Timeline event details', DeliveryTimelineEventOutputSerializer),
            404: openapi.Response('Timeline event not found'),
        }
    )
    def retrieve(self, request, pk=None):
        """Get details for a specific timeline event"""
        try:
            # Execute the query via application service
            event = self.delivery_service.get_timeline_event(pk)
            
            if not event:
                return Response(
                    {'error': 'Timeline event not found'},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Serialize the result using query serializer
            serializer = DeliveryTimelineEventOutputSerializer(event)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('delivery_id', openapi.IN_QUERY, description="Filter by delivery ID", type=openapi.TYPE_STRING),
        ],
        responses={
            200: openapi.Response('List of timeline events', DeliveryTimelineEventOutputSerializer(many=True)),
            400: openapi.Response('Invalid delivery ID format'),
        }
    )
    def list(self, request):
        """Get a list of timeline events, optionally filtered by delivery ID"""
        try:
            # Get query parameters
            delivery_id = request.query_params.get('delivery_id')
            
            # Execute the query via application service
            if delivery_id:
                try:
                    delivery_uuid = UUID(delivery_id)
                    events = self.delivery_service.get_delivery_timeline(delivery_uuid)
                except ValueError:
                    return Response(
                        {'error': 'Invalid delivery ID format'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            else:
                # Return all timeline events if no delivery_id is provided
                # This might be limited or paginated in a real-world scenario
                events = self.delivery_service.get_all_timeline_events()
            
            # Serialize the results using query serializer
            serializer = DeliveryTimelineEventOutputSerializer(events, many=True)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
