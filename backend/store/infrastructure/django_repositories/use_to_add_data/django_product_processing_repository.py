from typing import Optional
import uuid

from store.domain.models.entities import Category, Product, StoreProduct
from store.domain.repositories.use_to_add_data.product_processing_repository import ProductProcessingRepository
from store.infrastructure.django_models.orm_models import CategoryModel, ProductModel, StoreProductModel

class DjangoProductProcessingRepository(ProductProcessingRepository):
    """Django ORM implementation of ProductProcessingRepository"""
    
    def find_category_by_path(self, category_path: str) -> Optional[Category]:
        """Find a category by its path"""
        try:
            category_model = CategoryModel.objects.get(path=category_path)
            return Category(
                id=category_model.id,
                name=category_model.name,
                path=category_model.path,
                slug=category_model.slug,
                store_brand_id=category_model.store_brand.id
            )
        except CategoryModel.DoesNotExist:
            return None
    
    def create_category(self, category: Category) -> Category:
        """Create a new category"""
        category_model = CategoryModel(
            id=category.id,
            name=category.name,
            path=category.path,
            slug=category.slug,
            store_brand=category.store_brand_id
        )
        category_model.save()
        return Category(
            id=category_model.id,
            name=category_model.name,
            path=category_model.path,
            slug=category_model.slug,
            store_brand_id=category_model.store_brand.id
        )
    
    def find_product_by_name(self, name: str) -> Optional[Product]:
        """Find a product by its name"""
        try:
            product_model = ProductModel.objects.get(name=name)
            return Product(
                id=product_model.id,
                name=product_model.name,
                slug=product_model.slug,
                quantity=product_model.quantity,
                unit=product_model.unit,
                description=product_model.description,
                image_url=product_model.image_url,
            )
        except ProductModel.DoesNotExist:
            return None
    
    def create_product(self, product: Product) -> Product:
        """Create a new product"""
        product_model = ProductModel(
            id=product.id,
            name=product.name,
            slug=product.slug,
            quantity=product.quantity,
            unit=product.unit,
            description=product.description,
            image_url=product.image_url
        )
        product_model.save()
        return Product(
            id=product_model.id,
            name=product_model.name,
            slug=product_model.slug,
            quantity=product_model.quantity,
            unit=product_model.unit,
            description=product_model.description,
            image_url=product_model.image_url
        )
    
    def find_store_product(self, 
                           store_brand_id: uuid.UUID, 
                           product_id: uuid.UUID, 
                           category_id: uuid.UUID) -> Optional[StoreProduct]:
        """Find a store product by store brand and product"""
        try:
            store_product_model = StoreProductModel.objects.get(
                store_brand_id=store_brand_id,
                product_id=product_id,
                category_id=category_id
            )
            return StoreProduct(
                id=store_product_model.id,
                store_brand_id=store_product_model.store_brand.id,
                product_id=store_product_model.product.id,
                category_id=store_product_model.category.id,
                price=store_product_model.price,
                price_per_unit=store_product_model.price_per_unit
            )
        except StoreProductModel.DoesNotExist:
            return None
    
    def update_store_product(self, 
                            store_product: StoreProduct) -> StoreProduct:
        """Update an existing store product"""
        store_product_model = StoreProductModel.objects.get(id=store_product.id)
        store_product_model.price = store_product.price
        store_product_model.price_per_unit = store_product.price_per_unit
        store_product_model.save()
        return StoreProduct(
            id=store_product_model.id,
            store_brand_id=store_product_model.store_brand.id,
            product_id=store_product_model.product.id,
            category_id=store_product_model.category.id,
            price=store_product_model.price,
            price_per_unit=store_product_model.price_per_unit
        )
    
    def create_store_product(self, 
                             store_product: StoreProduct) -> StoreProduct:
        """Create a new store product"""
        store_product_model = StoreProductModel(
            id=store_product.id,
            store_brand_id=store_product.store_brand_id,
            product_id=store_product.product_id,
            category_id=store_product.category_id,
            price=store_product.price,
            price_per_unit=store_product.price_per_unit
        )
        store_product_model.save()
        return StoreProduct(
            id=store_product_model.id,
            store_brand_id=store_product_model.store_brand.id,
            product_id=store_product_model.product.id,
            category_id=store_product_model.category.id,
            price=store_product_model.price,
            price_per_unit=store_product_model.price_per_unit
        )
