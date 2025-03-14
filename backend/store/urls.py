from django.urls import path
from drf_spectacular.utils import extend_schema_view, extend_schema
from .views import (
    CategoryProductsStoresView,
    StoreListView,
    StoreDetailView
)

app_name = 'store'

# Apply schema tags to views
CategoryProductsStoresView = extend_schema(tags=['Stores'])(CategoryProductsStoresView)
StoreListView = extend_schema(tags=['Stores'])(StoreListView)
StoreDetailView = extend_schema(tags=['Stores'])(StoreDetailView)

urlpatterns = [
    # Store listing and details
    path('', 
         StoreListView.as_view(), 
         name='store-list'),
    
    path('<slug:slug>/', 
         StoreDetailView.as_view(), 
         name='store-detail'),
    
    # Category-based product listing
    path('categories/<uuid:category_id>/products/', 
         CategoryProductsStoresView.as_view(), 
         name='category-products'),
]