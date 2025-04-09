from django.contrib import admin
from .models import Payment

@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ['id', 'amount', 'status', 'created_at']
    list_filter = ['status', 'created_at']
    search_fields = ['transaction_id']
    date_hierarchy = 'created_at'

    fieldsets = (
        ('Payment Details', {
            'fields': ('amount', 'status')
        }),
        ('Transaction Info', {
            'fields': ('transaction_id', 'created_at')
        })
    )

    def has_add_permission(self, request):
        # Payments should only be created through the API
        return False

    def has_change_permission(self, request, obj=None):
        # Payments shouldn't be modified manually
        return False
