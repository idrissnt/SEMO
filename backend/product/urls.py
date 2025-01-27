from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ProductViewSet, CategoryViewSet

app_name = 'product'

router = DefaultRouter()
router.register('categories', CategoryViewSet, basename='category')
router.register('', ProductViewSet, basename='product')

urlpatterns = [
    path('', include(router.urls)),
    # You can add custom routes here if needed
    path('seasonal/', ProductViewSet.as_view({'get': 'list'}), name='seasonal-products'),
]
