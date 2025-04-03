"""
Domain entities for the tasks app.
This package contains all the domain entities for the tasks app.
"""
from tasks.domain.models.entities.task import Task, TaskAttribute
from tasks.domain.models.entities.task_category import TaskCategory, TaskCategoryTemplate
from tasks.domain.models.entities.task_application import TaskApplication, NegotiationOffer
from tasks.domain.models.entities.task_assignment import TaskAssignment
from tasks.domain.models.entities.review import Review
from tasks.domain.models.entities.chat_message import ChatMessage

__all__ = [
    'Task',
    'TaskAttribute',
    'TaskCategory',
    'TaskCategoryTemplate',
    'TaskApplication',
    'NegotiationOffer',
    'TaskAssignment',
    'Review',
    'ChatMessage',
]
