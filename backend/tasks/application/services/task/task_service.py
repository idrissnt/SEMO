"""
Application service for task-related operations.
"""
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime

from ....domain.models.entities.task import Task, TaskAttribute
from ....domain.models.entities.task_category import TaskCategory
from ....domain.models.value_objects.task_status import TaskStatus
from ....domain.repositories.task.task_repository import TaskRepository
from ....domain.repositories.category.category_template_repository import TaskCategoryTemplateRepository
from ....domain.services.task_service_interface import TaskService


class TaskApplicationService:
    """Application service for task-related operations"""
    
    def __init__(
        self,
        task_repository: TaskRepository,
        task_category_template_repository: TaskCategoryTemplateRepository,
        TaskService: TaskService
    ):
        self.task_repository = task_repository
        self.task_category_template_repository = task_category_template_repository
        self.task_service = task_service
    
    def get_task(self, task_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Get task by ID
        
        Args:
            task_id: UUID of the task
            
        Returns:
            Dictionary with task information if found, None otherwise
        """
        task = self.task_repository.get_by_id(task_id)
        if task:
            return self._task_to_dict(task)
        return None
    
    def get_tasks_by_requester(self, requester_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all tasks created by a requester
        
        Args:
            requester_id: UUID of the requester
            
        Returns:
            List of dictionaries with task information
        """
        tasks = self.task_repository.get_by_requester_id(requester_id)
        return [self._task_to_dict(task) for task in tasks]
    
    def get_tasks_by_status(self, status: str) -> List[Dict[str, Any]]:
        """Get all tasks with a specific status
        
        Args:
            status: Status of the tasks to retrieve
            
        Returns:
            List of dictionaries with task information
        """
        try:
            task_status = TaskStatus(status)
            tasks = self.task_repository.get_by_status(task_status)
            return [self._task_to_dict(task) for task in tasks]
        except ValueError:
            return []
    
    def get_tasks_by_category(self, category: str) -> List[Dict[str, Any]]:
        """Get all tasks in a specific category
        
        Args:
            category: Category of the tasks to retrieve
            
        Returns:
            List of dictionaries with task information
        """
        try:
            task_category = TaskCategory(category)
            tasks = self.task_repository.get_by_category(task_category)
            return [self._task_to_dict(task) for task in tasks]
        except ValueError:
            return []
    
    def search_tasks_by_location(self, latitude: float, longitude: float, radius_km: float) -> List[Dict[str, Any]]:
        """Search for tasks within a radius of a location
        
        Args:
            latitude: Latitude of the center point
            longitude: Longitude of the center point
            radius_km: Radius in kilometers
            
        Returns:
            List of dictionaries with task information
        """
        tasks = self.task_repository.search_by_location(latitude, longitude, radius_km)
        return [self._task_to_dict(task) for task in tasks]
    
    def create_task(self, task_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new task
        
        Args:
            task_data: Dictionary with task data
            
        Returns:
            Dictionary with created task information
        """
        # Extract required fields
        requester_id = uuid.UUID(task_data['requester_id'])
        title = task_data['title']
        description = task_data['description']
        category = TaskCategory(task_data['category'])
        category_template_id = uuid.UUID(task_data['category_template_id'])
        location_address_id = uuid.UUID(task_data['location_address_id'])
        budget = float(task_data['budget'])
        scheduled_date = datetime.fromisoformat(task_data['scheduled_date'])
        
        # Extract attributes
        attributes = []
        for attr_data in task_data.get('attributes', []):
            attribute = TaskAttribute(
                name=attr_data['name'],
                question=attr_data['question'],
                answer=attr_data.get('answer')
            )
            attributes.append(attribute)
        
        # Create task
        task = Task(
            requester_id=requester_id,
            title=title,
            description=description,
            category=category,
            category_template_id=category_template_id,
            location_address_id=location_address_id,
            budget=budget,
            scheduled_date=scheduled_date,
            attributes=attributes
        )
        
        # Save task
        created_task = self.task_repository.create(task)
        return self._task_to_dict(created_task)
    
    def update_task(self, task_id: uuid.UUID, task_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Update an existing task
        
        Args:
            task_id: UUID of the task to update
            task_data: Dictionary with updated task data
            
        Returns:
            Dictionary with updated task information if successful, None otherwise
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
        if 'category_template_id' in task_data:
            task.category_template_id = uuid.UUID(task_data['category_template_id'])
        if 'location_address_id' in task_data:
            task.location_address_id = uuid.UUID(task_data['location_address_id'])
        if 'budget' in task_data:
            task.budget = float(task_data['budget'])
        if 'scheduled_date' in task_data:
            task.scheduled_date = datetime.fromisoformat(task_data['scheduled_date'])
        
        # Update attributes
        if 'attributes' in task_data:
            task.attributes = []
            for attr_data in task_data['attributes']:
                attribute = TaskAttribute(
                    name=attr_data['name'],
                    question=attr_data['question'],
                    answer=attr_data.get('answer')
                )
                task.attributes.append(attribute)
        
        # Save task
        updated_task = self.task_repository.update(task)
        return self._task_to_dict(updated_task)
    
    def delete_task(self, task_id: uuid.UUID) -> bool:
        """Delete a task
        
        Args:
            task_id: UUID of the task to delete
            
        Returns:
            True if successful, False otherwise
        """
        return self.task_repository.delete(task_id)
    
    def publish_task(self, task_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Publish a task, making it visible to performers
        
        Args:
            task_id: UUID of the task to publish
            
        Returns:
            Dictionary with published task information if successful, None otherwise
        """
        # Get existing task
        task = self.task_repository.get_by_id(task_id)
        if not task:
            return None
        
        # Publish task
        task.publish()
        
        # Save task
        updated_task = self.task_repository.update(task)
        return self._task_to_dict(updated_task)
    
    def _task_to_dict(self, task: Task) -> Dict[str, Any]:
        """Convert Task object to dictionary
        
        Args:
            task: Task object
            
        Returns:
            Dictionary with task information
        """
        return {
            'id': str(task.id),
            'requester_id': str(task.requester_id),
            'title': task.title,
            'description': task.description,
            'category': task.category.value,
            'category_template_id': str(task.category_template_id),
            'location_address_id': str(task.location_address_id),
            'budget': task.budget,
            'scheduled_date': task.scheduled_date.isoformat(),
            'status': task.status.value,
            'attributes': [
                {
                    'name': attr.name,
                    'question': attr.question,
                    'answer': attr.answer
                }
                for attr in task.attributes
            ],
            'created_at': task.created_at.isoformat(),
            'updated_at': task.updated_at.isoformat()
        }
