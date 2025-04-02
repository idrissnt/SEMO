"""
API viewset for driver-specific notifications.

This module provides API endpoints for managing driver notifications, including
retrieving, sending, and updating notification statuses.
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
from deliveries.domain.models.value_objects import NotificationStatus


class DriverNotificationViewSet(viewsets.ViewSet):
    """ViewSet for managing driver-specific notifications"""
    
    permission_classes = [IsAuthenticated]
    
    def get_driver_notification_service(self):
        """Get the driver notification service"""
        return ApplicationServiceFactory.create_driver_notification_service()
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('List of driver notifications', DriverNotificationSerializer(many=True)),
            500: openapi.Response('Server error'),
        },
        manual_parameters=[
            openapi.Parameter(
                'status', 
                openapi.IN_QUERY, 
                description="Filter by notification status (PENDING, SENT, ACCEPTED, REFUSED, CANCELLED)",
                type=openapi.TYPE_STRING,
                required=False
            ),
            openapi.Parameter(
                'limit', 
                openapi.IN_QUERY, 
                description="Maximum number of notifications to return",
                type=openapi.TYPE_INTEGER,
                required=False
            ),
            openapi.Parameter(
                'cursor', 
                openapi.IN_QUERY, 
                description="Cursor (notification ID) for pagination - returns notifications older than this ID",
                type=openapi.TYPE_STRING,
                required=False
            ),
        ]
    )
    @action(detail=False, methods=['get'], url_path='list')
    def list_notifications(self, request: Request) -> Response:
        """Get all notifications for the authenticated driver with optional filtering and pagination"""
        try:
            # Get the driver ID from the authenticated user
            driver_id = request.user.id
            
            # Get query parameters
            status_param = request.query_params.get('status')
            limit_param = request.query_params.get('limit')
            cursor_param = request.query_params.get('cursor')
            
            # Convert status to enum if provided
            status_filter = None
            if status_param:
                try:
                    status_filter = NotificationStatus(status_param)
                except ValueError:
                    return Response(
                        {"error": f"Invalid status value: {status_param}"},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            
            # Convert limit to integer if provided
            limit = int(limit_param) if limit_param else 20
            
            # Convert cursor to UUID if provided
            cursor = None
            if cursor_param:
                try:
                    cursor = UUID(cursor_param)
                except ValueError:
                    return Response(
                        {"error": f"Invalid cursor value: {cursor_param}"},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            
            # Get notifications
            notifications = self.get_driver_notification_service().get_driver_notifications(
                driver_id=driver_id,
                status=status_filter,
                limit=limit,
                cursor=cursor
            )
            
            # Serialize notifications
            serializer = DriverNotificationSerializer(notifications, many=True)
            
            # Return response
            return Response(serializer.data, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Notifications sent successfully'),
            500: openapi.Response('Server error'),
        }
    )
    @action(detail=False, methods=['post'], url_path='send-pending')
    def send_pending(self, request: Request) -> Response:
        """Send all pending notifications to the authenticated driver"""
        try:
            # Get the driver ID from the authenticated user
            driver_id = request.user.id
            
            # Send pending notifications
            results = self.get_driver_notification_service().send_pending_notifications(
                driver_id=driver_id
            )
            
            # Return response
            if results:
                success_count = sum(1 for success in results.values() if success)
                return Response(
                    {
                        "message": f"Sent {success_count} out of {len(results)} notifications",
                        "results": {str(k): v for k, v in results.items()}
                    },
                    status=status.HTTP_200_OK
                )
            else:
                return Response(
                    {"message": "No pending notifications found"},
                    status=status.HTTP_200_OK
                )
                
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
