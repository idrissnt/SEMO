"""
Django ORM implementation of the payment repository interface.

This module provides a concrete implementation of the payment repository
interface using Django's ORM for data access.
"""

from typing import List, Optional
from uuid import UUID

from payments.domain.models.entities import Payment
from payments.domain.repositories.payment_repository_interfaces import PaymentRepository
from payments.infrastructure.django_models.orm_models import PaymentModel


class DjangoPaymentRepository(PaymentRepository):
    """Django ORM implementation of PaymentRepository
    
    This class provides a concrete implementation of the payment repository
    interface using Django's ORM for data access. It handles the conversion
    between domain entities and ORM models.
    """
    
    def create(self, payment: Payment) -> Payment:
        payment_model = PaymentModel(
            id=payment.id,
            order_id=payment.order_id,
            amount=payment.amount,
            currency=payment.currency,
            status=payment.status,
            external_id=payment.external_id,
            external_client_secret=payment.external_client_secret,
            payment_method_id=payment.payment_method_id,
        )
        
        if payment.metadata:
            payment_model.metadata = payment.metadata
            
        payment_model.save()
        return self._to_domain_entity(payment_model)
    
    def get_by_id(self, payment_id: UUID) -> Optional[Payment]:
        try:
            payment_model = PaymentModel.objects.get(id=payment_id)
            return self._to_domain_entity(payment_model)
        except PaymentModel.DoesNotExist:
            return None
    
    def get_by_order_id(self, order_id: UUID) -> Optional[Payment]:
        try:
            payment_model = PaymentModel.objects.get(order_id=order_id)
            return self._to_domain_entity(payment_model)
        except PaymentModel.DoesNotExist:
            return None
    
    def get_by_external_id(self, external_id: str) -> Optional[Payment]:
        try:
            payment_model = PaymentModel.objects.get(external_id=external_id)
            return self._to_domain_entity(payment_model)
        except PaymentModel.DoesNotExist:
            return None
    
    def get_by_user_id(self, user_id: UUID) -> List[Payment]:
        # Use the reverse relationship from OrderModel to PaymentModel
        payment_models = PaymentModel.objects.filter(payment_order__user_id=user_id)
        return [self._to_domain_entity(model) for model in payment_models]
    
    def update(self, payment: Payment) -> Payment:
        try:
            payment_model = PaymentModel.objects.get(id=payment.id)
            payment_model.status = payment.status
            payment_model.amount = payment.amount
            payment_model.currency = payment.currency
            payment_model.external_id = payment.external_id
            payment_model.external_client_secret = payment.external_client_secret
            payment_model.payment_method_id = payment.payment_method_id
            payment_model.requires_action = payment.requires_action
            
            if payment.metadata:
                payment_model.metadata = payment.metadata
                
            payment_model.save()
            return self._to_domain_entity(payment_model)
        except PaymentModel.DoesNotExist:
            raise ValueError(f"Payment with ID {payment.id} does not exist")
    
    def belongs_to_user(self, payment_id: UUID, user_id: UUID) -> bool:
        # Use the reverse relationship from OrderModel to PaymentModel
        return PaymentModel.objects.filter(id=payment_id, payment_order__user_id=user_id).exists()
    
    def _to_domain_entity(self, model: PaymentModel) -> Payment:
        return Payment(
            id=model.id,
            order_id=model.order_id,
            amount=float(model.amount),
            currency=model.currency,
            status=model.status,
            external_id=model.external_id,
            external_client_secret=model.external_client_secret,
            payment_method_id=model.payment_method_id,
            requires_action=model.requires_action,
            metadata=model.metadata,
            created_at=model.created_at,
            updated_at=model.updated_at
        )
