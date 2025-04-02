"""
ViewSet for delivery search service.

This module provides a ViewSet for the delivery search service, including
finding nearby deliveries, following Domain-Driven Design principles
and Clean Architecture with CQRS pattern.
"""
import logging
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from deliveries.interfaces.api.views.base_viewset import BaseViewSet
from deliveries.interfaces.api.serializers import (
    DeliveryOutputSerializer,
    NearbyLocationsInputSerializer,
)
from deliveries.infrastructure.factory import ApplicationServiceFactory

logger = logging.getLogger(__name__)


class DeliverySearchViewSet(BaseViewSet):
    """ViewSet for delivery search service
    
    This ViewSet follows the CQRS pattern with separate serializers for
    commands (inputs) and queries (outputs), and uses dependency injection
    for repositories and services through the ApplicationServiceFactory.
    """
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(
        query_serializer=NearbyLocationsInputSerializer,
        manual_parameters=[
            openapi.Parameter('status', openapi.IN_QUERY, description="Filter by delivery status", type=openapi.TYPE_STRING),
        ],
        responses={
            200: openapi.Response('List of nearby deliveries', DeliveryOutputSerializer(many=True)),
            400: openapi.Response('Invalid input'),
        }
    )
    @action(detail=False, methods=['get'], url_path='nearby')
    def nearby_deliveries(self, request):
        """Find deliveries near a specific location"""
        try:
            # Validate input using query serializer
            query_params = {
                'latitude': request.query_params.get('latitude'),
                'longitude': request.query_params.get('longitude'),
                'radius_km': request.query_params.get('radius_km', 2.0)
            }
            
            # Convert string parameters to proper types
            if query_params['latitude'] and query_params['longitude']:
                query_params['latitude'] = float(query_params['latitude'])
                query_params['longitude'] = float(query_params['longitude'])
            if query_params['radius_km']:
                query_params['radius_km'] = float(query_params['radius_km'])
            
            validated_data = self.validate_serializer(
                NearbyLocationsInputSerializer, 
                query_params
            )
            
            # Get status filter if provided
            status_filter = request.query_params.get('status')
            
            # Execute the query via application service
            search_service = ApplicationServiceFactory.create_delivery_search_service()
            deliveries = search_service.find_nearby_deliveries(
                latitude=validated_data['latitude'],
                longitude=validated_data['longitude'],
                radius_km=validated_data.get('radius_km', 2.0),
                status=status_filter
            )
            
            # Serialize the results using query serializer
            serializer = DeliveryOutputSerializer(deliveries, many=True)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('query', openapi.IN_QUERY, description="Search query", type=openapi.TYPE_STRING, required=True),
        ],
        responses={
            200: openapi.Response('List of matching deliveries', DeliveryOutputSerializer(many=True)),
        }
    )
    @action(detail=False, methods=['get'], url_path='search')
    def search_deliveries(self, request):
        """Search for deliveries by query string"""
        try:
            # Get query parameter
            query = request.query_params.get('query', '')
            
            if not query:
                return Response(
                    {'error': 'Query parameter is required'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Execute the query via application service
            search_service = ApplicationServiceFactory.create_delivery_search_service()
            deliveries = search_service.search_deliveries(query)
            
            # Serialize the results using query serializer
            serializer = DeliveryOutputSerializer(deliveries, many=True)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
