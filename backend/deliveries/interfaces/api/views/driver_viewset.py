"""
ViewSet for driver management.

This module provides a ViewSet for managing delivery drivers, including creating,
retrieving, and updating driver information, following Domain-Driven Design principles
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
    DriverOutputSerializer,
    DriverCreateInputSerializer,
    DriverUpdateInfoInputSerializer,
    DriverUpdateAvailabilityInputSerializer,
    DeliveryOutputSerializer,
)

logger = logging.getLogger(__name__)


class DriverViewSet(BaseViewSet):
    """ViewSet for managing delivery drivers
    
    This ViewSet follows the CQRS pattern with separate serializers for
    commands (inputs) and queries (outputs), and uses dependency injection
    for repositories and services.
    """
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(
        request_body=DriverCreateInputSerializer,
        responses={
            201: openapi.Response('Driver created successfully', DriverOutputSerializer),
            400: openapi.Response('Invalid request parameters'),
        }
    )
    def create(self, request):
        """Create a new driver profile"""
        try:
            # Validate input using command serializer
            validated_data = self.validate_serializer(
                DriverCreateInputSerializer, 
                request.data
            )
            
            # Execute the command via application service
            driver = self.delivery_service.create_driver(
                user_id=validated_data['user_id'],
                license_number=validated_data.get('license_number', ''),
                has_vehicle=validated_data.get('has_vehicle', False)
            )
            
            # Serialize the result using query serializer
            serializer = DriverOutputSerializer(driver)
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Driver details', DriverOutputSerializer),
            404: openapi.Response('Driver not found'),
        }
    )
    def retrieve(self, request, pk=None):
        """Get details for a specific driver"""
        try:
            # Execute the query via application service
            driver = self.delivery_service.get_driver(pk)
            
            if not driver:
                return Response(
                    {'error': 'Driver not found'},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Serialize the result using query serializer
            serializer = DriverOutputSerializer(driver)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('List of drivers', DriverOutputSerializer(many=True)),
        }
    )
    def list(self, request):
        """Get a list of all drivers, optionally filtered by availability"""
        try:
            # Get query parameters
            available_only = request.query_params.get('available', 'false').lower() == 'true'
            
            # Execute the query via application service
            if available_only:
                drivers = self.delivery_service.get_available_drivers()
            else:
                drivers = self.delivery_service.get_all_drivers()
            
            # Serialize the results using query serializer
            serializer = DriverOutputSerializer(drivers, many=True)
            
            return Response(serializer.data)
                
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        request_body=DriverUpdateInfoInputSerializer,
        responses={
            200: openapi.Response('Driver information updated successfully', DriverOutputSerializer),
            400: openapi.Response('Invalid request parameters'),
            404: openapi.Response('Driver not found'),
        }
    )
    @action(detail=True, methods=['patch'], url_path='info')
    def update_info(self, request, pk=None):
        """Update a driver's information"""
        try:
            # Validate driver ID
            driver_uuid = UUID(pk)
            
            # Validate input using command serializer
            validated_data = self.validate_serializer(
                DriverUpdateInfoInputSerializer, 
                request.data
            )
            
            # Execute the command via application service
            success, message, driver = self.delivery_service.update_driver_info(
                driver_id=driver_uuid,
                license_number=validated_data['license_number'],
                has_vehicle=validated_data['has_vehicle']
            )
            
            if success:
                # Serialize the result using query serializer
                serializer = DriverOutputSerializer(driver)
                return Response({
                    'message': message,
                    'driver': serializer.data
                })
            else:
                return Response(
                    {'error': message},
                    status=status.HTTP_404_NOT_FOUND
                )
                
        except ValueError:
            return Response(
                {'error': 'Invalid driver ID format'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        request_body=DriverUpdateAvailabilityInputSerializer,
        responses={
            200: openapi.Response('Driver availability updated successfully', DriverOutputSerializer),
            400: openapi.Response('Invalid request parameters'),
            404: openapi.Response('Driver not found'),
        }
    )
    @action(detail=True, methods=['patch'], url_path='availability')
    def update_availability(self, request, pk=None):
        """Update a driver's availability status"""
        try:
            # Validate driver ID
            driver_uuid = UUID(pk)
            
            # Validate input using command serializer
            validated_data = self.validate_serializer(
                DriverUpdateAvailabilityInputSerializer, 
                request.data
            )
            
            # Execute the command via application service
            success, message, driver = self.delivery_service.update_driver_availability(
                driver_id=driver_uuid,
                is_available=validated_data['is_available']
            )
            
            if success:
                # Serialize the result using query serializer
                serializer = DriverOutputSerializer(driver)
                return Response({
                    'message': message,
                    'driver': serializer.data
                })
            else:
                return Response(
                    {'error': message},
                    status=status.HTTP_404_NOT_FOUND
                )
                
        except ValueError:
            return Response(
                {'error': 'Invalid driver ID format'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return self.handle_exception(e)
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('List of assigned deliveries', DeliveryOutputSerializer(many=True)),
            404: openapi.Response('Driver not found'),
        }
    )
    @action(detail=True, methods=['get'], url_path='deliveries')
    def assigned_deliveries(self, request, pk=None):
        """Get all deliveries assigned to a specific driver"""
        try:
            # Validate driver ID
            driver_uuid = UUID(pk)
            
            # Execute the query via application service
            deliveries = self.delivery_service.get_driver_deliveries(driver_uuid)
            
            if deliveries is None:
                return Response(
                    {'error': 'Driver not found'},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Serialize the results using query serializer
            serializer = DeliveryOutputSerializer(deliveries, many=True)
            
            return Response(serializer.data)
                
        except ValueError:
            return Response(
                {'error': 'Invalid driver ID format'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return self.handle_exception(e)
