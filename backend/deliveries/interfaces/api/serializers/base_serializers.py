"""
Base serializers for the deliveries domain.

This module provides base serializers and common patterns for serializing
domain entities and value objects, following DDD principles.
"""
from rest_framework import serializers

from deliveries.domain.models.value_objects import GeoPoint, RouteInfo


class ValueObjectSerializer(serializers.Serializer):
    """
    Base serializer for value objects
    
    Value objects are immutable, so this serializer ensures that
    update operations create new instances rather than modifying
    existing ones.
    """
    
    def update(self, instance, validated_data):
        """
        Value objects are immutable, so we create a new instance
        instead of updating the existing one.
        """
        return self.create(validated_data)


class GeoPointSerializer(ValueObjectSerializer):
    """Serializer for GeoPoint value object"""
    latitude = serializers.FloatField(min_value=-90, max_value=90)
    longitude = serializers.FloatField(min_value=-180, max_value=180)
    
    def create(self, validated_data):
        return GeoPoint(**validated_data)


class RouteInfoSerializer(ValueObjectSerializer):
    """Serializer for RouteInfo value object"""
    origin = GeoPointSerializer()
    destination = GeoPointSerializer()
    distance_meters = serializers.IntegerField(min_value=0)
    duration_seconds = serializers.IntegerField(min_value=0)
    polyline = serializers.CharField(allow_blank=True)
    waypoints = GeoPointSerializer(many=True, required=False)
    
    def create(self, validated_data):
        origin_data = validated_data.pop('origin')
        destination_data = validated_data.pop('destination')
        waypoints_data = validated_data.pop('waypoints', [])
        
        origin = GeoPoint(**origin_data)
        destination = GeoPoint(**destination_data)
        waypoints = [GeoPoint(**point) for point in waypoints_data]
        
        return RouteInfo(
            origin=origin,
            destination=destination,
            waypoints=waypoints,
            **validated_data
        )


class EntitySerializer(serializers.Serializer):
    """
    Base serializer for domain entities
    
    This serializer provides common functionality for serializing
    domain entities, including handling nested value objects.
    """
    id = serializers.UUIDField(read_only=True)
    
    def get_value_object(self, data, serializer_class, allow_null=True):
        """
        Helper method to create a value object from serialized data
        
        Args:
            data: The serialized data
            serializer_class: The serializer class to use
            allow_null: Whether to allow null values
            
        Returns:
            The value object instance or None if data is None and allow_null is True
        """
        if data is None:
            if allow_null:
                return None
            raise serializers.ValidationError("This field may not be null.")
            
        serializer = serializer_class(data=data)
        serializer.is_valid(raise_exception=True)
        return serializer.save()
