"""
ViewSet for geospatial functionality.

This module provides a ViewSet for geospatial functionality, including location
updates, nearby deliveries, and route information, following Domain-Driven Design
principles and Clean Architecture with CQRS pattern.
"""
import logging
from uuid import UUID
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from deliveries.domain.models.value_objects import GeoPoint
from deliveries.interfaces.api.views.base_viewset import BaseViewSet
from deliveries.interfaces.api.serializers import (
    DeliveryLocationOutputSerializer,
    DeliveryLocationCreateInputSerializer,
    NearbyLocationsInputSerializer,
    DeliveryOutputSerializer,
    RouteInfoSerializer,
    GeoPointSerializer
)

logger = logging.getLogger(__name__)


class GeoSpatialViewSet(BaseViewSet):
    """ViewSet for geospatial functionality
    
    This ViewSet follows the CQRS pattern with separate serializers for
    commands (inputs) and queries (outputs), and uses dependency injection
    for repositories and services.
    """
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(
        request_body=DeliveryLocationCreateInputSerializer,
        responses={
            200: openapi.Response('Location updated successfully', DeliveryLocationOutputSerializer),
            400: openapi.Response('Invalid request parameters'),
            404: openapi.Response('Delivery not found'),
        }
    )
    @action(detail=True, methods=['post'], url_path='location')
    def update_location(self, request, pk=None):
        """
        Update the current location of a delivery
        
        This endpoint records the current location of a delivery and updates
        the estimated arrival time based on the new location.
        """
        try:
            # Validate delivery ID
            delivery_uuid = UUID(pk)
            
            # Validate input using command serializer
            validated_data = self.validate_serializer(
                DeliveryLocationCreateInputSerializer, 
                request.data
            )
            
            # Extract location data
            location = validated_data['location']
            
            # Execute the command via application service
            success, message, location_entity = self.delivery_service.update_delivery_location(
                delivery_id=delivery_uuid,
                latitude=location['latitude'],
                longitude=location['longitude']
            )
            
            if success:
                # Serialize the result using query serializer
                serializer = DeliveryLocationOutputSerializer(location_entity)
                return Response({
                    'message': message,
                    'location': serializer.data
                })
            else:
                return Response(
                    {'error': message},
                    status=status.HTTP_400_BAD_REQUEST if 'Invalid' in message else status.HTTP_404_NOT_FOUND
                )
                
        except ValueError:
            return Response(
                {'error': 'Invalid delivery ID format'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        query_serializer=NearbyLocationsInputSerializer,
        responses={
            200: openapi.Response('List of nearby deliveries', DeliveryOutputSerializer(many=True)),
            400: openapi.Response('Invalid request parameters'),
        }
    )
    @action(detail=False, methods=['get'], url_path='nearby')
    def nearby_deliveries(self, request):
        """
        Find deliveries near a specific location
        
        This endpoint finds deliveries within a specified radius of a location,
        optionally filtered by status.
        """
        try:
            # Validate input using query serializer
            serializer = NearbyLocationsInputSerializer(data=request.query_params)
            serializer.is_valid(raise_exception=True)
            
            # Extract validated data
            latitude = serializer.validated_data['latitude']
            longitude = serializer.validated_data['longitude']
            radius = serializer.validated_data['radius_km']
            status_filter = request.query_params.get('status')
            
            # Execute the query via application service
            deliveries = self.delivery_service.find_nearby_deliveries(
                latitude=latitude,
                longitude=longitude,
                radius_km=radius,
                status=status_filter
            )
            
            # Serialize the results using query serializer
            output_serializer = DeliveryOutputSerializer(deliveries, many=True)
            
            return Response(output_serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Route information', RouteInfoSerializer),
            404: openapi.Response('Delivery not found or route not available'),
        }
    )
    @action(detail=True, methods=['get'], url_path='route')
    def delivery_route(self, request, pk=None):
        """
        Get route information for a delivery
        
        This endpoint calculates the route between the store and delivery location,
        providing distance, duration, and polyline data for map display.
        """
        try:
            # Validate delivery ID
            delivery_uuid = UUID(pk)
            
            # Execute the query via application service
            route_info = self.delivery_service.get_delivery_route(delivery_uuid)
            
            if route_info:
                # The route_info is already a dictionary, but we could use a serializer
                # if we wanted to transform it to a different format
                return Response(route_info)
            else:
                return Response(
                    {'error': 'Route information not available'},
                    status=status.HTTP_404_NOT_FOUND
                )
                
        except ValueError:
            return Response(
                {'error': 'Invalid delivery ID format'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return self.handle_exception(e)
