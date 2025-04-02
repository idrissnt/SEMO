"""
Serializers for the Driver entity.

This module provides serializers for the Driver domain entity,
following CQRS pattern with separate input and output serializers.
"""
from rest_framework import serializers

from deliveries.domain.models.entities import Driver
from deliveries.interfaces.api.serializers.base_serializers import EntitySerializer


class DriverOutputSerializer(EntitySerializer):
    """
    Serializer for outputting Driver entity data
    
    This serializer is used for read operations (queries) and focuses on
    providing a complete representation of a Driver entity.
    """
    id = serializers.UUIDField(read_only=True)
    user_id = serializers.UUIDField(read_only=True)
    is_available = serializers.BooleanField(read_only=True)
    license_number = serializers.CharField(read_only=True)
    has_vehicle = serializers.BooleanField(read_only=True)


class DriverCreateInputSerializer(EntitySerializer):
    """
    Serializer for creating a new Driver
    
    This serializer is used for the create operation and only includes
    fields that are required for creating a new Driver. Following Clean Architecture,
    this serializer only validates input data and doesn't create entities directly.
    """
    user_id = serializers.UUIDField()
    license_number = serializers.CharField(required=False, allow_blank=True)
    has_vehicle = serializers.BooleanField(default=False)
    
    def validate(self, data):
        """Validate the input data"""
        # Set default values
        data.setdefault('is_available', True)
        
        # Any additional validation specific to driver creation
        # could be added here
        return data


class DriverUpdateInfoInputSerializer(EntitySerializer):
    """
    Serializer for updating a Driver's information
    
    This serializer is focused on the specific use case of updating
    a driver's information, following the Command pattern and Clean Architecture.
    It only validates input data and doesn't modify entities directly.
    """
    license_number = serializers.CharField()
    has_vehicle = serializers.BooleanField()
    
    def validate(self, data):
        """Validate the input data"""
        # Any additional validation specific to driver info updates
        # could be added here
        return data


class DriverUpdateAvailabilityInputSerializer(EntitySerializer):
    """
    Serializer for updating a Driver's availability
    
    This serializer is focused on the specific use case of updating
    a driver's availability status, following the Command pattern and Clean Architecture.
    It only validates input data and doesn't modify entities directly.
    """
    is_available = serializers.BooleanField()
    
    def validate(self, data):
        """Validate the input data"""
        # Any additional validation specific to availability updates
        # could be added here
        return data
