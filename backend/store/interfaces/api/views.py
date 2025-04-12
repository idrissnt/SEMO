from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
import uuid

from store.interfaces.api.serializers import (
    ProductNameSerializer,
    StoreBrandSerializer, 
    ProductWithDetailsSerializer,
    SearchResultsByStoreSerializer
)

# Factory imports for dependency injection
from store.infrastructure.factory import StoreFactory


class StoreBrandLocationViewSet(viewsets.ViewSet):
    """API endpoint for store brands and locations"""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.store_brand_location_service = StoreFactory.create_store_brand_location_service()

    def list(self, request):
        """Get all store brands
        url: stores/store-brands/
        method: GET"""
        return Response([])

    @action(detail=False, methods=['get'], url_path='nearby-stores')
    def nearby_stores(self, request):
        """Find for each store brand the nearest store using the user's address
        url: stores/store-brands/nearby-stores/
        method: GET
        query parameters: address (optional), radius (optional), brand_slugs (optional)"""
        # Get parameters from request
        address = request.query_params.get('address', '')
        radius = request.query_params.get('radius', '5.0')
        # brand_slugs = request.query_params.getlist('brand_slugs', None)
        
        try:
            radius_km = float(radius)
        except ValueError:
            return Response({"error": "Invalid radius value"}, 
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Find by address
        nearby_brands = self.store_brand_location_service.find_nearby_store_brands_by_address(
            address=address,
            radius_km=radius_km,
            # brand_slugs=brand_slugs if brand_slugs else None
        )
        
        serializer = StoreBrandSerializer(nearby_brands, many=True)
        return Response(serializer.data)
    
class StoreProductViewSet(viewsets.ViewSet):
    """API endpoint for store products"""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.store_products_service = StoreFactory.create_store_products_service()
    
    def list(self, request):
        """Get all products
        url: stores/store-products/
        method: GET"""
        return Response([])

    @action(detail=False, methods=['get'], url_path='all-products')
    def all_products(self, request):
        """List products for a specific store
        url: stores/store-products/all-products/
        method: GET
        query parameters: store_id (required)"""
        store_id = request.query_params.get('store_id')
        if not store_id:
            return Response(
                {"error": "store_id query parameter is required"},  
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            store_uuid = uuid.UUID(store_id)
        except ValueError:
            return Response({"error": "Invalid UUID format"}, 
                            status=status.HTTP_400_BAD_REQUEST)
            
        products = self.store_products_service.get_products_by_store_id(store_uuid)
        serializer = ProductWithDetailsSerializer(products, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], url_path='by-category')
    def products_by_category(self, request):
        """Get products by category slugs
        url: stores/store-products/by-category/
        method: GET
        query parameters: category_path (optional)"""
        category_path = request.query_params.get('category_path', '')
        store_id = request.query_params.get('store_id')
        
        store_uuid = None
        if store_id:
            try:
                store_uuid = uuid.UUID(store_id)
            except ValueError:
                return Response({"error": "Invalid UUID format"}, 
                                status=status.HTTP_400_BAD_REQUEST)
                
        products_by_category = self.store_products_service.get_products_by_category_path(
            category_path=category_path,
            store_brand_id=store_uuid
        )
        
        result = ProductWithDetailsSerializer(products_by_category, many=True)
        return Response(result.data)


class SearchViewSet(viewsets.ViewSet):
    """API endpoint for search functionality"""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.search_service = StoreFactory.create_search_products_service()
    
    def list(self, request):
        """Get all products
        url: stores/search/
        method: GET"""
        return Response([])

    @action(detail=False, methods=['get'])
    def autocomplete(self, request):
        """Get autocomplete suggestions for a partial search query
        url: stores/search/autocomplete/
        method: GET
        query parameters: q (required)"""
        query = request.query_params.get('q', '')
            
        suggestions = self.search_service.autocomplete_query(
            partial_query=query
        )

        serializer = ProductNameSerializer(suggestions, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def products(self, request):
        """Search for products globally or within a specific store
        url: stores/search/products/
        method: GET
        query parameters: q (required), page (default=1), page_size (default=10), store_id (optional)"""
        query = request.query_params.get('q', '')
        store_id = request.query_params.get('store_id')
        page = request.query_params.get('page', '1')
        page_size = request.query_params.get('page_size', '10')
        
        if not query:
            return Response(
                {"error": "Search query (q) is required"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Parse pagination parameters
        try:
            page = int(page)
            page_size = int(page_size)
            if page < 1 or page_size < 1:
                raise ValueError("Invalid pagination values")
        except ValueError:
            return Response(
                {"error": "Invalid pagination parameters"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Create pagination params
        from backend.store.domain.value_objects.pagination import PaginationParams
        pagination = PaginationParams(page=page, page_size=page_size)
                
        # Parse store_id if provided
        store_uuid = None
        if store_id:
            try:
                store_uuid = uuid.UUID(store_id)
            except ValueError:
                return Response({"error": "Invalid UUID format"}, 
                                status=status.HTTP_400_BAD_REQUEST)
        
        # Use the search_products method with pagination - now returns (results, metadata)
        result, metadata = self.search_service.search_products(
            query=query,
            store_id=store_uuid,
            pagination=pagination
        )

        # Use different serializers based on whether this is a global or store-specific search
        if store_uuid:
            # Store-specific search returns a list of products
            serializer = ProductWithDetailsSerializer(result, many=True)
            data = serializer.data
            
            # Calculate total pages for store-specific search using the metadata
            total_count = metadata['total_count']
            total_pages = (total_count + pagination.limit - 1) // pagination.limit
        else:
            # Global search returns products grouped by store
            serializer = SearchResultsByStoreSerializer(result)
            data = serializer.data
            
            # For global search, calculate pages for each store using the metadata
            total_pages = {}
            store_counts = metadata['store_counts']
            
            for store_id, count in store_counts.items():
                store_total_pages = (count + pagination.limit - 1) // pagination.limit
                total_pages[store_id] = store_total_pages
        
        # Add pagination metadata to the response
        response_data = {
            'results': data,
            'pagination': {
                'current_page': page,
                'page_size': page_size,
                'total_pages': total_pages
            }
        }
            
        return Response(response_data)
    
    