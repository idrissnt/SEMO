"""
Serializers for the Delivery entity.

This module provides serializers for the Delivery domain entity,
following CQRS pattern with separate input and output serializers.
"""
from rest_framework import serializers

from deliveries.domain.models.entities import Delivery
from deliveries.interfaces.api.serializers.base_serializers import EntitySerializer, GeoPointSerializer


class DeliveryOutputSerializer(EntitySerializer):
    """
    Serializer for outputting Delivery entity data
    
    This serializer is used for read operations (queries) and focuses on
    providing a complete representation of a Delivery entity.
    """
    id = serializers.UUIDField(read_only=True)
    order_id = serializers.UUIDField(read_only=True)
    fee = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    total_items = serializers.IntegerField(read_only=True)
    items = serializers.JSONField(read_only=True)
    order_total_price = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    delivery_address_human_readable = serializers.CharField(read_only=True)
    store_brand_id = serializers.UUIDField(read_only=True)
    store_brand_name = serializers.CharField(read_only=True)
    store_brand_image_logo = serializers.CharField(read_only=True)
    store_brand_address_human_readable = serializers.CharField(read_only=True)
    notes_for_driver = serializers.CharField(read_only=True, allow_null=True)
    driver_id = serializers.UUIDField(read_only=True, allow_null=True)
    schedule_for = serializers.DateTimeField(read_only=True)
    status = serializers.CharField(read_only=True)
    estimated_total_time = serializers.IntegerField(read_only=True)
    created_at = serializers.DateTimeField(read_only=True)
    estimated_arrival_time = serializers.DateTimeField(read_only=True)
    
    # Nested value objects
    delivery_location_geopoint = GeoPointSerializer(read_only=True)
    store_location_geopoint = GeoPointSerializer(read_only=True)


class DeliveryCreateInputSerializer(EntitySerializer):
    """
    Serializer for creating a new Delivery
    
    This serializer is used for the create operation and only includes
    fields that are required for creating a new Delivery. Following Clean Architecture,
    this serializer only validates input data and doesn't create entities directly.
    """
    order_id = serializers.UUIDField()
    
    def validate(self, data):
        """Validate the input data"""
        # Any additional validation specific to delivery creation
        # could be added here
        return data


class DeliveryUpdateStatusInputSerializer(EntitySerializer):
    """
    Serializer for updating a Delivery's status
    
    This serializer is focused on the specific use case of updating
    a delivery's status, following the Command pattern.
    """
    status = serializers.CharField()
    notes = serializers.CharField(required=False, allow_blank=True)
    
    def validate_status(self, value):
        """Validate status transitions"""
        status_order = ['pending', 'assigned', 'out_for_delivery', 'delivered', 'cancelled']
        
        if value not in status_order:
            raise serializers.ValidationError(f"Invalid status: {value}")
        
        # If we have an instance (an existing delivery), validate the transition
        if self.instance:
            current_status = self.instance.status
            
            # If current status is a terminal state, no transitions allowed
            if current_status in ['delivered', 'cancelled']:
                raise serializers.ValidationError(
                    f"Cannot change status from terminal state: {current_status}"
                )
                
            # If not a terminal state, check for valid transitions
            if value != 'cancelled' and status_order.index(value) < status_order.index(current_status):
                raise serializers.ValidationError("Cannot revert to previous status")
                
        return value


class DeliveryAssignDriverInputSerializer(EntitySerializer):
    """
    Serializer for assigning a driver to a Delivery
    
    This serializer is focused on the specific use case of assigning
    a driver to a delivery, following the Command pattern and Clean Architecture.
    It only validates input data and doesn't modify entities directly.
    """
    driver_id = serializers.UUIDField()
    
    def validate(self, data):
        """Validate the input data"""
        # Any additional validation specific to driver assignment
        # could be added here
        return data


class DeliveryUpdateLocationInputSerializer(EntitySerializer):
    """
    Serializer for updating a Delivery's locations
    
    This serializer is focused on the specific use case of updating
    the geospatial coordinates for a delivery.
    """
    delivery_location_geopoint = GeoPointSerializer(required=False)
    store_location_geopoint = GeoPointSerializer(required=False)
    
    def validate(self, data):
        """Validate that at least one location is provided"""
        if not data.get('delivery_location_geopoint') and not data.get('store_location_geopoint'):
            raise serializers.ValidationError(
                "At least one of 'delivery_location_geopoint' or 'store_location_geopoint' must be provided"
            )
        return data


class DeliveryUpdateETAInputSerializer(EntitySerializer):
    """
    Serializer for updating a Delivery's estimated arrival time
    
    This serializer is focused on the specific use case of updating
    the estimated arrival time for a delivery, following Clean Architecture.
    It only validates input data and doesn't modify entities directly.
    """
    estimated_arrival_time = serializers.DateTimeField()
    
    def validate(self, data):
        """Validate the input data"""
        # Any additional validation specific to ETA updates
        # could be added here
        return data
