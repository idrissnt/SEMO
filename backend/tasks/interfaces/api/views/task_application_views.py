from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from ....infrastructure.factory import ServiceFactory
from ..serializers import TaskApplicationSerializer


class TaskApplicationViewSet(viewsets.ViewSet):
    """ViewSet for task applications"""
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.application_service = ServiceFactory.get_application_service()
    
    def create(self, request):
        """Apply for a task"""
        serializer = TaskApplicationSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            performer_id = uuid.UUID(str(request.user.id))
            application = self.application_service.apply_for_task(
                task_id=serializer.validated_data["task_id"],
                performer_id=performer_id,
                message=serializer.validated_data["message"],
                price_offer=float(serializer.validated_data["price_offer"]) if "price_offer" in serializer.validated_data else None
            )
            return Response(application, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["get"])
    def my_applications(self, request):
        """Get all applications submitted by the authenticated user"""
        performer_id = uuid.UUID(str(request.user.id))
        applications = self.application_service.get_applications_by_performer(performer_id)
        return Response(applications)
    
    @action(detail=True, methods=["get"])
    def task_applications(self, request, pk=None):
        """Get all applications for a task"""
        try:
            task_id = uuid.UUID(pk)
            # Check if the user is the task requester
            task = self.application_service.get_task_by_id(task_id)
            if not task:
                return Response(
                    {"error": "Task not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            if str(task["requester_id"]) != str(request.user.id):
                return Response(
                    {"error": "You are not authorized to view applications for this task"},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            applications = self.application_service.get_applications_for_task(task_id)
            return Response(applications)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=["post"])
    def accept(self, request, pk=None):
        """Accept an application and assign the task"""
        try:
            application_id = uuid.UUID(pk)
            requester_id = uuid.UUID(str(request.user.id))
            
            # Get the application to find the task ID
            application = self.task_application_repository.get_by_id(application_id)
            if not application:
                return Response(
                    {"error": "Application not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            assignment = self.task_application_service.assign_task(
                task_id=application.task_id,
                application_id=application_id,
                requester_id=requester_id
            )
            return Response(assignment)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
