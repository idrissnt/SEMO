from core.domain.services.logging_service_interface import LoggingServiceInterface
from core.domain.value_objects.result import Result

from core.domain.models.entities.welcom_asset import StoreAsset, TaskAsset, CompanyAsset
from core.domain.repositories.welcome_assets_repository import WelcomeAssetsRepository

class WelcomeAssetApplicationService:
    """Application service for welcome assets operations"""
    
    def __init__(self, welcome_asset_repository: WelcomeAssetsRepository, 
                 logger: LoggingServiceInterface):

        self.welcome_asset_repository = welcome_asset_repository
        self.logger = logger
    
    def get_store_assets(self) -> Result[StoreAsset, str]:
        """Get store asset
            
        Returns:
            Result containing StoreAsset on success or error message on failure
        """
        
        try:
            welcome_asset = self.welcome_asset_repository.get_store_assets()
            return Result.success(welcome_asset)
            
        except Exception as e:
            self.logger.error("Error getting store assets", {"exception": str(e)})
            return Result.failure(e)
    
    def get_task_assets(self) -> Result[TaskAsset, str]:
        """Get task asset
            
        Returns:
            Result containing TaskAsset on success or error message on failure
        """
        
        try:
            welcome_asset = self.welcome_asset_repository.get_task_assets()
            return Result.success(welcome_asset)
            
        except Exception as e:
            self.logger.error("Error getting task assets", {"exception": str(e)})
            return Result.failure(e)
    
    def get_company_asset(self) -> Result[CompanyAsset, str]:
        """Get company asset
            
        Returns:
            Result containing CompanyAsset on success or error message on failure
        """
        
        try:
            welcome_asset = self.welcome_asset_repository.get_company_asset()
            return Result.success(welcome_asset)
            
        except Exception as e:
            self.logger.error("Error getting company asset", {"exception": str(e)})
            return Result.failure(e)
    