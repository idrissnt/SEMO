from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from ....infrastructure.factory import ServiceFactory
from ..serializers import (
    TaskSerializer,
    TaskCreateSerializer,
    TaskSearchSerializer,
    TaskCategoryTemplateSerializer
)


class TaskViewSet(viewsets.ViewSet):
    """ViewSet for tasks"""
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.task_application_service = ServiceFactory.get_task_application_service()
    
    def list(self, request):
        """Get all tasks created by the authenticated user"""
        requester_id = uuid.UUID(str(request.user.id))
        tasks = self.task_application_service.get_tasks_by_requester(requester_id)
        return Response(tasks)
    
    def retrieve(self, request, pk=None):
        """Get a task by ID"""
        try:
            task_id = uuid.UUID(pk)
            task = self.task_application_service.get_task_by_id(task_id)
            if not task:
                return Response(
                    {"error": "Task not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            return Response(task)
        except ValueError:
            return Response(
                {"error": "Invalid task ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def create(self, request):
        """Create a new task"""
        serializer = TaskCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            requester_id = uuid.UUID(str(request.user.id))
            task = self.task_application_service.create_task(
                requester_id=requester_id,
                category=serializer.validated_data["category"],
                title=serializer.validated_data["title"],
                description=serializer.validated_data["description"],
                location_address_id=serializer.validated_data["location_address_id"],
                budget=float(serializer.validated_data["budget"]),
                scheduled_date=serializer.validated_data["scheduled_date"],
                attribute_answers=serializer.validated_data["attribute_answers"]
            )
            return Response(task, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=["post"])
    def publish(self, request, pk=None):
        """Publish a task"""
        try:
            task_id = uuid.UUID(pk)
            requester_id = uuid.UUID(str(request.user.id))
            task = self.task_application_service.publish_task(task_id, requester_id)
            return Response(task)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=["post"])
    def cancel(self, request, pk=None):
        """Cancel a task"""
        try:
            task_id = uuid.UUID(pk)
            user_id = uuid.UUID(str(request.user.id))
            task = self.task_application_service.cancel_task(task_id, user_id)
            return Response(task)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["get"])
    def categories(self, request):
        """Get all task categories with their templates"""
        categories = self.task_application_service.get_task_categories()
        return Response(categories)
    
    @action(detail=False, methods=["post"])
    def search(self, request):
        """Search for tasks near a location"""
        serializer = TaskSearchSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        tasks = self.task_application_service.search_tasks(
            latitude=serializer.validated_data["latitude"],
            longitude=serializer.validated_data["longitude"],
            radius_km=serializer.validated_data["radius_km"],
            category=serializer.validated_data.get("category")
        )
        return Response(tasks)
