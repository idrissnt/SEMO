from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views.views import ProductViewSet, CategoryViewSet

app_name = 'product'

router = DefaultRouter()
# Register categories first to ensure it's a top-level endpoint
router.register(r'categories', CategoryViewSet, basename='category')
router.register(r'', ProductViewSet, basename='product')

urlpatterns = [
    path('', include(router.urls)),
    # You can add custom routes here if needed
    path('seasonal/', ProductViewSet.as_view({'get': 'list'}), name='seasonal-products'),
]
