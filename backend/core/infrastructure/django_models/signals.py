from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.cache import cache

from core.infrastructure.django_models.welcom_asset_orm_model import TaskAssetModel, StoreAssetModel, CompanyAssetModel

@receiver(post_save, sender=TaskAssetModel)
def clear_task_asset_cache(sender, instance, **kwargs):
    """Clear the task asset cache when a TaskAssetModel is saved (Updated values)"""
    cache.delete('welcome_tasks')

@receiver(post_save, sender=StoreAssetModel)
def clear_store_asset_cache(sender, instance, **kwargs):
    """Clear the store asset cache when a StoreAssetModel is saved (Updated values)"""
    cache.delete('welcome_stores')

@receiver(post_save, sender=CompanyAssetModel)
def clear_company_asset_cache(sender, instance, **kwargs):
    """Clear the company asset cache when a CompanyAssetModel is saved (Updated values)"""
    cache.delete('welcome_company')
