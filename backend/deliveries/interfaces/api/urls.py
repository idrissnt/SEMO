from django.urls import path, include
from rest_framework.routers import DefaultRouter
from views import DriverViewSet
from views import DeliveryViewSet, DeliveryTimelineViewSet, DeliveryLocationViewSet
from views import OrderDeliveryViewSet

app_name = 'deliveries'

router = DefaultRouter()
router.register(r'drivers', DriverViewSet, basename='driver')
router.register(r'deliveries', DeliveryViewSet, basename='delivery')
router.register(r'delivery-timeline', DeliveryTimelineViewSet, basename='delivery-timeline')
router.register(r'delivery-locations', DeliveryLocationViewSet, basename='delivery-location')

urlpatterns = [
    path('', include(router.urls)),
    path('orders/<uuid:pk>/delivery/', 
         OrderDeliveryViewSet.as_view({'get': 'retrieve'}),
         name='order-delivery'),
]