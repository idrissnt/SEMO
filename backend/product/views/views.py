from typing import Dict, List, Optional, Union

from django.db.models import Count, Q, QuerySet
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from drf_spectacular.utils import extend_schema, OpenApiParameter

from product.models import Product, ProductCategory, StoreProduct
from product.serializers import (
    ProductListSerializer, 
    ProductDetailSerializer,
    ProductCategorySerializer,
    StoreProductSerializer
)

# Create your views here.

@extend_schema(tags=['Products'])
class ProductViewSet(ModelViewSet):
    """ViewSet for Product-related operations"""
    queryset: QuerySet = Product.objects.all()
    # permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self) -> Union[ProductListSerializer, ProductDetailSerializer]:
        """Dynamically select serializer based on action"""
        if self.action == 'list':
            return ProductListSerializer
        return ProductDetailSerializer

    def get_serializer_context(self) -> Dict[str, Request]:
        """Add request to serializer context"""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    @extend_schema(
        parameters=[
            OpenApiParameter(name='store_id', type=str, required=False),
            OpenApiParameter(name='category_id', type=str, required=False),
            OpenApiParameter(name='parent_category_id', type=str, required=False),
            OpenApiParameter(name='search', type=str, required=False),
            OpenApiParameter(name='min_price', type=float, required=False),
            OpenApiParameter(name='max_price', type=float, required=False),
            OpenApiParameter(name='is_available', type=bool, required=False),
            OpenApiParameter(name='is_seasonal', type=bool, required=False)
        ]
    )
    def list(self, request: Request, *args, **kwargs) -> Response:
        """
        List products with optional filtering
        
        Supports filtering by:
        - store_id
        - category_id
        - parent_category_id
        - search term
        - price range
        - availability
        - is_seasonal
        """
        queryset: QuerySet = self.get_queryset()
        
        # Apply filters
        store_id: Optional[str] = request.query_params.get('store_id')
        if store_id:
            queryset = queryset.filter(storeproduct__store_id=store_id)
        
        category_id: Optional[str] = request.query_params.get('category_id')
        if category_id:
            queryset = queryset.filter(
                Q(category_id=category_id) |
                Q(category__parent_category_id=category_id)
            )
        
        # New: Filter by parent category
        parent_category_id: Optional[str] = request.query_params.get('parent_category_id')
        if parent_category_id:
            queryset = queryset.filter(
                Q(category__parent_category_id=parent_category_id)
            )
        
        search: Optional[str] = request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) |
                Q(description__icontains=search)
            )
        
        min_price: Optional[str] = request.query_params.get('min_price')
        if min_price:
            queryset = queryset.filter(storeproduct__price__gte=float(min_price))
        
        max_price: Optional[str] = request.query_params.get('max_price')
        if max_price:
            queryset = queryset.filter(storeproduct__price__lte=float(max_price))
        
        is_available: Optional[str] = request.query_params.get('is_available')
        if is_available:
            queryset = queryset.filter(storeproduct__is_available=is_available.lower() == 'true')
        
        # New: Filter by seasonal status
        is_seasonal: Optional[str] = request.query_params.get('is_seasonal')
        if is_seasonal is not None:
            queryset = queryset.filter(is_seasonal=is_seasonal.lower() == 'true')
        
        serializer = self.get_serializer(queryset.distinct(), many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def availability(self, request: Request, pk: Optional[str] = None) -> Response:
        """
        Get product availability across stores
        
        :param request: HTTP request object
        :param pk: Product UUID
        :return: List of store products where product is available
        """
        product: Product = self.get_object()
        store_products: QuerySet = product.storeproduct_set.filter(is_available=True)
        serializer = StoreProductSerializer(store_products, many=True, context={'request': request})
        return Response(serializer.data)

@extend_schema(tags=['Categories'])
class CategoryViewSet(ModelViewSet):
    """ViewSet for Product Category operations"""
    queryset: QuerySet = ProductCategory.objects.all()
    serializer_class = ProductCategorySerializer
    # permission_classes = [IsAuthenticated]
    
    def list(self, request: Request, *args, **kwargs) -> Response:
        """
        List categories with optional filtering
        
        Supports filtering by:
        - store_id
        - root_only
        """
        print("CategoryViewSet: list method called")
        print("Request query params:", request.query_params)
        
        queryset: QuerySet = self.get_queryset()
        
        # Filter by store
        store_id: Optional[str] = request.query_params.get('store_id')
        if store_id:
            print(f"Filtering by store_id: {store_id}")
            queryset = queryset.filter(stores__id=store_id)
        
        # Only root categories
        root_only: Optional[str] = request.query_params.get('root_only')
        if root_only and root_only.lower() == 'true':
            print("Filtering root categories only")
            queryset = queryset.filter(parent_category__isnull=True)
        
        print(f"Total categories found: {queryset.count()}")
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    def get_queryset(self) -> QuerySet:
        """
        Get queryset with optional filtering
        
        Supports filtering by:
        - store_id
        - root categories only
        """
        queryset: QuerySet = ProductCategory.objects.all()
        
        # Filter by store
        store_id: Optional[str] = self.request.query_params.get('store_id')
        if store_id:
            queryset = queryset.filter(stores__id=store_id)
        
        # Only root categories
        root_only: Optional[str] = self.request.query_params.get('root_only')
        if root_only and root_only.lower() == 'true':
            queryset = queryset.filter(parent_category__isnull=True)
        
        return queryset
    
    @action(detail=True, methods=['get'])
    def products(self, request: Request, pk: Optional[str] = None) -> Response:
        """
        Get all products in this category and its subcategories
        
        :param request: HTTP request object
        :param pk: Category UUID
        :return: List of products in category
        """
        category: ProductCategory = self.get_object()
        products: QuerySet = Product.objects.filter(
            Q(category=category) |
            Q(category__parent_category=category)
        ).distinct()
        
        serializer = ProductListSerializer(products, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def subcategories(self, request: Request, pk: Optional[str] = None) -> Response:
        """
        Get all subcategories of this category
        
        :param request: HTTP request object
        :param pk: Category UUID
        :return: List of subcategories
        """
        category: ProductCategory = self.get_object()
        subcategories: QuerySet = category.subcategories.all()
        serializer = ProductCategorySerializer(subcategories, many=True)
        return Response(serializer.data)
