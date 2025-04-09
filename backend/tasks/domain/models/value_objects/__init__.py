"""
Value objects for the tasks app.
This package contains all the value objects for the tasks app.
"""
from .task_status import TaskStatus
from .application_status import ApplicationStatus

__all__ = [
    'TaskStatus',
    'ApplicationStatus',
]
