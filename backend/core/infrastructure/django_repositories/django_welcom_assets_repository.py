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
            title_one=model.title_one,
            title_two=model.title_two,
            first_logo_url=model.first_logo_url,
            second_logo_url=model.second_logo_url,
            third_logo_url=model.third_logo_url
        )
    
    def get_task_assets(self) -> TaskAsset:
        """Get task asset
        
        Returns:
            TaskAsset object
        """
        tasks = cache.get_or_set('welcome_tasks', lambda: TaskAssetModel.objects.first(), 60*60)
        
        return self._to_task_domain(tasks)
    
    def _to_task_domain(self, model: TaskAssetModel) -> TaskAsset:
        """Convert ORM model to domain model"""
        return TaskAsset(
            id=model.id,
            title_one=model.title_one,
            title_two=model.title_two,
            first_image_url=model.first_image_url,
            second_image_url=model.second_image_url,
            third_image_url=model.third_image_url,
            fourth_image_url=model.fourth_image_url,
            fifth_image_url=model.fifth_image_url
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
            logo_url=model.logo_url
        )   