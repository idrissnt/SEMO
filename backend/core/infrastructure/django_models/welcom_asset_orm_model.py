from django.db import models
import uuid

class StoreAssetModel(models.Model):
    """Django ORM model for StoreAsset"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title_one = models.CharField(max_length=255)
    title_two = models.CharField(max_length=255)
    first_logo_url = models.ImageField(default='stores/default.png', )
    second_logo_url = models.ImageField(default='stores/default.png', )
    third_logo_url = models.ImageField(default='stores/default.png', )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'store_assets'   

    def __str__(self):
        return f"StoreAsset - {self.title_one} {self.title_two}"

class TaskAssetModel(models.Model):
    """Django ORM model for TaskAsset"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title_one = models.CharField(max_length=255)
    title_two = models.CharField(max_length=255)
    first_image_url = models.ImageField(default='stores/default.png', )
    second_image_url = models.ImageField(default='stores/default.png', )
    third_image_url = models.ImageField(default='stores/default.png', )
    fourth_image_url = models.ImageField(default='stores/default.png', )
    fifth_image_url = models.ImageField(default='stores/default.png', )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'task_assets'

    def __str__(self):
        return f"TaskAsset - {self.title_one} {self.title_two}"


class CompanyAssetModel(models.Model):
    """Django ORM model for CompanyAsset"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    logo_url = models.ImageField(default='stores/default.png', )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'company_assets'

    def __str__(self):
        return f"CompanyAsset - {self.name} {self.logo_url}"
    