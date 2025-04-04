
"""
Django ORM repositories for the tasks app.
This module re-exports all repositories for backward compatibility.
"""
# Task models
from tasks.infrastructure.django_repositories.django_task_repository import DjangoTaskRepository

# Application models
from tasks.infrastructure.django_repositories.django_task_application_repository import DjangoTaskApplicationRepository

# Assignment models
from tasks.infrastructure.django_repositories.django_task_assignment_repository import DjangoTaskAssignmentRepository

# Review models
from tasks.infrastructure.django_repositories.django_review_repository import DjangoReviewRepository

# Negotiation models
from tasks.infrastructure.django_repositories.django_negotiation_offer_repository import DjangoNegotiationOfferRepository

# Predefined task type models
from tasks.infrastructure.django_repositories.django_predefined_task_type_repository import DjangoPredefinedTaskTypeRepository

# Chat message models
from tasks.infrastructure.django_repositories.django_chat_message_repository import DjangoChatMessageRepository

# Task category models
from tasks.infrastructure.django_repositories.django_task_category_repository import DjangoTaskCategoryRepository

__all__ = [
    'DjangoTaskRepository',
    'DjangoTaskApplicationRepository',
    'DjangoTaskAssignmentRepository',
    'DjangoReviewRepository',
    'DjangoNegotiationOfferRepository',
    'DjangoPredefinedTaskTypeRepository',
    'DjangoChatMessageRepository',
    'DjangoTaskCategoryRepository'
]
