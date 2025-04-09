"""
Serializers for message-related API endpoints.

This module contains serializers for converting message domain entities to/from
API representations.
"""
from rest_framework import serializers

from ....domain.models import Message


class MessageSerializer(serializers.Serializer):
    """
    Serializer for Message entities.
    
    This serializer converts Message domain entities to/from API representations.
    It handles both serialization (domain entity to API representation) and
    deserialization (API representation to domain entity).
    """
    id = serializers.UUIDField(read_only=True)
    conversation_id = serializers.UUIDField()
    sender_id = serializers.UUIDField(read_only=True)
    content = serializers.CharField()
    content_type = serializers.CharField(default="text")
    sent_at = serializers.DateTimeField(read_only=True)
    delivered_at = serializers.DateTimeField(read_only=True, allow_null=True)
    read_at = serializers.DateTimeField(read_only=True, allow_null=True)
    metadata = serializers.JSONField(default=dict, required=False)
    
    def to_representation(self, instance):
        """
        Convert a domain entity to a dictionary.
        
        This method is called when serializing a Message domain entity to an
        API representation. It handles both Message objects and dictionaries.
        
        Args:
            instance: Message domain entity or dictionary
            
        Returns:
            Dictionary representation of the message
        """
        # If the instance is already a dict, use it directly
        if isinstance(instance, dict):
            return instance
        # If the instance is a Pydantic model, use its model_dump method
        if hasattr(instance, 'model_dump'):
            # Start with the base model data
            result = instance.model_dump()

            # Convert UUIDs to strings for JSON serialization
            result['id'] = str(result['id'])
            result['conversation_id'] = str(result['conversation_id'])
            result['sender_id'] = str(result['sender_id'])

            # Format datetime objects
            if result['sent_at']:
                result['sent_at'] = result['sent_at'].isoformat()
            if result['delivered_at']:
                result['delivered_at'] = result['delivered_at'].isoformat()
            if result['read_at']:
                result['read_at'] = result['read_at'].isoformat()

            # Ensure metadata is not None
            result['metadata'] = result['metadata'] or {}
            return result
        # Fallback to standard serialization
        return super().to_representation(instance)
    
    def create(self, validated_data):
        """
        Create a new Message domain entity.
        
        This method is called when deserializing an API representation to a
        Message domain entity during creation.
        
        Args:
            validated_data: Validated data from the serializer
            
        Returns:
            Message domain entity
        """
        # Create a new Message entity
        return Message.create(
            conversation_id=validated_data['conversation_id'],
            sender_id=validated_data.get('sender_id'),  # Will be set by the view
            content=validated_data['content'],
            content_type=validated_data.get('content_type', 'text'),
            metadata=validated_data.get('metadata', {})
        )
    
    def update(self, instance, validated_data):
        """
        Update an existing Message domain entity.
        
        This method is called when deserializing an API representation to a
        Message domain entity during update.
        
        Args:
            instance: Existing Message domain entity
            validated_data: Validated data from the serializer
            
        Returns:
            Updated Message domain entity
        """
        # For Pydantic models, we need to create a new instance with updated values
        # since Pydantic models are immutable
        update_data = {
            'content': validated_data.get('content', instance.content),
            'content_type': validated_data.get('content_type', instance.content_type),
            'metadata': validated_data.get('metadata', instance.metadata)
        }
        
        # Create a new instance with updated values
        return instance.model_copy(update=update_data)


class MessageCreateSerializer(serializers.Serializer):
    """
    Serializer for creating messages.
    
    This serializer is used for validating message creation requests.
    It includes only the fields that can be set by the client.
    """
    conversation_id = serializers.UUIDField()
    content = serializers.CharField()
    content_type = serializers.CharField(default="text")
    metadata = serializers.JSONField(default=dict, required=False)


class MessageReadReceiptSerializer(serializers.Serializer):
    """
    Serializer for message read receipts.
    
    This serializer is used for validating read receipt requests.
    """
    message_ids = serializers.ListField(
        child=serializers.UUIDField(),
        min_length=1
    )
