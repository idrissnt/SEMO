from payments.domain.repositories.repository_interfaces import (
    PaymentRepository, 
    PaymentMethodRepository,
    PaymentTransactionRepository
)
from payments.infrastructure.django_repositories.payment_repository import DjangoPaymentRepository
from payments.infrastructure.django_repositories.payment_method_repository import DjangoPaymentMethodRepository
from payments.infrastructure.django_repositories.payment_transaction_repository import DjangoPaymentTransactionRepository


class RepositoryFactory:
    """Factory for creating repository instances"""
    
    @staticmethod
    def create_payment_repository() -> PaymentRepository:
        """Create a payment repository instance"""
        return DjangoPaymentRepository()
    
    @staticmethod
    def create_payment_method_repository() -> PaymentMethodRepository:
        """Create a payment method repository instance"""
        return DjangoPaymentMethodRepository()
    
    @staticmethod
    def create_payment_transaction_repository() -> PaymentTransactionRepository:
        """Create a payment transaction repository instance"""
        return DjangoPaymentTransactionRepository()
