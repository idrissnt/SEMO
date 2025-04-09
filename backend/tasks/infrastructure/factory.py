from typing import Optional

# Import repository interfaces
from ..domain.repositories import (
    TaskRepository,
    TaskApplicationRepository,
    ChatMessageRepository,
    NegotiationOfferRepository,
    TaskAssignmentRepository,
    ReviewRepository,
    PredefinedTaskTypeRepository,
    TaskCategoryRepository
)

# Import repository implementations
from .django_repositories import (
    DjangoTaskRepository,
    DjangoTaskApplicationRepository,
    DjangoChatMessageRepository,
    DjangoNegotiationOfferRepository,
    DjangoTaskAssignmentRepository,
    DjangoReviewRepository,
    DjangoPredefinedTaskTypeRepository,
    DjangoTaskCategoryRepository
)

# Import application services
from ..application.services import (
    TaskService,
    TaskApplicationService,
    ChatService,
    AssignmentService,
    ReviewService,
    PredefinedTaskTypeService,
    TaskCategoryService
)


class RepositoryFactory:
    """Factory for creating repository instances"""
    
    _task_repository: Optional[TaskRepository] = None
    _task_application_repository: Optional[TaskApplicationRepository] = None
    _chat_message_repository: Optional[ChatMessageRepository] = None
    _negotiation_offer_repository: Optional[NegotiationOfferRepository] = None
    _task_assignment_repository: Optional[TaskAssignmentRepository] = None
    _review_repository: Optional[ReviewRepository] = None
    _predefined_type_repository: Optional[PredefinedTaskTypeRepository] = None
    _task_category_repository: Optional[TaskCategoryRepository] = None
    
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
    def get_predefined_type_repository(cls) -> PredefinedTaskTypeRepository:
        """Get the predefined task type repository instance
        
        Returns:
            PredefinedTaskTypeRepository instance
        """
        if cls._predefined_type_repository is None:
            cls._predefined_type_repository = DjangoPredefinedTaskTypeRepository()
        return cls._predefined_type_repository
        
    @classmethod
    def get_task_category_repository(cls) -> TaskCategoryRepository:
        """Get the task category repository instance
        
        Returns:
            TaskCategoryRepository instance
        """
        if cls._task_category_repository is None:
            cls._task_category_repository = DjangoTaskCategoryRepository()
        return cls._task_category_repository
    
class ServiceFactory:
    """Factory for creating service instances"""
    
    # Application services
    _task_service: Optional[TaskService] = None
    _task_application_service: Optional[TaskApplicationService] = None
    _chat_service: Optional[ChatService] = None
    _assignment_service: Optional[AssignmentService] = None
    _review_service: Optional[ReviewService] = None
    _predefined_type_service: Optional[PredefinedTaskTypeService] = None
    _task_category_service: Optional[TaskCategoryService] = None
    
    # Application service getters
    @classmethod
    def get_task_service(cls) -> TaskService:
        """Get the task service instance
        
        Returns:
            TaskService instance
        """
        if cls._task_service is None:
            cls._task_service = TaskService(
                task_repository=RepositoryFactory.get_task_repository(),
                predefined_type_repository=RepositoryFactory.get_predefined_type_repository(),
            )
        return cls._task_service
    
    @classmethod
    def get_task_application_service(cls) -> TaskApplicationService:
        """Get the application service instance
        
        Returns:
            TaskApplicationService instance
        """
        if cls._task_application_service is None:
            cls._task_application_service = TaskApplicationService(
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
    def get_predefined_type_service(cls) -> PredefinedTaskTypeService:
        """Get the predefined task type service instance
        
        Returns:
            PredefinedTaskTypeService instance
        """
        if cls._predefined_type_service is None:
            cls._predefined_type_service = PredefinedTaskTypeService(
                predefined_type_repository=RepositoryFactory.get_predefined_type_repository()
            )
        return cls._predefined_type_service
        
    @classmethod
    def get_task_category_service(cls) -> TaskCategoryService:
        """Get the task category service instance
        
        Returns:
            TaskCategoryService instance
        """
        if cls._task_category_service is None:
            cls._task_category_service = TaskCategoryService(
                task_category_repository=RepositoryFactory.get_task_category_repository()
            )
        return cls._task_category_service
    
   