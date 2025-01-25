from django.db import models
from store.models import Store

# Create your models here.

class Product(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    image_url = models.ImageField(
        upload_to='products/images/',
        default='images/products/potatos.png'
    )
    store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name='products')
    is_seasonal = models.BooleanField(default=False)
    is_popular = models.BooleanField(default=False)
    category = models.CharField(max_length=100)
    stock = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-is_popular', 'name']
        indexes = [
            models.Index(fields=['is_seasonal']),
            models.Index(fields=['is_popular']),
            models.Index(fields=['category']),
        ]

    def __str__(self):
        return f"{self.name} - {self.store.name}"
