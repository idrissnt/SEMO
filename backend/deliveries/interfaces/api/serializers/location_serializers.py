"""
Serializers for the DeliveryLocation entity.

This module provides serializers for the DeliveryLocation domain entity,
following CQRS pattern with separate input and output serializers.
"""
from rest_framework import serializers

from deliveries.domain.models.entities import DeliveryLocation
from deliveries.interfaces.api.serializers.base_serializers import EntitySerializer, GeoPointSerializer


class DeliveryLocationOutputSerializer(EntitySerializer):
    """
    Serializer for outputting DeliveryLocation entity data
    
    This serializer is used for read operations (queries) and focuses on
    providing a complete representation of a DeliveryLocation entity.
    """
    id = serializers.UUIDField(read_only=True)
    delivery_id = serializers.UUIDField(read_only=True)
    driver_id = serializers.UUIDField(read_only=True)
    location = GeoPointSerializer(read_only=True)
    recorded_at = serializers.DateTimeField(read_only=True)


class DeliveryLocationCreateInputSerializer(EntitySerializer):
    """
    Serializer for creating a new DeliveryLocation
    
    This serializer is used for the create operation and only includes
    fields that are required for creating a new DeliveryLocation. Following Clean Architecture,
    this serializer only validates input data and doesn't create entities directly.
    """
    delivery_id = serializers.UUIDField()
    driver_id = serializers.UUIDField(required=False)
    location = GeoPointSerializer()
    
    def validate(self, data):
        """Validate the input data"""
        # Any additional validation specific to location creation
        # could be added here
        return data


class NearbyLocationsInputSerializer(serializers.Serializer):
    """
    Serializer for querying nearby delivery locations
    
    This serializer is used for the specific query of finding
    delivery locations near a given point. Following Clean Architecture,
    this serializer only validates input data and provides a method to convert
    to a domain value object.
    """
    latitude = serializers.FloatField(min_value=-90, max_value=90)
    longitude = serializers.FloatField(min_value=-180, max_value=180)
    radius_km = serializers.FloatField(min_value=0.1, max_value=50, default=2.0)
    
    def validate(self, data):
        """Validate the input data"""
        # Any additional validation specific to nearby location queries
        # could be added here
        return data
    
    def to_geo_point(self):
        """Convert the validated data to a GeoPoint value object"""
        from deliveries.domain.models.value_objects import GeoPoint
        return GeoPoint(
            latitude=self.validated_data['latitude'],
            longitude=self.validated_data['longitude']
        )
