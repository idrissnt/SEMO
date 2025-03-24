from django.contrib import admin
from django.utils.html import format_html
from .models import StoreBrand, Category, Product, StoreProduct

@admin.register(StoreBrand)
class StoreBrandAdmin(admin.ModelAdmin):
    list_display = ['name', 'type', 'display_logo']
    list_filter = ['type']
    search_fields = ['name', 'type']
    prepopulated_fields = {'slug': ('name',)}

    def display_logo(self, obj):
        if obj.image_logo:
            return format_html('<img src="{}" width="50" height="50" />', obj.image_logo.url)
        return "-"
    display_logo.short_description = 'Logo'

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'path', 'slug']
    search_fields = ['name', 'path']
    prepopulated_fields = {'slug': ('name',)}

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ['name', 'display_image', 'quantity', 'unit']
    list_filter = ['unit']
    search_fields = ['name', 'description']
    prepopulated_fields = {'slug': ('name',)}

    def display_image(self, obj):
        if obj.image_url:
            return format_html('<img src="{}" width="50" height="50" />', obj.image_url.url)
        return "-"
    display_image.short_description = 'Image'

@admin.register(StoreProduct)
class StoreProductAdmin(admin.ModelAdmin):
    list_display = ['store_brand', 'product', 'category', 'price', 'price_per_unit']
    list_filter = ['store_brand', 'category']
    search_fields = ['store_brand__name', 'product__name', 'category__name']
    autocomplete_fields = ['store_brand', 'product', 'category']
