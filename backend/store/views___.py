from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from drf_spectacular.utils import extend_schema, OpenApiParameter
from django.db.models import Count
from .models import Store
from .serializers import StoreListSerializer, StoreDetailSerializer
from product.models import Product, StoreProduct


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
        
        # Filter stores by product
        product_id = request.query_params.get('product_id')
        if product_id:
            # Remove angle brackets and whitespace
            product_id = product_id.strip('<>').strip()
            
            try:
                # Verify the product exists first
                Product.objects.get(id=product_id)
                
                # Filter stores that have the specific product
                queryset = queryset.filter(
                    storeproduct__product_id=product_id
                ).distinct()
                
                # If no stores found, return an empty list instead of an error
                if not queryset.exists():
                    return Response([], status=status.HTTP_200_OK)
            
            except Product.DoesNotExist:
                # If product doesn't exist, return an empty list
                return Response([], status=status.HTTP_200_OK)
        
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

    @action(detail=True, methods=['get'])
    def get_product(self, request, pk=None):
        """
        Retrieve a specific product within a store
        URL: /api/v1/stores/{store_uuid}/get_product/{product_uuid}/
        """
        try:
            # Validate store exists
            store = Store.objects.get(id=pk)
        except Store.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Store not found',
                'errors': f'No store found with ID: {pk}'
            }, status=status.HTTP_404_NOT_FOUND)

        # Get product_id from URL or query parameters
        product_id = request.query_params.get('product_id') or self.kwargs.get('product_uuid')
        
        if not product_id:
            return Response({
                'success': False,
                'message': 'Product ID is required',
                'errors': 'No product_id provided in URL or query parameters'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Validate product exists
            from product.models import Product, StoreProduct
            product = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Product not found',
                'errors': f'No product found with ID: {product_id}'
            }, status=status.HTTP_404_NOT_FOUND)

        try:
            # Check if product is in this specific store
            store_product = StoreProduct.objects.get(
                store=store, 
                product=product
            )
        except StoreProduct.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Product not available in this store',
                'errors': f'Product {product.name} is not sold in store {store.name}'
            }, status=status.HTTP_404_NOT_FOUND)

        # Prepare detailed product information
        product_data = {
            'success': True,
            'store': {
                'id': str(store.id),
                'name': store.name
            },
            'product': {
                'id': str(product.id),
                'name': product.name,
                'description': product.description,
                'category': str(product.category.name) if product.category else None,
                'image_url': request.build_absolute_uri(product.image_url.url) if product.image_url else None,
                'unit': product.unit,
                'is_seasonal': product.is_seasonal
            },
            'store_product_details': {
                'price': float(store_product.price),
                'discount_price': float(store_product.discount_price) if store_product.discount_price else None,
                'stock': store_product.stock,
                'is_available': store_product.stock > 0,
                'position_in_store': store_product.position_in_store,
                'discount_end_date': store_product.discount_end_date
            }
        }

        return Response(product_data)

    @action(detail=False, methods=['get'])
    def product_availability(self, request):
        """Get product availability across stores"""
        product_id = request.query_params.get('product_id')
        if not product_id:
            return Response({
                'success': False,
                'message': 'Product ID is required',
                'errors': 'No product_id provided in query parameters'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Get the product based on the ID
            product = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Product not found',
                'errors': f'No product found with ID: {product_id}'
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({
                'success': False,
                'message': 'An error occurred while fetching the product',
                'errors': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Find stores where the product is available (via StoreProduct model)
        store_products = StoreProduct.objects.filter(product=product)

        # If no store products found
        if not store_products.exists():
            return Response({
                'success': False,
                'message': 'Product not available in any store',
                'errors': f'No store products found for product: {product.name}'
            }, status=status.HTTP_404_NOT_FOUND)

        store_availability = []
        for store_product in store_products:
            store = store_product.store
            store_data = {
                'store_id': str(store.id),
                'store_name': store.name,
                'is_available': store_product.stock > 0,  # Check stock to determine availability
                'stock': store_product.stock,  # Show available stock
                'price': float(store_product.price),
                'discount_price': float(store_product.discount_price) if store_product.discount_price else None
            }
            store_availability.append(store_data)

        return Response({
            'success': True,
            'product_id': str(product.id),
            'product_name': product.name,
            'store_availability': store_availability
        })

    @action(detail=False, methods=['get'])
    def full_details(self, request):
        """Get all stores with their categories and products"""
        stores = self.get_queryset()
        
        # Optional filters
        is_open = request.query_params.get('is_open')
        if is_open is not None:
            is_open = is_open.lower() in ['true', '1', 'yes']
            stores = stores.filter(is_open=is_open)
            
        response_data = []
        for store in stores:
            # Get categories for this store
            categories = store.categories.filter(parent_category__isnull=True)
            categories_data = []
            
            for category in categories:
                # Get subcategories
                subcategories = category.subcategories.all()
                subcategories_data = []
                
                for subcategory in subcategories:
                    # Get products in subcategory for this store
                    products = subcategory.products.filter(
                        storeproduct__store=store
                    ).distinct()
                    
                    subcategories_data.append({
                        'id': str(subcategory.id),
                        'name': subcategory.name,
                        'description': subcategory.description,
                        'products': [{
                            'id': str(product.id),
                            'name': product.name,
                            'description': product.description,
                            'image_url': request.build_absolute_uri(product.image_url.url) if product.image_url else None,
                            'unit': product.unit,
                            'is_seasonal': product.is_seasonal,
                            'store_details': {
                                'price': float(product.storeproduct_set.get(store=store).price),
                                'stock': product.storeproduct_set.get(store=store).stock,
                                'is_available': product.storeproduct_set.get(store=store).is_available,
                                'position': product.storeproduct_set.get(store=store).position_in_store
                            }
                        } for product in products]
                    })
                
                # Get products directly in main category
                main_products = category.products.filter(
                    storeproduct__store=store
                ).distinct()
                
                categories_data.append({
                    'id': str(category.id),
                    'name': category.name,
                    'description': category.description,
                    'products': [{
                        'id': str(product.id),
                        'name': product.name,
                        'description': product.description,
                        'image_url': request.build_absolute_uri(product.image_url.url) if product.image_url else None,
                        'unit': product.unit,
                        'is_seasonal': product.is_seasonal,
                        'store_details': {
                            'price': float(product.storeproduct_set.get(store=store).price),
                            'stock': product.storeproduct_set.get(store=store).stock,
                            'is_available': product.storeproduct_set.get(store=store).is_available,
                            'position': product.storeproduct_set.get(store=store).position_in_store
                        }
                    } for product in main_products],
                    'subcategories': subcategories_data
                })
            
            # Store details with categories
            store_data = {
                'id': str(store.id),
                'name': store.name,
                'description': store.description,
                'logo_url': request.build_absolute_uri(store.logo_url.url) if store.logo_url else None,
                'rating': str(store.rating),
                'total_reviews': store.total_reviews,
                'is_open': store.is_open,
                'is_currently_open': store.is_currently_open(),
                'delivery_type': store.delivery_type,
                'delivery_fee': float(store.delivery_fee),
                'minimum_order': float(store.minimum_order),
                'categories': categories_data
            }
            
            response_data.append(store_data)
        
        return Response(response_data)
