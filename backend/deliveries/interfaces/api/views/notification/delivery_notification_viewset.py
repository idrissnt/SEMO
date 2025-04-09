"""
API viewset for delivery-related notifications.

This module provides API endpoints for handling delivery acceptance/refusal.
"""
from uuid import UUID
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from deliveries.infrastructure.factory import ApplicationServiceFactory
from deliveries.interfaces.api.serializers.notification_serializers import DriverNotificationSerializer
from deliveries.interfaces.api.serializers.delivery_serializers import DeliveryOutputSerializer


class DeliveryNotificationViewSet(viewsets.ViewSet):
    """ViewSet for managing delivery-related notifications"""
    
    permission_classes = [IsAuthenticated]
    
    def get_delivery_notification_service(self):
        """Get the delivery notification service"""
        return ApplicationServiceFactory.create_delivery_notification_service()
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Delivery accepted successfully'),
            400: openapi.Response('Invalid request or delivery already assigned'),
            404: openapi.Response('Delivery not found'),
            500: openapi.Response('Server error'),
        }
    )
    @action(detail=True, methods=['post'], url_path='accept')
    def accept(self, request: Request, pk=None) -> Response:
        """Accept a delivery"""
        try:
            # Get the driver ID from the authenticated user
            driver_id = request.user.id
            
            # Convert string ID to UUID
            try:
                delivery_id = UUID(pk)
            except ValueError:
                return Response(
                    {"error": "Invalid delivery ID format"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Handle delivery acceptance
            success, message, delivery = self.get_delivery_notification_service().handle_delivery_acceptance_from_notification(
                delivery_id=delivery_id,
                driver_id=driver_id
            )
            
            # Return response
            if success:
                response_data = {"message": message}
                if delivery:
                    serializer = DeliveryOutputSerializer(delivery)
                    response_data["delivery"] = serializer.data
                return Response(response_data, status=status.HTTP_200_OK)
            else:
                return Response(
                    {"error": message},
                    status=status.HTTP_400_BAD_REQUEST
                )
                
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Delivery refused successfully'),
            400: openapi.Response('Invalid request'),
            404: openapi.Response('Delivery not found'),
            500: openapi.Response('Server error'),
        }
    )
    @action(detail=True, methods=['post'], url_path='refuse')
    def refuse(self, request: Request, pk=None) -> Response:
        """Refuse a delivery"""
        try:
            # Get the driver ID from the authenticated user
            driver_id = request.user.id
            
            # Convert string ID to UUID
            try:
                delivery_id = UUID(pk)
            except ValueError:
                return Response(
                    {"error": "Invalid delivery ID format"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Handle delivery refusal
            success, message = self.get_delivery_notification_service().handle_delivery_refusal(
                delivery_id=delivery_id,
                driver_id=driver_id
            )
            
            # Return response
            if success:
                return Response(
                    {"message": message},
                    status=status.HTTP_200_OK
                )
            else:
                return Response(
                    {"error": message},
                    status=status.HTTP_400_BAD_REQUEST
                )
                
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
