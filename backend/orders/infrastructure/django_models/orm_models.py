from django.db import models
from django.conf import settings
from store.models import  StoreBrand, StoreProduct
from payments.models import Payment
import uuid


class OrderModel(models.Model):
    """Django ORM model for Order"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    STATUS_CHOICES = (
        ('pending', 'Pending'), 
        ('processing', 'Processing'), 
        ('delivered', 'Delivered'), 
        ('cancelled', 'Cancelled')
    )
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    store_brand = models.ForeignKey(StoreBrand, on_delete=models.CASCADE)  
    cart_total_price = models.DecimalField(max_digits=10, decimal_places=2)
    cart_total_items = models.IntegerField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    payment = models.OneToOneField(Payment, on_delete=models.SET_NULL, null=True, blank=True, related_name='payment_order')
    cart_id = models.UUIDField(null=True, blank=True)
    
    class Meta:
        db_table = 'orders'

    def __str__(self):
        return f'Order {self.id} - {self.status}'


class OrderItemModel(models.Model):
    """Django ORM model for OrderItem"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(OrderModel, on_delete=models.CASCADE, related_name='order_items')
    quantity = models.IntegerField()
    one_item_price = models.DecimalField(max_digits=10, decimal_places=2)  # Price when ordered
    store_product = models.ForeignKey(StoreProduct, on_delete=models.CASCADE)  # Store-specific product snapshot
    created_at = models.DateTimeField(auto_now_add=True)
    class Meta:
        db_table = 'order_items'
        unique_together = ('order', 'store_product')

    def __str__(self):
        return f'{self.store_product.product.name} x {self.quantity} - {self.one_item_price}'


class OrderTimelineModel(models.Model):
    """Django ORM model for OrderTimeline"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(OrderModel, on_delete=models.CASCADE, related_name='timeline_events')
    EVENT_TYPES = (
        ('created', 'Created'),
        ('payment_received', 'Payment Received'),
        ('processing', 'Processing'),
        ('out_for_delivery', 'Out for Delivery'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    )
    event_type = models.CharField(max_length=20, choices=EVENT_TYPES)
    timestamp = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'order_timeline'
        unique_together = ('order', 'event_type')
        ordering = ['-timestamp']

    def __str__(self):
        return f'{self.order.id} - {self.event_type} at {self.timestamp}'
