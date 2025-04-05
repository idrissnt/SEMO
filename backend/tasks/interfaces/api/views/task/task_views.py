from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from infrastructure.factory import ServiceFactory
from serializers import (
    TaskSerializer,
    TaskCreateSerializer,
    TaskSearchSerializer,
)


class TaskViewSet(viewsets.ViewSet):
    """ViewSet for tasks"""
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.task_application_service = ServiceFactory.get_task_application_service()
    
    @action(detail=False, methods=["get"])
    def list(self, request):
        """Get all tasks created by the authenticated user"""
        requester_id = uuid.UUID(str(request.user.id))
        tasks = self.task_application_service.get_tasks_by_requester(requester_id)
        # Use the TaskSerializer to convert the list of domain entities to a response
        serializer = TaskSerializer(tasks, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=["get"])
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
            # Use the TaskSerializer to convert the domain entity to a response
            serializer = TaskSerializer(task)
            return Response(serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid task ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["post"])
    def create(self, request):
        """Create a new task
        
        Endpoint: POST /api/tasks/
        
        The frontend should send all required fields directly in the request body
        """
        serializer = TaskCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Prepare task data dictionary
            task_data = {
                'requester_id': str(request.user.id),
                'category': serializer.validated_data["category"],
                'title': serializer.validated_data["title"],
                'description': serializer.validated_data["description"],
                'location_address': serializer.validated_data["location_address"],
                'budget': str(serializer.validated_data["budget"]),
                'estimated_duration': serializer.validated_data.get("estimated_duration"),
                'scheduled_date': serializer.validated_data["scheduled_date"].isoformat(),
                'attributes': []
            }
            
            # Add image_url if present
            if 'image_url' in serializer.validated_data and serializer.validated_data['image_url']:
                task_data['image_url'] = serializer.validated_data['image_url']
                
            # Add attributes if present
            if 'attribute_answers' in serializer.validated_data and serializer.validated_data['attribute_answers']:
                for name, answer in serializer.validated_data['attribute_answers'].items():
                    task_data['attributes'].append({
                        'name': name,
                        'question': name.replace('_', ' ').capitalize(),
                        'answer': answer
                    })
            
            # Create the task using the application service
            task = self.task_application_service.create_task(task_data)
            
            # Use the TaskSerializer to convert the domain entity to a response
            response_serializer = TaskSerializer(task)
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
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
        
    @action(detail=False, methods=["post"])
    def search_by_location(self, request):
        """Search for tasks near a location
        
        Endpoint: POST /api/tasks/search_by_location/
        """
        serializer = TaskSearchSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        tasks = self.task_application_service.search_tasks_by_location(
            latitude=serializer.validated_data["latitude"],
            longitude=serializer.validated_data["longitude"],
            radius_km=serializer.validated_data["radius_km"]
        )
        return Response(tasks)
