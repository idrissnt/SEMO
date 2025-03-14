from django.db import models
from django.conf import settings
from store.models import StoreProduct, Store
import uuid

class Cart(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    store = models.ForeignKey(Store, on_delete=models.CASCADE)  # Cart is store-specific
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['user', 'store']  # One cart per user per store
        db_table = 'carts'

    def total_price(self):
        return sum(item.total_price() for item in self.cart_items.all())

    def total_items(self):
        return sum(item.quantity for item in self.cart_items.all())

    def is_empty(self):
        return self.total_items() == 0

    def __str__(self):
        return f"{self.user} - {self.store}"

        

class CartItem(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE, related_name='cart_items')
    store_product = models.ForeignKey(StoreProduct, on_delete=models.CASCADE)  # Tracks store-specific product
    quantity = models.PositiveIntegerField(default=1)
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'cart_items'

    def total_price(self):
        return self.store_product.price * self.quantity

    def __str__(self):
        return f"{self.store_product.product.name}"