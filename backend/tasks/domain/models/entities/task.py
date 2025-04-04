"""
Task and task attribute entities.

This module defines two key domain models:
1. TaskAttribute - A specific question and answer about a task
2. Task - The main entity representing a job that needs to be done

Tasks can be created in two ways:
1. Based on a predefined task type (using predefined_type_id)
2. As a custom task (without using a predefined type)
"""
from dataclasses import dataclass, field
from typing import Optional, List
import uuid
from datetime import datetime

from tasks.domain.models import TaskStatus
from predefined_task_type import TaskCategory


@dataclass
class TaskAttribute:
    """Domain model representing a task attribute (question and answer)"""
    name: str
    question: str
    answer: Optional[str] = None
    id: uuid.UUID = field(default_factory=uuid.uuid4)


@dataclass
class Task:
    """Domain model representing a task.
    
    A task can be created in two ways:
    1. Based on a predefined task type - Using defaults and questions from the predefined type
    2. As a custom task - With all details provided by the user
    
    When created from a predefined task type, the default values are copied from the template,
    but the task doesn't maintain a relationship with the template after creation.
    """
    requester_id: uuid.UUID
    title: str
    description: str
    image_url: str
    category_id: uuid.UUID  # Reference to TaskCategory by ID
    location_address: str
    budget: float
    estimated_duration: int
    scheduled_date: datetime
    attributes: List[TaskAttribute]
    status: TaskStatus = TaskStatus.DRAFT
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    
    def publish(self) -> None:
        """Publish the task, making it visible to performers
        
        Raises:
            ValueError: If the task is not in DRAFT status
        """
        if self.status != TaskStatus.DRAFT:
            raise ValueError(f"Cannot publish task with status {self.status.value}. Only DRAFT tasks can be published.")
            
        self.status = TaskStatus.PUBLISHED
        self.updated_at = datetime.now()
    
    def assign(self, performer_id: uuid.UUID) -> None:
        """Assign the task to a performer
        
        Args:
            performer_id: UUID of the performer to assign the task to
            
        Raises:
            ValueError: If the task is not in PUBLISHED status
        """
        if self.status != TaskStatus.PUBLISHED:
            raise ValueError(f"Cannot assign task with status {self.status.value}. Only PUBLISHED tasks can be assigned.")
            
        self.status = TaskStatus.ASSIGNED
        self.updated_at = datetime.now()
    
    def start(self) -> None:
        """Mark the task as in progress
        
        Raises:
            ValueError: If the task is not in ASSIGNED status
        """
        if self.status != TaskStatus.ASSIGNED:
            raise ValueError(f"Cannot start task with status {self.status.value}. Only ASSIGNED tasks can be started.")
            
        self.status = TaskStatus.IN_PROGRESS
        self.updated_at = datetime.now()
    
    def complete(self) -> None:
        """Mark the task as completed
        
        Raises:
            ValueError: If the task is not in IN_PROGRESS status
        """
        if self.status != TaskStatus.IN_PROGRESS:
            raise ValueError(f"Cannot complete task with status {self.status.value}. Only IN_PROGRESS tasks can be completed.")
            
        self.status = TaskStatus.COMPLETED
        self.updated_at = datetime.now()
    
    def cancel(self) -> None:
        """Cancel the task
        
        Raises:
            ValueError: If the task cannot be canceled due to its current status
        """
        if self.status in [TaskStatus.COMPLETED, TaskStatus.IN_PROGRESS, TaskStatus.ASSIGNED]:
            raise ValueError(f"Cannot cancel task with status {self.status.value}. Only DRAFT or PUBLISHED tasks can be canceled.")
            
        self.status = TaskStatus.CANCELLED
        self.updated_at = datetime.now()
