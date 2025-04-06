"""
Serializers for conversation-related API endpoints.

This module contains serializers for converting conversation domain entities to/from
API representations.
"""
from rest_framework import serializers
import uuid

from ....domain.models import Conversation


class ConversationSerializer(serializers.Serializer):
    """
    Serializer for Conversation entities.
    
    This serializer converts Conversation domain entities to/from API representations.
    It handles both serialization (domain entity to API representation) and
    deserialization (API representation to domain entity).
    """
    id = serializers.UUIDField(read_only=True)
    type = serializers.CharField()
    participants = serializers.ListField(child=serializers.UUIDField())
    created_at = serializers.DateTimeField(read_only=True)
    last_message_at = serializers.DateTimeField(read_only=True, allow_null=True)
    title = serializers.CharField(allow_null=True, required=False)
    metadata = serializers.JSONField(default=dict, required=False)
    
    # Additional fields for the API that aren't in the domain entity
    unread_count = serializers.IntegerField(read_only=True, required=False)
    last_message = serializers.DictField(read_only=True, required=False)
    
    def to_representation(self, instance):
        """
        Convert a domain entity to a dictionary.
        
        This method is called when serializing a Conversation domain entity to an
        API representation. It handles both Conversation objects and dictionaries.
        
        Args:
            instance: Conversation domain entity or dictionary
            
        Returns:
            Dictionary representation of the conversation
        """
        # If the instance is already a dict, use it directly
        if isinstance(instance, dict):
            return instance
        
        # Otherwise, convert the domain entity to a dict
        result = {
            'id': str(instance.id),
            'type': instance.type,
            'participants': [str(p) for p in instance.participants],
            'created_at': instance.created_at.isoformat() if instance.created_at else None,
            'last_message_at': instance.last_message_at.isoformat() if instance.last_message_at else None,
            'title': instance.title,
            'metadata': instance.metadata
        }
        
        # Add additional fields if they exist in the context
        if hasattr(instance, 'unread_count'):
            result['unread_count'] = instance.unread_count
        
        if hasattr(instance, 'last_message'):
            result['last_message'] = instance.last_message
        
        return result
    
    def create(self, validated_data):
        """
        Create a new Conversation domain entity.
        
        This method is called when deserializing an API representation to a
        Conversation domain entity during creation.
        
        Args:
            validated_data: Validated data from the serializer
            
        Returns:
            Conversation domain entity
        """
        # Create a new Conversation entity
        return Conversation.create(
            participants=validated_data['participants'],
            type=validated_data.get('type', 'direct'),
            title=validated_data.get('title'),
            metadata=validated_data.get('metadata', {})
        )
    
    def update(self, instance, validated_data):
        """
        Update an existing Conversation domain entity.
        
        This method is called when deserializing an API representation to a
        Conversation domain entity during update.
        
        Args:
            instance: Existing Conversation domain entity
            validated_data: Validated data from the serializer
            
        Returns:
            Updated Conversation domain entity
        """
        # Update the Conversation entity
        instance.title = validated_data.get('title', instance.title)
        instance.metadata = validated_data.get('metadata', instance.metadata)
        
        # Handle participants update (more complex)
        if 'participants' in validated_data and instance.type != 'direct':
            # For direct conversations, participants can't be changed
            # For group conversations, we need to add/remove participants
            new_participants = validated_data['participants']
            
            # Add new participants
            for participant_id in new_participants:
                if participant_id not in instance.participants:
                    instance.add_participant(participant_id)
            
            # Remove participants who are no longer in the list
            for participant_id in list(instance.participants):
                if participant_id not in new_participants:
                    instance.remove_participant(participant_id)
        
        return instance


class ConversationCreateSerializer(serializers.Serializer):
    """
    Serializer for creating conversations.
    
    This serializer is used for validating conversation creation requests.
    It includes only the fields that can be set by the client.
    """
    type = serializers.CharField(default="direct")
    participants = serializers.ListField(
        child=serializers.UUIDField(),
        min_length=1
    )
    title = serializers.CharField(allow_null=True, required=False)
    metadata = serializers.JSONField(default=dict, required=False)
    
    def validate(self, data):
        """
        Validate the conversation creation data.
        
        This method performs additional validation beyond field-level validation.
        It ensures that direct conversations have exactly 2 participants.
        
        Args:
            data: Validated data from the serializer
            
        Returns:
            Validated data
            
        Raises:
            ValidationError: If the data is invalid
        """
        # Validate that direct conversations have exactly 2 participants
        if data.get('type') == 'direct' and len(data.get('participants', [])) != 2:
            raise serializers.ValidationError(
                "Direct conversations must have exactly 2 participants"
            )
        
        return data


class TaskConversationCreateSerializer(serializers.Serializer):
    """
    Serializer for creating task-related conversations.
    
    This serializer is used for validating task conversation creation requests.
    """
    task_id = serializers.UUIDField()
    requester_id = serializers.UUIDField()
    performer_id = serializers.UUIDField()
    task_title = serializers.CharField(required=False)
