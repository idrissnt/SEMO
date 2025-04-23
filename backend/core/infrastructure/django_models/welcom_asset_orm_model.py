from django.db import models
import uuid

class StoreAssetModel(models.Model):
    """Django ORM model for StoreAsset"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    card_title_one = models.CharField(max_length=255)
    card_title_two = models.CharField(max_length=255)
    store_title = models.CharField(max_length=255)
    store_logo_one_url = models.ImageField(default='stores/default.png', )
    store_logo_two_url = models.ImageField(default='stores/default.png', )
    store_logo_three_url = models.ImageField(default='stores/default.png', )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'store_assets'   

    def __str__(self):
        return f"StoreAsset - {self.card_title_one} {self.card_title_two}"

class TaskAssetModel(models.Model):
    """Django ORM model for TaskAsset"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=255, null=True, blank=True)
    task_image_url = models.ImageField(default='stores/default.png')
    tasker_profile_image_url = models.ImageField(default='stores/default.png', null=True, blank=True)
    tasker_profile_title = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'task_assets'

    def __str__(self):
        return f"TaskAsset - {self.title}"


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
    