"""
ORM model for task attributes.
"""
from django.db import models
import uuid

from task import TaskModel


class TaskAttributeModel(models.Model):
    """Django ORM model for task attributes (questions and answers)"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    task = models.ForeignKey(TaskModel, on_delete=models.CASCADE, related_name='attributes')
    name = models.CharField(max_length=100)
    question = models.TextField()
    answer = models.TextField(null=True, blank=True)
    
    class Meta:
        db_table = 'task_attributes'
        verbose_name = 'Task Attribute'
        verbose_name_plural = 'Task Attributes'
    
    def __str__(self):
        return f"{self.name} for task {self.task.title}"
