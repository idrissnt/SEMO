
"""
Views for the tasks app.
This module re-exports all views.
"""
# Import task-related views
from .task import TaskViewSet
from .task import TaskCategoryViewSet
from .task import PredefinedTaskViewSet   

# Import application-related views
from .task_application_views import TaskApplicationViewSet

# Import assignment-related views
from .task_assignment_views import TaskAssignmentViewSet

# Import review-related views
from .review_views import ReviewViewSet

__all__ = [
    'TaskViewSet',
    'TaskCategoryViewSet',
    'PredefinedTaskViewSet',
    'TaskApplicationViewSet',
    'TaskAssignmentViewSet',
    'ReviewViewSet',
]
