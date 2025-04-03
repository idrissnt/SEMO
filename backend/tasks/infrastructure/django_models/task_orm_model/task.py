"""
ORM model for tasks.
"""
from django.db import models
import uuid
from django.contrib.gis.db import models as gis_models


from django.conf import settings
from the_user_app.infrastructure.django_models.orm_models import AddressModel
from tasks.infrastructure.django_models.task.category_template import TaskCategoryTemplateModel


class TaskModel(models.Model):
    """Django ORM model for tasks"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    requester = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='requested_tasks')
    title = models.CharField(max_length=100)
    description = models.TextField()
    image_url = models.ImageField(default='tasks/default.png', )
    category = models.CharField(max_length=50)
    category_template = models.ForeignKey(TaskCategoryTemplateModel, on_delete=models.PROTECT, related_name='tasks')
    location_address = models.ForeignKey(AddressModel, on_delete=models.CASCADE)
    location_point = gis_models.PointField(geography=True, null=True)
    budget = models.DecimalField(max_digits=10, decimal_places=2)
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
