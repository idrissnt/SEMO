"""
Serializer for predefined task types.
"""
from rest_framework import serializers
from datetime import datetime


class PredefinedTaskTypeSerializer(serializers.Serializer):
    """Serializer for predefined task types
    
    Predefined task types serve as templates for common tasks, providing default values,
    suggested formats, and relevant questions for specific categories of tasks.
    
    This serializer can handle both PredefinedTaskType domain entities and dictionaries.
    """
    id = serializers.UUIDField(read_only=True)
    category_id = serializers.UUIDField()
    title_template = serializers.CharField()
    description_template = serializers.CharField()
    image_url = serializers.ImageField(required=False)
    location_address = serializers.CharField(required=False)
    scheduled_date = serializers.DateTimeField(required=False, allow_null=True)
    estimated_budget_range = serializers.ListField(child=serializers.FloatField())
    estimated_duration_range = serializers.ListField(child=serializers.IntegerField())
    attribute_templates = serializers.ListField(
        child=serializers.DictField(
            child=serializers.CharField()
        )
    )
    
    def to_representation(self, instance):
        """Convert PredefinedTaskType domain entity to dictionary representation"""
        # If instance is a PredefinedTaskType domain entity, convert it to a dictionary
        if hasattr(instance, '__dataclass_fields__'):  # Check if it's a dataclass
            return {
                'id': str(instance.id),
                'category_id': str(instance.category_id),
                'title_template': instance.title_template,
                'description_template': instance.description_template,
                'image_url': instance.image_url,
                'location_address': instance.location_address,
                'scheduled_date': instance.scheduled_date.isoformat() if instance.scheduled_date and isinstance(instance.scheduled_date, datetime) else instance.scheduled_date,
                'estimated_budget_range': list(instance.estimated_budget_range),
                'estimated_duration_range': list(instance.estimated_duration_range),
                'attribute_templates': instance.attribute_templates
            }
        
        # If it's already a dictionary, use the default behavior
        return super().to_representation(instance)
