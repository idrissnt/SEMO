from django.db import models
from orders.models import Order
import uuid

from deliveries.domain.models.constants import DeliveryStatus, DeliveryEventType
from django.conf import settings

class DriverModel(models.Model):
    """Django ORM model for Driver"""
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    mean_time_taken = models.FloatField(default=0)    # Mean time taken by the driver to complete the delivery
    license_number = models.CharField(max_length=100, unique=True, null=True, blank=True)
    is_available = models.BooleanField(default=True, null=True, blank=True)
    has_vehicle = models.BooleanField(default=False, null=True, blank=True)
    
    class Meta:
        db_table = 'drivers'
    
    def __str__(self):
        return self.user.username

class DeliveryModel(models.Model):
    """Django ORM model for Delivery"""
    STATUS_CHOICES = tuple([(status, label) for status, label in DeliveryStatus.LABELS.items()])
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.OneToOneField(Order, on_delete=models.CASCADE)
    driver = models.ForeignKey(DriverModel, on_delete=models.SET_NULL, null=True)
    estimated_total_time = models.FloatField(default=0)  # Our estimated total time to deliver the order
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=DeliveryStatus.PENDING)
    delivery_address = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    store_brand_address = models.TextField()
    schedule_for = models.DateTimeField(null=True, blank=True)
    notes_for_driver = models.TextField(null=True, blank=True)
    class Meta:
        db_table = 'deliveries'
        
    def __str__(self):
        return f'Delivery for Order {self.order.id} - {self.status}'


class DeliveryTimelineModel(models.Model):
    """Django ORM model for DeliveryTimeline"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    delivery = models.ForeignKey(DeliveryModel, on_delete=models.CASCADE, related_name='timeline_events')
    EVENT_TYPES = tuple([(event_type, label) for event_type, label in DeliveryEventType.LABELS.items()])
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
