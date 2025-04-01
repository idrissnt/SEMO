from django.urls import path, include
from rest_framework.routers import DefaultRouter
from orders.interfaces.api.views import OrderViewSet, OrderItemViewSet, OrderTimelineViewSet

app_name = 'orders'

router = DefaultRouter()
router.register(r'orders', OrderViewSet, basename='order')
router.register(r'order-items', OrderItemViewSet, basename='orderitem')
router.register(r'order-timeline', OrderTimelineViewSet, basename='ordertimeline')

urlpatterns = [
    path('', include(router.urls)),
]