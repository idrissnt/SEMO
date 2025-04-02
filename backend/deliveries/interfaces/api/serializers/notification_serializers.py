"""
Serializers for driver notifications.

This module provides serializers for driver notification entities.
"""
from rest_framework import serializers

from deliveries.domain.models.entities.notification_entities import DriverNotification


class DriverNotificationSerializer(serializers.Serializer):
    """Serializer for driver notifications"""
    
    id = serializers.UUIDField()
    driver_id = serializers.UUIDField()
    delivery_id = serializers.UUIDField()
    title = serializers.CharField()
    body = serializers.CharField()
    data = serializers.JSONField()
    status = serializers.CharField(source='status.value')
    created_at = serializers.DateTimeField()
    updated_at = serializers.DateTimeField()
    
    def to_representation(self, instance: DriverNotification) -> dict:
        """Convert notification entity to dictionary representation"""
        ret = super().to_representation(instance)
        # Convert status enum to string value
        ret['status'] = instance.status.value
        return ret
