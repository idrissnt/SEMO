"""
Serializers for task categories.
"""
from rest_framework import serializers
from tasks.domain.models import TaskCategory


class TaskCategorySerializer(serializers.Serializer):
    """Serializer for task categories
    
    This serializer can handle both TaskCategory domain entities and dictionaries.
    It includes UI-specific fields like image_url, icon_name, and color_hex.
    """
    id = serializers.UUIDField(read_only=True)
    type = serializers.CharField()
    name = serializers.CharField()
    display_name = serializers.CharField()
    description = serializers.CharField()
    image_url = serializers.URLField()
    icon_name = serializers.CharField()
    color_hex = serializers.CharField()
    created_at = serializers.DateTimeField(read_only=True)
    updated_at = serializers.DateTimeField(read_only=True)
    
    def to_representation(self, instance):
        """Convert TaskCategory domain entity to dictionary representation"""
        # If instance is a TaskCategory domain entity, convert it to a dictionary
        if hasattr(instance, '__dataclass_fields__'):  # Check if it's a dataclass
            return {
                'id': str(instance.id),
                'type': instance.type.value,
                'name': instance.name,
                'display_name': instance.display_name,
                'description': instance.description,
                'image_url': instance.image_url,
                'icon_name': instance.icon_name,
                'color_hex': instance.color_hex,
                'created_at': instance.created_at.isoformat() if instance.created_at else None,
                'updated_at': instance.updated_at.isoformat() if instance.updated_at else None,
            }
        # If instance is already a dictionary, use the default to_representation
        return super().to_representation(instance)
    
    def create(self, validated_data):
        """Create a new TaskCategory instance"""
        # This method will be called when creating a new category
        # The validated_data will be passed to the service layer
        return validated_data
    
    def update(self, instance, validated_data):
        """Update an existing TaskCategory instance"""
        # This method will be called when updating an existing category
        # The instance and validated_data will be passed to the service layer
        return {**instance, **validated_data}
