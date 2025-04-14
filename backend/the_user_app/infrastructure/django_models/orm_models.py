import uuid
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.contrib.postgres.fields import ArrayField

from ...domain.models.value_objects import ExperienceLevel

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
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=150, unique=True, 
                               null=True, blank=True)
    email = models.EmailField(_('email address'), unique=True)
    first_name = models.CharField(max_length=255)
    profile_photo_url = models.URLField(null=True, blank=True, default=None)
    last_name = models.CharField(max_length=255, null=True, blank=True)
    phone_number = models.CharField(max_length=15, unique=True, 
                                   null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_login = models.DateTimeField(null=True, blank=True)
    last_logout = models.DateTimeField(null=True, blank=True)

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
    user = models.OneToOneField(CustomUserModel, on_delete=models.CASCADE, 
                            related_name='address')
    street_number = models.CharField(max_length=20)
    street_name = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    zip_code = models.CharField(max_length=20)
    country = models.CharField(max_length=255)

    class Meta:
        db_table = 'user_address'
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


class TaskPerformerProfileModel(models.Model):
    """Django ORM model for task PerformerProfile"""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(CustomUserModel, on_delete=models.CASCADE, related_name='performer_profile')
    skills = ArrayField(models.CharField(max_length=100), default=list)
    experience_level = models.CharField(max_length=20, choices=ExperienceLevel.choices())
    profile_photo_url = models.URLField(null=True, blank=True, default=None)
    availability = models.JSONField(default=dict)  # JSON structure for availability schedule
    preferred_radius_km = models.IntegerField(default=10)
    bio = models.TextField(null=True, blank=True)
    hourly_rate = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    rating = models.FloatField(null=True, blank=True)
    completed_tasks_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'performer_profiles'
        verbose_name = 'Performer Profile'
        verbose_name_plural = 'Performer Profiles'
        indexes = [
            models.Index(fields=['user']),
            models.Index(fields=['experience_level']),
            models.Index(fields=['rating']),
        ]
    
    def __str__(self):
        return f"Performer Profile for {self.user.email}"
