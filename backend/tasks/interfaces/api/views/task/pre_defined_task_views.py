from rest_framework import viewsets, status
from rest_framework.decorators import action, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
import uuid

from .....infrastructure.factory import ServiceFactory
from ...serializers import (
    PredefinedTaskTypeSerializer,
    TaskSerializer,
    TaskCategorySerializer
)

class PredefinedTaskViewSet(viewsets.ViewSet):
    """ViewSet for predefined tasks"""
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.predefined_type_service = ServiceFactory.get_predefined_type_service()
        self.task_category_service = ServiceFactory.get_task_category_service()
        self.task_service = ServiceFactory.get_task_service()

    def get_permissions(self):
        """Allow anyone to retrieve, list predefined tasks, or view categories"""
        if self.action in ['list', 'retrieve', 'get_all_categories', 'tasks_by_category']:
            return [AllowAny()]
        elif self.action == 'create':
            return [IsAdminUser()]
        return [IsAuthenticated()]

    def list(self, request):
        """Get all predefined task types
        
        Endpoint: GET /api/predefined-tasks/
        
        Returns a list of all predefined task types.
        This endpoint is publicly accessible (no authentication required).
        """
        predefined_types = self.predefined_type_service.get_all_predefined_tasks()
        serializer = PredefinedTaskTypeSerializer(predefined_types, many=True)
        return Response(serializer.data)
    
    def retrieve(self, request, pk=None):
        """Get a specific predefined task by ID
        
        Endpoint: GET /api/predefined-tasks/{pk}/
        
        Returns details of a specific predefined task type.
        """
        try:
            predefined_task_id = uuid.UUID(pk)
            predefined_type = self.predefined_type_service.get_predefined_task_by_id(predefined_task_id)
            
            if not predefined_type:
                return Response(
                    {"error": "Predefined task type not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Use the PredefinedTaskTypeSerializer to convert the domain entity to a response
            serializer = PredefinedTaskTypeSerializer(predefined_type)
            return Response(serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid predefined task type ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, url_path='categorie/(?P<category_id>[^/.]+)/tasks', methods=["get"])
    def tasks_by_category(self, request, category_id=None):
        """Get all tasks for a specific category
        
        Endpoint: GET /api/predefined-tasks/categorie/{category_id}/tasks/
        
        Returns a list of all tasks that belong to the specified category.
        This endpoint is publicly accessible (no authentication required).
        """
        try:
            category_id = uuid.UUID(category_id)
            
            # First check if the category exists
            category = self.task_category_service.get_category_by_id(category_id)
            if not category:
                return Response(
                    {"error": "Category not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Get all tasks for this category
            tasks = self.task_service.get_tasks_by_category_id(category_id)
            
            # Serialize the tasks
            serializer = TaskSerializer(tasks, many=True)
            
            return Response(serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid category ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, url_path='categories', methods=["get"])
    def get_all_categories(self, request):
        """Get all task categories that have predefined tasks
        
        Endpoint: GET /api/predefined-tasks/categories/
        
        Returns a list of all task categories that have associated predefined tasks.
        This endpoint is publicly accessible (no authentication required).
        """
        categories = self.predefined_type_service.get_all_categories()
        serializer = TaskCategorySerializer(categories, many=True)
        return Response(serializer.data)