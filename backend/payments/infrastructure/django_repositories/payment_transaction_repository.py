from typing import List, Optional
from uuid import UUID

from payments.domain.models.entities import PaymentTransaction
from payments.domain.repositories.repository_interfaces import PaymentTransactionRepository
from payments.infrastructure.django_models.orm_models import PaymentTransactionModel


class DjangoPaymentTransactionRepository(PaymentTransactionRepository):
    """Django ORM implementation of PaymentTransactionRepository"""
    
    def create(self, transaction: PaymentTransaction) -> PaymentTransaction:
        """Create a new payment transaction"""
        transaction_model = PaymentTransactionModel(
            id=transaction.id,
            payment_id=transaction.payment_id,
            transaction_type=transaction.transaction_type,
            status=transaction.status,
            amount=transaction.amount,
            provider_transaction_id=transaction.provider_transaction_id,
            error_message=transaction.error_message
        )
        transaction_model.save()
        return self._to_domain_entity(transaction_model)
    
    def get_by_id(self, transaction_id: UUID) -> Optional[PaymentTransaction]:
        """Get transaction by ID"""
        try:
            transaction_model = PaymentTransactionModel.objects.get(id=transaction_id)
            return self._to_domain_entity(transaction_model)
        except PaymentTransactionModel.DoesNotExist:
            return None
    
    def get_by_payment_id(self, payment_id: UUID) -> List[PaymentTransaction]:
        """Get all transactions for a payment"""
        transaction_models = PaymentTransactionModel.objects.filter(payment_id=payment_id)
        return [self._to_domain_entity(model) for model in transaction_models]
    
    def get_by_provider_transaction_id(self, provider_transaction_id: str) -> Optional[PaymentTransaction]:
        """Get transaction by provider transaction ID"""
        try:
            transaction_model = PaymentTransactionModel.objects.get(
                provider_transaction_id=provider_transaction_id
            )
            return self._to_domain_entity(transaction_model)
        except PaymentTransactionModel.DoesNotExist:
            return None
    
    def _to_domain_entity(self, model: PaymentTransactionModel) -> PaymentTransaction:
        """Convert ORM model to domain entity"""
        return PaymentTransaction(
            id=model.id,
            payment_id=model.payment_id,
            transaction_type=model.transaction_type,
            status=model.status,
            amount=float(model.amount),
            provider_transaction_id=model.provider_transaction_id,
            error_message=model.error_message,
            created_at=model.created_at
        )
