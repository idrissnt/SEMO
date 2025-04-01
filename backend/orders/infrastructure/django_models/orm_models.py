from django.db import models
from django.conf import settings
from store.models import  StoreBrand, StoreProduct
from payments.models import Payment
import uuid
from orders.domain.models.constants import OrderStatus, OrderEventType


class OrderModel(models.Model):
    """Django ORM model for Order"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    store_brand = models.ForeignKey(StoreBrand, on_delete=models.CASCADE)  
    payment = models.OneToOneField(Payment, on_delete=models.SET_NULL, null=True, blank=True, related_name='payment_order')
    cart_total_price = models.DecimalField(max_digits=10, decimal_places=2)
    cart_total_items = models.IntegerField()
    fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    order_total_price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    user_store_distance = models.FloatField(default=0)  # Distance in meters
    status = models.CharField(
        max_length=20, 
        choices=tuple((status, OrderStatus.LABELS[status]) for status in OrderStatus.ALL),
        default=OrderStatus.PENDING
    )
    created_at = models.DateTimeField(auto_now_add=True)
    schedule_for = models.DateTimeField(null=True, blank=True)
    notes_for_driver = models.TextField(null=True, blank=True)
    store_brand_address = models.CharField(max_length=255, null=True, blank=True)
    total_time = models.FloatField(default=0)  # Total time in minutes
    cart_id = models.UUIDField(null=True, blank=True)
    
    class Meta:
        db_table = 'orders'

    def __str__(self):
        return f'Order {self.id} - {self.status}'


class OrderItemModel(models.Model):
    """Django ORM model for OrderItem"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(OrderModel, on_delete=models.CASCADE, related_name='order_items')
    store_product = models.ForeignKey(StoreProduct, on_delete=models.CASCADE)  # Store-specific product snapshot
    quantity = models.IntegerField()
    product_price = models.DecimalField(max_digits=10, decimal_places=2)  # Price when ordered
    item_total_price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    class Meta:
        db_table = 'order_items'
        unique_together = ('order', 'store_product')

    def __str__(self):
        return f'{self.store_product.product.name} x {self.quantity} - {self.product_price}'


class OrderTimelineModel(models.Model):
    """Django ORM model for OrderTimeline"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(OrderModel, on_delete=models.CASCADE, related_name='timeline_events')

    EVENT_TYPES = tuple((event_type, OrderEventType.LABELS[event_type]) for event_type in OrderEventType.ALL)
    event_type = models.CharField(max_length=20, choices=EVENT_TYPES)
    timestamp = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'order_timeline'
        unique_together = ('order', 'event_type')
        ordering = ['-timestamp']

    def __str__(self):
        return f'{self.order.id} - {self.event_type} at {self.timestamp}'
