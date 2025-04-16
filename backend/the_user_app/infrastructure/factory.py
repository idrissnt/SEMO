from the_user_app.domain.repositories.repository_interfaces import UserRepository, AddressRepository, AuthRepository, TaskPerformerProfileRepository
from the_user_app.infrastructure.django_repositories.django_user_repository import DjangoUserRepository
from the_user_app.infrastructure.django_repositories.django_address_repository import DjangoAddressRepository
from the_user_app.infrastructure.django_repositories.django_auth_repository import DjangoAuthRepository
from the_user_app.infrastructure.django_repositories.django_task_performer_profile_repository import DjangoTaskPerformerProfileRepository

from the_user_app.domain.services.logging_service_interface import LoggingServiceInterface
from the_user_app.infrastructure.services.django_logging_service import DjangoLoggingService

from the_user_app.application.services.auth_service import AuthApplicationService
from the_user_app.application.services.user_service import UserApplicationService
from the_user_app.application.services.address_service import AddressApplicationService
from the_user_app.application.services.task_performer_service import TaskPerformerApplicationService

class UserFactory:
    """Factory for creating user-related services and repositories"""
    
    # Singleton instance of the logging service
    _logging_service = None
    
    @staticmethod
    def create_user_repository() -> UserRepository:
        """Create a UserRepository implementation
        
        Returns:
            UserRepository implementation
        """
        return DjangoUserRepository()
    
    @staticmethod
    def create_address_repository() -> AddressRepository:
        """Create an AddressRepository implementation
        
        Returns:
            AddressRepository implementation
        """
        return DjangoAddressRepository()
    
    @staticmethod
    def create_auth_repository() -> AuthRepository:
        """Create an AuthRepository implementation
        
        Returns:
            AuthRepository implementation
        """
        return DjangoAuthRepository()
    
    @staticmethod
    def create_logging_service(logger_name: str = "semo") -> LoggingServiceInterface:
        """Create or get the singleton LoggingService instance
        
        Args:
            logger_name: Name of the logger
            
        Returns:
            LoggingServiceInterface implementation
        """
        if UserFactory._logging_service is None:
            UserFactory._logging_service = DjangoLoggingService(logger_name)
        return UserFactory._logging_service
    
    @staticmethod
    def create_auth_service() -> AuthApplicationService:
        """Create an AuthApplicationService
        
        Returns:
            AuthApplicationService instance
        """
        user_repository = UserFactory.create_user_repository()
        auth_repository = UserFactory.create_auth_repository()
        logging_service = UserFactory.create_logging_service("auth")
        return AuthApplicationService(user_repository, auth_repository, logging_service)
    
    @staticmethod
    def create_user_service() -> UserApplicationService:
        """Create a UserApplicationService
        
        Returns:
            UserApplicationService instance
        """
        user_repository = UserFactory.create_user_repository()
        return UserApplicationService(user_repository)
    
    @staticmethod
    def create_address_service() -> AddressApplicationService:
        """Create an AddressApplicationService
        
        Returns:
            AddressApplicationService instance
        """
        address_repository = UserFactory.create_address_repository()
        user_repository = UserFactory.create_user_repository()
        return AddressApplicationService(address_repository, user_repository)
    
    @staticmethod
    def create_task_performer_profile_repository() -> TaskPerformerProfileRepository:
        """Create a TaskPerformerProfileRepository implementation
        
        Returns:
            TaskPerformerProfileRepository implementation
        """
        return DjangoTaskPerformerProfileRepository()
    
    @staticmethod
    def create_task_performer_service() -> TaskPerformerApplicationService:
        """Create a TaskPerformerApplicationService
        
        Returns:
            TaskPerformerApplicationService instance
        """
        task_performer_profile_repository = UserFactory.create_task_performer_profile_repository()
        user_repository = UserFactory.create_user_repository()
        return TaskPerformerApplicationService(task_performer_profile_repository, user_repository)
