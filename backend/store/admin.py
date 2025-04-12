from django.contrib import admin
from django.utils.html import format_html
from django.db.models import Q

# Import ORM models following DDD infrastructure layer pattern
from store.models import (
    StoreBrand,
    Category,
    Product,
    StoreProduct
)


@admin.register(StoreBrand)
class StoreBrandAdmin(admin.ModelAdmin):
    """Admin interface for StoreBrand entities"""
    list_display = ['name', 'type', 'display_logo', 'slug']
    list_filter = ['type']
    search_fields = ['name', 'type']
    prepopulated_fields = {'slug': ('name',)}
    readonly_fields = ['display_logo', 'display_banner']
    fieldsets = [
        ('Basic Information', {
            'fields': ['name', 'type', 'slug']
        }),
        ('Images', {
            'fields': ['image_logo', 'display_logo', 'image_banner', 'display_banner'],
            'description': 'Upload store brand images. Images will be stored in S3.'
        })
    ]

    def display_logo(self, obj):
        """Display the store logo in the admin interface"""
        if obj.image_logo:
            return format_html('<img src="{}" width="100" height="100" style="object-fit: contain;" />', obj.image_logo.url)
        return "-"
    display_logo.short_description = 'Logo Preview'

    def display_banner(self, obj):
        """Display the store banner in the admin interface"""
        if obj.image_banner:
            return format_html('<img src="{}" width="300" height="100" style="object-fit: cover;" />', obj.image_banner.url)
        return "-"
    display_banner.short_description = 'Banner Preview'


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    """Admin interface for Category entities"""
    list_display = ['name', 'path', 'slug', 'get_store_brands']
    search_fields = ['name', 'path']
    prepopulated_fields = {'slug': ('name',)}
    filter_horizontal = ['store_brand']
    list_filter = ['store_brand']

    def get_store_brands(self, obj):
        """Display all store brands associated with this category"""
        return ", ".join([store.name for store in obj.store_brand.all()])
    get_store_brands.short_description = 'Store Brands'


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    """Admin interface for Product entities"""
    list_display = ['name', 'display_image', 'quantity', 'unit', 'slug']
    list_filter = ['unit']
    search_fields = ['name', 'description']
    prepopulated_fields = {'slug': ('name',)}
    readonly_fields = ['display_image', 'display_thumbnail']
    fieldsets = [
        ('Basic Information', {
            'fields': ['name', 'slug', 'quantity', 'unit']
        }),
        ('Description', {
            'fields': ['description']
        }),
        ('Images', {
            'fields': ['image_url', 'display_image', 'display_thumbnail'],
            'description': 'Upload product images. Images will be stored in S3 and automatically resized.'
        })
    ]

    def display_image(self, obj):
        """Display the product image in the admin interface"""
        if obj.image_url:
            return format_html('<img src="{}" width="200" height="150" style="object-fit: contain;" />', obj.image_url.url)
        return "-"
    display_image.short_description = 'Image Preview'

    def display_thumbnail(self, obj):
        """Display the product thumbnail in the admin interface"""
        if hasattr(obj, 'image_thumbnail') and obj.image_thumbnail:
            return format_html('<img src="{}" width="100" height="75" style="object-fit: contain;" />', obj.image_thumbnail.url)
        return "-"
    display_thumbnail.short_description = 'Thumbnail Preview'


@admin.register(StoreProduct)
class StoreProductAdmin(admin.ModelAdmin):
    """Admin interface for StoreProduct entities"""
    list_display = ['store_brand', 'product', 'category', 'price', 'price_per_unit']
    list_filter = ['store_brand', 'category']
    search_fields = ['store_brand__name', 'product__name', 'category__name']
    autocomplete_fields = ['store_brand', 'product', 'category']
    
    fieldsets = [
        ('Store Information', {
            'fields': ['store_brand']
        }),
        ('Product Information', {
            'fields': ['product', 'category']
        }),
        ('Pricing', {
            'fields': ['price', 'price_per_unit']
        })
    ]
    
    def formfield_for_foreignkey(self, db_field, request, **kwargs):
        """Filter categories based on the selected store brand"""
        if db_field.name == "category" and request.POST.get('store_brand'):
            store_brand_id = request.POST.get('store_brand')
            kwargs["queryset"] = Category.objects.filter(store_brand__id=store_brand_id)
        return super().formfield_for_foreignkey(db_field, request, **kwargs)
