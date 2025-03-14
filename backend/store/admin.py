from django.contrib import admin
from django.utils.html import format_html
from .models import Store, Category, Product, StoreProduct

@admin.register(Store)
class StoreAdmin(admin.ModelAdmin):
    list_display = ['name', 'city', 'address', 'display_image']
    list_filter = ['city']
    search_fields = ['name', 'address', 'city']
    prepopulated_fields = {'slug': ('name',)}

    def display_image(self, obj):
        if obj.image_url:
            return format_html('<img src="{}" width="50" height="50" />', obj.image_url.url)
        return "-"
    display_image.short_description = 'Image'

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'path', 'slug']
    search_fields = ['name', 'path']
    prepopulated_fields = {'slug': ('name',)}

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ['name', 'display_image', 'quantity', 'unit', 'price_per_unit']
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
    list_display = ['store', 'product', 'category', 'price', 'price_per_unit']
    list_filter = ['store', 'category']
    search_fields = ['store__name', 'product__name', 'category__name']
    autocomplete_fields = ['store', 'product', 'category']
