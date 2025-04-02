from django.db import models
from django.contrib.gis.db import models as gis_models
from django.contrib.gis.geos import Point
from orders.models import Order
import uuid

from deliveries.domain.models.constants import DeliveryStatus, DeliveryEventType
from deliveries.infrastructure.django_models.driver_orm_models.driver_model import DriverModel


class DeliveryModel(models.Model):
    """Django ORM model for Delivery"""
    STATUS_CHOICES = tuple([(status, label) for status, label in DeliveryStatus.LABELS.items()])
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.OneToOneField(Order, on_delete=models.CASCADE)
    driver = models.ForeignKey(DriverModel, on_delete=models.SET_NULL, null=True)
    estimated_total_time = models.FloatField(default=0)  # Our estimated total time to deliver the order
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=DeliveryStatus.PENDING)
    delivery_address_human_readable = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    store_brand_address_human_readable = models.TextField()
    schedule_for = models.DateTimeField(null=True, blank=True)
    notes_for_driver = models.TextField(null=True, blank=True)
    
    # Geospatial fields
    delivery_location_geopoint = gis_models.PointField(geography=True, null=True, blank=True)
    store_location_geopoint = gis_models.PointField(geography=True, null=True, blank=True)
    estimated_arrival_time = models.DateTimeField(null=True, blank=True)
    class Meta:
        db_table = 'deliveries'
        
    def __str__(self):
        return f'Delivery for Order {self.order.id} - {self.status}'


class DeliveryTimelineModel(models.Model):
    """Django ORM model for DeliveryTimeline
    Records a chronological sequence of events 
    (created, assigned, picked up, delivered, etc.) for each delivery
    Captures when and why a delivery's status changed"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    delivery = models.ForeignKey(DeliveryModel, on_delete=models.CASCADE, related_name='timeline_events')
    EVENT_TYPES = tuple([(event_type, label) for event_type, label in DeliveryEventType.LABELS.items()])
    event_type = models.CharField(max_length=20, choices=EVENT_TYPES)
    timestamp = models.DateTimeField(auto_now_add=True)
    notes = models.TextField(null=True, blank=True)
    # Keep these for backward compatibility
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    # New geospatial field
    location = gis_models.PointField(geography=True, null=True, blank=True)
    
    def save(self, *args, **kwargs):
        # Auto-populate the location field from lat/long if provided
        if self.latitude is not None and self.longitude is not None and not self.location:
            self.location = Point(self.longitude, self.latitude, srid=4326)
        super().save(*args, **kwargs)

    class Meta:
        db_table = 'delivery_timeline'
        ordering = ['-timestamp']
    
    def __str__(self):
        return f'{self.delivery.id} - {self.event_type} at {self.timestamp}'


class DeliveryLocationModel(models.Model):
    """Django ORM model for DeliveryLocation
    to track the location of the driver during the delivery
    Captures the exact location of the driver at specific points in time
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    delivery = models.ForeignKey(DeliveryModel, on_delete=models.CASCADE, related_name='location_updates')
    driver = models.ForeignKey(DriverModel, on_delete=models.CASCADE)
    # Keep these for backward compatibility
    latitude = models.FloatField()
    longitude = models.FloatField()
    # New geospatial field
    location = gis_models.PointField(geography=True, spatial_index=True)
    timestamp = models.DateTimeField(auto_now_add=True)
    
    def save(self, *args, **kwargs):
        # Auto-populate the location field from lat/long
        if not self.location:
            self.location = Point(self.longitude, self.latitude, srid=4326)
        super().save(*args, **kwargs)

    class Meta:
        db_table = 'delivery_locations'
        ordering = ['-timestamp']
        # Add spatial index
        indexes = [
            gis_models.Index(fields=['location']),
        ]
    
    def __str__(self):
        return f'Location for {self.delivery.id} at {self.timestamp}'
