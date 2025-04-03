"""
Repository interface for NegotiationOffer domain model.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
import uuid

from ...models.entities.task_application import NegotiationOffer


class NegotiationOfferRepository(ABC):
    """Repository interface for NegotiationOffer domain model"""
    
    @abstractmethod
    def get_by_id(self, offer_id: uuid.UUID) -> Optional[NegotiationOffer]:
        """Get offer by ID
        
        Args:
            offer_id: UUID of the offer
            
        Returns:
            NegotiationOffer object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_application_id(self, application_id: uuid.UUID) -> List[NegotiationOffer]:
        """Get all offers for a task application
        
        Args:
            application_id: UUID of the task application
            
        Returns:
            List of NegotiationOffer objects ordered by creation time
        """
        pass
    
    @abstractmethod
    def get_latest_by_application_id(self, application_id: uuid.UUID) -> Optional[NegotiationOffer]:
        """Get the latest offer for a task application
        
        Args:
            application_id: UUID of the task application
            
        Returns:
            Latest NegotiationOffer object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def create(self, offer: NegotiationOffer) -> NegotiationOffer:
        """Create a new offer
        
        Args:
            offer: NegotiationOffer object to create
            
        Returns:
            Created NegotiationOffer object
        """
        pass
    
    @abstractmethod
    def delete(self, offer_id: uuid.UUID) -> bool:
        """Delete an offer
        
        Args:
            offer_id: UUID of the offer to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
