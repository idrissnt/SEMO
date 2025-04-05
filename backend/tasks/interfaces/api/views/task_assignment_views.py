from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from infrastructure.factory import ServiceFactory
from serializers import TaskAssignmentSerializer


class TaskAssignmentViewSet(viewsets.ViewSet):
    """ViewSet for task assignments"""
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.assignment_service = ServiceFactory.get_assignment_service()
    
    @action(detail=False, methods=["get"])
    def my_assignments(self, request):
        """Get all assignments for the authenticated user as a performer"""
        performer_id = uuid.UUID(str(request.user.id))
        assignments = self.assignment_service.get_assignments_by_performer(performer_id)
        return Response(assignments)
    
    @action(detail=True, methods=["post"])
    def start(self, request, pk=None):
        """Start a task assignment"""
        try:
            assignment_id = uuid.UUID(pk)
            performer_id = uuid.UUID(str(request.user.id))
            
            assignment = self.assignment_service.start_task(
                assignment_id=assignment_id,
                performer_id=performer_id
            )
            return Response(assignment)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=["post"])
    def complete(self, request, pk=None):
        """Complete a task assignment"""
        try:
            assignment_id = uuid.UUID(pk)
            performer_id = uuid.UUID(str(request.user.id))
            
            assignment = self.assignment_service.complete_task(
                assignment_id=assignment_id,
                performer_id=performer_id
            )
            return Response(assignment)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
