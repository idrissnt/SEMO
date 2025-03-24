from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, Address, BlacklistedToken, LogoutEvent

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ('email', 'first_name', 'last_name', 'is_staff', 'is_active',)
    list_filter = ('email', 'is_staff', 'is_active',)
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name', 'phone_number')}),
        ('Role info', {'fields': ('role', 'vehicle_type', 'license_number', 'is_available')}),
        ('Permissions', {'fields': ('is_staff', 'is_active')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password1', 'password2', 'first_name', 'last_name', 'is_staff', 'is_active')}
        ),
    )
    search_fields = ('email',)
    ordering = ('email',)

admin.site.register(CustomUser, CustomUserAdmin)

# Register Address model
class AddressAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'street_number', 'street_name', 'city', 'zip_code', 'country')
    search_fields = ('street_name', 'city', 'zip_code')
    list_filter = ('city', 'country')

admin.site.register(Address, AddressAdmin)

# Register BlacklistedToken model
class BlacklistedTokenAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'blacklisted_at', 'expires_at')
    search_fields = ('user__email',)
    list_filter = ('blacklisted_at',)

admin.site.register(BlacklistedToken, BlacklistedTokenAdmin)

# Register LogoutEvent model
class LogoutEventAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'ip_address', 'created_at')
    search_fields = ('user__email', 'ip_address')
    list_filter = ('created_at',)

admin.site.register(LogoutEvent, LogoutEventAdmin)
