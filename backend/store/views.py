from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from drf_spectacular.utils import extend_schema, OpenApiParameter
from django.db.models import Count
from .models import Store
from .serializers import StoreListSerializer, StoreDetailSerializer

# Create your views here.

@extend_schema(tags=['Stores'])
class StoreViewSet(ModelViewSet):
    queryset = Store.objects.all()
    
    def get_serializer_class(self):
        if self.action == 'list':
            return StoreListSerializer
        return StoreDetailSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    def list(self, request, *args, **kwargs):
        """List stores with optional filtering"""
        queryset = self.get_queryset()
        
        # Filter by is_big_store
        is_big_store = request.query_params.get('is_big_store')
        if is_big_store is not None:
            # Convert string to boolean
            is_big_store = is_big_store.lower() in ['true', '1', 'yes']
            queryset = queryset.filter(is_big_store=is_big_store)
        
        # Optional additional filters
        is_open = request.query_params.get('is_open')
        if is_open is not None:
            is_open = is_open.lower() in ['true', '1', 'yes']
            queryset = queryset.filter(is_open=is_open)
        
        # Serialize and return
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
    
    @extend_schema(
        parameters=[
            OpenApiParameter(name='lat', type=float, required=True),
            OpenApiParameter(name='lng', type=float, required=True),
            OpenApiParameter(name='radius', type=float, required=False, default=5.0)
        ]
    )
    @action(detail=False, methods=['get'])
    def nearby(self, request):
        """Get stores near a specific location"""
        lat = float(request.query_params.get('lat', 0))
        lng = float(request.query_params.get('lng', 0))
        radius = float(request.query_params.get('radius', 5.0))
        
        # Filter stores within radius (simplified version)
        stores = Store.objects.filter(
            latitude__range=(lat - radius, lat + radius),
            longitude__range=(lng - radius, lng + radius),
            is_open=True
        )
        
        serializer = StoreListSerializer(stores, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def popular(self, request):
        """Get popular stores based on rating and number of products"""
        stores = Store.objects.annotate(
            product_count=Count('products')
        ).filter(
            rating__gte=4.0,
            product_count__gte=10,
            is_open=True
        ).order_by('-rating', '-product_count')[:10]
        
        serializer = StoreListSerializer(stores, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def categories(self, request, pk=None):
        """Get store categories with their products"""
        store = self.get_object()
        categories = store.categories.filter(parent_category__isnull=True)
        from product.serializers import ProductCategorySerializer
        serializer = ProductCategorySerializer(categories, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def popular_products(self, request, pk=None):
        """Get popular products in the store"""
        store = self.get_object()
        products = store.get_popular_products(limit=10)
        from product.serializers import ProductListSerializer
        serializer = ProductListSerializer(products, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def rate(self, request, pk=None):
        """Rate a store"""
        store = self.get_object()
        rating = request.data.get('rating')
        
        try:
            rating = float(rating)
            if not (1.0 <= rating <= 5.0):
                raise ValueError
        except (TypeError, ValueError):
            return Response(
                {'error': 'Rating must be a number between 1 and 5'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        store.update_rating(rating)
        return Response({'status': 'success'})
    
    @action(detail=True, methods=['get'])
    def delivery_estimate(self, request, pk=None):
        """Get delivery time estimate for the store"""
        store = self.get_object()
        return Response({
            'delivery_time': store.get_delivery_time_estimate(),
            'preparation_time': store.preparation_time
        })
