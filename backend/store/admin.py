from django.contrib import admin
from .models import Store

# Register your models here.

@admin.register(Store)
class StoreAdmin(admin.ModelAdmin):
    list_display = ('name', 'address', 'rating', 'is_popular', 'created_at')
    list_filter = ('is_popular', 'rating')
    search_fields = ('name', 'address', 'description')
    readonly_fields = ('created_at', 'updated_at')
    list_per_page = 20
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'description', 'address')
        }),
        ('Location', {
            'fields': ('latitude', 'longitude')
        }),
        ('Store Status', {
            'fields': ('rating', 'is_popular')
        }),
        ('Media', {
            'fields': ('image_url',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
