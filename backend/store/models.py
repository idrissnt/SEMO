from django.db import models
from django.utils import timezone
import uuid
from django.core.validators import MinValueValidator, MaxValueValidator

class Store(models.Model):
    DELIVERY_CHOICES = [
        ('FAST', '15-30 minutes'),
        ('STANDARD', '30-45 minutes'),
        ('SCHEDULED', 'Schedule for later')
    ]

    # Basic Information
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    description = models.TextField(max_length=500, blank=True, null=True)
    logo_url = models.ImageField(
        upload_to='images/stores/', 
        default='images/stores/big_stores/carrefour_logo.png',
        null=True, 
        blank=True 
    )
    
    # Location
    address = models.CharField(max_length=255, blank=True, null=True)
    latitude = models.DecimalField(
        max_digits=9, 
        decimal_places=6,
        null=True,
        blank=True
    )
    longitude = models.DecimalField(
        max_digits=9, 
        decimal_places=6,
        null=True,
        blank=True
    )
    delivery_radius = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        help_text="Delivery radius in kilometers",
        default=5.00
    )

    # Operating Hours
    is_open = models.BooleanField(default=True)
    is_big_store = models.BooleanField(default=False)
    working_hours = models.JSONField(
        default=dict,
        help_text="Store working hours in format: {'monday': {'open': '09:00', 'close': '21:00'}}",
        null=True,
        blank=True
    )
    
    # Delivery Options
    delivery_type = models.CharField(
        max_length=20,
        choices=DELIVERY_CHOICES,
        default='STANDARD'
    )
    preparation_time = models.JSONField(
        default=dict,
        help_text="""
        Preparation time settings in minutes:
        {
            'default': 15,
            'by_category': {'fresh': 10, 'frozen': 20},
            'by_order_size': {'small': 10, 'medium': 20, 'large': 30}
        }
        """,
        null=True,
        blank=True
    )
    minimum_order = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00
    )
    delivery_fee = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00
    )
    free_delivery_threshold = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True
    )

    # Store Features
    has_fresh_products = models.BooleanField(default=False)
    has_frozen_products = models.BooleanField(default=False)
    supports_pickup = models.BooleanField(default=False)
    
    # Performance Metrics
    rating = models.DecimalField(
        max_digits=3, 
        decimal_places=2,
        default=0.00,
        validators=[
            MinValueValidator(1.0),
            MaxValueValidator(5.0)
        ]
    )
    total_reviews = models.PositiveIntegerField(default=0)
    
    # Promotions and Special Offers
    current_promotions = models.JSONField(
        default=list,
        help_text="List of current promotional offers",
        null=True,
        blank=True
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-rating', 'name']
        indexes = [
            models.Index(fields=['rating']),
            models.Index(fields=['is_open']),
            models.Index(fields=['delivery_type']),
        ]

    def __str__(self):
        return self.name

    def is_currently_open(self):
        """Check if store is open based on working hours"""
        if not self.is_open:
            return False
            
        current_time = timezone.localtime()
        day_name = current_time.strftime('%A').lower() # convert to day of the week and in lowercase (e.g., 'monday')
        
        if day_name not in self.working_hours:
            return False
            
        hours = self.working_hours[day_name]
        open_time = timezone.datetime.strptime(hours['open'], '%H:%M').time()
        close_time = timezone.datetime.strptime(hours['close'], '%H:%M').time()
        
        return open_time <= current_time.time() <= close_time

    def calculate_preparation_time(self, order_items):
        """
        Calculate preparation time based on order items
        order_items: list of (product, quantity) tuples
        """
        base_time = self.preparation_time.get('default', 15)
        
        # Add category-specific time
        category_times = self.preparation_time.get('by_category', {})
        for product, _ in order_items:
            if product.category:
                category_name = product.category.name.lower()
                if category_name in category_times:
                    base_time += category_times[category_name]
        
        # Adjust for order size
        total_items = sum(quantity for _, quantity in order_items)
        size_times = self.preparation_time.get('by_order_size', {})
        if total_items > 20:
            base_time += size_times.get('large', 15)
        elif total_items > 10:
            base_time += size_times.get('medium', 10)
        
        return base_time

    def get_delivery_time_estimate(self, order_items=None):
        """Get total estimated time including preparation and delivery"""
        prep_time = self.calculate_preparation_time(order_items) if order_items else 15
        
        delivery_times = {
            'FAST': 15,
            'STANDARD': 30,
            'SCHEDULED': 0  # Scheduled delivery doesn't need immediate delivery time
        }
        
        delivery_time = delivery_times.get(self.delivery_type, 30)
        return prep_time + delivery_time

    def calculate_delivery_fee(self, order_total):
        """Calculate delivery fee based on order total"""
        if self.free_delivery_threshold and order_total >= self.free_delivery_threshold:
            return 0
        return self.delivery_fee

    def get_active_promotions(self):
        """Get list of currently active promotions"""
        return [
            promo for promo in self.current_promotions
            if not promo.get('end_date') or
            timezone.datetime.fromisoformat(promo['end_date']) > timezone.now()
        ]

    def update_rating(self, new_rating):
        """Update store rating with a new review"""
        total = self.rating * self.total_reviews
        self.total_reviews += 1
        self.rating = (total + new_rating) / self.total_reviews
        self.save()

    @property
    def total_product_categories(self):
        return self.categories.count()

    @property
    def main_product_categories(self):
        return self.categories.filter(parent_category__isnull=True)

    def get_popular_products(self, limit=10):
        """Get most popular products in the store"""
        return self.products.filter(
            storeproduct__is_available=True
        ).order_by('-storeproduct__stock')[:limit]

    def get_low_stock_products(self, threshold=10):
        """Get products with low stock"""
        return self.products.filter(
            storeproduct__is_available=True,
            storeproduct__stock__lte=threshold
        )

    def get_category_tree(self):
        """Get hierarchical category structure"""
        return self.categories.filter(
            parent_category__isnull=True
        ).prefetch_related('subcategories')
