from the_user_app.domain.repositories.address_repository_interfaces import AddressRepository
from the_user_app.domain.repositories.auth_repository_interfaces import AuthRepository
from the_user_app.domain.repositories.user_repository_interfaces import UserRepository
from the_user_app.domain.repositories.task_performer_repository_interfaces import TaskPerformerProfileRepository
from the_user_app.domain.repositories.verification_code_repository import VerificationCodeRepository
from the_user_app.domain.services.template_services import TemplateService
from the_user_app.domain.services.verification_service import VerificationService

from the_user_app.infrastructure.django_repositories.django_user_repository import DjangoUserRepository
from the_user_app.infrastructure.django_repositories.django_address_repository import DjangoAddressRepository
from the_user_app.infrastructure.django_repositories.django_auth_repository import DjangoAuthRepository
from the_user_app.infrastructure.django_repositories.django_task_performer_profile_repository import DjangoTaskPerformerProfileRepository
from the_user_app.infrastructure.django_repositories.django_verification_code_repository import DjangoVerificationCodeRepository
from the_user_app.infrastructure.services.verification_service_impl import VerificationServiceImpl
from the_user_app.infrastructure.services.template_service_impl import DjangoTemplateService

from core.infrastructure.factories.logging_factory import CoreLoggingFactory
from core.infrastructure.services.email_service_impl import DummyEmailService, SendGridEmailService
from core.infrastructure.services.ovh_sms_service_impl import OVHSmsService, DummySmsService

from the_user_app.application.services.auth_service import AuthApplicationService
from the_user_app.application.services.user_service import UserApplicationService
from the_user_app.application.services.address_service import AddressApplicationService
from the_user_app.application.services.task_performer_service import TaskPerformerApplicationService
from the_user_app.application.services.verification_service_application import VerificationApplicationService



from django.conf import settings

class UserFactory:
    """Factory for creating user-related services and repositories"""
    
    # Singleton instances
    _logging_service = None
    _verification_service = None
    _email_service = None
    _sms_service = None
    _template_service = None
    _verification_code_repository = None
    _verification_application_service = None
    
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
        logger = CoreLoggingFactory.create_logger("auth")
        return AuthApplicationService(user_repository, auth_repository, logger)
    
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
        
    @staticmethod
    def create_email_service():
        """Create an EmailService implementation
        
        Returns:
            EmailService implementation
        """
        if UserFactory._email_service is None:
            logger = CoreLoggingFactory.create_logger("email")
            
            # Use SendGrid in production, dummy in development
            if hasattr(settings, 'SENDGRID_API_KEY') and settings.SENDGRID_API_KEY:
                UserFactory._email_service = SendGridEmailService(
                    api_key=settings.SENDGRID_API_KEY,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    logger=logger
                )
            else:
                UserFactory._email_service = DummyEmailService(logger)
                
        return UserFactory._email_service
    
    @staticmethod
    def create_sms_service():
        """Create an SmsService implementation
        
        Returns:
            SmsService implementation
        """
        if UserFactory._sms_service is None:
            logger = CoreLoggingFactory.create_logger("sms")
            
            # Prioritize OVH if configured
            if hasattr(settings, 'OVH_APPLICATION_KEY') and settings.OVH_APPLICATION_KEY:
                UserFactory._sms_service = OVHSmsService(
                    application_key=settings.OVH_APPLICATION_KEY,
                    application_secret=settings.OVH_APPLICATION_SECRET,
                    consumer_key=settings.OVH_CONSUMER_KEY,
                    service_name=settings.OVH_SMS_SERVICE_NAME,
                    sender=settings.OVH_SMS_SENDER,
                    logger=logger
                )
            # Use dummy service if neither is configured
            else:
                UserFactory._sms_service = DummySmsService(logger)
                
        return UserFactory._sms_service
    
    @staticmethod
    def create_verification_code_repository() -> VerificationCodeRepository:
        """Create a VerificationCodeRepository implementation
        
        Returns:
            VerificationCodeRepository implementation
        """
        if UserFactory._verification_code_repository is None:
            UserFactory._verification_code_repository = DjangoVerificationCodeRepository()
                
        return UserFactory._verification_code_repository
    
    @staticmethod
    def create_template_service() -> TemplateService:
        """Create a TemplateService implementation
        
        Returns:
            TemplateService implementation
        """
        if UserFactory._template_service is None:
            logger = CoreLoggingFactory.create_logger("template")
            UserFactory._template_service = DjangoTemplateService(logger)
                
        return UserFactory._template_service
    
    @staticmethod
    def create_verification_service() -> VerificationService:
        """Create a VerificationService implementation
        
        Returns:
            VerificationService implementation
        """
        if UserFactory._verification_service is None:
            email_service = UserFactory.create_email_service()
            sms_service = UserFactory.create_sms_service()
            verification_code_repository = UserFactory.create_verification_code_repository()
            template_service = UserFactory.create_template_service()
            logger = CoreLoggingFactory.create_logger("verification")
            
            # Get code expiry time from settings or use default
            code_expiry_minutes = getattr(settings, 'VERIFICATION_CODE_EXPIRY_MINUTES', 15)
            
            UserFactory._verification_service = VerificationServiceImpl(
                email_service=email_service,
                sms_service=sms_service,
                verification_code_repository=verification_code_repository,
                template_service=template_service,
                logger=logger,
                code_expiry_minutes=code_expiry_minutes
            )
            
        return UserFactory._verification_service
        
    @staticmethod
    def create_verification_application_service() -> VerificationApplicationService:
        """Create a VerificationApplicationService
        
        Returns:
            VerificationApplicationService instance
        """
        if UserFactory._verification_application_service is None:
            user_repository = UserFactory.create_user_repository()
            verification_service = UserFactory.create_verification_service()
            logger = CoreLoggingFactory.create_logger("verification_application")
            
            UserFactory._verification_application_service = VerificationApplicationService(
                user_repository=user_repository,
                verification_service=verification_service,
                logger=logger
            )
            
        return UserFactory._verification_application_service
