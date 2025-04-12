from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from django.db import transaction
import uuid

from store.infrastructure.factory import StoreFactory
from .collection_serializers import (
    ProductCollectionBatchSerializer,
    CollectedProductSerializer,
    BatchCreateSerializer,
    ProductCreateSerializer,
    BulkProductCreateSerializer,
    BatchStatusUpdateSerializer
)

class ProductCollectionViewSet(viewsets.ViewSet):
    """ViewSet for product collection operations"""
    permission_classes = [IsAdminUser]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.collection_service = StoreFactory.create_product_collection_service()
    
    def create(self, request):
        """Create a new collection batch"""
        serializer = BatchCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            batch = self.collection_service.create_collection_batch(
                store_brand_id=serializer.validated_data['store_brand_id'],
                collector_id=request.user.id,
                name=serializer.validated_data['name']
            )
            
            response_serializer = ProductCollectionBatchSerializer(batch)
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'], url_path='add-product')
    def add_product(self, request, pk=None):
        """Add a product to a collection batch
        url: /product-collections/{pk}/add-product/"""
        serializer = ProductCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Verify batch belongs to user
            batch = self.collection_service.batch_repository.get_batch_by_id(uuid.UUID(pk))
            if not batch or str(batch.collector_id) != str(request.user.id):
                return Response(
                    {"error": "Batch not found or you don't have permission to access it"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Add product
            product = self.collection_service.add_product_to_batch(
                batch_id=uuid.UUID(pk),
                product_data=serializer.validated_data
            )
            
            response_serializer = CollectedProductSerializer(product)
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'], url_path='bulk-add-products')
    def bulk_add_products(self, request, pk=None):
        """Add multiple products to a collection batch
        
        url: /product-collections/{pk}/bulk-add-products/
        method: POST
        body: JSON array of product data
        """
        serializer = BulkProductCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Verify batch belongs to user
            batch = self.collection_service.batch_repository.get_batch_by_id(uuid.UUID(pk))
            if not batch or str(batch.collector_id) != str(request.user.id):
                return Response(
                    {"error": "Batch not found or you don't have permission to access it"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Add products
            with transaction.atomic():
                products = self.collection_service.bulk_add_products(
                    batch_id=uuid.UUID(pk),
                    products_data=serializer.validated_data['products']
                )
            
            response_serializer = CollectedProductSerializer(products, many=True)
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'], url_path='update-status')
    def update_status(self, request, pk=None):
        """Update the status of a collection batch
        
        url: /product-collections/{pk}/update-status/
        """
        serializer = BatchStatusUpdateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Verify batch belongs to user
            batch = self.collection_service.batch_repository.get_batch_by_id(uuid.UUID(pk))
            if not batch or str(batch.collector_id) != str(request.user.id):
                return Response(
                    {"error": "Batch not found or you don't have permission to access it"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Update status
            success = self.collection_service.update_batch_status(
                batch_id=uuid.UUID(pk),
                status=serializer.validated_data['status']
            )
            
            if not success:
                return Response(
                    {"error": "Failed to update batch status"},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
            
            # Get updated batch
            updated_batch = self.collection_service.batch_repository.get_batch_by_id(uuid.UUID(pk))
            response_serializer = ProductCollectionBatchSerializer(updated_batch)
            
            return Response(response_serializer.data)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'])
    def process(self, request, pk=None):
        """Process a completed batch to create actual products
        
        url: /product-collections/{pk}/process/
        method: POST
        """
        try:
            # Verify batch belongs to user
            batch = self.collection_service.batch_repository.get_batch_by_id(uuid.UUID(pk))
            if not batch or str(batch.collector_id) != str(request.user.id):
                return Response(
                    {"error": "Batch not found or you don't have permission to access it"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Process batch
            success_count, error_count, error_messages = self.collection_service.process_batch(uuid.UUID(pk))
            
            return Response({
                "success_count": success_count,
                "error_count": error_count,
                "error_messages": error_messages
            })
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
