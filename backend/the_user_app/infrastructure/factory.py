from the_user_app.domain.repositories.repository_interfaces import UserRepository, AddressRepository, AuthRepository, TaskPerformerProfileRepository
from the_user_app.infrastructure.django_repositories.django_user_repository import DjangoUserRepository
from the_user_app.infrastructure.django_repositories.django_address_repository import DjangoAddressRepository
from the_user_app.infrastructure.django_repositories.django_auth_repository import DjangoAuthRepository
from the_user_app.infrastructure.django_repositories.django_task_performer_profile_repository import DjangoTaskPerformerProfileRepository


from the_user_app.application.services.auth_service import AuthApplicationService
from the_user_app.application.services.user_service import UserApplicationService
from the_user_app.application.services.address_service import AddressApplicationService
from the_user_app.application.services.task_performer_service import TaskPerformerApplicationService

class UserFactory:
    """Factory for creating user-related services and repositories"""
    
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
    def create_auth_service() -> AuthApplicationService:
        """Create an AuthApplicationService
        
        Returns:
            AuthApplicationService instance
        """
        user_repository = UserFactory.create_user_repository()
        auth_repository = UserFactory.create_auth_repository()
        return AuthApplicationService(user_repository, auth_repository)
    
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
