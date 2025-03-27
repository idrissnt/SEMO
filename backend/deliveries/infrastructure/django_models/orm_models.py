from django.db import models
from orders.models import Order
from the_user_app.models import CustomUser
import uuid


class DriverModel(models.Model):
    """Django ORM model for Driver"""
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    # Removed is_available as it's redundant with CustomUser.is_available
    
    class Meta:
        db_table = 'drivers'
    
    def __str__(self):
        return self.user.username


class DeliveryModel(models.Model):
    """Django ORM model for Delivery"""
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('assigned', 'Assigned'),
        ('out_for_delivery', 'Out for Delivery'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    )
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.OneToOneField(Order, on_delete=models.CASCADE)
    driver = models.ForeignKey(DriverModel, on_delete=models.SET_NULL, null=True)
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    delivery_address = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'deliveries'
        
    def __str__(self):
        return f'Delivery for Order {self.order.id} - {self.status}'


class DeliveryTimelineModel(models.Model):
    """Django ORM model for DeliveryTimeline"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    delivery = models.ForeignKey(DeliveryModel, on_delete=models.CASCADE, related_name='timeline_events')
    EVENT_TYPES = (
        ('created', 'Created'),
        ('assigned', 'Assigned to Driver'),
        ('picked_up', 'Picked Up'),
        ('out_for_delivery', 'Out for Delivery'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    )
    event_type = models.CharField(max_length=20, choices=EVENT_TYPES)
    timestamp = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)

    class Meta:
        db_table = 'delivery_timeline'
        ordering = ['-timestamp']
    
    def __str__(self):
        return f'{self.delivery.id} - {self.event_type} at {self.timestamp}'


class DeliveryLocationModel(models.Model):
    """Django ORM model for DeliveryLocation"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    delivery = models.ForeignKey(DeliveryModel, on_delete=models.CASCADE, related_name='location_updates')
    driver = models.ForeignKey(DriverModel, on_delete=models.CASCADE)
    latitude = models.FloatField()
    longitude = models.FloatField()
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'delivery_locations'
        ordering = ['-timestamp']
    
    def __str__(self):
        return f'Location for {self.delivery.id} at {self.timestamp}'
