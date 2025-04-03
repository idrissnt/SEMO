"""
Task status value object.
"""
from enum import Enum


class TaskStatus(Enum):
    """Enum representing the status of a task"""
    DRAFT = "draft"
    PUBLISHED = "published"
    ASSIGNED = "assigned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
