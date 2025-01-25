from django.db import models

# Create your models here.

class Store(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    address = models.CharField(max_length=255, blank=True, null=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    image_url = models.ImageField(
        upload_to='images/stores/',
        default='images/stores/carrefour.png'
    )
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
    is_popular = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-rating', 'name']
        indexes = [
            models.Index(fields=['rating']),
            models.Index(fields=['is_popular']),
        ]

    def __str__(self):
        return self.name
