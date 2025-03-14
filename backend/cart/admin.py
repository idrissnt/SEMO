from django.contrib import admin
from .models import Cart, CartItem

@admin.register(Cart)
class CartAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'store', 'created_at', 'total_items', 'total_price']
    list_filter = ['store', 'created_at']
    search_fields = ['user__email', 'store__name']
    readonly_fields = ['created_at', 'updated_at', 'total_items', 'total_price']
    date_hierarchy = 'created_at'

    def total_items(self, obj):
        return obj.total_items()
    total_items.short_description = 'Number of Items'

    def total_price(self, obj):
        return obj.total_price()
    total_price.short_description = 'Total Amount'

@admin.register(CartItem)
class CartItemAdmin(admin.ModelAdmin):
    list_display = ['cart', 'store_product', 'quantity', 'total_price', 'added_at']
    list_filter = ['cart__store', 'added_at']
    search_fields = ['cart__user__email', 'store_product__product__name']
    autocomplete_fields = ['store_product']
    readonly_fields = ['added_at', 'total_price']

    def total_price(self, obj):
        return obj.total_price()
    total_price.short_description = 'Total Price'
