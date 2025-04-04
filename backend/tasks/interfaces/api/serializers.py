"""Serializers for the tasks app.
This module re-exports all serializers for backward compatibility.
"""

# Import all serializers from the new modular structure
from .serializers.task_serializer import TaskSerializer, TaskCreateSerializer, TaskSearchSerializer
from .serializers.task_attribute_serializer import TaskAttributeSerializer
from .serializers.predefined_task_type_serializer import PredefinedTaskTypeSerializer
from .serializers.task_application_serializer import TaskApplicationSerializer
from .serializers.task_assignment_serializer import TaskAssignmentSerializer
from .serializers.review_serializer import ReviewSerializer
from .serializers.task_category_serializer import TaskCategorySerializer


# Re-export all serializers for backward compatibility
__all__ = [
    'TaskSerializer',
    'TaskCreateSerializer',
    'TaskAttributeSerializer',
    'PredefinedTaskTypeSerializer',
    'TaskApplicationSerializer',
    'TaskAssignmentSerializer',
    'ReviewSerializer',
    'TaskSearchSerializer',
    'TaskCategorySerializer',
]
