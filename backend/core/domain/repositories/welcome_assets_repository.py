from abc import ABC, abstractmethod
from core.domain.models.entities.welcom_asset import StoreAsset, TaskAsset, CompanyAsset
from typing import List

class WelcomeAssetsRepository(ABC):
    """Repository interface for welcome assets"""

    @abstractmethod
    def get_store_assets(self) -> StoreAsset:
        """Get store asset"""
        pass

    @abstractmethod
    def get_all_task_assets(self) -> List[TaskAsset]:
        """Get task asset"""
        pass
    
    @abstractmethod
    def get_company_asset(self) -> CompanyAsset:
        """Get company asset"""
        pass
    
