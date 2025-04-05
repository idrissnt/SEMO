from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from infrastructure.factory import ServiceFactory
from serializers import TaskApplicationSerializer


class TaskApplicationViewSet(viewsets.ViewSet):
    """ViewSet for task applications"""
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.task_application_service = ServiceFactory.get_task_application_service()
        self.task_service = ServiceFactory.get_task_service()
    
    def create(self, request):
        """Apply for a task"""
        serializer = TaskApplicationSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Get the authenticated user's ID as the performer ID
            performer_id = uuid.UUID(str(request.user.id))
            
            # Validate task exists
            task_id = serializer.validated_data["task_id"]
            
            task = self.task_service.get_task_by_id(task_id)
            if not task:
                return Response(
                    {"error": "Task not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Check if performer has already applied for this task
            applications = self.task_application_service.get_applications_by_performer(performer_id)
            if any(app.task_id == task_id for app in applications):
                return Response(
                    {"error": "You have already applied for this task"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Create application data dictionary
            application_data = {
                'task_id': task_id,
                'performer_id': performer_id,
                'initial_message': serializer.validated_data["message"],
                'initial_offer': float(serializer.validated_data["price_offer"]) if "price_offer" in serializer.validated_data else None
            }
            
            # Create application
            application = self.task_application_service.create_application(application_data)
            
            # Return serialized response
            response_serializer = TaskApplicationSerializer(application)
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["get"])
    def my_applications(self, request):
        """Get all applications submitted by the authenticated user"""
        performer_id = uuid.UUID(str(request.user.id))
        applications = self.task_application_service.get_applications_by_performer(performer_id)
        return Response(applications)
    
    @action(detail=True, methods=["get"])
    def task_applications(self, request, pk=None):
        """Get all applications for a task for the requester
        
        Endpoint: GET /api/applications/{task_id}/task_applications/
        
        Returns all applications for a specific task. Only the task requester can view these.
        """
        try:
            task_id = uuid.UUID(pk)
            
            # Get the task to check ownership
            task = self.task_service.get_task_by_id(task_id)
            if not task:
                return Response(
                    {"error": "Task not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Check if the user is the task requester
            requester_id = uuid.UUID(str(request.user.id))
            if task.requester_id != requester_id:
                return Response(
                    {"error": "You are not authorized to view applications for this task"},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            # Get all applications for the task
            applications = self.task_application_service.get_applications_by_task(task_id)
            
            # Return serialized response
            serializer = TaskApplicationSerializer(applications, many=True)
            return Response(serializer.data)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=["post"])
    def accept(self, request, pk=None):
        """Accept an application
        
        Endpoint: POST /api/applications/{application_id}/accept/
        
        Accepts an application for a task and updates its status to accepted.
        Only the task requester can accept applications.
        """
        try:
            application_id = uuid.UUID(pk)
            requester_id = uuid.UUID(str(request.user.id))
            
            # Get the application
            application = self.task_application_service.get_application(application_id)
            if not application:
                return Response(
                    {"error": "Application not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Get the task to check ownership
            task = self.task_service.get_task_by_id(application.task_id)
            if not task:
                return Response(
                    {"error": "Task not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Check if the user is the task requester
            if task.requester_id != requester_id:
                return Response(
                    {"error": "You are not authorized to accept applications for this task"},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            # Accept the application
            updated_application = self.task_application_service.accept_application(application_id)
            
            # Return serialized response
            serializer = TaskApplicationSerializer(updated_application)
            return Response(serializer.data)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
