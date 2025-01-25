from django.contrib import admin
from django.utils.html import format_html
from .models import Recipe

@admin.register(Recipe)
class RecipeAdmin(admin.ModelAdmin):
    list_display = ('name', 'preparation_time', 'difficulty', 'is_popular', 'image_preview')
    list_filter = ('difficulty', 'is_popular', 'preparation_time')
    search_fields = ('name', 'instructions')
    filter_horizontal = ('ingredients',)
    readonly_fields = ('created_at', 'updated_at', 'image_preview')
    list_per_page = 20

    def image_preview(self, obj):
        if obj.image_url:
            return format_html('<img src="{}" style="max-height: 50px;"/>', obj.image_url.url)
        return "No image"
    image_preview.short_description = 'Image'

    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'instructions')
        }),
        ('Recipe Details', {
            'fields': ('preparation_time', 'difficulty', 'is_popular')
        }),
        ('Ingredients', {
            'fields': ('ingredients',),
            'description': 'Select multiple ingredients for this recipe'
        }),
        ('Media', {
            'fields': ('image_url', 'image_preview')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
