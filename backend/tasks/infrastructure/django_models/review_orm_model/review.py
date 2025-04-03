"""
ORM model for reviews.
"""
from django.db import models
import uuid

from the_user_app.infrastructure.django_models.orm_models import CustomUserModel
from tasks.infrastructure.django_models.task_orm_model.task import TaskModel


class ReviewModel(models.Model):
    """Django ORM model for reviews"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    task = models.ForeignKey(TaskModel, on_delete=models.CASCADE, related_name='reviews')
    reviewer = models.ForeignKey(CustomUserModel, on_delete=models.CASCADE, related_name='reviews_given')
    reviewee = models.ForeignKey(CustomUserModel, on_delete=models.CASCADE, related_name='reviews_received')
    rating = models.IntegerField()  # 1-5 stars
    comment = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'reviews'
        verbose_name = 'Review'
        verbose_name_plural = 'Reviews'
        indexes = [
            models.Index(fields=['task']),
            models.Index(fields=['reviewer']),
            models.Index(fields=['reviewee']),
        ]
        unique_together = ('task', 'reviewer', 'reviewee')
    
    def __str__(self):
        return f"Review for {self.reviewee.email} by {self.reviewer.email}"
