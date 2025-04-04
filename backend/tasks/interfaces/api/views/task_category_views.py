"""
API views for task categories.
"""
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
import uuid

from infrastructure.factory import ServiceFactory
from serializers.task_category_serializer import TaskCategorySerializer
from serializers import TaskSerializer


class TaskCategoryViewSet(viewsets.ViewSet):
    """ViewSet for task categories
    
    This ViewSet provides endpoints for managing task categories,
    including listing all categories, retrieving a specific category,
    and creating/updating/deleting categories.
    """
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.task_category_service = ServiceFactory.get_task_category_service()
    
    def list(self, request):
        """Get all task categories
        
        Endpoint: GET /api/categories/
        
        This endpoint returns all task categories with their UI details
        like images, icons, and colors.
        """
        categories = self.task_category_service.get_all_categories()
        serializer = TaskCategorySerializer(categories, many=True)
        return Response(serializer.data)
    
    def retrieve(self, request, pk=None):
        """Get a specific task category by ID
        
        Endpoint: GET /api/categories/{pk}/
        
        Args:
            pk: UUID of the category to retrieve
        """
        try:
            category_id = uuid.UUID(pk)
            category = self.task_category_service.get_category_by_id(category_id)
            
            if not category:
                return Response(
                    {"error": "Category not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            serializer = TaskCategorySerializer(category)
            return Response(serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid category ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def create(self, request):
        """Create a new task category
        
        Endpoint: POST /api/categories/
        """
        serializer = TaskCategorySerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        category = self.task_category_service.create_category(serializer.validated_data)
        response_serializer = TaskCategorySerializer(category)
        return Response(
            response_serializer.data,
            status=status.HTTP_201_CREATED
        )
    
    def update(self, request, pk=None):
        """Update an existing task category
        
        Endpoint: PUT /api/categories/{pk}/
        
        Args:
            pk: UUID of the category to update
        """
        try:
            category_id = uuid.UUID(pk)
            serializer = TaskCategorySerializer(data=request.data)
            
            if not serializer.is_valid():
                return Response(
                    serializer.errors,
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            category = self.task_category_service.update_category(
                category_id, serializer.validated_data
            )
            
            if not category:
                return Response(
                    {"error": "Category not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            response_serializer = TaskCategorySerializer(category)
            return Response(response_serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid category ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def destroy(self, request, pk=None):
        """Delete a task category
        
        Endpoint: DELETE /api/categories/{pk}/
        
        Args:
            pk: UUID of the category to delete
        """
        try:
            category_id = uuid.UUID(pk)
            success = self.task_category_service.delete_category(category_id)
            
            if not success:
                return Response(
                    {"error": "Category not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            return Response(status=status.HTTP_204_NO_CONTENT)
        except ValueError:
            return Response(
                {"error": "Invalid category ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
            
    @action(detail=True, methods=["get"])
    def tasks(self, request, pk=None):
        """Get all tasks for a specific category
        
        Endpoint: GET /api/categories/{pk}/tasks/
        
        This endpoint returns all tasks that belong to a specific category.
        
        Args:
            pk: UUID of the category
        """
        try:
            category_id = uuid.UUID(pk)
            
            # First check if the category exists
            category = self.task_category_service.get_category_by_id(category_id)
            if not category:
                return Response(
                    {"error": "Category not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Get the task application service to fetch tasks
            task_service = ServiceFactory.get_task_application_service()
            
            # Get all tasks for this category
            tasks = task_service.get_tasks_by_category_id(category_id)
            
            # Serialize the tasks
            serializer = TaskSerializer(tasks, many=True)
            
            return Response(serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid category ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
