from django.urls import path, include
from rest_framework.routers import DefaultRouter

from deliveries.interfaces.api.views import (
    DeliveryViewSet,
    GeoSpatialViewSet,
    DriverViewSet,
    TimelineViewSet
)

app_name = 'deliveries'

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'deliveries', DeliveryViewSet, basename='delivery')
router.register(r'geo', GeoSpatialViewSet, basename='geospatial')
router.register(r'drivers', DriverViewSet, basename='driver')
router.register(r'timeline', TimelineViewSet, basename='timeline')

urlpatterns = [
    path('', include(router.urls)),
]