from django.contrib import admin
from .models import Product, ProductCategory, StoreProduct

@admin.register(ProductCategory)
class ProductCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'store', 'parent_category', 'created_at')
    search_fields = ('name', 'store__name', 'parent_category__name')
    list_filter = ('store', 'created_at')
    ordering = ('store', 'name')
    list_display_links = ('name',)
    autocomplete_fields = ('store', 'parent_category')  # Enables better UX for foreign keys

class StoreProductInline(admin.TabularInline):
    model = StoreProduct
    extra = 1  # Number of empty inline rows to display by default
    fields = ('store', 'price', 'stock', 'is_available', 'discount_price', 'discount_end_date')
    readonly_fields = ('created_at', 'updated_at')  # Mark these as read-only

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'unit', 'is_seasonal', 'lowest_price', 'created_at')
    search_fields = ('name', 'category__name', 'stores__name')
    list_filter = ('unit', 'is_seasonal', 'category', 'created_at')
    ordering = ('name',)
    autocomplete_fields = ('category', 'stores')  # To quickly search related categories and stores
    inlines = [StoreProductInline]  # Display store-specific product info inline

@admin.register(StoreProduct)
class StoreProductAdmin(admin.ModelAdmin):
    list_display = ('product', 'store', 'price', 'stock', 'is_available', 'discount_price', 'current_price', 'position_in_store', 'updated_at')
    search_fields = ('product__name', 'store__name')
    list_filter = ('store', 'is_available', 'discount_end_date')
    ordering = ('store', 'product__name')
    readonly_fields = ('created_at', 'updated_at')
    autocomplete_fields = ['store', 'product']
