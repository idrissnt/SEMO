from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DriverViewSet, DeliveryViewSet, OrderDeliveryViewSet

app_name = 'deliveries'

router = DefaultRouter()
router.register(r'drivers', DriverViewSet, basename='driver')
router.register(r'deliveries', DeliveryViewSet, basename='delivery')

urlpatterns = [
    path('', include(router.urls)),
    path('orders/<uuid:pk>/delivery/', 
         OrderDeliveryViewSet.as_view({'get': 'retrieve'}),
         name='order-delivery'),
]