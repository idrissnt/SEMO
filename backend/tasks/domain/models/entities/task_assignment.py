"""
Task assignment entity.
"""
from dataclasses import dataclass, field
from typing import Optional
import uuid
from datetime import datetime

from the_user_app.domain.models.entities import TaskPerformerProfile


@dataclass
class TaskAssignment:
    """Domain model representing a task assignment to a performer"""
    task_id: uuid.UUID
    performer_id: uuid.UUID  # ID of the TaskPerformerProfile
    performer: Optional[TaskPerformerProfile] = None  # Reference to the TaskPerformerProfile entity
    assigned_at: datetime = field(default_factory=datetime.now)
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    
    def start(self) -> None:
        """Mark the assignment as started"""
        if not self.started_at:
            self.started_at = datetime.now()
    
    def complete(self) -> None:
        """Mark the assignment as completed"""
        if self.started_at and not self.completed_at:
            self.completed_at = datetime.now()
