"""
ORM model for tasks.

This module defines the database model for storing tasks, which can be created
either based on a predefined task type or as custom tasks.
"""
from django.db import models
import uuid
from django.contrib.gis.db import models as gis_models


from django.conf import settings
from .task_category_model import TaskCategoryModel

class TaskModel(models.Model):
    """Django ORM model for tasks
    
    Tasks can be created in two ways:
    1. Based on a predefined task type - Using defaults and questions from the predefined type
    2. As a custom task - With all details provided by the user
    
    When created from a predefined task type, the default values are copied from the template,
    but the task doesn't maintain a relationship with the template after creation.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    requester = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='requested_tasks')
    title = models.CharField(max_length=100)
    description = models.TextField()
    image_url = models.ImageField(default='tasks/default.png', )
    category = models.ForeignKey(TaskCategoryModel, on_delete=models.PROTECT, related_name='tasks')
    location_address = models.JSONField()
    location_point = gis_models.PointField(geography=True, null=True)
    budget = models.DecimalField(max_digits=10, decimal_places=2)
    estimated_duration = models.IntegerField()
    scheduled_date = models.DateTimeField()
    status = models.CharField(max_length=20, default='draft')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'tasks'
        verbose_name = 'Task'
        verbose_name_plural = 'Tasks'
        indexes = [
            models.Index(fields=['requester']),
            models.Index(fields=['category']),
            models.Index(fields=['status']),
            models.Index(fields=['scheduled_date']),
        ]
    
    def __str__(self):
        return f"{self.title} ({self.status})"
