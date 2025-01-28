from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response

from product.models import Product, StoreProduct

class ProductAvailabilityMixin:
    """Mixin for product-related store operations"""

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
