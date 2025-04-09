"""
Django ORM model for driver notifications.

This module provides the Django ORM model for storing driver notifications.
"""
import uuid
from django.db import models
from django.db import models

from deliveries.infrastructure.django_models.driver_orm_models.driver_model import DriverModel
from deliveries.infrastructure.django_models.delivery_orm_models.delivery_models import DeliveryModel
from deliveries.domain.models.value_objects import NotificationStatus

class DriverNotificationModel(models.Model):
    """Django ORM model for driver notifications"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    driver = models.ForeignKey(DriverModel, on_delete=models.CASCADE, related_name="notifications")
    delivery = models.ForeignKey(DeliveryModel, on_delete=models.CASCADE, related_name="notifications")
    title = models.CharField(max_length=255)
    body = models.TextField()
    data = models.JSONField(default=dict)
    status = models.CharField(max_length=20, default=NotificationStatus.PENDING.value)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = "driver_notifications"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["driver", "status"]),
            models.Index(fields=["delivery", "driver"]),
        ]
        
    def __str__(self):
        return f"Notification for {self.driver} - {self.title[:30]}"
