from django.contrib import admin
from .infrastructure.django_models.task_orm_models import (
    TaskModel,
    TaskAttributeModel,
    TaskApplicationModel,
    TaskAssignmentModel,
    ReviewModel,
    TaskCategoryTemplateModel
)


@admin.register(TaskCategoryTemplateModel)
class TaskCategoryTemplateAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'description')
    search_fields = ('name', 'category', 'description')


class TaskAttributeInline(admin.TabularInline):
    model = TaskAttributeModel
    extra = 1


@admin.register(TaskModel)
class TaskAdmin(admin.ModelAdmin):
    list_display = ('title', 'requester', 'category', 'budget', 'scheduled_date', 'status')
    list_filter = ('category', 'status', 'created_at')
    search_fields = ('title', 'description', 'requester__email')
    inlines = [TaskAttributeInline]


@admin.register(TaskApplicationModel)
class TaskApplicationAdmin(admin.ModelAdmin):
    list_display = ('task', 'performer', 'price_offer', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('task__title', 'performer__email', 'message')


@admin.register(TaskAssignmentModel)
class TaskAssignmentAdmin(admin.ModelAdmin):
    list_display = ('task', 'performer', 'assigned_at', 'started_at', 'completed_at')
    list_filter = ('assigned_at', 'started_at', 'completed_at')
    search_fields = ('task__title', 'performer__email')


@admin.register(ReviewModel)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('task', 'reviewer', 'reviewee', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('task__title', 'reviewer__email', 'reviewee__email', 'comment')
