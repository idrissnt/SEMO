from payments.domain.repositories.payment_repository_interfaces import PaymentRepository
from payments.domain.repositories.payment_method_repository_interfaces import PaymentMethodRepository
from payments.domain.services.payment_service_interface import (
    PaymentServiceInterface,
    PaymentMethodServiceInterface
)
from payments.infrastructure.django_repositories.payment_repository import DjangoPaymentRepository
from payments.infrastructure.django_repositories.payment_method_repository import DjangoPaymentMethodRepository
from payments.infrastructure.services.stripe_payment_service import StripePaymentService
from payments.infrastructure.services.stripe_payment_method_service import StripePaymentMethodService
from payments.application.services.payment_application_service import PaymentApplicationService


class RepositoryFactory:
    """Factory for creating repository instances
    
    This factory is responsible for creating repository instances that implement
    the repository interfaces defined in the domain layer.
    """
    
    @staticmethod
    def create_payment_repository() -> PaymentRepository:
        """Create a payment repository instance"""
        return DjangoPaymentRepository()
    
    @staticmethod
    def create_payment_method_repository() -> PaymentMethodRepository:
        """Create a payment method repository instance"""
        return DjangoPaymentMethodRepository()


class DomainServiceFactory:
    """Factory for creating domain service instances
    
    This factory is responsible for creating domain service instances that implement
    the service interfaces defined in the domain layer.
    """
    
    @staticmethod
    def create_payment_service(payment_repository: PaymentRepository) -> PaymentServiceInterface:
        """Create a payment service instance"""
        return StripePaymentService(payment_repository)
    
    @staticmethod
    def create_payment_method_service(payment_method_repository: PaymentMethodRepository) -> PaymentMethodServiceInterface:
        """Create a payment method service instance"""
        return StripePaymentMethodService(payment_method_repository)


from payments.application.services.payment_method_application_service import PaymentMethodApplicationService

class ServiceFactory:
    """Factory for creating application service instances
    
    This factory is responsible for creating and wiring up all the dependencies
    needed by the application services, following the Dependency Inversion Principle.
    It creates repositories and domain services, then injects them into the
    application services.
    """
    
    @staticmethod
    def create_payment_service() -> PaymentApplicationService:
        """Create a payment application service instance with all dependencies
        
        Returns:
            A fully configured PaymentApplicationService instance
        """
        # Create repositories
        payment_repository = RepositoryFactory.create_payment_repository()
        
        # Create domain services
        payment_service = DomainServiceFactory.create_payment_service(payment_repository)
        
        # Create and return the application service
        return PaymentApplicationService(
            payment_service=payment_service,
            payment_repository=payment_repository
        )
    
    @staticmethod
    def create_payment_method_service() -> PaymentMethodApplicationService:
        """Create a payment method application service instance with all dependencies
        
        Returns:
            A fully configured PaymentMethodApplicationService instance
        """
        # Create repositories
        payment_method_repository = RepositoryFactory.create_payment_method_repository()
        
        # Create domain services
        payment_method_service = DomainServiceFactory.create_payment_method_service(payment_method_repository)
        
        # Create and return the application service
        return PaymentMethodApplicationService(
            payment_method_service=payment_method_service
        )
