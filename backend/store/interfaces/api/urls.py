from django.urls import path, include
from rest_framework.routers import DefaultRouter

from store.interfaces.api.views import (
    StoreBrandLocationViewSet,
    StoreProductViewSet,
    SearchViewSet
)

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'store-brands', StoreBrandLocationViewSet, basename='store-brands')
router.register(r'store-products', StoreProductViewSet, basename='store-products')
router.register(r'search', SearchViewSet, basename='search')

# The API URLs are now determined automatically by the router
urlpatterns = [
    path('', include(router.urls)),
]