from django.contrib import admin
from .models import Delivery, Driver

@admin.register(Delivery)
class DeliveryAdmin(admin.ModelAdmin):
    list_display = ['id', 'order', 'driver', 'status', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['order__user__email', 'driver__user__email', 'delivery_address']
    readonly_fields = ['created_at']
    date_hierarchy = 'created_at'

    fieldsets = (
        ('Basic Info', {
            'fields': ('order', 'driver', 'status')
        }),
        ('Delivery Details', {
            'fields': ('delivery_address',)
        }),
        ('Timestamps', {
            'fields': ('created_at',),
            'classes': ('collapse',)
        })
    )

@admin.register(Driver)
class DriverAdmin(admin.ModelAdmin):
    list_display = ['user', 'is_available']
    list_filter = ['is_available']
    search_fields = ['user__email', 'user__first_name', 'user__last_name']

    fieldsets = (
        ('Driver Info', {
            'fields': ('user', 'is_available')
        }),
    )
