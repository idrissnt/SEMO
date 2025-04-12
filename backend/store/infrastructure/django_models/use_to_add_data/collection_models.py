from django.db import models
import uuid
from django.contrib.auth import get_user_model
from store.infrastructure.django_models.orm_models import StoreBrandModel

User = get_user_model()

class ProductCollectionBatchModel(models.Model):
    """Django ORM model for ProductCollectionBatch"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    store_brand = models.ForeignKey(StoreBrandModel, on_delete=models.CASCADE)
    collector = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=255)
    status = models.CharField(
        max_length=20,
        choices=[
            ('draft', 'Draft'),
            ('in_progress', 'In Progress'),
            ('completed', 'Completed'),
            ('processed', 'Processed')
        ],
        default='draft'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'product_collection_batches'
        indexes = [
            models.Index(fields=['collector', 'status']),
            models.Index(fields=['store_brand', 'status']),
        ]
    
    def __str__(self):
        return f"{self.name} - {self.status}"

class CollectedProductModel(models.Model):
    """Django ORM model for CollectedProduct"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    batch = models.ForeignKey(ProductCollectionBatchModel, on_delete=models.CASCADE, related_name='products')
    name = models.CharField(max_length=255)
    slug = models.CharField(max_length=255)
    quantity = models.IntegerField()
    unit = models.CharField(max_length=10)
    description = models.TextField(blank=True)
    category_name = models.CharField(max_length=255)
    category_path = models.CharField(max_length=255)
    category_slug = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)
    image_url = models.TextField()  # Base64 encoded image or URL
    notes = models.TextField(blank=True, null=True)
    status = models.CharField(
        max_length=20,
        choices=[
            ('pending', 'Pending'),
            ('processed', 'Processed'),
            ('error', 'Error')
        ],
        default='pending'
    )
    error_message = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'collected_products'
        indexes = [
            models.Index(fields=['batch']),
            models.Index(fields=['status']),
            models.Index(fields=['slug']),
            models.Index(fields=['name']),
        ]
    
    def __str__(self):
        return f"{self.name} ({self.quantity} {self.unit})"
