"""
ORM model for predefined task types.

This module defines the database model for storing predefined task types,
which serve as templates for common tasks that users can create.
"""
from django.db import models
from django.db import models
import uuid
from .task_category_model import TaskCategoryModel

class PredefinedTaskTypeModel(models.Model):
    """Django ORM model for predefined task types
    
    This model stores predefined task types that serve as templates for common tasks,
    providing default values, formats, and relevant questions for specific categories of tasks.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title_template = models.TextField()  # Template for task title
    description_template = models.TextField()  # Template for task description
    image_url = models.ImageField(default='tasks/default.png', )
    category = models.ForeignKey(TaskCategoryModel, on_delete=models.PROTECT, related_name='predefined_task_types')
    location_address = models.CharField(max_length=255)
    estimated_budget_range = models.JSONField()  # Tuple of (min, max) budget range
    estimated_duration_range = models.JSONField()  # Tuple of (min, max) duration range
    scheduled_date = models.DateTimeField()
    attribute_templates = models.JSONField()  # List of {name, question} dictionaries
    
    class Meta:
        db_table = 'predefined_task_types'
        verbose_name = 'Predefined Task Type'
        verbose_name_plural = 'Predefined Task Types'
    
    def __str__(self):
        return f"{self.title_template} ({self.category})"
