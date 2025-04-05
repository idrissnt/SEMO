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
            
            # Validate assignment exists
            assignment = self.assignment_service.get_assignment(assignment_id)
            if not assignment:
                return Response(
                    {"error": "Assignment not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Validate performer is assigned to this task
            if assignment.performer_id != performer_id:
                return Response(
                    {"error": "You are not assigned to this task"},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            # Check if assignment is already started
            if assignment.started_at:
                return Response(
                    {"error": "Assignment already started"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Check if assignment is already completed
            if assignment.completed_at:
                return Response(
                    {"error": "Assignment already completed"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Start the assignment
            updated_assignment = self.assignment_service.start_assignment(assignment_id)
            
            # Return serialized response
            serializer = TaskAssignmentSerializer(updated_assignment)
            return Response(serializer.data)
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
            
            # Validate assignment exists
            assignment = self.assignment_service.get_assignment(assignment_id)
            if not assignment:
                return Response(
                    {"error": "Assignment not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Validate performer is assigned to this task
            if assignment.performer_id != performer_id:
                return Response(
                    {"error": "You are not assigned to this task"},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            # Check if assignment is already completed
            if assignment.completed_at:
                return Response(
                    {"error": "Assignment already completed"},
                    status=status.HTTP_400_BAD_REQUEST
                )
                
            # Check if assignment has been started
            if not assignment.started_at:
                return Response(
                    {"error": "Assignment must be started before it can be completed"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Complete the assignment
            updated_assignment = self.assignment_service.complete_assignment(assignment_id)
            
            # Return serialized response
            serializer = TaskAssignmentSerializer(updated_assignment)
            return Response(serializer.data)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
