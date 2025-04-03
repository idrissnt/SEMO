"""
Django ORM models for the tasks app.
This module re-exports all models for backward compatibility.
"""
# Task models
from tasks.infrastructure.django_models.task.task import TaskModel
from tasks.infrastructure.django_models.task.attribute import TaskAttributeModel
from tasks.infrastructure.django_models.task.category_template import TaskCategoryTemplateModel

# Application models
from tasks.infrastructure.django_models.application.application import TaskApplicationModel
from tasks.infrastructure.django_models.application.negotiation import NegotiationOfferModel
from tasks.infrastructure.django_models.application.chat_message import ChatMessageModel

# Assignment models
from tasks.infrastructure.django_models.assignment.assignment import TaskAssignmentModel

# Review models
from tasks.infrastructure.django_models.review.review import ReviewModel

__all__ = [
    'TaskModel',
    'TaskAttributeModel',
    'TaskCategoryTemplateModel',
    'TaskApplicationModel',
    'NegotiationOfferModel',
    'ChatMessageModel',
    'TaskAssignmentModel',
    'ReviewModel',
]
