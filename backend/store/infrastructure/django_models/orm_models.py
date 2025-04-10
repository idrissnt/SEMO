from django.db import models
from django_ltree.fields import PathField
from django.contrib.postgres.indexes import GinIndex, GistIndex
from django.contrib.postgres.search import SearchVectorField
from imagekit.models import ProcessedImageField, ImageSpecField
from imagekit.processors import ResizeToFill
import uuid


# note : Add FTS Index to PostgreSQL database when migrating 

class StoreBrandModel(models.Model):
    """Django ORM model for StoreBrand"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    type = models.CharField(max_length=255)
    slug = models.SlugField(unique=True)
    image_logo = models.ImageField(default='stores/default.png', )
    image_banner = models.ImageField(default='stores/default.png', )
    
    class Meta:
        db_table = 'store_brands'
    
    def __str__(self):
        return self.name

class CategoryModel(models.Model):
    """Django ORM model for Category"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255, unique=True)
    store_brand = models.ManyToManyField(StoreBrandModel)
    path = PathField()  # Hierarchical path (e.g., "Store1.Food.Fruits")
    slug = models.SlugField(unique=True)
    
    # Field to store pre-computed search vectors    
    class Meta:
        indexes = [
            GistIndex(fields=['path'], name='category_path_gist'),  # Speeds up hierarchical queries
            GinIndex(fields=['name'], name='category_name_trigram_idx', opclasses=['gin_trgm_ops'])  # For trigram similarity
        ]
        # unique_together = ('store_brand', 'path')  # Path must be unique per store
        db_table = 'categories'
        
    def __str__(self):
        return f"{self.store_brand.name} - {self.name}"

class ProductModel(models.Model):
    """Django ORM model for Product"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    slug = models.SlugField(unique=True)
    quantity = models.IntegerField()
    unit = models.CharField(max_length=10)
    description = models.TextField()
    
    image_url = ProcessedImageField(
        processors=[ResizeToFill(800, 600)],  # Full-size image
        format='JPEG',
        options={'quality': 80},
        default='stores/default.png'
    )
    image_thumbnail = ImageSpecField(
        source='image_url',  # Generate thumbnail from main image. this field is not stored in the database
        processors=[ResizeToFill(200, 150)],  # Resize to 200x150
        format='JPEG',
        options={'quality': 60}
    )
    # Field to store pre-computed search vectors
    search_vector = SearchVectorField(null=True)

    def save(self, *args, **kwargs):
        """Override save to update search vector"""
        # First save the model to ensure it exists in the database
        super().save(*args, **kwargs)
        
        # Then update the search vector
        from django.contrib.postgres.search import SearchVector
    
        # Update only this instance
        type(self).objects.filter(pk=self.pk).update(
            search_vector=(
                SearchVector('name', weight='A', config='french') +
                SearchVector('description', weight='B', config='french')
            )
        )
    
    class Meta:
        # Uses GIN index for fast fuzzy matching
        indexes = [
            GinIndex(fields=['search_vector']),  # For full-text search
            GinIndex(fields=['name'], name='product_name_trigram_idx', opclasses=['gin_trgm_ops'])  # For trigram similarity
        ]
        db_table = 'products'

    def __str__(self):
        return self.name

class StoreProductModel(models.Model):
    """Django ORM model for StoreProduct"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    store_brand = models.ForeignKey(StoreBrandModel, on_delete=models.CASCADE)
    product = models.ForeignKey(ProductModel, on_delete=models.CASCADE)
    category = models.ForeignKey(CategoryModel, on_delete=models.CASCADE)  # Category within the store's hierarchy
    price = models.DecimalField(max_digits=10, decimal_places=2)
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        indexes = [
            models.Index(fields=['category', 'store_brand']),  # Speeds up category-store lookups
            models.Index(fields=['product']),  # Helps product retrieval
        ]
        unique_together = ['store_brand', 'category', 'product']  # A product and category can exist once per store
        db_table = 'store_products'

    def __str__(self):
        return f'{self.product.name} at {self.store_brand.name} - ${self.price}'
