"""
WebSocket serializers for the messaging system.

This module contains serializers for converting domain models to JSON
for WebSocket communication.
"""
from rest_framework import serializers

from ....domain.models import Message, Conversation, Participant


class MessageSerializer(serializers.Serializer):
    """
    Serializer for Message entities in WebSocket communication.
    """
    id = serializers.UUIDField()
    conversation_id = serializers.UUIDField()
    sender_id = serializers.UUIDField()
    content = serializers.CharField()
    content_type = serializers.CharField()
    sent_at = serializers.DateTimeField()
    delivered_at = serializers.DateTimeField(allow_null=True)
    read_at = serializers.DateTimeField(allow_null=True)
    metadata = serializers.JSONField(default=dict)


class ConversationSerializer(serializers.Serializer):
    """
    Serializer for Conversation entities in WebSocket communication.
    """
    id = serializers.UUIDField()
    name = serializers.CharField(allow_null=True)
    type = serializers.CharField()
    created_at = serializers.DateTimeField(allow_null=True)
    updated_at = serializers.DateTimeField(allow_null=True)
    participants = serializers.ListField(child=serializers.UUIDField())
    metadata = serializers.JSONField(default=dict)


class ParticipantSerializer(serializers.Serializer):
    """
    Serializer for Participant entities in WebSocket communication.
    """
    user_id = serializers.UUIDField()
    conversation_id = serializers.UUIDField()
    joined_at = serializers.DateTimeField(allow_null=True)
    last_read_at = serializers.DateTimeField(allow_null=True)
    is_admin = serializers.BooleanField(default=False)
