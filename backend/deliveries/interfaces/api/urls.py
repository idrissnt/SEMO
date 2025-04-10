from django.urls import path, include
from rest_framework.routers import DefaultRouter

from deliveries.interfaces.api.views.notification.delivery_notification_viewset import DeliveryNotificationViewSet
from deliveries.interfaces.api.views.notification.driver_notification_viewset import DriverNotificationViewSet
from deliveries.interfaces.api.views.delivery_application_viewset import DeliveryApplicationViewSet
from deliveries.interfaces.api.views.location_application_viewset import LocationApplicationViewSet
from deliveries.interfaces.api.views.delivery_search_viewset import DeliverySearchViewSet

app_name = 'deliveries'

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'delivery-notifications', DeliveryNotificationViewSet, basename='delivery-notification')
router.register(r'driver-notifications', DriverNotificationViewSet, basename='driver-notification')

# Register new application service viewsets
router.register(r'delivery', DeliveryApplicationViewSet, basename='delivery')
router.register(r'location', LocationApplicationViewSet, basename='location')
router.register(r'delivery-search', DeliverySearchViewSet, basename='delivery-search')

urlpatterns = [
    path('', include(router.urls)),
]