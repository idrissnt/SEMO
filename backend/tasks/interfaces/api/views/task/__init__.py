
"""
Views for the tasks app.
This module re-exports all views for backward compatibility.
"""
# Import task-related views
from .task_views import TaskViewSet
from .task_category_views import TaskCategoryViewSet
from .pre_defined_task_views import PredefinedTaskViewSet

__all__ = [
    'TaskViewSet',
    'TaskCategoryViewSet',
    'PredefinedTaskViewSet',
]
