"""
Django ORM models for driver devices and location tracking.

This module provides the Django ORM models for storing driver device tokens
for push notifications and tracking driver locations.
"""
from django.db import models
from django.contrib.gis.db import models as gis_models
from django.contrib.gis.geos import Point
import uuid
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

class DriverDeviceModel(models.Model):
    """Django ORM model for driver devices (for push notifications)"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    driver = models.ForeignKey(DriverModel, on_delete=models.CASCADE, related_name='devices')
    device_token = models.CharField(max_length=255)
    device_type = models.CharField(max_length=20)  # 'android', 'ios', etc.
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'driver_devices'
        unique_together = ('driver', 'device_token')
        indexes = [
            models.Index(fields=['device_token']),
            models.Index(fields=['driver', 'is_active']),
        ]
    
    def __str__(self):
        return f"Device for {self.driver.user.email} ({self.device_type})"


class DriverLocationModel(models.Model):
    """Django ORM model for tracking driver locations"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    driver = models.ForeignKey(DriverModel, on_delete=models.CASCADE, related_name='locations')
    # Geospatial field for location
    location = gis_models.PointField(geography=True, spatial_index=True)
    # Standard fields for latitude/longitude for backward compatibility
    latitude = models.FloatField()
    longitude = models.FloatField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
    
    def save(self, *args, **kwargs):
        # Auto-populate the location field from lat/long if not set
        if not self.location and self.latitude is not None and self.longitude is not None:
            self.location = Point(self.longitude, self.latitude, srid=4326)
        # Auto-populate lat/long from location if not set
        elif self.location and (self.latitude is None or self.longitude is None):
            self.latitude = self.location.y
            self.longitude = self.location.x
        super().save(*args, **kwargs)
    
    class Meta:
        db_table = 'driver_locations'
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['driver', '-timestamp']),
            gis_models.Index(fields=['location']),
        ]
    
    def __str__(self):
        return f"Location for {self.driver.user.email} at {self.timestamp}"
