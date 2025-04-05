"""
Application service for task-related operations.
"""
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime

from domain.models import (Task, TaskAttribute,TaskCategory,
                           TaskStatus)

from domain.repositories import (TaskRepository,PredefinedTaskTypeRepository)


class TaskApplicationService:
    """Application service for task-related operations"""
    
    def __init__(
        self,
        task_repository: TaskRepository,
        predefined_type_repository: PredefinedTaskTypeRepository,
    ):
        self.task_repository = task_repository
        self.predefined_type_repository = predefined_type_repository
    
    def get_task_by_id(self, task_id: uuid.UUID) -> Optional[Task]:
        """Get task by ID
        
        Args:
            task_id: UUID of the task
            
        Returns:
            Task object if found, None otherwise
        """
        task = self.task_repository.get_by_id(task_id)
        if task:
            return task
        return None
    
    def get_tasks_by_requester(self, requester_id: uuid.UUID) -> List[Task]:
        """Get all tasks created by a requester
        
        Args:
            requester_id: UUID of the requester
            
        Returns:
            List of Task objects
        """
        all_tasks = self.task_repository.get_by_requester_id(requester_id)
        return all_tasks
        
    def get_tasks_by_category_id(self, category_id: uuid.UUID) -> List[Task]:
        """Get all tasks in a specific category
        
        Args:
            category_id: UUID of the category
            
        Returns:
            List of Task objects
        """
        return self.task_repository.get_by_category_id(category_id)
    
    def get_tasks_by_status(self, status: str) -> List[Task]:
        """Get all tasks with a specific status
        
        Args:
            status: Status of the tasks to retrieve
            
        Returns:
            List of Task objects
        """
        try:
            task_status = TaskStatus(status)
            all_tasks = self.task_repository.get_by_status(task_status)
            return all_tasks
        except ValueError:
            return []
    
    def get_tasks_by_category(self, category: str) -> List[Task]:
        """Get all tasks in a specific category
        
        Args:
            category: Category of the tasks to retrieve
            
        Returns:
            List of Task objects
        """
        try:
            task_category = TaskCategory(category)
            all_tasks = self.task_repository.get_by_category(task_category)
            return all_tasks
        except ValueError:
            return []
    
    def search_tasks_by_location(self, latitude: float, longitude: float, radius_km: float) -> List[Task]:
        """Search for tasks within a radius of a location
        
        Args:
            latitude: Latitude of the center point
            longitude: Longitude of the center point
            radius_km: Radius in kilometers
            
        Returns:
            List of Task objects
        """
        all_tasks = self.task_repository.search_by_location(latitude, longitude, radius_km)
        return all_tasks
    
    def create_task(self, task_data: Dict[str, Any]) -> Task:
        """Create a new task
        
        This method assumes that the input data has already been validated by the interface layer.
        It focuses on creating the domain entity and persisting it.
        
        Args:
            task_data: Dictionary with validated task data
            
        Returns:
            Task object
        """
        # Create attributes from task_data
        attributes = []
        for attr_data in task_data.get('attributes', []):
            attribute = TaskAttribute(
                name=attr_data['name'],
                question=attr_data['question'],
                answer=attr_data.get('answer')
            )
            attributes.append(attribute)
        
        # Get estimated_duration with default value if not provided
        estimated_duration = task_data.get('estimated_duration', 60)  # Default to 60 minutes
        
        # Create task domain entity
        task = Task(
            requester_id=uuid.UUID(task_data['requester_id']),
            title=task_data['title'],
            description=task_data['description'],
            image_url=task_data.get('image_url'),
            category=TaskCategory(task_data['category']),
            location_address=task_data['location_address'],
            budget=float(task_data['budget']),
            estimated_duration=estimated_duration,
            scheduled_date=datetime.fromisoformat(task_data['scheduled_date']),
            attributes=attributes
        )
        
        # Save task
        created_task = self.task_repository.create(task)
        return created_task
    
    def update_task(self, task_id: uuid.UUID, task_data: Dict[str, Any]) -> Optional[Task]:
        """Update an existing task
        
        Args:
            task_id: UUID of the task to update
            task_data: Dictionary with updated task data
            
        Returns:
            Task object if successful, None otherwise
        """
        # Get existing task
        task = self.task_repository.get_by_id(task_id)
        if not task:
            return None
        
        # Update fields
        if 'title' in task_data:
            task.title = task_data['title']
        if 'description' in task_data:
            task.description = task_data['description']
        if 'category' in task_data:
            task.category = TaskCategory(task_data['category'])
        if 'location_address' in task_data:
            task.location_address = task_data['location_address']
        if 'budget' in task_data:
            task.budget = float(task_data['budget'])
        if 'estimated_duration' in task_data:
            task.estimated_duration = int(task_data['estimated_duration'])
        if 'scheduled_date' in task_data:
            task.scheduled_date = datetime.fromisoformat(task_data['scheduled_date'])
        
        # Save task
        updated_task = self.task_repository.update(task)
        return updated_task
    
    def delete_task(self, task_id: uuid.UUID) -> bool:
        """Delete a task
        
        Args:
            task_id: UUID of the task to delete
            
        Returns:
            True if successful, False otherwise
        """
        return self.task_repository.delete(task_id)
    
    def publish_task(self, task_id: uuid.UUID, requester_id: uuid.UUID) -> Optional[Task]:
        """Publish a task, making it visible to performers
        
        This method checks that the requester is the owner of the task
        before allowing them to publish it.
        
        Args:
            task_id: UUID of the task to publish
            requester_id: UUID of the user requesting to publish the task
            
        Returns:
            Task object if successful, None otherwise
            
        Raises:
            ValueError: If the requester is not the owner of the task or if the task
                       cannot be published due to its current status
        """
        # Get existing task
        task = self.task_repository.get_by_id(task_id)
        if not task:
            return None
        
        # Check authorization - only the task owner can publish it
        if task.requester_id != requester_id:
            raise ValueError("Only the task owner can publish this task")
        
        # Publish task using the domain entity's method
        # The domain entity will validate if the task can be published
        try:
            task.publish()
        except ValueError as e:
            # Re-raise the domain exception with additional context if needed
            raise ValueError(f"Cannot publish task: {str(e)}")
        
        # Save task
        updated_task = self.task_repository.update(task)
        return updated_task
    
    def cancel_task(self, task_id: uuid.UUID, user_id: uuid.UUID) -> Optional[Task]:
        """Cancel a task
        
        This method allows a task to be canceled by its owner.
        The domain entity will validate if the task can be canceled based on its status.
        
        Args:
            task_id: UUID of the task to cancel
            user_id: UUID of the user canceling the task
            
        Returns:
            Task object if successful, None otherwise
            
        Raises:
            ValueError: If the user is not authorized to cancel the task or if the task
                       cannot be canceled due to its current status
        """
        # Get existing task
        task = self.task_repository.get_by_id(task_id)
        if not task:
            return None
        
        # Check authorization - only the task owner can cancel it
        if task.requester_id != user_id:
            raise ValueError("Only the task owner can cancel this task")
        
        # Cancel task using the domain entity's method
        # The domain entity will validate if the task can be canceled
        try:
            task.cancel()
        except ValueError as e:
            # Re-raise the domain exception with additional context if needed
            raise ValueError(f"Cannot cancel task: {str(e)}")
        
        # Save task
        updated_task = self.task_repository.update(task)
        return updated_task