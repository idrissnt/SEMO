"""
Django implementation of the NegotiationOfferRepository interface.
"""
from typing import List, Optional
import uuid
from decimal import Decimal

from ...domain.repositories.application.negotiation_repository import NegotiationOfferRepository
from ...domain.models.entities.task_application import NegotiationOffer
from ..django_models.application.negotiation import NegotiationOfferModel


class DjangoNegotiationOfferRepository(NegotiationOfferRepository):
    """Django ORM implementation of the NegotiationOfferRepository interface"""
    
    def get_by_id(self, offer_id: uuid.UUID) -> Optional[NegotiationOffer]:
        """Get offer by ID
        
        Args:
            offer_id: UUID of the offer
            
        Returns:
            NegotiationOffer object if found, None otherwise
        """
        try:
            offer_model = NegotiationOfferModel.objects.get(id=offer_id)
            return self._to_entity(offer_model)
        except NegotiationOfferModel.DoesNotExist:
            return None
    
    def get_by_application_id(self, application_id: uuid.UUID) -> List[NegotiationOffer]:
        """Get all offers for a task application
        
        Args:
            application_id: UUID of the task application
            
        Returns:
            List of NegotiationOffer objects
        """
        offer_models = NegotiationOfferModel.objects.filter(application_id=application_id).order_by('created_at')
        return [self._to_entity(offer_model) for offer_model in offer_models]
    
    def create(self, application_id: uuid.UUID, amount: Decimal, message: str, created_by: str) -> NegotiationOffer:
        """Create a new negotiation offer
        
        Args:
            application_id: UUID of the task application
            amount: Offer amount
            message: Offer message
            created_by: Who created the offer ('requester' or 'performer')
            
        Returns:
            Created NegotiationOffer object
        """
        offer_model = NegotiationOfferModel.objects.create(
            application_id=application_id,
            amount=amount,
            message=message,
            created_by=created_by
        )
        return self._to_entity(offer_model)
    
    def delete(self, offer_id: uuid.UUID) -> bool:
        """Delete a negotiation offer
        
        Args:
            offer_id: UUID of the offer to delete
            
        Returns:
            True if deleted, False otherwise
        """
        try:
            offer_model = NegotiationOfferModel.objects.get(id=offer_id)
            offer_model.delete()
            return True
        except NegotiationOfferModel.DoesNotExist:
            return False
    
    def _to_entity(self, offer_model: NegotiationOfferModel) -> NegotiationOffer:
        """Convert Django ORM model to domain entity
        
        Args:
            offer_model: Django ORM model
            
        Returns:
            NegotiationOffer domain entity
        """
        return NegotiationOffer(
            id=offer_model.id,
            application_id=offer_model.application.id,
            amount=offer_model.amount,
            message=offer_model.message,
            created_by=offer_model.created_by,
            created_at=offer_model.created_at
        )
