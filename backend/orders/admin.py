from django.contrib import admin
from .models import Order, OrderItem

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'store_brand', 'status', 'created_at']
    list_filter = ['status', 'store_brand', 'created_at']
    search_fields = ['user__email', 'store_brand__name']
    readonly_fields = ['created_at']
    date_hierarchy = 'created_at'

@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
    list_display = ['store_product', 'quantity', 'total_price']
    list_filter = ['order__status']
    search_fields = ['order__user__email', 'store_product__product__name']

    def total_price(self, obj):
        return obj.quantity * obj.product_price
    total_price.short_description = 'Total Price'
