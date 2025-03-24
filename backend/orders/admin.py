from django.contrib import admin
from .models import Order, OrderItem

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'store_brand', 'status', 'total_amount', 'created_at']
    list_filter = ['status', 'store_brand', 'created_at']
    search_fields = ['user__email', 'store_brand__name']
    readonly_fields = ['created_at']
    date_hierarchy = 'created_at'

@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
    list_display = ['order', 'store_product', 'quantity', 'price_at_order', 'total_price']
    list_filter = ['order__status']
    search_fields = ['order__user__email', 'store_product__product__name']
    readonly_fields = ['price_at_order']

    def total_price(self, obj):
        return obj.quantity * obj.price_at_order
    total_price.short_description = 'Total Price'
