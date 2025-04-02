"""
Django ORM implementation of the driver notification repository.

This module provides a Django ORM implementation of the DriverNotificationRepository interface
for managing driver notifications.
"""
from typing import List, Optional, Dict, Any
from uuid import UUID
from datetime import datetime

from django.db.models import Q

from deliveries.domain.models.entities.notification_entities import DriverNotification
from deliveries.domain.models.value_objects import NotificationStatus
from deliveries.domain.repositories.notification_repo.driver_notification_repository_interfaces import DriverNotificationRepository
from deliveries.infrastructure.django_models.notification_orm_models.driver_notification_model import DriverNotificationModel
from deliveries.infrastructure.django_models.driver_orm_models.driver_model import DriverModel
from deliveries.infrastructure.django_models.delivery_orm_models.delivery_models import DeliveryModel

class DjangoDriverNotificationRepository(DriverNotificationRepository):
    """Django ORM implementation of DriverNotificationRepository"""
    
    def create(self, driver_id: UUID, delivery_id: UUID, title: str, body: str, 
              data: Dict[str, Any]) -> DriverNotification:
        """Create a new driver notification"""
        try:
            # Get the driver and delivery models
            driver_model = DriverModel.objects.get(id=driver_id)
            delivery_model = DeliveryModel.objects.get(id=delivery_id)
            
            # Create the notification model
            notification_model = DriverNotificationModel.objects.create(
                driver=driver_model,
                delivery=delivery_model,
                title=title,
                body=body,
                data=data,
                status=NotificationStatus.PENDING.value
            )
            
            # Convert to domain entity
            return self._to_domain_entity(notification_model)
        except Exception as e:
            raise ValueError(f"Error creating notification: {str(e)}")
    
    def get_pending_notifications(self, driver_id: UUID) -> List[DriverNotification]:
        """Get all pending notifications for a driver"""
        try:
            # Query for pending notifications
            notification_models = DriverNotificationModel.objects.filter(
                driver__id=driver_id,
                status=NotificationStatus.PENDING.value
            ).select_related('driver', 'delivery')
            
            # Convert to domain entities
            return [self._to_domain_entity(model) for model in notification_models]
        except Exception as e:
            raise ValueError(f"Error getting pending notifications: {str(e)}")
    
    def update_status(self, notification_id: UUID, new_status: NotificationStatus, data: Optional[Dict] = None) -> bool:
        """Update the status and optionally the data of a notification"""
        try:
            # Prepare update fields
            update_fields = {
                'status': new_status.value,
                'updated_at': datetime.now()
            }
            
            # Add data if provided
            if data is not None:
                update_fields['data'] = data
            
            # Update the notification
            rows_updated = DriverNotificationModel.objects.filter(
                id=notification_id
            ).update(**update_fields)
            
            return rows_updated > 0
        except Exception as e:
            raise ValueError(f"Error updating notification status: {str(e)}")
    
    def get_by_delivery_and_driver(self, delivery_id: UUID, driver_id: UUID) -> Optional[DriverNotification]:
        """Get a notification by delivery and driver IDs"""
        try:
            # Query for the notification
            notification_model = DriverNotificationModel.objects.filter(
                delivery__id=delivery_id,
                driver__id=driver_id
            ).select_related('driver', 'delivery').first()
            
            # Convert to domain entity if found
            if notification_model:
                return self._to_domain_entity(notification_model)
            
            return None
        except Exception as e:
            raise ValueError(f"Error getting notification by delivery and driver: {str(e)}")
    
    def get_by_id(self, notification_id: UUID) -> Optional[DriverNotification]:
        """Get a notification by ID"""
        try:
            # Query for the notification
            notification_model = DriverNotificationModel.objects.filter(
                id=notification_id
            ).select_related('driver', 'delivery').first()
            
            # Convert to domain entity if found
            if notification_model:
                return self._to_domain_entity(notification_model)
            
            return None
        except Exception as e:
            raise ValueError(f"Error getting notification by ID: {str(e)}")
    
    def delete_notifications(self, 
                          driver_id: UUID,
                          notification_id: Optional[UUID] = None,
                          notification_ids: Optional[List[UUID]] = None,
                          status: Optional[NotificationStatus] = None,
                          delete_all: bool = False) -> int:
        """Unified method to delete notifications with various filtering options"""
        try:
            # Start with a base query for the driver's notifications
            query = DriverNotificationModel.objects.filter(driver__id=driver_id)
            
            # Apply filters based on provided parameters
            if notification_id is not None:
                # Delete a single notification
                query = query.filter(id=notification_id)
            elif notification_ids is not None and len(notification_ids) > 0:
                # Delete multiple notifications by ID
                query = query.filter(id__in=notification_ids)
            elif not delete_all and status is None:
                # If not deleting all and no status filter, don't delete anything
                return 0
            
            # Apply status filter if provided
            if status is not None:
                query = query.filter(status=status.value)
            
            # Execute the deletion
            count, _ = query.delete()
            
            # Return the number of notifications deleted
            return count
        except Exception as e:
            raise ValueError(f"Error deleting notifications: {str(e)}")
    
    def update_delivery_notifications(self,
                                    delivery_id: UUID,
                                    new_status: NotificationStatus,
                                    exclude_driver_id: UUID) -> int:
        """Update all notifications for a delivery using Django ORM with PostgreSQL JSON operations"""
        try:

            # Start with a base query for the delivery's notifications
            query = DriverNotificationModel.objects.filter(delivery__id=delivery_id)
            
            # Only update notifications with PENDING status
            query = query.filter(status=NotificationStatus.PENDING.value)
            
            # Exclude the specified driver if provided
            if exclude_driver_id is not None:
                query = query.exclude(driver__id=exclude_driver_id)
            
            # Prepare update fields
            update_fields = {
                'status': new_status.value,
                'updated_at': datetime.now()
            }
            # Execute the update
            count = query.update(**update_fields)
            
            # Return the number of notifications updated
            return count
        except Exception as e:
            raise ValueError(f"Error updating delivery notifications: {str(e)}")
    
    def get_notifications_for_delivery(self, delivery_id: UUID, status: Optional[NotificationStatus] = None) -> List[DriverNotification]:
        """Get all notifications for a specific delivery"""
        try:
            # Start with a base query for the delivery's notifications
            query = DriverNotificationModel.objects.filter(delivery__id=delivery_id)
            
            # Apply status filter if provided
            if status is not None:
                query = query.filter(status=status.value)
            
            # Include related models for better performance
            query = query.select_related('driver', 'delivery')
            
            # Convert to domain entities
            return [self._to_domain_entity(model) for model in query]
        except Exception as e:
            raise ValueError(f"Error getting notifications for delivery: {str(e)}")
    
    def get_all_driver_notifications(self,
                                  driver_id: UUID,
                                  status: Optional[NotificationStatus] = None,
                                  limit: Optional[int] = 20,
                                  cursor: Optional[UUID] = None) -> List[DriverNotification]:
        """Get all notifications for a driver with optional filtering and cursor-based pagination"""
        try:
            # Start with a base query for the driver's notifications
            query = DriverNotificationModel.objects.filter(driver__id=driver_id)
            
            # Apply status filter if provided
            if status is not None:
                query = query.filter(status=status.value)
            
            # Apply cursor-based pagination if provided
            if cursor is not None:
                # Get the created_at timestamp of the cursor notification
                try:
                    cursor_notification = DriverNotificationModel.objects.get(id=cursor)
                    # Get notifications created before the cursor notification
                    query = query.filter(
                        Q(created_at__lt=cursor_notification.created_at) | 
                        Q(created_at=cursor_notification.created_at, id__lt=cursor)
                    )
                except DriverNotificationModel.DoesNotExist:
                    # If cursor notification doesn't exist, just continue without filtering
                    pass
            
            # Order by created_at descending (newest first)
            query = query.order_by('-created_at')
            
            # Apply limit
            if limit is not None:
                query = query[:limit]
            
            # Include related models for better performance
            query = query.select_related('driver', 'delivery')
            
            # Convert to domain entities
            return [self._to_domain_entity(model) for model in query]
        except Exception as e:
            raise ValueError(f"Error getting all driver notifications: {str(e)}")
    
    def _to_domain_entity(self, notification_model: DriverNotificationModel) -> DriverNotification:
        """Convert ORM model to domain entity"""
        return DriverNotification(
            id=notification_model.id,
            driver_id=notification_model.driver.id,
            delivery_id=notification_model.delivery.id,
            title=notification_model.title,
            body=notification_model.body,
            data=notification_model.data,
            status=NotificationStatus(notification_model.status),
            created_at=notification_model.created_at,
            updated_at=notification_model.updated_at
        )
