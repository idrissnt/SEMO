"""
Django ORM models for analytics data.
"""
import uuid
from django.db import models


class SearchQueryLog(models.Model):
    """Model for logging search queries"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    query = models.CharField(max_length=255)
    store_id = models.UUIDField(null=True, blank=True)
    user_id = models.UUIDField(null=True, blank=True)
    result_count = models.IntegerField(default=0)
    timestamp = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        indexes = [
            models.Index(fields=['query']),
            models.Index(fields=['store_id']),
            models.Index(fields=['timestamp']),
            models.Index(fields=['result_count']),
        ]
