"""
Django model for TaskCategory.
"""
import uuid
from django.db import models


class TaskCategoryModel(models.Model):
    """Django model for TaskCategory"""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    type = models.CharField(max_length=50)
    name = models.CharField(max_length=100)
    display_name = models.CharField(max_length=100)
    description = models.TextField()
    image_url = models.URLField()
    icon_name = models.CharField(max_length=50)
    color_hex = models.CharField(max_length=7)  # Format: #RRGGBB
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'task_categories'
        verbose_name = 'Task Category'
        verbose_name_plural = 'Task Categories'
    
    def __str__(self):
        return self.display_name
