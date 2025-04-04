"""
Serializers for tasks.
"""
from rest_framework import serializers
from datetime import datetime

from .task_attribute_serializer import TaskAttributeSerializer


class TaskSerializer(serializers.Serializer):
    """Serializer for tasks
    
    This serializer can handle both Task domain entities and dictionaries.
    It properly converts domain entities to API-friendly representations.
    """
    id = serializers.UUIDField(read_only=True)
    requester_id = serializers.UUIDField()
    title = serializers.CharField(max_length=100)
    description = serializers.CharField()
    image_url = serializers.ImageField(required=False)
    category_id = serializers.UUIDField()
    location_address = serializers.JSONField()
    budget = serializers.DecimalField(max_digits=10, decimal_places=2)
    estimated_duration = serializers.IntegerField()
    scheduled_date = serializers.DateTimeField()
    status = serializers.CharField(read_only=True)
    attributes = TaskAttributeSerializer(many=True)
    created_at = serializers.DateTimeField(read_only=True)
    updated_at = serializers.DateTimeField(read_only=True)
    
    def to_representation(self, instance):
        """Convert Task domain entity to dictionary representation
        
        This method handles both Task domain entities and dictionaries,
        ensuring consistent output regardless of input type.
        """
        # If instance is a Task domain entity, convert it to a dictionary
        if hasattr(instance, '__dataclass_fields__'):  # Check if it's a dataclass (Task)
            return {
                'id': str(instance.id),
                'requester_id': str(instance.requester_id),
                'title': instance.title,
                'description': instance.description,
                'image_url': instance.image_url,
                'category_id': str(instance.category_id),
                'location_address': instance.location_address,
                'budget': float(instance.budget),
                'estimated_duration': instance.estimated_duration,
                'scheduled_date': instance.scheduled_date.isoformat() if isinstance(instance.scheduled_date, datetime) else instance.scheduled_date,
                'status': instance.status.value if hasattr(instance.status, 'value') else instance.status,
                'attributes': [
                    {
                        'name': attr.name,
                        'question': attr.question,
                        'answer': attr.answer
                    }
                    for attr in instance.attributes
                ],
                'created_at': instance.created_at.isoformat() if isinstance(instance.created_at, datetime) else instance.created_at,
                'updated_at': instance.updated_at.isoformat() if isinstance(instance.updated_at, datetime) else instance.updated_at
            }
        
        # If it's already a dictionary, use the default behavior
        return super().to_representation(instance)


class TaskCreateSerializer(serializers.Serializer):
    """Serializer for creating tasks
    
    This serializer validates input data for task creation.
    """
    requester_id = serializers.UUIDField()
    title = serializers.CharField(max_length=100)
    description = serializers.CharField()
    image_url = serializers.ImageField(required=False)
    category_id = serializers.UUIDField()
    location_address = serializers.JSONField()
    budget = serializers.DecimalField(max_digits=10, decimal_places=2)
    estimated_duration = serializers.IntegerField()
    scheduled_date = serializers.DateTimeField()
    attributes = TaskAttributeSerializer(many=True)


class TaskSearchSerializer(serializers.Serializer):
    """Serializer for task search parameters"""
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()
    radius_km = serializers.FloatField(default=10.0)
