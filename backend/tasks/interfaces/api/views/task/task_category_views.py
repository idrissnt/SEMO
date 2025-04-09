"""
API views for task categories.
"""
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
import uuid

from .....infrastructure.factory import ServiceFactory
from ...serializers import TaskCategorySerializer
from ...serializers import TaskSerializer


class TaskCategoryViewSet(viewsets.ViewSet):
    """ViewSet for task categories
    
    This ViewSet provides endpoints for managing task categories,
    including listing all categories, retrieving a specific category,
    and creating/updating/deleting categories.
    """
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.task_category_service = ServiceFactory.get_task_category_service()
    
    def get_permissions(self):
        """Allow anyone to retrieve or list categories, to get tasks by category or tasks by category id
        Allow only admin to create categories
        other actions require authentication"""
        if self.action == 'list' or self.action == 'retrieve':
            return [AllowAny()]
        elif self.action == 'create':
            return [IsAdminUser()]
        return [IsAuthenticated()]

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

    @action(detail=True, methods=["get"], url_path="tasks", permission_classes=[AllowAny])
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
    
    @action(detail=True, url_path='task-detail/(?P<task_id>[^/.]+)', methods=["get"], permission_classes=[AllowAny])
    def task_detail(self, request, pk=None, task_id=None):
        """Get a single task in a specific category
        
        Endpoint: GET /api/categories/{pk}/task-detail/{task_id}/
        
        This endpoint returns a specific task that belongs to a specific category.
        It verifies both that the category exists and that the task belongs to that category.
        
        Args:
            pk: UUID of the category
            task_id: UUID of the task
        """
        try:
            category_id = uuid.UUID(pk)
            task_id = uuid.UUID(task_id)
            
            # First check if the category exists
            category = self.task_category_service.get_category_by_id(category_id)
            if not category:
                return Response(
                    {"error": "Category not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Get the task application service to fetch the task
            task_service = ServiceFactory.get_task_application_service()
            
            # Get the specific task
            task = task_service.get_task_by_id(task_id)
            
            # Check if task exists
            if not task:
                return Response(
                    {"error": "Task not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
                
            # Check if task belongs to the specified category
            if str(task.category_id) != str(category_id):
                return Response(
                    {"error": "Task does not belong to the specified category"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Serialize the task
            serializer = TaskSerializer(task)
            
            return Response(serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid category ID or task ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
