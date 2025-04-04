"""
Serializer for task attributes.
"""
from rest_framework import serializers


class TaskAttributeSerializer(serializers.Serializer):
    """Serializer for task attributes
    
    This serializer can handle both TaskAttribute domain entities and dictionaries.
    """
    name = serializers.CharField(max_length=100)
    question = serializers.CharField()
    answer = serializers.CharField(required=False, allow_null=True)
    
    def to_representation(self, instance):
        """Convert TaskAttribute domain entity to dictionary representation"""
        # If instance is a TaskAttribute domain entity, convert it to a dictionary
        if hasattr(instance, '__dataclass_fields__'):  # Check if it's a dataclass
            return {
                'name': instance.name,
                'question': instance.question,
                'answer': instance.answer
            }
        
        # If it's already a dictionary, use the default behavior
        return super().to_representation(instance)
