"""
ORM model for negotiation offers.
"""
from django.db import models
import uuid

from tasks.infrastructure.django_models.task_orm_models import TaskApplicationModel

class NegotiationOfferModel(models.Model):
    """Django ORM model for negotiation offers"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    application = models.ForeignKey(TaskApplicationModel, on_delete=models.CASCADE, related_name='offers')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    message = models.TextField()
    created_by = models.CharField(max_length=20)  # 'requester' or 'performer'
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'negotiation_offers'
        verbose_name = 'Negotiation Offer'
        verbose_name_plural = 'Negotiation Offers'
        ordering = ['created_at']
    
    def __str__(self):
        return f"Offer of ${self.amount} by {self.created_by} at {self.created_at}"
