from django.db import models
from django.conf import settings
from store.models import StoreProduct, Store
from payments.models import Payment
import uuid

class Order(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    STATUS_CHOICES = (('pending', 'Pending'), ('processing', 'Processing'), ('delivered', 'Delivered'), ('cancelled', 'Cancelled'))
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    store = models.ForeignKey(Store, on_delete=models.CASCADE)  # Order is store-specific
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    payment = models.OneToOneField(Payment, on_delete=models.SET_NULL, null=True, blank=True, related_name='payment_order')

    class Meta:
        db_table = 'orders'

    def __str__(self):
        return f'Order {self.id} - {self.status}'

class OrderItem(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='order_items')
    store_product = models.ForeignKey(StoreProduct, on_delete=models.CASCADE)  # Store-specific product snapshot (saved version)
    quantity = models.IntegerField()
    price_at_order = models.DecimalField(max_digits=10, decimal_places=2)  # Price when ordered

    class Meta:
        db_table = 'order_items'

    def __str__(self):
        return f'{self.store_product.product.name} x {self.quantity}'