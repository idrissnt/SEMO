from typing import List, Optional
from uuid import UUID

from payments.domain.models.entities import Payment
from payments.domain.repositories.repository_interfaces import PaymentRepository
from payments.infrastructure.django_models.orm_models import PaymentModel


class DjangoPaymentRepository(PaymentRepository):
    """Django ORM implementation of PaymentRepository"""
    
    def create(self, payment: Payment) -> Payment:
        """Create a new payment"""
        payment_model = PaymentModel(
            id=payment.id,
            order_id=payment.order_id,
            payment_method=payment.payment_method,
            status=payment.status,
            amount=payment.amount,
            transaction_id=payment.transaction_id
        )
        payment_model.save()
        return self._to_domain_entity(payment_model)
    
    def get_by_id(self, payment_id: UUID) -> Optional[Payment]:
        """Get payment by ID"""
        try:
            payment_model = PaymentModel.objects.get(id=payment_id)
            return self._to_domain_entity(payment_model)
        except PaymentModel.DoesNotExist:
            return None
    
    def get_by_order_id(self, order_id: UUID) -> Optional[Payment]:
        """Get payment by order ID"""
        try:
            payment_model = PaymentModel.objects.get(order_id=order_id)
            return self._to_domain_entity(payment_model)
        except PaymentModel.DoesNotExist:
            return None
    
    def get_by_user_id(self, user_id: UUID) -> List[Payment]:
        """Get all payments for a user"""
        payment_models = PaymentModel.objects.filter(order__user_id=user_id)
        return [self._to_domain_entity(model) for model in payment_models]
    
    def update(self, payment: Payment) -> Payment:
        """Update an existing payment"""
        try:
            payment_model = PaymentModel.objects.get(id=payment.id)
            payment_model.payment_method = payment.payment_method
            payment_model.status = payment.status
            payment_model.amount = payment.amount
            payment_model.transaction_id = payment.transaction_id
            payment_model.save()
            return self._to_domain_entity(payment_model)
        except PaymentModel.DoesNotExist:
            raise ValueError(f"Payment with ID {payment.id} does not exist")
    
    def _to_domain_entity(self, model: PaymentModel) -> Payment:
        """Convert ORM model to domain entity"""
        return Payment(
            id=model.id,
            order_id=model.order.id,
            payment_method=model.payment_method,
            status=model.status,
            amount=float(model.amount),
            transaction_id=model.transaction_id,
            created_at=model.created_at
        )
