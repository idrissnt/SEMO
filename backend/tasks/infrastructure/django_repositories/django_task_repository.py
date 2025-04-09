from typing import List, Optional
import uuid
from django.db import transaction
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D

# Import domain entities and value objects
from ...domain.models import (
    Task, TaskAttribute, 
    TaskStatus
)
from ...domain.repositories import TaskRepository

# Import ORM models
from ..django_models import TaskModel, TaskAttributeModel


class DjangoTaskRepository(TaskRepository):
    """Django ORM implementation of TaskRepository"""
    
    def get_by_id(self, task_id: uuid.UUID) -> Optional[Task]:
        """Get task by ID
        
        Args:
            task_id: UUID of the task
            
        Returns:
            Task object if found, None otherwise
        """
        try:
            task_model = TaskModel.objects.prefetch_related('attributes').get(id=task_id)
            return self._task_model_to_domain(task_model)
        except TaskModel.DoesNotExist:
            return None
    
    def get_by_requester_id(self, requester_id: uuid.UUID) -> List[Task]:
        """Get all tasks created by a requester
        
        Args:
            requester_id: UUID of the requester
            
        Returns:
            List of Task objects
        """
        task_models = TaskModel.objects.prefetch_related('attributes').filter(requester_id=requester_id)
        return [self._task_model_to_domain(task_model) for task_model in task_models]
    
    def get_by_status(self, status: str) -> List[Task]:
        """Get all tasks with a specific status
        
        Args:
            status: Status of the tasks to retrieve
            
        Returns:
            List of Task objects
        """
        task_models = TaskModel.objects.prefetch_related('attributes').filter(status=status)
        return [self._task_model_to_domain(task_model) for task_model in task_models]
    
    def get_by_category_id(self, category_id: uuid.UUID) -> List[Task]:
        """Get all tasks in a specific category
        
        Args:
            category_id: UUID of the category
            
        Returns:
            List of Task objects
        """
        task_models = TaskModel.objects.prefetch_related('attributes').filter(category_id=category_id)
        return [self._task_model_to_domain(task_model) for task_model in task_models]
    
    def search_by_location(self, latitude: float, longitude: float, radius_km: float) -> List[Task]:
        """Search for tasks within a radius of a location
        
        Args:
            latitude: Latitude of the center point
            longitude: Longitude of the center point
            radius_km: Radius in kilometers
            
        Returns:
            List of Task objects
        """
        point = Point(longitude, latitude, srid=4326)
        task_models = TaskModel.objects.prefetch_related('attributes').filter(
            location_point__distance_lte=(point, D(km=radius_km)),
            status=TaskStatus.PUBLISHED.value
        )
        return [self._task_model_to_domain(task_model) for task_model in task_models]
    
    @transaction.atomic
    def create(self, task: Task) -> Task:
        """Create a new task
        
        Args:
            task: Task object to create
            
        Returns:
            Created Task object
        """
        # Create the task model
        task_model = TaskModel(
            id=task.id,
            requester_id=task.requester_id,
            title=task.title,
            description=task.description,
            image_url=task.image_url,
            category_id=task.category_id,
            location_address=task.location_address,
            budget=task.budget,
            estimated_duration=task.estimated_duration,
            scheduled_date=task.scheduled_date,
            status=task.status.value,
            created_at=task.created_at,
            updated_at=task.updated_at
        )
        
        # Get the address coordinates for geospatial queries
        address_model = task_model.location_address
        if hasattr(address_model, 'latitude') and hasattr(address_model, 'longitude'):
            if address_model.latitude and address_model.longitude:
                task_model.location_point = Point(
                    float(address_model.longitude),
                    float(address_model.latitude),
                    srid=4326
                )
        
        task_model.save()
        
        # Create the task attributes
        for attr in task.attributes:
            TaskAttributeModel.objects.create(
                id=attr.id,
                task=task_model,
                name=attr.name,
                question=attr.question,
                answer=attr.answer
            )
        
        # Return the domain entity
        return self._task_model_to_domain(task_model)
    
    @transaction.atomic
    def update(self, task: Task) -> Task:
        """Update an existing task
        
        Args:
            task: Task object with updated fields
            
        Returns:
            Updated Task object
        """
        try:
            task_model = TaskModel.objects.get(id=task.id)
            
            # Update the task model fields
            task_model.title = task.title
            task_model.description = task.description
            task_model.image_url = task.image_url
            task_model.category_id = task.category_id
            task_model.location_address = task.location_address
            task_model.budget = task.budget
            task_model.estimated_duration = task.estimated_duration
            task_model.scheduled_date = task.scheduled_date
            task_model.status = task.status.value
            task_model.updated_at = task.updated_at
            
            # Get the address coordinates for geospatial queries
            address_model = task_model.location_address
            if hasattr(address_model, 'latitude') and hasattr(address_model, 'longitude'):
                if address_model.latitude and address_model.longitude:
                    task_model.location_point = Point(
                        float(address_model.longitude),
                        float(address_model.latitude),
                        srid=4326
                    )
            
            task_model.save()
            
            # Update the task attributes
            # First, get the existing attributes
            existing_attrs = {str(attr.id): attr for attr in task_model.attributes.all()}
            
            # Update or create attributes
            for attr in task.attributes:
                attr_id_str = str(attr.id)
                if attr_id_str in existing_attrs:
                    # Update existing attribute
                    attr_model = existing_attrs[attr_id_str]
                    attr_model.name = attr.name
                    attr_model.question = attr.question
                    attr_model.answer = attr.answer
                    attr_model.save()
                else:
                    # Create new attribute
                    TaskAttributeModel.objects.create(
                        id=attr.id,
                        task=task_model,
                        name=attr.name,
                        question=attr.question,
                        answer=attr.answer
                    )
            
            # Delete attributes that are no longer in the domain entity
            domain_attr_ids = {str(attr.id) for attr in task.attributes}
            for attr_id_str, attr_model in existing_attrs.items():
                if attr_id_str not in domain_attr_ids:
                    attr_model.delete()
            
            # Return the domain entity
            return self._task_model_to_domain(task_model)
        
        except TaskModel.DoesNotExist:
            return self.create(task)
    
    @transaction.atomic
    def delete(self, task_id: uuid.UUID) -> bool:
        """Delete a task
        
        Args:
            task_id: UUID of the task to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            task_model = TaskModel.objects.get(id=task_id)
            task_model.delete()
            return True
        except TaskModel.DoesNotExist:
            return False
    
    def _task_model_to_domain(self, task_model: TaskModel) -> Task:
        """Convert a TaskModel to a Task domain entity
        
        Args:
            task_model: TaskModel to convert
            
        Returns:
            Task domain entity
        """
        # Convert attributes
        attributes = []
        for attr_model in task_model.attributes.all():
            attributes.append(TaskAttribute(
                id=attr_model.id,
                name=attr_model.name,
                question=attr_model.question,
                answer=attr_model.answer
            ))
        
        # Create and return the domain entity
        return Task(
            id=task_model.id,
            requester_id=task_model.requester.id,
            title=task_model.title,
            description=task_model.description,
            image_url=task_model.image_url,
            category_id=task_model.category.id,
            location_address=task_model.location_address,
            budget=float(task_model.budget),
            estimated_duration=task_model.estimated_duration,
            scheduled_date=task_model.scheduled_date,
            status=TaskStatus(task_model.status),
            attributes=attributes,
            created_at=task_model.created_at,
            updated_at=task_model.updated_at
        )
