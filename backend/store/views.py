# views.py
from rest_framework import generics
from .models import Store, Category, StoreProduct
from .serializers import (
    MinimalStoreSerializer, 
    StoreProductSerializer, 
    StoreDetailSerializer
)
from rest_framework.permissions import AllowAny

class CategoryProductsStoresView(generics.ListAPIView):
    """
    Use select_related to minimize queries.
    Retrieve all products in a specific category 
    (including subcategories) and the stores that sell them.
    
    GET /api/categories/{category_id}/products/

    """
    permission_classes = [AllowAny]
    serializer_class = StoreProductSerializer 

    def get_queryset(self):
        category_id = self.kwargs['category_id']
        # Get all subcategories of the given category (using LTREE path : path__descendants)
        category = Category.objects.get(id=category_id)
        subcategories = Category.objects.filter(path__descendants=category.path)
        # Get all StoreProducts in these categories
        return StoreProduct.objects.filter(category__in=subcategories).select_related('store', 'product', 'category')

class StoreListView(generics.ListAPIView):
    """
    Retrieve a list of stores without nested categories/products.
    
    GET /api/stores/
    """
    permission_classes = [AllowAny]
    serializer_class = MinimalStoreSerializer
    queryset = Store.objects.all()

class StoreDetailView(generics.RetrieveAPIView):
    """
    API endpoint to retrieve detailed information about a single store, including:
    - Store metadata (name, address, working hours)
    - Hierarchical categories/subcategories
    - Products within each category
    
    GET /api/stores/{store_slug}/
    Example: /api/stores/fresh-grocers/
    """
    permission_classes = [AllowAny]
    serializer_class = StoreDetailSerializer  # Uses custom serializer for nested data
    lookup_field = 'slug'  # Use human-readable slug instead of ID in URLs
    queryset = Store.objects.prefetch_related(
        # Prefetch all categories belonging to this store
        # Uses reverse relationship (store.category_set)
        'category_set',

        # Prefetch all StoreProduct relationships for this store
        # Also prefetch RELATED PRODUCTS through StoreProduct (storeproduct_set__product)
        'storeproduct_set__product',

        # Prefetch CATEGORIES for each StoreProduct relationship
        # (storeproduct_set__category)
        'storeproduct_set__category'
    ).all()  # Get all stores (filtering happens via slug lookup)

    """
    Query Optimization Strategy:
    1. Single database query to get store by slug
    2. Three additional queries (via prefetch_related):
       - All categories in store
       - All store-product relationships + products
       - All store-product relationships + categories
    3. Total: 4 queries (instead of N+1 queries for nested data)
    
    Without prefetch_related, this would trigger:
    - 1 query for store
    - 1 query per category (N queries)
    - 1 query per product (M queries)
    = 1 + N + M queries (potentially hundreds)
    """
