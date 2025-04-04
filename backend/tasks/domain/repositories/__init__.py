"""
Repository interfaces for the tasks app.
This module re-exports all repository interfaces for backward compatibility.
"""
# Import from task repositories
from .task.task_repository import TaskRepository

# Import from application repositories
from .application.application_repository import TaskApplicationRepository
from .application.chat_message_repository import ChatMessageRepository
from .application.negotiation_repository import NegotiationOfferRepository

# Import from assignment repositories
from .assignment.assignment_repository import TaskAssignmentRepository

# Import from review repositories
from .review.review_repository import ReviewRepository

# Import from category repositories
from .category.predefined_category_repository import PredefinedTaskTypeRepository
from .task_category.task_category_repository import TaskCategoryRepository

__all__ = [
    'TaskRepository',
    'TaskApplicationRepository',
    'ChatMessageRepository',
    'NegotiationOfferRepository',
    'TaskAssignmentRepository',
    'ReviewRepository',
    'PredefinedTaskTypeRepository',
    'TaskCategoryRepository',
]
