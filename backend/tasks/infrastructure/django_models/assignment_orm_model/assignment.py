"""
ORM model for task assignments.
"""
from django.db import models
import uuid

from the_user_app.infrastructure.django_models.orm_models import TaskPerformerProfileModel
from django_models import TaskModel


class TaskAssignmentModel(models.Model):
    """Django ORM model for task assignments"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    task = models.OneToOneField(TaskModel, on_delete=models.CASCADE, related_name='assignment')
    performer = models.ForeignKey(TaskPerformerProfileModel, on_delete=models.CASCADE, related_name='task_assignments')
    assigned_at = models.DateTimeField(auto_now_add=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'task_assignments'
        verbose_name = 'Task Assignment'
        verbose_name_plural = 'Task Assignments'
        indexes = [
            models.Index(fields=['task']),
            models.Index(fields=['performer']),
        ]
    
    def __str__(self):
        return f"Assignment of {self.task.title} to {self.performer.user_name}"
