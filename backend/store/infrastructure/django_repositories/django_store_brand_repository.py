from typing import List

from store.domain.models.entities import StoreBrand
from store.domain.repositories.repository_interfaces import StoreBrandRepository
from store.infrastructure.django_models.orm_models import StoreBrandModel


class DjangoStoreBrandRepository(StoreBrandRepository):
    """Django ORM implementation of StoreBrandRepository"""
    
    def get_all_store_brands(self) -> List[StoreBrand]:
        """Get all store brands
        
        Returns:
            List of StoreBrand objects
        """
        queryset = StoreBrandModel.objects.all()
        
        return [self._to_domain(model) for model in queryset]
    
    def _to_domain(self, model: StoreBrandModel) -> StoreBrand:
        """Convert ORM model to domain model"""
        return StoreBrand(
            id=model.id,
            name=model.name,
            slug=model.slug,
            image_logo=model.image_logo.url if model.image_logo else None,
            image_banner=model.image_banner.url if model.image_banner else None
        )