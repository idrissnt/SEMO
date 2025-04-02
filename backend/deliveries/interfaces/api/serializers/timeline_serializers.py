"""
Serializers for the DeliveryTimelineEvent entity.

This module provides serializers for the DeliveryTimelineEvent domain entity,
following CQRS pattern with separate input and output serializers.
"""
from rest_framework import serializers

from deliveries.interfaces.api.serializers.base_serializers import EntitySerializer, GeoPointSerializer


class DeliveryTimelineEventOutputSerializer(EntitySerializer):
    """
    Serializer for outputting DeliveryTimelineEvent entity data
    
    This serializer is used for read operations (queries) and focuses on
    providing a complete representation of a DeliveryTimelineEvent entity.
    """
    id = serializers.UUIDField(read_only=True)
    delivery_id = serializers.UUIDField(read_only=True)
    event_type = serializers.CharField(read_only=True)
    notes = serializers.CharField(read_only=True)
    location = GeoPointSerializer(read_only=True)
    timestamp = serializers.DateTimeField(read_only=True)


class DeliveryTimelineEventCreateInputSerializer(EntitySerializer):
    """
    Serializer for creating a new DeliveryTimelineEvent
    
    This serializer is used for the create operation and only includes
    fields that are required for creating a new DeliveryTimelineEvent. Following Clean Architecture,
    this serializer only validates input data and doesn't create entities directly.
    """
    delivery_id = serializers.UUIDField()
    event_type = serializers.CharField()
    notes = serializers.CharField(required=False, allow_blank=True)
    location = GeoPointSerializer(required=False)
    
    def validate(self, data):
        """Validate the input data"""
        # Any additional validation specific to timeline event creation
        # could be added here
        
        # Validate event_type
        # valid_event_types = ['created', 'assigned', 'picked_up', 'delivered', 'cancelled', 'status_changed', 'location_updated']
        valid_event_types = ['created', 'assigned', 'in_the_store', 'out_for_delivery', 'delivered', 'cancelled', 'status_changed', 'location_updated']
        if data.get('event_type') and data['event_type'] not in valid_event_types:
            raise serializers.ValidationError(f"Invalid event_type. Must be one of: {', '.join(valid_event_types)}")
            
        return data
