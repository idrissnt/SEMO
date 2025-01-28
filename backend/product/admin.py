from django.contrib import admin
from django import forms
from django.core.exceptions import ValidationError
from django.contrib.admin.widgets import FilteredSelectMultiple
from .models import (
    Product, 
    ProductCategory, 
    StoreProduct, 
    StoreCategoryAssociation,
    Store
)
from django.utils.html import format_html, mark_safe

class StoreCategoryAssociationInline(admin.TabularInline):
    model = StoreCategoryAssociation
    extra = 1
    min_num = 0
    can_delete = True
    fields = ('store', 'is_primary')
    autocomplete_fields = ['store']

class ProductCategoryAdminForm(forms.ModelForm):
    stores = forms.ModelMultipleChoiceField(
        queryset=Store.objects.all(),
        required=False,
        widget=FilteredSelectMultiple('Stores', False),
        help_text='Select multiple stores using CTRL/CMD + Click'
    )

    class Meta:
        model = ProductCategory
        fields = ['name', 'description', 'parent_category', 'stores']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance.pk:
            # Get existing stores for this category
            self.initial['stores'] = Store.objects.filter(
                category_associations__category=self.instance
            )

        # Add filter capabilities to store selection
        self.fields['stores'].widget.attrs.update({
            'class': 'filtered-select',
            'style': 'min-width: 300px; min-height: 200px;'
        })

    def clean(self):
        cleaned_data = super().clean()
        parent_category = cleaned_data.get('parent_category')
        stores = cleaned_data.get('stores', [])

        if parent_category and stores:
            parent_stores = parent_category.stores.all()
            if not set(stores) & set(parent_stores):
                raise ValidationError({
                    'stores': "Subcategory must share at least one store with its parent category."
                })
        return cleaned_data

    def save(self, commit=True):
        instance = super().save(commit=False)
        if commit:
            instance.save()
            if 'stores' in self.cleaned_data:
                # Clear existing associations
                StoreCategoryAssociation.objects.filter(category=instance).delete()
                # Create new associations
                for store in self.cleaned_data['stores']:
                    StoreCategoryAssociation.objects.create(
                        category=instance,
                        store=store,
                        is_primary=False
                    )
        return instance

@admin.register(ProductCategory)
class ProductCategoryAdmin(admin.ModelAdmin):
    form = ProductCategoryAdminForm
    list_display = [
        'name', 
        'get_stores_display', 
        'get_parent_category_display',
        'created_at'
    ]
    list_filter = ['stores', 'parent_category']
    search_fields = ['name', 'description', 'stores__name']
    readonly_fields = ['created_at']
    
    class Media:
        css = {
            'all': ('admin/css/widgets.css',)
        }
        js = ('admin/js/SelectBox.js', 'admin/js/SelectFilter2.js')
    
    def get_stores_display(self, obj):
        stores = obj.stores.all()
        if stores:
            return mark_safe("<br>".join([store.name for store in stores]))
        return "-"
    get_stores_display.short_description = 'Stores'
    get_stores_display.allow_tags = True
    
    def get_parent_category_display(self, obj):
        if obj.parent_category:
            return format_html(
                '<span style="color: #666;">{}</span> → <strong>{}</strong>',
                obj.parent_category.name,
                obj.name
            )
        return format_html('<strong>{}</strong> (Main Category)', obj.name)
    get_parent_category_display.short_description = 'Category Path'

@admin.register(StoreCategoryAssociation)
class StoreCategoryAssociationAdmin(admin.ModelAdmin):
    list_display = ['store', 'category', 'is_primary', 'created_at']
    list_filter = ['store', 'category', 'is_primary']
    search_fields = ['store__name', 'category__name']
    readonly_fields = ['created_at']

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
