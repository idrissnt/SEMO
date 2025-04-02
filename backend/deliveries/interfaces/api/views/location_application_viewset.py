"""
ViewSet for location application service.

This module provides a ViewSet for the location application service, including
updating and tracking delivery locations, following Domain-Driven Design principles
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

from deliveries.interfaces.api.views.base_viewset import BaseViewSet
from deliveries.interfaces.api.serializers import (
    DeliveryLocationOutputSerializer,
    DeliveryLocationCreateInputSerializer,
    NearbyLocationsInputSerializer,
    RouteInfoSerializer,
    GeoPointSerializer
)
from deliveries.infrastructure.factory import ApplicationServiceFactory

logger = logging.getLogger(__name__)


class LocationApplicationViewSet(BaseViewSet):
    """ViewSet for location application service
    
    This ViewSet follows the CQRS pattern with separate serializers for
    commands (inputs) and queries (outputs), and uses dependency injection
    for repositories and services through the ApplicationServiceFactory.
    """
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(
        request_body=DeliveryLocationCreateInputSerializer,
        responses={
            201: openapi.Response('Created location', DeliveryLocationOutputSerializer),
            400: openapi.Response('Invalid input'),
            404: openapi.Response('Delivery not found'),
        }
    )
    @action(detail=True, methods=['post'], url_path='update-location')
    def update_location(self, request, pk=None):
        """Update the current location of a delivery"""
        try:
            # Validate input using command serializer
            validated_data = self.validate_serializer(
                DeliveryLocationCreateInputSerializer, 
                request.data
            )
            
            # Execute the command via application service
            location_service = ApplicationServiceFactory.create_location_application_service()
            success, message, location = location_service.update_delivery_location(
                delivery_id=UUID(pk),
                latitude=validated_data['latitude'],
                longitude=validated_data['longitude']
            )
            
            if not success:
                return Response(
                    {'error': message},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Serialize the result using query serializer
            serializer = DeliveryLocationOutputSerializer(location)
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Location history', DeliveryLocationOutputSerializer(many=True)),
            404: openapi.Response('Delivery not found'),
        }
    )
    @action(detail=True, methods=['get'], url_path='location-history')
    def location_history(self, request, pk=None):
        """Get the location history for a delivery"""
        try:
            # Execute the query via application service
            location_service = ApplicationServiceFactory.create_location_application_service()
            locations = location_service.get_delivery_location_history(
                delivery_id=UUID(pk)
            )
            
            # Serialize the results using query serializer
            serializer = DeliveryLocationOutputSerializer(locations, many=True)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        query_serializer=NearbyLocationsInputSerializer,
        responses={
            200: openapi.Response('Route information', RouteInfoSerializer),
            400: openapi.Response('Invalid input'),
            404: openapi.Response('Delivery not found'),
        }
    )
    @action(detail=True, methods=['get'], url_path='route-info')
    def route_info(self, request, pk=None):
        """Get route information for a delivery"""
        try:
            # Validate input using query serializer
            query_params = {
                'latitude': request.query_params.get('latitude'),
                'longitude': request.query_params.get('longitude')
            }
            
            # Convert string parameters to proper types
            if query_params['latitude'] and query_params['longitude']:
                query_params['latitude'] = float(query_params['latitude'])
                query_params['longitude'] = float(query_params['longitude'])
            
            validated_data = self.validate_serializer(
                NearbyLocationsInputSerializer, 
                query_params
            )
            
            # Create GeoPoint from validated data
            current_location = validated_data.to_geo_point()
            
            # Execute the query via application service
            location_service = ApplicationServiceFactory.create_location_application_service()
            route_info = location_service.get_route_info(
                delivery_id=UUID(pk),
                current_location=current_location
            )
            
            if not route_info:
                return Response(
                    {'error': 'Could not calculate route'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Serialize the result using query serializer
            serializer = RouteInfoSerializer(route_info)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Current location', GeoPointSerializer),
            404: openapi.Response('Delivery not found or no location available'),
        }
    )
    @action(detail=True, methods=['get'], url_path='current-location')
    def current_location(self, request, pk=None):
        """Get the current location for a delivery"""
        try:
            # Execute the query via application service
            location_service = ApplicationServiceFactory.create_location_application_service()
            location = location_service.get_current_delivery_location(
                delivery_id=UUID(pk)
            )
            
            if not location:
                return Response(
                    {'error': 'No location available for this delivery'},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Serialize the result using query serializer
            serializer = GeoPointSerializer(location)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
