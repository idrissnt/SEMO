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
    list_display = ['id', 'title_one', 'title_two', 'first_logo_url', 'second_logo_url', 'third_logo_url']
    search_fields = ['title_one', 'title_two']

    fieldsets = [
        ('Store Asset', {
            'fields': ('title_one', 'title_two', 'first_logo_url', 'second_logo_url', 'third_logo_url')
        }),
    ]

    readonly_fields = ['created_at']
    date_hierarchy = 'created_at'

@admin.register(TaskAsset)
class TaskAssetAdmin(admin.ModelAdmin):
    list_display = ['id', 'title_one', 'title_two', 'first_image_url', 'second_image_url', 'third_image_url', 'fourth_image_url', 'fifth_image_url']
    search_fields = ['title_one', 'title_two']

    fieldsets = [
        ('Task Asset', {
            'fields': ('title_one', 'title_two', 'first_image_url', 'second_image_url', 'third_image_url', 'fourth_image_url', 'fifth_image_url')
        }),
    ]

    readonly_fields = ['created_at']
    date_hierarchy = 'created_at'