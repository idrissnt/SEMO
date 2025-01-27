from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from drf_spectacular.utils import extend_schema, OpenApiParameter
from django.db.models import Count, Q
from .models import Product, ProductCategory, StoreProduct
from .serializers import (
    ProductListSerializer, 
    ProductDetailSerializer,
    ProductCategorySerializer,
    StoreProductSerializer
)

# Create your views here.

@extend_schema(tags=['Products'])
class ProductViewSet(ModelViewSet):
    queryset = Product.objects.all()
    
    def get_serializer_class(self):
        if self.action == 'list':
            return ProductListSerializer
        return ProductDetailSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    @extend_schema(
        parameters=[
            OpenApiParameter(name='store_id', type=str, required=False),
            OpenApiParameter(name='category_id', type=str, required=False),
            OpenApiParameter(name='search', type=str, required=False),
            OpenApiParameter(name='min_price', type=float, required=False),
            OpenApiParameter(name='max_price', type=float, required=False),
            OpenApiParameter(name='is_available', type=bool, required=False)
        ]
    )
    def list(self, request, *args, **kwargs):
        """List products with optional filtering"""
        queryset = self.get_queryset()
        
        # Apply filters
        store_id = request.query_params.get('store_id')
        if store_id:
            queryset = queryset.filter(storeproduct__store_id=store_id)
        
        category_id = request.query_params.get('category_id')
        if category_id:
            queryset = queryset.filter(
                Q(category_id=category_id) |
                Q(category__parent_category_id=category_id)
            )
        
        search = request.query_params.get('search')
        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) |
                Q(description__icontains=search)
            )
        
        min_price = request.query_params.get('min_price')
        if min_price:
            queryset = queryset.filter(storeproduct__price__gte=float(min_price))
        
        max_price = request.query_params.get('max_price')
        if max_price:
            queryset = queryset.filter(storeproduct__price__lte=float(max_price))
        
        is_available = request.query_params.get('is_available')
        if is_available:
            queryset = queryset.filter(storeproduct__is_available=is_available.lower() == 'true')
        
        serializer = self.get_serializer(queryset.distinct(), many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def availability(self, request, pk=None):
        """Get product availability across stores"""
        product = self.get_object()
        store_products = product.storeproduct_set.filter(is_available=True)
        serializer = StoreProductSerializer(store_products, many=True, context={'request': request})
        return Response(serializer.data)

@extend_schema(tags=['Categories'])
class CategoryViewSet(ModelViewSet):
    queryset = ProductCategory.objects.all()
    serializer_class = ProductCategorySerializer
    
    def get_queryset(self):
        queryset = ProductCategory.objects.all()
        
        # Filter by store
        store_id = self.request.query_params.get('store_id')
        if store_id:
            queryset = queryset.filter(store_id=store_id)
        
        # Only root categories
        root_only = self.request.query_params.get('root_only')
        if root_only and root_only.lower() == 'true':
            queryset = queryset.filter(parent_category__isnull=True)
        
        return queryset
    
    @action(detail=True, methods=['get'])
    def products(self, request, pk=None):
        """Get all products in this category and its subcategories"""
        category = self.get_object()
        products = Product.objects.filter(
            Q(category=category) |
            Q(category__parent_category=category)
        ).distinct()
        
        serializer = ProductListSerializer(products, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def subcategories(self, request, pk=None):
        """Get all subcategories of this category"""
        category = self.get_object()
        subcategories = category.subcategories.all()
        serializer = ProductCategorySerializer(subcategories, many=True)
        return Response(serializer.data)
