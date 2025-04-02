"""
API viewset for driver notifications.

This module provides API endpoints for managing driver notifications, including
retrieving pending notifications and handling delivery acceptance/refusal.
"""
from uuid import UUID
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from deliveries.interfaces.api.serializers.notification_serializers import DriverNotificationSerializer
from deliveries.infrastructure.factory import RepositoryFactory
from deliveries.application.services.notification_service import NotificationApplicationService
from deliveries.domain.models.value_objects import NotificationStatus


class NotificationViewSet(viewsets.ViewSet):
    """ViewSet for managing driver notifications"""
    
    permission_classes = [IsAuthenticated]
    
    def get_notification_repository(self):
        """Get the notification repository"""
        return RepositoryFactory.create_driver_notification_repository()
    
    def get_notification_service(self):
        """Get the notification application service"""
        delivery_repository = RepositoryFactory.create_delivery_repository()
        driver_repository = RepositoryFactory.create_driver_repository()
        return NotificationApplicationService(
            delivery_repository=delivery_repository,
            driver_repository=driver_repository
        )
    
    @swagger_auto_schema(
        responses={
            200: openapi.Response('List of pending notifications', DriverNotificationSerializer(many=True)),
            500: openapi.Response('Server error'),
        }
    )
    @action(detail=False, methods=['get'], url_path='pending')
    def pending(self, request: Request) -> Response:
        """Get all pending notifications for the authenticated driver"""
        try:
            # Get the driver ID from the authenticated user
            driver_id = request.user.id
            
            # Get pending notifications
            notifications = self.get_notification_repository().get_pending_notifications(
                driver_id=driver_id
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
    @action(detail=False, methods=['post'], url_path='send')
    def send(self, request: Request) -> Response:
        """Send all pending notifications to the authenticated driver"""
        try:
            # Get the driver ID from the authenticated user
            driver_id = request.user.id
            
            # Send pending notifications
            results = self.get_notification_service().send_pending_notifications(
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
    
    @swagger_auto_schema(
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'notification_id': openapi.Schema(
                    type=openapi.TYPE_STRING,
                    format=openapi.FORMAT_UUID,
                    description='Single notification ID to delete'
                ),
                'notification_ids': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(type=openapi.TYPE_STRING, format=openapi.FORMAT_UUID),
                    description='List of notification IDs to delete'
                ),
                'delete_all': openapi.Schema(
                    type=openapi.TYPE_BOOLEAN,
                    description='If true, delete all notifications for the driver'
                ),
                'status': openapi.Schema(
                    type=openapi.TYPE_STRING,
                    description="Filter by notification status (e.g., 'PENDING', 'SENT', 'ACCEPTED', 'REFUSED')"
                )
            }
        ),
        responses={
            200: openapi.Response('Notifications deleted successfully'),
            400: openapi.Response('Invalid request parameters'),
            500: openapi.Response('Server error'),
        }
    )
    @action(detail=False, methods=['post'], url_path='delete')
    def delete_notifications(self, request: Request) -> Response:
        """Unified endpoint to delete notifications
        
        This endpoint supports multiple deletion modes:
        1. Delete a single notification by ID
        2. Delete multiple notifications by ID list
        3. Delete all notifications for the driver
        4. Filter by notification status
        """
        try:
            # Get the driver ID from the authenticated user
            driver_id = request.user.id
            
            # Extract parameters from request body
            notification_id = request.data.get('notification_id')
            notification_ids = request.data.get('notification_ids')
            delete_all = request.data.get('delete_all', False)
            status_param = request.data.get('status')
            
            # Validate and convert notification_id if provided
            if notification_id:
                try:
                    notification_id = UUID(notification_id) if isinstance(notification_id, str) else notification_id
                    
                    # Check if notification exists and belongs to the driver
                    notification = self.get_notification_repository().get_by_id(notification_id)
                    if not notification:
                        return Response(
                            {"error": "Notification not found"},
                            status=status.HTTP_404_NOT_FOUND
                        )
                        
                    if notification.driver_id != driver_id:
                        return Response(
                            {"error": "You do not have permission to delete this notification"},
                            status=status.HTTP_403_FORBIDDEN
                        )
                except ValueError:
                    return Response(
                        {"error": "Invalid notification ID format"},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            
            # Validate and convert notification_ids if provided
            if notification_ids:
                try:
                    notification_ids = [UUID(id) if isinstance(id, str) else id for id in notification_ids]
                except ValueError:
                    return Response(
                        {"error": "Invalid notification ID format in list"},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            
            # Validate status parameter if provided
            status_filter = None
            if status_param:
                try:
                    status_filter = NotificationStatus(status_param)
                except ValueError:
                    return Response(
                        {"error": f"Invalid status value: {status_param}"},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            
            # Ensure at least one deletion criteria is provided
            if not notification_id and not notification_ids and not delete_all:
                return Response(
                    {"error": "You must specify at least one of: notification_id, notification_ids, or delete_all=true"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Delete notifications using the unified method
            count = self.get_notification_repository().delete_notifications(
                driver_id=driver_id,
                notification_id=notification_id,
                notification_ids=notification_ids,
                status=status_filter,
                delete_all=delete_all
            )
            
            # Return response
            return Response(
                {
                    "message": f"Successfully deleted {count} notifications",
                    "count": count
                },
                status=status.HTTP_200_OK
            )
                
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    # Keep the detail=True destroy method for RESTful compatibility
    @swagger_auto_schema(
        responses={
            200: openapi.Response('Notification deleted successfully'),
            404: openapi.Response('Notification not found'),
            500: openapi.Response('Server error'),
        }
    )
    @action(detail=True, methods=['delete'])
    def destroy(self, request: Request, pk=None) -> Response:
        """Delete a specific notification (RESTful compatibility method)"""
        try:
            # Convert string ID to UUID
            try:
                notification_id = UUID(pk)
            except ValueError:
                return Response(
                    {"error": "Invalid notification ID format"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Forward to the unified deletion endpoint
            request._full_data = {'notification_id': str(notification_id)}
            return self.delete_notifications(request)
                
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
