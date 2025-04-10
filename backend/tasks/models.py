"""
Bridge module that imports and re-exports Django ORM models from the infrastructure layer.
This allows Django to discover models in the standard location while maintaining DDD architecture.
"""

# Import models from infrastructure layer
from tasks.infrastructure.django_models import (
    TaskCategoryModel as TaskCategory,
    TaskAttributeModel as TaskAttribute,
    TaskModel as Task,
    PredefinedTaskTypeModel as PredefinedTaskType,

    TaskApplicationModel as TaskApplication,
    NegotiationOfferModel as NegotiationOffer,

    TaskAssignmentModel as TaskAssignment,

    ReviewModel as Review
)

# Re-export models with simplified names for Django admin and migrations
__all__ = ['PredefinedTaskType', 'TaskCategory', 'NegotiationOffer', 'TaskApplication', 'Task', 'TaskAttribute', 'TaskAssignment', 'Review']
