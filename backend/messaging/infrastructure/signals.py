"""
Signal handlers for the messaging system.

This module contains Django signal handlers for various events in the messaging system.
"""
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

from .django_models.message_model import MessageModel
from .django_models.conversation_model import ConversationModel
from ..domain.models.entities.message import Message
from ..domain.models.entities.conversation import Conversation


@receiver(post_save, sender=MessageModel)
def message_saved(sender, instance, created, **kwargs):
    """
    Handle message save events.
    
    This signal handler is triggered when a message is saved to the database.
    It broadcasts the message to all participants in the conversation via WebSockets.
    
    Args:
        sender: The model class that sent the signal
        instance: The actual instance being saved
        created: A boolean indicating if this is a new instance
        **kwargs: Additional keyword arguments
    """
    # Convert the message model to a domain entity
    message = Message(
        id=instance.id,
        conversation_id=instance.conversation_id,
        sender_id=instance.sender_id,
        content=instance.content,
        content_type=instance.content_type,
        sent_at=instance.sent_at,
        delivered_at=instance.delivered_at,
        read_by=instance.read_by,
        metadata=instance.metadata or {}
    )
    
    # Get the channel layer
    channel_layer = get_channel_layer()
    
    # Prepare the message data for WebSocket broadcast
    message_data = {
        'type': 'chat.message',
        'message': {
            'id': str(message.id),
            'conversation_id': str(message.conversation_id),
            'sender_id': str(message.sender_id),
            'content': message.content,
            'content_type': message.content_type,
            'sent_at': message.sent_at.isoformat() if message.sent_at else None,
            'delivered_at': message.delivered_at.isoformat() if message.delivered_at else None,
            'read_by': [str(user_id) for user_id in message.read_by],
            'metadata': message.metadata
        },
        'event': 'message.created' if created else 'message.updated'
    }
    
    # Broadcast the message to the conversation group
    group_name = f'conversation_{message.conversation_id}'
    async_to_sync(channel_layer.group_send)(
        group_name,
        message_data
    )


@receiver(post_delete, sender=MessageModel)
def message_deleted(sender, instance, **kwargs):
    """
    Handle message delete events.
    
    This signal handler is triggered when a message is deleted from the database.
    It broadcasts the deletion to all participants in the conversation via WebSockets.
    
    Args:
        sender: The model class that sent the signal
        instance: The actual instance being deleted
        **kwargs: Additional keyword arguments
    """
    # Get the channel layer
    channel_layer = get_channel_layer()
    
    # Prepare the message data for WebSocket broadcast
    message_data = {
        'type': 'chat.message',
        'message': {
            'id': str(instance.id),
            'conversation_id': str(instance.conversation_id)
        },
        'event': 'message.deleted'
    }
    
    # Broadcast the message to the conversation group
    group_name = f'conversation_{instance.conversation_id}'
    async_to_sync(channel_layer.group_send)(
        group_name,
        message_data
    )


@receiver(post_save, sender=ConversationModel)
def conversation_saved(sender, instance, created, **kwargs):
    """
    Handle conversation save events.
    
    This signal handler is triggered when a conversation is saved to the database.
    It broadcasts the conversation update to all participants via WebSockets.
    
    Args:
        sender: The model class that sent the signal
        instance: The actual instance being saved
        created: A boolean indicating if this is a new instance
        **kwargs: Additional keyword arguments
    """
    # Convert the conversation model to a domain entity
    conversation = Conversation(
        id=instance.id,
        participants=[participant.id for participant in instance.participants.all()],
        type=instance.type,
        title=instance.title,
        created_at=instance.created_at,
        updated_at=instance.updated_at,
        last_message_at=instance.last_message_at,
        metadata=instance.metadata or {}
    )
    
    # Get the channel layer
    channel_layer = get_channel_layer()
    
    # Prepare the conversation data for WebSocket broadcast
    conversation_data = {
        'type': 'chat.conversation',
        'conversation': {
            'id': str(conversation.id),
            'participants': [str(participant_id) for participant_id in conversation.participants],
            'type': conversation.type,
            'title': conversation.title,
            'created_at': conversation.created_at.isoformat() if conversation.created_at else None,
            'updated_at': conversation.updated_at.isoformat() if conversation.updated_at else None,
            'last_message_at': conversation.last_message_at.isoformat() if conversation.last_message_at else None,
            'metadata': conversation.metadata
        },
        'event': 'conversation.created' if created else 'conversation.updated'
    }
    
    # Broadcast the conversation update to all participants
    for participant_id in conversation.participants:
        # Each user has their own user-specific group
        group_name = f'user_{participant_id}'
        async_to_sync(channel_layer.group_send)(
            group_name,
            conversation_data
        )


@receiver(post_delete, sender=ConversationModel)
def conversation_deleted(sender, instance, **kwargs):
    """
    Handle conversation delete events.
    
    This signal handler is triggered when a conversation is deleted from the database.
    It broadcasts the deletion to all participants via WebSockets.
    
    Args:
        sender: The model class that sent the signal
        instance: The actual instance being deleted
        **kwargs: Additional keyword arguments
    """
    # Get the participant IDs before the instance is fully deleted
    participant_ids = [participant.id for participant in instance.participants.all()]
    
    # Get the channel layer
    channel_layer = get_channel_layer()
    
    # Prepare the conversation data for WebSocket broadcast
    conversation_data = {
        'type': 'chat.conversation',
        'conversation': {
            'id': str(instance.id)
        },
        'event': 'conversation.deleted'
    }
    
    # Broadcast the conversation deletion to all participants
    for participant_id in participant_ids:
        # Each user has their own user-specific group
        group_name = f'user_{participant_id}'
        async_to_sync(channel_layer.group_send)(
            group_name,
            conversation_data
        )
