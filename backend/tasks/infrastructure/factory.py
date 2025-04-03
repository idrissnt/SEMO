from typing import Optional

# Import repository interfaces
from ..domain.repositories.task.task_repository import TaskRepository
from ..domain.repositories.application.application_repository import TaskApplicationRepository
from ..domain.repositories.application.chat_message_repository import ChatMessageRepository
from ..domain.repositories.application.negotiation_repository import NegotiationOfferRepository
from ..domain.repositories.assignment.assignment_repository import TaskAssignmentRepository
from ..domain.repositories.review.review_repository import ReviewRepository
from ..domain.repositories.category.category_template_repository import TaskCategoryTemplateRepository

# Import domain services
from ..domain.services.task_service_interface import TaskService

# Import repository implementations
from .django_repositories.django_task_repository import DjangoTaskRepository
from .django_repositories.django_task_application_repository import DjangoTaskApplicationRepository
from .django_repositories.django_chat_message_repository import DjangoChatMessageRepository
from .django_repositories.django_negotiation_offer_repository import DjangoNegotiationOfferRepository
from .django_repositories.django_task_assignment_repository import DjangoTaskAssignmentRepository
from .django_repositories.django_review_repository import DjangoReviewRepository
from .django_repositories.django_task_category_template_repository import DjangoTaskCategoryTemplateRepository

# Import service implementations
from .services.task_service import DjangoTaskService

# Import application services
from ..application.services.task.task_service import TaskApplicationService
from ..application.services.application.application_service import ApplicationService
from ..application.services.application.chat_service import ChatService
from ..application.services.assignment.assignment_service import AssignmentService
from ..application.services.review.review_service import ReviewService
from ..application.services.category.category_template_service import CategoryTemplateService


class RepositoryFactory:
    """Factory for creating repository instances"""
    
    _task_repository: Optional[TaskRepository] = None
    _task_application_repository: Optional[TaskApplicationRepository] = None
    _chat_message_repository: Optional[ChatMessageRepository] = None
    _negotiation_offer_repository: Optional[NegotiationOfferRepository] = None
    _task_assignment_repository: Optional[TaskAssignmentRepository] = None
    _review_repository: Optional[ReviewRepository] = None
    _task_category_template_repository: Optional[TaskCategoryTemplateRepository] = None
    
    @classmethod
    def get_task_repository(cls) -> TaskRepository:
        """Get the task repository instance
        
        Returns:
            TaskRepository instance
        """
        if cls._task_repository is None:
            cls._task_repository = DjangoTaskRepository()
        return cls._task_repository
    
    @classmethod
    def get_task_application_repository(cls) -> TaskApplicationRepository:
        """Get the task application repository instance
        
        Returns:
            TaskApplicationRepository instance
        """
        if cls._task_application_repository is None:
            cls._task_application_repository = DjangoTaskApplicationRepository()
        return cls._task_application_repository
    
    @classmethod
    def get_chat_message_repository(cls) -> ChatMessageRepository:
        """Get the chat message repository instance
        
        Returns:
            ChatMessageRepository instance
        """
        if cls._chat_message_repository is None:
            cls._chat_message_repository = DjangoChatMessageRepository()
        return cls._chat_message_repository
    
    @classmethod
    def get_negotiation_offer_repository(cls) -> NegotiationOfferRepository:
        """Get the negotiation offer repository instance
        
        Returns:
            NegotiationOfferRepository instance
        """
        if cls._negotiation_offer_repository is None:
            cls._negotiation_offer_repository = DjangoNegotiationOfferRepository()
        return cls._negotiation_offer_repository
        
    @classmethod
    def get_task_assignment_repository(cls) -> TaskAssignmentRepository:
        """Get the task assignment repository instance
        
        Returns:
            TaskAssignmentRepository instance
        """
        if cls._task_assignment_repository is None:
            cls._task_assignment_repository = DjangoTaskAssignmentRepository()
        return cls._task_assignment_repository
    
    @classmethod
    def get_review_repository(cls) -> ReviewRepository:
        """Get the review repository instance
        
        Returns:
            ReviewRepository instance
        """
        if cls._review_repository is None:
            cls._review_repository = DjangoReviewRepository()
        return cls._review_repository
    
    @classmethod
    def get_task_category_template_repository(cls) -> TaskCategoryTemplateRepository:
        """Get the task category template repository instance
        
        Returns:
            TaskCategoryTemplateRepository instance
        """
        if cls._task_category_template_repository is None:
            cls._task_category_template_repository = DjangoTaskCategoryTemplateRepository()
        return cls._task_category_template_repository
    
    # For testing
    @classmethod
    def set_task_repository(cls, repository: TaskRepository) -> None:
        cls._task_repository = repository
    
    @classmethod
    def set_task_application_repository(cls, repository: TaskApplicationRepository) -> None:
        cls._task_application_repository = repository
    
    @classmethod
    def set_chat_message_repository(cls, repository: ChatMessageRepository) -> None:
        cls._chat_message_repository = repository
    
    @classmethod
    def set_negotiation_offer_repository(cls, repository: NegotiationOfferRepository) -> None:
        cls._negotiation_offer_repository = repository
    
    @classmethod
    def set_task_assignment_repository(cls, repository: TaskAssignmentRepository) -> None:
        cls._task_assignment_repository = repository
    
    @classmethod
    def set_review_repository(cls, repository: ReviewRepository) -> None:
        cls._review_repository = repository
    
    @classmethod
    def set_task_category_template_repository(cls, repository: TaskCategoryTemplateRepository) -> None:
        cls._task_category_template_repository = repository


class ServiceFactory:
    """Factory for creating service instances"""
    
    # Domain services
    _task_service: Optional[TaskService] = None
    
    # Application services
    _task_application_service: Optional[TaskApplicationService] = None
    _application_service: Optional[ApplicationService] = None
    _chat_service: Optional[ChatService] = None
    _assignment_service: Optional[AssignmentService] = None
    _review_service: Optional[ReviewService] = None
    _category_template_service: Optional[CategoryTemplateService] = None
    
    # Domain service getters
    @classmethod
    def get_task_service(cls) -> TaskService:
        """Get the task service instance
        
        Returns:
            TaskService instance
        """
        if cls._task_service is None:
            cls._task_service = DjangoTaskService(
                task_repository=RepositoryFactory.get_task_repository(),
                task_application_repository=RepositoryFactory.get_task_application_repository(),
                task_assignment_repository=RepositoryFactory.get_task_assignment_repository(),
                task_category_template_repository=RepositoryFactory.get_task_category_template_repository()
            )
        return cls._task_service
    
    # Application service getters
    @classmethod
    def get_task_application_service(cls) -> TaskApplicationService:
        """Get the task application service instance
        
        Returns:
            TaskApplicationService instance
        """
        if cls._task_application_service is None:
            cls._task_application_service = TaskApplicationService(
                task_repository=RepositoryFactory.get_task_repository(),
                task_category_template_repository=RepositoryFactory.get_task_category_template_repository(),
                task_service=cls.get_task_service()
            )
        return cls._task_application_service
    
    @classmethod
    def get_application_service(cls) -> ApplicationService:
        """Get the application service instance
        
        Returns:
            ApplicationService instance
        """
        if cls._application_service is None:
            cls._application_service = ApplicationService(
                task_repository=RepositoryFactory.get_task_repository(),
                task_application_repository=RepositoryFactory.get_task_application_repository(),
                negotiation_repository=RepositoryFactory.get_negotiation_offer_repository()
            )
        return cls._application_service
    
    @classmethod
    def get_chat_service(cls) -> ChatService:
        """Get the chat service instance
        
        Returns:
            ChatService instance
        """
        if cls._chat_service is None:
            cls._chat_service = ChatService(
                chat_message_repository=RepositoryFactory.get_chat_message_repository(),
                task_application_repository=RepositoryFactory.get_task_application_repository()
            )
        return cls._chat_service
    
    @classmethod
    def get_assignment_service(cls) -> AssignmentService:
        """Get the assignment service instance
        
        Returns:
            AssignmentService instance
        """
        if cls._assignment_service is None:
            cls._assignment_service = AssignmentService(
                task_repository=RepositoryFactory.get_task_repository(),
                task_assignment_repository=RepositoryFactory.get_task_assignment_repository(),
                task_application_repository=RepositoryFactory.get_task_application_repository()
            )
        return cls._assignment_service
    
    @classmethod
    def get_review_service(cls) -> ReviewService:
        """Get the review service instance
        
        Returns:
            ReviewService instance
        """
        if cls._review_service is None:
            cls._review_service = ReviewService(
                review_repository=RepositoryFactory.get_review_repository(),
                task_repository=RepositoryFactory.get_task_repository(),
                task_assignment_repository=RepositoryFactory.get_task_assignment_repository()
            )
        return cls._review_service
    
    @classmethod
    def get_category_template_service(cls) -> CategoryTemplateService:
        """Get the category template service instance
        
        Returns:
            CategoryTemplateService instance
        """
        if cls._category_template_service is None:
            cls._category_template_service = CategoryTemplateService(
                task_category_template_repository=RepositoryFactory.get_task_category_template_repository()
            )
        return cls._category_template_service
    
    # For testing - Domain services
    @classmethod
    def set_task_service(cls, service: TaskService) -> None:
        cls._task_service = service
        
    # For testing - Application services
    @classmethod
    def set_task_application_service(cls, service: TaskApplicationService) -> None:
        cls._task_application_service = service
    
    @classmethod
    def set_application_service(cls, service: ApplicationService) -> None:
        cls._application_service = service
    
    @classmethod
    def set_chat_service(cls, service: ChatService) -> None:
        cls._chat_service = service
    
    @classmethod
    def set_assignment_service(cls, service: AssignmentService) -> None:
        cls._assignment_service = service
    
    @classmethod
    def set_review_service(cls, service: ReviewService) -> None:
        cls._review_service = service
    
    @classmethod
    def set_category_template_service(cls, service: CategoryTemplateService) -> None:
        cls._category_template_service = service
