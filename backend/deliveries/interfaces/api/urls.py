from django.urls import path, include
from rest_framework.routers import DefaultRouter

from deliveries.interfaces.api.views import (
    DeliveryViewSet,
    GeoSpatialViewSet,
    DriverViewSet,
    TimelineViewSet
)
from deliveries.interfaces.api.views.notification.notification_viewset import NotificationViewSet
from deliveries.interfaces.api.views.notification.delivery_notification_viewset import DeliveryNotificationViewSet

app_name = 'deliveries'

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'deliveries', DeliveryViewSet, basename='delivery')
router.register(r'geo', GeoSpatialViewSet, basename='geospatial')
router.register(r'drivers', DriverViewSet, basename='driver')
router.register(r'timeline', TimelineViewSet, basename='timeline')
router.register(r'notifications', NotificationViewSet, basename='notification')
router.register(r'delivery-notifications', DeliveryNotificationViewSet, basename='delivery-notification')

urlpatterns = [
    path('', include(router.urls)),
]