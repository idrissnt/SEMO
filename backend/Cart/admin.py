from django.contrib import admin
from django.utils.html import format_html
from store.models import Article
from .models import Cart, CartItem

class CartAdmin(admin.ModelAdmin):

    list_display = ('id', 'created_at')

class CartItemAdmin(admin.ModelAdmin):

    list_display = ('id', 'article', 'quantity')



admin.site.register(CartItem, CartItemAdmin)


# @admin.register(Product)
# class ProductAdmin(admin.ModelAdmin):
#     list_display = ('name', 'price', 'store', 'category', 'is_seasonal', 'is_popular', 'stock', 'image_preview')
#     list_filter = ('is_seasonal', 'is_popular', 'store', 'category')
#     search_fields = ('name', 'description', 'store__name')
#     autocomplete_fields = ('store',)
#     readonly_fields = ('created_at', 'updated_at', 'image_preview')
#     list_per_page = 20

#     def image_preview(self, obj):
#         if obj.image_url:
#             return format_html('<img src="{}" style="max-height: 50px;"/>', obj.image_url.url)
#         return "No image"
#     image_preview.short_description = 'Image'

#     fieldsets = (
#         ('Basic Information', {
#             'fields': ('name', 'description', 'price')
#         }),
#         ('Store Information', {
#             'fields': ('store',)
#         }),
#         ('Product Status', {
#             'fields': ('is_seasonal', 'is_popular', 'category', 'stock')
#         }),
#         ('Media', {
#             'fields': ('image_url', 'image_preview')
#         }),
#         ('Timestamps', {
#             'fields': ('created_at', 'updated_at'),
#             'classes': ('collapse',)
#         }),
#     )
