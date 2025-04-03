"""
Task and task attribute entities.
"""
from dataclasses import dataclass, field
from typing import Optional, List
import uuid
from datetime import datetime

from tasks.domain.models.value_objects.task_status import TaskStatus
from tasks.domain.models.entities.task_category import TaskCategory


@dataclass
class TaskAttribute:
    """Domain model representing a task attribute (question and answer)"""
    name: str
    question: str
    answer: Optional[str] = None
    id: uuid.UUID = field(default_factory=uuid.uuid4)


@dataclass
class Task:
    """Domain model representing a task"""
    requester_id: uuid.UUID
    title: str
    description: str
    image_url: str
    category: TaskCategory
    category_template_id: uuid.UUID  # Direct reference to TaskCategoryTemplate
    location_address_id: uuid.UUID
    budget: float
    scheduled_date: datetime
    attributes: List[TaskAttribute]
    status: TaskStatus = TaskStatus.DRAFT
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    
    def publish(self) -> None:
        """Publish the task, making it visible to performers"""
        if self.status == TaskStatus.DRAFT:
            self.status = TaskStatus.PUBLISHED
            self.updated_at = datetime.now()
    
    def assign(self, performer_id: uuid.UUID) -> None:
        """Assign the task to a performer"""
        if self.status == TaskStatus.PUBLISHED:
            self.status = TaskStatus.ASSIGNED
            self.updated_at = datetime.now()
    
    def start(self) -> None:
        """Mark the task as in progress"""
        if self.status == TaskStatus.ASSIGNED:
            self.status = TaskStatus.IN_PROGRESS
            self.updated_at = datetime.now()
    
    def complete(self) -> None:
        """Mark the task as completed"""
        if self.status == TaskStatus.IN_PROGRESS:
            self.status = TaskStatus.COMPLETED
            self.updated_at = datetime.now()
    
    def cancel(self) -> None:
        """Cancel the task"""
        if self.status != TaskStatus.COMPLETED:
            self.status = TaskStatus.CANCELLED
            self.updated_at = datetime.now()
