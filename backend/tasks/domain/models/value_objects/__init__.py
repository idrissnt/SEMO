"""
Value objects for the tasks app.
This package contains all the value objects for the tasks app.
"""
from tasks.domain.models.value_objects.task_status import TaskStatus
from tasks.domain.models.value_objects.application_status import ApplicationStatus

__all__ = [
    'TaskStatus',
    'ApplicationStatus',
]
