import uuid
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.utils.translation import gettext_lazy as _

class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **extra_fields)

class CustomUserModel(AbstractUser):
    """Django ORM model for User"""
    ROLE_CHOICES = (
        ('customer', 'Customer'),
        ('driver', 'Driver'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=150, unique=True, 
                               null=True, blank=True)
    email = models.EmailField(_('email address'), unique=True)
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255, null=True, blank=True)
    phone_number = models.CharField(max_length=15, unique=True, 
                                   null=True, blank=True)
    license_number = models.CharField(max_length=100, unique=True, 
                                     null=True, blank=True)
    is_available = models.BooleanField(default=True, null=True, blank=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, 
                           default='customer', null=True, blank=True)
    has_vehicle = models.BooleanField(default=False, null=True, blank=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name']

    objects = CustomUserManager()

    class Meta:
        db_table = 'custom_user'

    def __str__(self):
        return self.email

class AddressModel(models.Model):
    """Django ORM model for Address"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUserModel, on_delete=models.CASCADE, 
                            related_name='addresses')
    street_number = models.CharField(max_length=20)
    street_name = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    zip_code = models.CharField(max_length=20)
    country = models.CharField(max_length=255)

    class Meta:
        db_table = 'user_addresses'
        indexes = [
            models.Index(fields=['user']),
        ]

    def __str__(self):
        return f'{self.street_number} {self.street_name}, {self.city}, {self.zip_code}'

class LogoutEventModel(models.Model):
    """Django ORM model for LogoutEvent"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(CustomUserModel, on_delete=models.CASCADE)
    device_info = models.CharField(max_length=255)
    ip_address = models.GenericIPAddressField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'logout_event'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
        ]

    def __str__(self):
        return f"{self.user.email} - {self.created_at}"

class BlacklistedTokenModel(models.Model):
    """Django ORM model for BlacklistedToken"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    token = models.CharField(max_length=500)
    user = models.ForeignKey(CustomUserModel, on_delete=models.CASCADE)
    blacklisted_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()

    class Meta:
        db_table = 'blacklisted_token'
        indexes = [
            models.Index(fields=['token']),
            models.Index(fields=['user', '-blacklisted_at']),
        ]

    def __str__(self):
        return f"{self.user.email} - {self.blacklisted_at}"
