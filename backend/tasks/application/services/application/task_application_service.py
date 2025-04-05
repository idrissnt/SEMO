"""
Application service for task application-related operations.
"""
from typing import List, Optional, Dict, Any
import uuid

from domain.models import TaskApplication, NegotiationOffer
from domain.repositories import (TaskRepository, 
                                TaskApplicationRepository, 
                                NegotiationOfferRepository)


class TaskApplicationService:
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
    
    def get_application(self, application_id: uuid.UUID) -> Optional[TaskApplication]:
        """Get application by ID
        
        Args:
            application_id: UUID of the application
            
        Returns:
            TaskApplication object if found, None otherwise
        """
        application = self.task_application_repository.get_by_id(application_id)
        if application:
            return application
        return None
    
    def get_applications_by_task(self, task_id: uuid.UUID) -> List[TaskApplication]:
        """Get all applications for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            List of TaskApplication objects
        """
        return self.task_application_repository.get_by_task_id(task_id)
    
    def get_applications_by_performer(self, performer_id: uuid.UUID) -> List[TaskApplication]:
        """Get all applications submitted by a performer
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of TaskApplication objects
        """
        return self.task_application_repository.get_by_performer_id(performer_id)
    
    def create_application(self, application_data: Dict[str, Any]) -> TaskApplication:
        """Create a new application
        
        Args:
            application_data: Dictionary with application data
            
        Returns:
            TaskApplication object
        """
        # Create application domain entity
        application = TaskApplication(
            task_id=uuid.UUID(application_data['task_id']),
            performer_id=uuid.UUID(application_data['performer_id']),
            initial_message=application_data['initial_message'],
            initial_offer=application_data.get('initial_offer')
        )
        
        # Save application
        return self.task_application_repository.create(application)
    
    def add_counter_offer(self, application_id: uuid.UUID, offer_data: Dict[str, Any]) -> Optional[TaskApplication]:
        """Add a counter offer to an application
        
        Args:
            application_id: UUID of the application
            offer_data: Dictionary with offer data
            
        Returns:
            TaskApplication object if successful, None otherwise
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
        updated_application = self.task_application_repository.update_status(application)
        
        return updated_application
    
    def accept_application(self, application_id: uuid.UUID) -> Optional[TaskApplication]:
        """Accept an application
        
        Args:
            application_id: UUID of the application to accept
            
        Returns:
            TaskApplication object if successful, None otherwise
        """
        # Get existing application
        application = self.task_application_repository.get_by_id(application_id)
        if not application:
            return None
        
        # Accept application
        application.accept()
        
        # Save application
        updated_application = self.task_application_repository.update_status(application)
        return updated_application
    
    def reject_application(self, application_id: uuid.UUID) -> Optional[TaskApplication]:
        """Reject an application
        
        Args:
            application_id: UUID of the application to reject
            
        Returns:
            TaskApplication object if successful, None otherwise
        """
        # Get existing application
        application = self.task_application_repository.get_by_id(application_id)
        if not application:
            return None
        
        # Reject application
        application.reject()
        
        # Save application
        updated_application = self.task_application_repository.update_status(application)
        return updated_application
    
    def withdraw_application(self, application_id: uuid.UUID) -> Optional[TaskApplication]:
        """Withdraw an application
        
        Args:
            application_id: UUID of the application to withdraw
            
        Returns:
            TaskApplication object if successful, None otherwise
        """
        # Get existing application
        application = self.task_application_repository.get_by_id(application_id)
        if not application:
            return None
        
        # Withdraw application
        application.withdraw()
        
        # Save application
        updated_application = self.task_application_repository.update_status(application)
        return updated_application
    
    def get_negotiation_history(self, application_id: uuid.UUID) -> List[NegotiationOffer]:
        """Get negotiation history for an application
        
        Args:
            application_id: UUID of the application
            
        Returns:
            List of NegotiationOffer objects
        """
        return self.negotiation_repository.get_by_application_id(application_id)
    
