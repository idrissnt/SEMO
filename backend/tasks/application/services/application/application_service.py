"""
Application service for task application-related operations.
"""
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime

from ....domain.models.entities.task_application import TaskApplication, NegotiationOffer
from ....domain.models.value_objects.application_status import ApplicationStatus
from ....domain.repositories.task.task_repository import TaskRepository
from ....domain.repositories.application.application_repository import TaskApplicationRepository
from ....domain.repositories.application.negotiation_repository import NegotiationOfferRepository


class ApplicationService:
    """Application service for task application-related operations"""
    
    def __init__(
        self,
        task_repository: TaskRepository,
        task_application_repository: TaskApplicationRepository,
        negotiation_repository: NegotiationOfferRepository
    ):
        self.task_repository = task_repository
        self.task_application_repository = task_application_repository
        self.negotiation_repository = negotiation_repository
    
    def get_application(self, application_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Get application by ID
        
        Args:
            application_id: UUID of the application
            
        Returns:
            Dictionary with application information if found, None otherwise
        """
        application = self.task_application_repository.get_by_id(application_id)
        if application:
            return self._application_to_dict(application)
        return None
    
    def get_applications_by_task(self, task_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all applications for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            List of dictionaries with application information
        """
        applications = self.task_application_repository.get_by_task_id(task_id)
        return [self._application_to_dict(app) for app in applications]
    
    def get_applications_by_performer(self, performer_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all applications submitted by a performer
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of dictionaries with application information
        """
        applications = self.task_application_repository.get_by_performer_id(performer_id)
        return [self._application_to_dict(app) for app in applications]
    
    def create_application(self, application_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new application
        
        Args:
            application_data: Dictionary with application data
            
        Returns:
            Dictionary with created application information
        """
        # Extract required fields
        task_id = uuid.UUID(application_data['task_id'])
        performer_id = uuid.UUID(application_data['performer_id'])
        initial_message = application_data['initial_message']
        initial_offer = float(application_data['initial_offer'])
        
        # Create application
        application = TaskApplication(
            task_id=task_id,
            performer_id=performer_id,
            initial_message=initial_message,
            initial_offer=initial_offer
        )
        
        # Save application
        created_application = self.task_application_repository.create(application)
        return self._application_to_dict(created_application)
    
    def add_counter_offer(self, application_id: uuid.UUID, offer_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Add a counter offer to an application
        
        Args:
            application_id: UUID of the application
            offer_data: Dictionary with offer data
            
        Returns:
            Dictionary with updated application information if successful, None otherwise
        """
        # Get existing application
        application = self.task_application_repository.get_by_id(application_id)
        if not application:
            return None
        
        # Extract offer data
        amount = float(offer_data['amount'])
        message = offer_data['message']
        created_by = offer_data['created_by']
        
        # Create negotiation offer
        offer = NegotiationOffer(
            amount=amount,
            message=message,
            created_by=created_by
        )
        
        # Add offer to application
        self.negotiation_repository.create(offer)
        
        # Update application status
        application.add_counter_offer(amount, message, created_by)
        updated_application = self.task_application_repository.update(application)
        
        return self._application_to_dict(updated_application)
    
    def accept_application(self, application_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Accept an application
        
        Args:
            application_id: UUID of the application to accept
            
        Returns:
            Dictionary with accepted application information if successful, None otherwise
        """
        # Get existing application
        application = self.task_application_repository.get_by_id(application_id)
        if not application:
            return None
        
        # Accept application
        application.accept()
        
        # Save application
        updated_application = self.task_application_repository.update(application)
        return self._application_to_dict(updated_application)
    
    def reject_application(self, application_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Reject an application
        
        Args:
            application_id: UUID of the application to reject
            
        Returns:
            Dictionary with rejected application information if successful, None otherwise
        """
        # Get existing application
        application = self.task_application_repository.get_by_id(application_id)
        if not application:
            return None
        
        # Reject application
        application.reject()
        
        # Save application
        updated_application = self.task_application_repository.update(application)
        return self._application_to_dict(updated_application)
    
    def withdraw_application(self, application_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Withdraw an application
        
        Args:
            application_id: UUID of the application to withdraw
            
        Returns:
            Dictionary with withdrawn application information if successful, None otherwise
        """
        # Get existing application
        application = self.task_application_repository.get_by_id(application_id)
        if not application:
            return None
        
        # Withdraw application
        application.withdraw()
        
        # Save application
        updated_application = self.task_application_repository.update(application)
        return self._application_to_dict(updated_application)
    
    def get_negotiation_history(self, application_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get negotiation history for an application
        
        Args:
            application_id: UUID of the application
            
        Returns:
            List of dictionaries with negotiation offer information
        """
        offers = self.negotiation_repository.get_by_application_id(application_id)
        return [self._offer_to_dict(offer) for offer in offers]
    
    def _application_to_dict(self, application: TaskApplication) -> Dict[str, Any]:
        """Convert TaskApplication object to dictionary
        
        Args:
            application: TaskApplication object
            
        Returns:
            Dictionary with application information
        """
        return {
            'id': str(application.id),
            'task_id': str(application.task_id),
            'performer_id': str(application.performer_id),
            'initial_message': application.initial_message,
            'initial_offer': application.initial_offer,
            'status': application.status.value,
            'chat_enabled': application.chat_enabled,
            'created_at': application.created_at.isoformat(),
            'updated_at': application.updated_at.isoformat(),
            'final_offer': application.get_final_offer()
        }
    
    def _offer_to_dict(self, offer: NegotiationOffer) -> Dict[str, Any]:
        """Convert NegotiationOffer object to dictionary
        
        Args:
            offer: NegotiationOffer object
            
        Returns:
            Dictionary with offer information
        """
        return {
            'id': str(offer.id),
            'amount': offer.amount,
            'message': offer.message,
            'created_by': offer.created_by,
            'created_at': offer.created_at.isoformat()
        }
