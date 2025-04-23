from typing import List

from core.domain.models.entities.welcom_asset import StoreAsset, TaskAsset, CompanyAsset
from core.domain.repositories.welcome_assets_repository import WelcomeAssetsRepository
from core.infrastructure.django_models.welcom_asset_orm_model import StoreAssetModel, TaskAssetModel, CompanyAssetModel
from django.core.cache import cache

class DjangoWelcomeAssetsRepository(WelcomeAssetsRepository):
    """Django ORM implementation of WelcomeAssetsRepository"""
    
    def get_store_assets(self) -> StoreAsset:
        """Get store asset
        
        Returns:
            StoreAsset object
        """
        stores = cache.get_or_set('welcome_stores', lambda: StoreAssetModel.objects.first(), 60*60)
        
        return self._to_store_domain(stores)
    
    def _to_store_domain(self, model: StoreAssetModel) -> StoreAsset:
        """Convert ORM model to domain model"""
        return StoreAsset(
            id=model.id,
            card_title_one=model.card_title_one,
            card_title_two=model.card_title_two,
            store_title=model.store_title,
            store_logo_one_url=model.store_logo_one_url.url,
            store_logo_two_url=model.store_logo_two_url.url,
            store_logo_three_url=model.store_logo_three_url.url
        )
    
    def get_all_task_assets(self) -> List[TaskAsset]:
        """Get task asset
        
        Returns:
            List of TaskAsset objects
        """
        tasks = cache.get_or_set('welcome_tasks', lambda: list(TaskAssetModel.objects.all()), 60*60)
        
        return [self._to_task_domain(task) for task in tasks]
    
    def _to_task_domain(self, model: TaskAssetModel) -> TaskAsset:
        """Convert ORM model to domain model"""
        return TaskAsset(
            id=model.id,
            title=model.title,
            task_image_url=model.task_image_url.url,
            tasker_profile_image_url=model.tasker_profile_image_url.url,
            tasker_profile_title=model.tasker_profile_title
        )
    
    def get_company_asset(self) -> CompanyAsset:
        """Get company asset
        
        Returns:
            CompanyAsset object
        """
        company = cache.get_or_set('welcome_company', lambda: CompanyAssetModel.objects.first(), 60*60)
        
        return self._to_company_domain(company)
    
    def _to_company_domain(self, model: CompanyAssetModel) -> CompanyAsset:
        """Convert ORM model to domain model"""
        return CompanyAsset(
            id=model.id,
            name=model.name,
            logo_url=model.logo_url.url
        )   