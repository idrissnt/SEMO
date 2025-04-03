"""
ORM model for task category templates.
"""
from django.db import models
from django.contrib.postgres.fields import JSONField
import uuid


class TaskCategoryTemplateModel(models.Model):
    """Django ORM model for task category templates"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    category = models.CharField(max_length=50)
    name = models.CharField(max_length=100)
    image_url = models.ImageField(default='tasks/default.png', )
    description = models.TextField()
    title_template = models.TextField()  # Template for task title
    description_template = models.TextField()  # Template for task description
    attribute_templates = JSONField()  # List of {name, question} dictionaries
    
    class Meta:
        db_table = 'task_category_templates'
        verbose_name = 'Task Category Template'
        verbose_name_plural = 'Task Category Templates'
    
    def __str__(self):
        return f"{self.name} ({self.category})"
