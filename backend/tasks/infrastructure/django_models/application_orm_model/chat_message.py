"""
ORM model for chat messages.
"""
from django.db import models
import uuid

from the_user_app.infrastructure.django_models.orm_models import CustomUserModel
from .application import TaskApplicationModel


class ChatMessageModel(models.Model):
    """Django ORM model for chat messages"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    task_application = models.ForeignKey(TaskApplicationModel, on_delete=models.CASCADE, related_name='chat_messages')
    sender = models.ForeignKey(CustomUserModel, on_delete=models.CASCADE, related_name='task_chat_messages')
    content = models.TextField()
    read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'chat_messages'
        verbose_name = 'Chat Message'
        verbose_name_plural = 'Chat Messages'
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['task_application']),
            models.Index(fields=['sender']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f"Message from {self.sender.email} at {self.created_at}"
