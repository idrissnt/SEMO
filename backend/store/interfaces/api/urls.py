from django.urls import path, include
from rest_framework.routers import DefaultRouter

from store.interfaces.api.views import (
    StoreBrandLocationViewSet,
    StoreProductViewSet,
    SearchViewSet
)
from store.interfaces.api.use_to_add_data.collection_views import ProductCollectionViewSet
from store.interfaces.api.use_to_add_data.image_upload_views import ImageUploadViewSet

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'store-brands', StoreBrandLocationViewSet, basename='store-brands')
router.register(r'store-products', StoreProductViewSet, basename='store-products')
router.register(r'search', SearchViewSet, basename='search')

# Collection
router.register(r'product-collections', ProductCollectionViewSet, basename='product-collections')
# Image Upload
router.register(r'images', ImageUploadViewSet, basename='images')

# The API URLs are now determined automatically by the router
urlpatterns = [
    path('', include(router.urls)),
]