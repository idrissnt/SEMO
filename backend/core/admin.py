from django.contrib import admin
from core.models import CompanyAsset, StoreAsset, TaskAsset

@admin.register(CompanyAsset)
class CompanyAssetAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'logo_url']
    search_fields = ['name']

    fieldsets = [
        ('Company Asset', {
            'fields': ('name', 'logo_url')
        }),
    ]

    readonly_fields = ['created_at']
    date_hierarchy = 'created_at'   

@admin.register(StoreAsset)
class StoreAssetAdmin(admin.ModelAdmin):
    list_display = ['id', 'card_title_one', 'card_title_two', 'store_title', 'store_logo_one_url', 'store_logo_two_url', 'store_logo_three_url']
    search_fields = ['card_title_one', 'card_title_two']

    fieldsets = [
        ('Store Asset', {
            'fields': ('card_title_one', 'card_title_two', 'store_title', 'store_logo_one_url', 'store_logo_two_url', 'store_logo_three_url')
        }),
    ]

    readonly_fields = ['created_at']
    date_hierarchy = 'created_at'

@admin.register(TaskAsset)
class TaskAssetAdmin(admin.ModelAdmin):
    list_display = ['id', 'title', 'task_image_url', 'tasker_profile_image_url', 'tasker_profile_title']
    search_fields = ['title']

    fieldsets = [
        ('Task Asset', {
            'fields': ('title', 'task_image_url', 'tasker_profile_image_url', 'tasker_profile_title')
        }),
    ]

    readonly_fields = ['created_at']
    date_hierarchy = 'created_at'