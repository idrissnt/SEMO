from django.db import models
from django.core.exceptions import ValidationError
from store.models import Store
import uuid
from django.utils import timezone

class ProductCategory(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    store = models.ForeignKey(
        Store, 
        on_delete=models.CASCADE,
        related_name='categories' # enable accessing a store's categories via store.categories
    )
    parent_category = models.ForeignKey(
        'self', 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        related_name='subcategories'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name_plural = 'Product Categories'
        unique_together = ('name', 'store', 'parent_category')
        ordering = ['name']

    def __str__(self):
        if self.parent_category:
            return f"{self.parent_category.name} → {self.name}"
        return self.name

    def clean(self):
        if self.parent_category and self.parent_category.store != self.store:
            raise ValidationError("Parent category must belong to the same store")

    def get_full_path(self):
        """Returns the full category path (e.g., 'Fruits → Citrus → Oranges')"""
        path = [self.name]
        current = self
        while current.parent_category:
            current = current.parent_category
            path.append(current.name)
        return " → ".join(reversed(path))

    def get_all_subcategories(self, include_self=True):
        """Returns all subcategories recursively"""
        categories = [self] if include_self else []
        for subcategory in self.subcategories.all():
            categories.extend(subcategory.get_all_subcategories())
        return categories

    @property
    def total_products(self):
        """Returns total number of products in this category and its subcategories"""
        return Product.objects.filter(
            category__in=self.get_all_subcategories()
        ).count()

class Product(models.Model):
    UNIT_CHOICES = [
        ('kg', 'Kilogram'),
        ('g', 'Gram'),
        ('l', 'Liter'),
        ('ml', 'Milliliter'),
        ('unit', 'Unit'),
        ('pack', 'Pack')
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    description = models.TextField()
    image_url = models.ImageField(
        upload_to='products/images/',
        default='images/products/default.png'
    )
    category = models.ForeignKey( #  models.ForeignKey == OneToOneField
        ProductCategory,  # Links the product to a ProductCategory
        on_delete=models.SET_NULL, # If a category is deleted, the product remains but the field is set to NULL
        null=True,
        related_name='products'
    )
    stores = models.ManyToManyField(
        Store, 
        through='StoreProduct',
        related_name='products'
    )
    unit = models.CharField(
        max_length=10,
        choices=UNIT_CHOICES,
        default='unit'
    )
    is_seasonal = models.BooleanField(default=False)
    nutritional_info = models.JSONField(
        default=dict,
        blank=True,
        help_text="Nutritional information per 100g/100ml"
    )
    allergens = models.JSONField(
        default=list,
        blank=True,
        help_text="List of allergens"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['name']
        unique_together = ('name', 'category')

    def __str__(self):
        return f"{self.name} ({self.get_unit_display()})"

    def add_to_store(self, store, price, stock=0, is_available=True):
        """Helper method to easily add product to a store"""
        return StoreProduct.objects.create(
            store=store,
            product=self,
            price=price,
            stock=stock,
            is_available=is_available
        )

    def get_price_range(self):
        """Returns min and max prices across all stores"""
        prices = self.storeproduct_set.values_list('price', flat=True)
        if not prices:
            return None, None
        return min(prices), max(prices)

    def get_available_stores(self):
        """Returns all stores where the product is available"""
        return self.stores.filter(
            storeproduct__is_available=True,
            storeproduct__stock__gt=0
        )

    @property
    def lowest_price(self):
        """Returns the lowest price across all stores"""
        min_price, _ = self.get_price_range()
        return min_price

# this helps to add additional Metadata
# instead of just creating class Product(models.Model):
#                                stores = models.ManyToManyField(Store)
class StoreProduct(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    store = models.ForeignKey(Store, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.IntegerField(default=0)
    is_available = models.BooleanField(default=True)
    discount_price = models.DecimalField(
        max_digits=10, 
        decimal_places=2,
        null=True,
        blank=True
    )
    discount_end_date = models.DateTimeField(null=True, blank=True)
    position_in_store = models.CharField(
        max_length=100,
        blank=True,
        help_text="Physical location in store (e.g., 'Aisle 5, Shelf 3')"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('store', 'product')
        indexes = [
            models.Index(fields=['store', 'product']),
            models.Index(fields=['is_available']),
            models.Index(fields=['price']),
        ]

    def __str__(self):
        return f"{self.product.name} in {self.store.name}"

    @property
    def current_price(self):
        """Returns the current effective price (considering discounts)"""
        if self.discount_price and self.discount_end_date and \
           self.discount_end_date > timezone.now():
            return self.discount_price
        return self.price

    def update_stock(self, quantity, action='add'):
        """Update stock levels"""
        if action == 'add':
            self.stock += quantity
        elif action == 'remove':
            self.stock = max(0, self.stock - quantity)
        elif action == 'set':
            self.stock = quantity
        self.save()
