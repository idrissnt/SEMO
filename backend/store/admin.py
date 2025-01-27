from django.contrib import admin
from .models import Store

# Register your models here.

@admin.register(Store)
class StoreAdmin(admin.ModelAdmin):
    list_display = [
        'name',
        'rating',
        'total_reviews',
        'is_open',
        'is_big_store',
        'delivery_type'
    ]
    list_filter = [
        'is_open',
        'is_big_store',
        'delivery_type',
        'has_fresh_products',
        'has_frozen_products',
        'supports_pickup'
    ]
    search_fields = ['name', 'description', 'address']
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'description', 'logo_url', 'address')
        }),
        ('Location', {
            'fields': ('latitude', 'longitude', 'delivery_radius')
        }),
        ('Store Status', {
            'fields': (
                'is_open', 
                'is_big_store',
                'working_hours',
                'delivery_type',
                'delivery_fee',
                'minimum_order',
                'free_delivery_threshold'
            )
        }),
        ('Features', {
            'fields': (
                'has_fresh_products',
                'has_frozen_products',
                'supports_pickup'
            )
        }),
        ('Preparation and Delivery', {
            'fields': ('preparation_time',),
            'description': 'Detailed preparation time settings'
        }),
        ('Performance', {
            'fields': ('rating', 'total_reviews'),
            'description': 'Store rating and review statistics'
        }),
        ('Promotions', {
            'fields': ('current_promotions',),
            'classes': ('collapse',)
        })
    )
