from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from core.interface.api.serializer.welcom_asset_serializers import (
    CompanyAssetSerializer,
    StoreAssetSerializer,
    TaskAssetSerializer
)
from core.infrastructure.factories.welcom_factory import CoreWelcomeFactory

class WelcomeAssetViewSet(viewsets.ViewSet):
    """ViewSet for welcome asset operations"""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.welcome_asset_service = CoreWelcomeFactory.create_welcome_asset_service()

    @action(detail=False, methods=['get'], permission_classes=[AllowAny], url_path='company-asset')
    def get_company_asset(self, request):
        
        # Get company asset and get Result object
        result = self.welcome_asset_service.get_company_asset()
        
        # Check if operation was successful
        if result.is_success():
            # On success, return the tokens
            serialized_data = CompanyAssetSerializer(result.value).data
            return Response(serialized_data, status=status.HTTP_200_OK)
        else:
            # If operation failed, raise the exception from the Result
            # This will be caught by the global exception handler
            if hasattr(result.error, '__call__'):
                # If it's a callable (like a function), call it
                raise result.error
            else:
                # Otherwise, raise it directly
                raise result.error
    
    @action(detail=False, methods=['get'], permission_classes=[AllowAny], url_path='store-assets')
    def get_store_assets(self, request):
        
        result = self.welcome_asset_service.get_store_assets()
        
        if result.is_success():
            serialized_data = StoreAssetSerializer(result.value).data
            return Response(serialized_data, status=status.HTTP_200_OK)
        else:
            if hasattr(result.error, '__call__'):
                raise result.error
            else:
                raise result.error
    
    @action(detail=False, methods=['get'], permission_classes=[AllowAny], url_path='task-assets')
    def get_task_assets(self, request):
        
        result = self.welcome_asset_service.get_task_assets()
        
        if result.is_success():
            serialized_data = TaskAssetSerializer(result.value).data
            return Response(serialized_data, status=status.HTTP_200_OK)
        else:
            if hasattr(result.error, '__call__'):
                raise result.error
            else:
                raise result.error
    
