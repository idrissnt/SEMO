"""
Admin interface for the messaging system.

This module defines the Django admin interface for the messaging system,
allowing administrators to manage conversations, messages, and attachments.
"""
from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse

from .infrastructure.django_models.message_model import MessageModel
from .infrastructure.django_models.conversation_model import ConversationModel
from .infrastructure.django_models.attachment_model import AttachmentModel


@admin.register(ConversationModel)
class ConversationAdmin(admin.ModelAdmin):
    """Admin interface for conversations."""
    list_display = ('id', 'title', 'type', 'last_message_at', 'participant_count')
    list_filter = ('type', 'last_message_at')
    search_fields = ('title', 'participants__username')
    readonly_fields = ('id', 'last_message_at')
    date_hierarchy = 'created_at'
    
    def participant_count(self, obj):
        """Return the number of participants in the conversation."""
        return obj.participants.count()
    participant_count.short_description = 'Participants'
    
    def get_queryset(self, request):
        """Optimize the queryset by prefetching related objects."""
        return super().get_queryset(request).prefetch_related('participants')


@admin.register(MessageModel)
class MessageAdmin(admin.ModelAdmin):
    """Admin interface for messages."""
    list_display = ('id', 'conversation', 'sender', 'content_type', 'content_preview')
    list_filter = ('content_type', 'sender')
    search_fields = ('id', 'content_type', 'sender__username', 'conversation__id')
    readonly_fields = ('id', 'sent_at', 'delivered_at')
    date_hierarchy = 'sent_at'
    
    def content_preview(self, obj):
        """Return a preview of the message content."""
        if obj.content_type == 'text':
            return obj.content[:50] + ('...' if len(obj.content) > 50 else '')
        return f'[{obj.content_type}]'
    content_preview.short_description = 'Content'
    
    def get_queryset(self, request):
        """Optimize the queryset by selecting related objects."""
        return super().get_queryset(request).select_related('sender', 'conversation')

