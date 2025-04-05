"""
Application service for task assignment-related operations.
"""
from typing import List, Optional, Dict, Any
import uuid

from domain.models import ( TaskAssignment,
                          TaskStatus,
                          ApplicationStatus)

from domain.repositories import (TaskRepository,
                                TaskAssignmentRepository,
                                TaskApplicationRepository)


class AssignmentService:
    """Application service for task assignment-related operations"""
    
    def __init__(
        self,
        task_repository: TaskRepository,
        task_assignment_repository: TaskAssignmentRepository,
        task_application_repository: TaskApplicationRepository
    ):
        self.task_repository = task_repository
        self.task_assignment_repository = task_assignment_repository
        self.task_application_repository = task_application_repository
    
    def get_assignment(self, assignment_id: uuid.UUID) -> Optional[TaskAssignment]:
        """Get assignment by ID
        
        Args:
            assignment_id: UUID of the assignment
            
        Returns:
            TaskAssignment object if found, None otherwise
        """
        assignment = self.task_assignment_repository.get_by_id(assignment_id)
        if assignment:
            return assignment
        return None
    
    def get_assignment_by_task(self, task_id: uuid.UUID) -> Optional[TaskAssignment]:
        """Get assignment for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            TaskAssignment object if found, None otherwise
        """
        assignment = self.task_assignment_repository.get_by_task_id(task_id)
        if assignment:
            return assignment
        return None
    
    def get_assignments_by_performer(self, performer_id: uuid.UUID) -> List[TaskAssignment]:
        """Get all assignments for a performer
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of TaskAssignment objects
        """
        assignments = self.task_assignment_repository.get_by_performer_id(performer_id)
        return assignments
    
    def get_active_assignments_by_performer(self, performer_id: uuid.UUID) -> List[TaskAssignment]:
        """Get all active assignments for a performer (assigned but not completed)
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of TaskAssignment objects
        """
        assignments = self.task_assignment_repository.get_active_by_performer_id(performer_id)
        return assignments
    
    def create_assignment(self, assignment_data: Dict[str, Any]) -> Optional[TaskAssignment]:
        """Create a new assignment
        
        Args:
            assignment_data: Dictionary with assignment data
            
        Returns:
            TaskAssignment object if successful, None otherwise
        """
        # Extract required fields
        task_id = uuid.UUID(assignment_data['task_id'])
        performer_id = uuid.UUID(assignment_data['performer_id'])
        
        # Check if task exists and is in published status
        task = self.task_repository.get_by_id(task_id)
        if not task or task.status != TaskStatus.PUBLISHED:
            return None
        
        # Check if there's an accepted application from this performer
        applications = self.task_application_repository.get_by_task_id(task_id)
        performer_application = next((app for app in applications 
                                     if app.performer_id == performer_id 
                                     and app.status.value == ApplicationStatus.ACCEPTED.value), None)
        if not performer_application:
            return None
        
        # Create assignment
        assignment = TaskAssignment(
            task_id=task_id,
            performer_id=performer_id
        )
        
        # Save assignment
        created_assignment = self.task_assignment_repository.create(assignment)
        
        # Update task status
        task.assign(performer_id)
        self.task_repository.update(task)
        
        return created_assignment
    
    def start_assignment(self, assignment_id: uuid.UUID) -> TaskAssignment:
        """Mark an assignment as started
        
        Args:
            assignment_id: UUID of the assignment to start
            
        Returns:
            Updated TaskAssignment object
        """
        # Get existing assignment
        assignment = self.task_assignment_repository.get_by_id(assignment_id)
        
        # Start assignment
        assignment.start()
        
        # Save assignment
        updated_assignment = self.task_assignment_repository.update(assignment)
        
        # Update task status
        task = self.task_repository.get_by_id(assignment.task_id)
        if task:
            task.start()
            self.task_repository.update(task)
        
        return updated_assignment
    
    def complete_assignment(self, assignment_id: uuid.UUID) -> TaskAssignment:
        """Mark an assignment as completed
        
        Args:
            assignment_id: UUID of the assignment to complete
            
        Returns:
            Updated TaskAssignment object
        """
        # Get existing assignment
        assignment = self.task_assignment_repository.get_by_id(assignment_id)
        
        # Complete assignment
        assignment.complete()
        
        # Save assignment
        updated_assignment = self.task_assignment_repository.update(assignment)
        
        # Update task status
        task = self.task_repository.get_by_id(assignment.task_id)
        if task:
            task.complete()
            self.task_repository.update(task)
        
        return updated_assignment
