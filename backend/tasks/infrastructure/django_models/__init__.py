"""
Django ORM models for the tasks app.
This module re-exports all models for backward compatibility.
"""
# Task models
from tasks.infrastructure.django_models.task_orm_model.task import TaskModel
from tasks.infrastructure.django_models.task_orm_model.attribute import TaskAttributeModel
from tasks.infrastructure.django_models.task_orm_model.predefined_task_type import PredefinedTaskTypeModel

# Application models
from tasks.infrastructure.django_models.application_orm_model.application import TaskApplicationModel
from tasks.infrastructure.django_models.application_orm_model.negotiation import NegotiationOfferModel
from tasks.infrastructure.django_models.application_orm_model.chat_message import ChatMessageModel

# Assignment models
from tasks.infrastructure.django_models.assignment_orm_model.assignment import TaskAssignmentModel

# Review models
from tasks.infrastructure.django_models.review_orm_model.review import ReviewModel

# Category models
from tasks.infrastructure.django_models.task_orm_model.task_category_model import TaskCategoryModel

__all__ = [
    'TaskModel',
    'TaskAttributeModel',
    'PredefinedTaskTypeModel',
    'TaskApplicationModel',
    'NegotiationOfferModel',
    'ChatMessageModel',
    'TaskAssignmentModel',
    'ReviewModel',
    'TaskCategoryModel',
]
