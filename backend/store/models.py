from django.db import models
from django.utils.text import slugify
from django_ltree.fields import PathField
from django.contrib.postgres.indexes import GistIndex
from imagekit.models import ProcessedImageField, ImageSpecField
from imagekit.processors import ResizeToFill
import uuid

class Store(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    slug = models.SlugField(unique=True) # Auto-generated from store name, for SEO-friendly URLs
    address = models.CharField(max_length=255)
    city = models.CharField(max_length=100)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    image_logo = models.ImageField(default='stores/default.png')
    image_banner = models.ImageField(default='stores/default.png')

    working_hours = models.JSONField(
        default=dict,
        help_text="Store working hours in format: {'monday': {'open': '09:00', 'close': '21:00'}}",
        null=True,
        blank=True
    )
    class Meta:
        db_table = 'stores'

    def get_popular_products(self, limit=10):
        """Get most popular products in the store"""

    # def is_currently_open(self):
    #     """Check if store is open based on working hours"""
    #     if not self.is_open:
    #         return False
            
    #     current_time = timezone.localtime()
    #     day_name = current_time.strftime('%A').lower() # convert to day of the week and in lowercase (e.g., 'monday')
        
    #     if day_name not in self.working_hours:
    #         return False
            
    #     hours = self.working_hours[day_name]
    #     open_time = timezone.datetime.strptime(hours['open'], '%H:%M').time()
    #     close_time = timezone.datetime.strptime(hours['close'], '%H:%M').time()
        
    #     return open_time <= current_time.time() <= close_time

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

class Category(models.Model):  # Hierarchical categories
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255, unique=True)
    store = models.ForeignKey(Store, on_delete=models.CASCADE)
    path = PathField()  # Hierarchical path (e.g., "Store1.Food.Fruits")
    slug = models.SlugField(unique=True)
    
    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    class Meta:
        indexes = [
            GistIndex(fields=['path'], name='category_path_gist'),  # Speeds up hierarchical queries
        ]
        unique_together = ('store', 'path')  # Path must be unique per store
        db_table = 'categories'

    def __str__(self):
        return f"{self.store.name} - {self.name}"

class Product(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    slug = models.SlugField(unique=True)
    quantity = models.IntegerField()
    unit = models.CharField(max_length=10)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)
    description = models.TextField()
    image_url = ProcessedImageField(
        processors=[ResizeToFill(800, 600)],  # Full-size image
        format='JPEG',
        options={'quality': 80},
        default='stores/default.png'
    )
    
    image_thumbnail = ImageSpecField(
        source='image_url',  # Generate thumbnail from main image
        processors=[ResizeToFill(200, 150)],  # Resize to 200x150
        format='JPEG',
        options={'quality': 60}
    )

    class Meta:
        db_table = 'products'

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

class StoreProduct(models.Model):
    # StoreProduct (Many-to-Many Relationship with Extra Fields)
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    store = models.ForeignKey(Store, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)  # Category within the store's hierarchy
    price = models.DecimalField(max_digits=10, decimal_places=2)
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        unique_together = ['store', 'category', 'product']  # A product and category can exist once per store
        db_table = 'store_products'

    def __str__(self):
        return f'{self.product.name} at {self.store.name} - ${self.price}' 