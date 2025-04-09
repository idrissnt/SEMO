"""
ORM model for task applications.
"""
from django.db import models
import uuid

from the_user_app.infrastructure.django_models.orm_models import TaskPerformerProfileModel
from ..task_orm_model.task import TaskModel
from ....domain.models.value_objects.application_status import ApplicationStatus


class TaskApplicationModel(models.Model):
    """Django ORM model for task applications"""
    STATUS_CHOICES = ApplicationStatus.choices()
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    task = models.ForeignKey(TaskModel, on_delete=models.CASCADE, related_name='applications')
    performer = models.ForeignKey(TaskPerformerProfileModel, on_delete=models.CASCADE, related_name='task_applications')
    initial_message = models.TextField()
    initial_offer = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=ApplicationStatus.PENDING.value)
    chat_enabled = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'task_applications'
        verbose_name = 'Task Application'
        verbose_name_plural = 'Task Applications'
        indexes = [
            models.Index(fields=['task']),
            models.Index(fields=['performer']),
        ]
        unique_together = ('task', 'performer')
    
    def __str__(self):
        return f"Application for {self.task.title} by {self.performer.user_name}"
