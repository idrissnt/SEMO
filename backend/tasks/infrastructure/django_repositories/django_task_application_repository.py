from typing import List, Optional
import uuid
from django.db import transaction

# Import domain entities
from ...domain.models.entities.task_application import TaskApplication, NegotiationOffer
from ...domain.models.value_objects.application_status import ApplicationStatus
from ...domain.repositories.repository_interfaces import TaskApplicationRepository

# Import ORM models
from ..django_models.application.application import TaskApplicationModel
from ..django_models.application.negotiation import NegotiationOfferModel


class DjangoTaskApplicationRepository(TaskApplicationRepository):
    """Django ORM implementation of TaskApplicationRepository"""
    
    def get_by_id(self, application_id: uuid.UUID) -> Optional[TaskApplication]:
        """Get application by ID
        
        Args:
            application_id: UUID of the application
            
        Returns:
            TaskApplication object if found, None otherwise
        """
        try:
            application_model = TaskApplicationModel.objects.get(id=application_id)
            return self._application_model_to_domain(application_model)
        except TaskApplicationModel.DoesNotExist:
            return None
    
    def get_by_task_id(self, task_id: uuid.UUID) -> List[TaskApplication]:
        """Get all applications for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            List of TaskApplication objects
        """
        application_models = TaskApplicationModel.objects.filter(task_id=task_id)
        return [self._application_model_to_domain(model) for model in application_models]
    
    def get_by_performer_id(self, performer_id: uuid.UUID) -> List[TaskApplication]:
        """Get all applications submitted by a performer
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of TaskApplication objects
        """
        application_models = TaskApplicationModel.objects.filter(performer_id=performer_id)
        return [self._application_model_to_domain(model) for model in application_models]
    
    @transaction.atomic
    def create(self, application: TaskApplication) -> TaskApplication:
        """Create a new application
        
        Args:
            application: TaskApplication object to create
            
        Returns:
            Created TaskApplication object
        """
        application_model = TaskApplicationModel(
            id=application.id,
            task_id=application.task_id,
            performer_id=application.performer_id,
            message=application.message,
            price_offer=application.price_offer,
            created_at=application.created_at
        )
        application_model.save()
        return self._application_model_to_domain(application_model)
    
    @transaction.atomic
    def update(self, application: TaskApplication) -> TaskApplication:
        """Update an existing application
        
        Args:
            application: TaskApplication object with updated fields
            
        Returns:
            Updated TaskApplication object
        """
        try:
            application_model = TaskApplicationModel.objects.get(id=application.id)
            application_model.message = application.message
            application_model.price_offer = application.price_offer
            application_model.save()
            return self._application_model_to_domain(application_model)
        except TaskApplicationModel.DoesNotExist:
            return self.create(application)
    
    @transaction.atomic
    def delete(self, application_id: uuid.UUID) -> bool:
        """Delete an application
        
        Args:
            application_id: UUID of the application to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            application_model = TaskApplicationModel.objects.get(id=application_id)
            application_model.delete()
            return True
        except TaskApplicationModel.DoesNotExist:
            return False
    
    def _application_model_to_domain(self, model: TaskApplicationModel) -> TaskApplication:
        """Convert a TaskApplicationModel to a TaskApplication domain entity
        
        Args:
            model: TaskApplicationModel to convert
            
        Returns:
            TaskApplication domain entity
        """
        return TaskApplication(
            id=model.id,
            task_id=model.task_id,
            performer_id=model.performer_id,
            message=model.message,
            price_offer=float(model.price_offer) if model.price_offer else None,
            created_at=model.created_at
        )
