from typing import Dict, List, Optional, Union

from django.db.models import Count, QuerySet
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.request import Request
from rest_framework.response import Response

from store.models import Store
from store.serializers import StoreListSerializer, StoreDetailSerializer
from .product_views import ProductAvailabilityMixin
from .delivery_views import DeliveryMixin

class StoreViewSet(viewsets.ModelViewSet, ProductAvailabilityMixin, DeliveryMixin):
    """Main ViewSet for Store operations with type hints"""
    queryset: QuerySet = Store.objects.annotate(
        total_products=Count('products', distinct=True)
    )
    serializer_class = StoreListSerializer
    # permission_classes = [IsAuthenticated]

    def get_serializer_class(self) -> StoreListSerializer:
        """Dynamic serializer selection with type hints"""
        if self.action == 'retrieve':
            return StoreDetailSerializer
        return StoreListSerializer

    @action(detail=True, methods=['get'])
    def get_product(self, request: Request, pk: Optional[str] = None) -> Response:
        """
        Retrieve a specific product within a store
        
        :param request: HTTP request object
        :param pk: Store UUID
        :return: Response with product details or error
        """
        try:
            # Validate store exists
            store: Store = Store.objects.get(id=pk)
        except Store.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Store not found',
                'errors': f'No store found with ID: {pk}'
            }, status=status.HTTP_404_NOT_FOUND)

        # Get product_id from URL or query parameters
        product_id: Optional[str] = request.query_params.get('product_id') or self.kwargs.get('product_uuid')
        
        if not product_id:
            return Response({
                'success': False,
                'message': 'Product ID is required',
                'errors': 'No product_id provided in URL or query parameters'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Validate product exists
            from product.models import Product, StoreProduct
            product: Product = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Product not found',
                'errors': f'No product found with ID: {product_id}'
            }, status=status.HTTP_404_NOT_FOUND)

        try:
            # Check if product is in this specific store
            store_product: StoreProduct = StoreProduct.objects.get(
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
        product_data: Dict[str, Union[bool, Dict[str, Optional[Union[str, float, int, bool]]]]] = {
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
    def full_details(self, request: Request) -> Response:
        """Get all stores with their categories and products"""
        stores: QuerySet = self.get_queryset()
        
        # Optional filters
        is_open: Optional[str] = request.query_params.get('is_open')
        if is_open is not None:
            is_open = is_open.lower() in ['true', '1', 'yes']
            stores = stores.filter(is_open=is_open)
            
        response_data: List[Dict[str, Union[str, int, bool, List[Dict[str, Union[str, int, bool]]]]]] = []
        for store in stores:
            # Get categories for this store
            categories: QuerySet = store.categories.filter(parent_category__isnull=True)
            categories_data: List[Dict[str, Union[str, int, bool, List[Dict[str, Union[str, int, bool]]]]]] = []
            
            for category in categories:
                # Get subcategories
                subcategories: QuerySet = category.subcategories.all()
                subcategories_data: List[Dict[str, Union[str, int, bool]]] = []
                
                for subcategory in subcategories:
                    # Get products in subcategory for this store
                    products: QuerySet = subcategory.products.filter(
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
                main_products: QuerySet = category.products.filter(
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
            store_data: Dict[str, Union[str, int, bool, List[Dict[str, Union[str, int, bool]]]]] = {
                'id': str(store.id),
                'name': store.name,
                'description': store.description,
                'logo_url': request.build_absolute_uri(store.logo_url.url) if store.logo_url else None,
                'rating': str(store.rating),
                'total_reviews': store.total_reviews,
                'is_open': store.is_open,
                'is_big_store': store.is_big_store,
                'is_currently_open': store.is_currently_open(),
                'delivery_type': store.delivery_type,
                'delivery_fee': float(store.delivery_fee),
                'minimum_order': float(store.minimum_order),
                'categories': categories_data
            }
            
            response_data.append(store_data)
        
        return Response(response_data)

    @action(detail=False, methods=['get'])
    def debug_uuids(self, request: Request) -> Response:
        """
        Debug method to retrieve UUIDs for stores, products, and their associations
        
        :param request: HTTP request object
        :return: Response with UUID information
        """
        from product.models import Product, StoreProduct
        
        # Get store UUIDs
        stores: QuerySet = self.get_queryset()
        store_uuids: List[str] = [str(store.id) for store in stores]
        
        # Get product UUIDs
        products: QuerySet = Product.objects.all()
        product_uuids: List[str] = [str(product.id) for product in products]
        
        # Get store-product associations
        store_product_associations: List[Dict[str, Union[str, int, bool]]] = []
        for sp in StoreProduct.objects.all():
            store_product_associations.append({
                'store_id': str(sp.store.id),
                'store_name': sp.store.name,
                'product_id': str(sp.product.id),
                'product_name': sp.product.name,
                'stock': sp.stock,
                'is_available': sp.stock > 0
            })
        
        return Response({
            'stores': {
                'total_count': len(store_uuids),
                'uuids': store_uuids
            },
            'products': {
                'total_count': len(product_uuids),
                'uuids': product_uuids
            },
            'store_product_associations': {
                'total_count': len(store_product_associations),
                'associations': store_product_associations
            }
        })
