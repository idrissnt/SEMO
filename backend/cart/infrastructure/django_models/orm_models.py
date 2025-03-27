from django.db import models
from django.conf import settings
from store.models import StoreProduct, StoreBrand
import uuid
from django.utils import timezone

class CartModel(models.Model):
    """ORM model for Cart"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    store_brand = models.ForeignKey(StoreBrand, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    reserved_until = models.DateTimeField(null=True, blank=True)
    cart_total_price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    cart_total_items = models.IntegerField(default=0)

    class Meta:
        unique_together = ['user', 'store_brand']  # One cart per user per store
        db_table = 'carts'
        
    def reserve(self, minutes=15):
        """Reserve cart items for a specified time"""
        self.reserved_until = timezone.now() + timezone.timedelta(minutes=minutes)
        self.save()
        return self
    
    def release_reservation(self):
        """Release cart reservation"""
        self.reserved_until = None
        self.save()
        return self
    
    def is_reserved(self):
        """Check if cart is currently reserved"""
        return self.reserved_until and self.reserved_until > timezone.now()

    def __str__(self):
        return f"{self.user} - {self.store_brand}"


class CartItemModel(models.Model):
    """ORM model for CartItem"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    cart = models.ForeignKey(CartModel, on_delete=models.CASCADE, related_name='cart_items')
    store_product = models.ForeignKey(StoreProduct, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    added_at = models.DateTimeField(auto_now_add=True)
    product_price = models.DecimalField(max_digits=10, decimal_places=2)
    item_total_price = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        db_table = 'cart_items'
        unique_together = ['cart', 'store_product']  # One cart item per product

    def __str__(self):
        return f"{self.store_product.product.name}"
