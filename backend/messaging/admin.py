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
    list_display = ('id', 'title', 'type', 'created_at', 'last_message_at', 'participant_count')
    list_filter = ('type', 'created_at', 'last_message_at')
    search_fields = ('id', 'title')
    readonly_fields = ('id', 'created_at', 'updated_at', 'last_message_at')
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
    list_display = ('id', 'conversation_link', 'sender', 'content_preview', 'content_type', 'sent_at', 'delivered_at')
    list_filter = ('content_type', 'sent_at', 'delivered_at')
    search_fields = ('id', 'content', 'sender__username', 'conversation__id')
    readonly_fields = ('id', 'sent_at', 'delivered_at')
    date_hierarchy = 'sent_at'
    
    def content_preview(self, obj):
        """Return a preview of the message content."""
        if obj.content_type == 'text':
            return obj.content[:50] + ('...' if len(obj.content) > 50 else '')
        return f'[{obj.content_type}]'
    content_preview.short_description = 'Content'
    
    def conversation_link(self, obj):
        """Return a link to the conversation admin page."""
        url = reverse('admin:messaging_conversationmodel_change', args=[obj.conversation_id])
        return format_html('<a href="{}">{}</a>', url, obj.conversation_id)
    conversation_link.short_description = 'Conversation'
    
    def get_queryset(self, request):
        """Optimize the queryset by selecting related objects."""
        return super().get_queryset(request).select_related('sender', 'conversation')


@admin.register(AttachmentModel)
class AttachmentAdmin(admin.ModelAdmin):
    """Admin interface for file attachments."""
    list_display = ('id', 'filename', 'content_type', 'file_size', 'uploaded_by', 'uploaded_at')
    list_filter = ('content_type', 'uploaded_at')
    search_fields = ('id', 'filename', 'uploaded_by__username')
    readonly_fields = ('id', 'file_size', 'uploaded_at')
    date_hierarchy = 'uploaded_at'
    
    def file_size(self, obj):
        """Return the file size in a human-readable format."""
        size_bytes = obj.file.size if obj.file else 0
        
        # Convert to appropriate unit
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size_bytes < 1024 or unit == 'GB':
                break
            size_bytes /= 1024
        
        return f"{size_bytes:.2f} {unit}"
    file_size.short_description = 'File Size'
    
    def get_queryset(self, request):
        """Optimize the queryset by selecting related objects."""
        return super().get_queryset(request).select_related('uploaded_by')
