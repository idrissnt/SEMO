"""
Storage backends for S3 file storage.

This module provides custom storage classes for different types of files,
following Domain-Driven Design principles by separating storage concerns.
"""
from storages.backends.s3boto3 import S3Boto3Storage
from django.conf import settings


class MediaStorage(S3Boto3Storage):
    """
    Storage class for media files (user-uploaded content).
    
    This class configures S3 storage specifically for media files like
    product images, store logos, and other user-uploaded content.
    """
    location = 'media'  # Stores files under the 'media/' prefix in the bucket
    file_overwrite = getattr(settings, 'AWS_S3_OVERWRITE', False)
    default_acl = getattr(settings, 'AWS_DEFAULT_ACL', 'public-read')
