import os
import uuid
import boto3
from botocore.exceptions import ClientError
from typing import Tuple, BinaryIO
from django.conf import settings

from store.domain.services.use_to_add_data.file_storage_service import FileStorageService


class S3FileStorageService(FileStorageService):
    """AWS S3 implementation of FileStorageService"""
    
    def __init__(self):
        """Initialize S3 client and configuration"""
        self.s3_client = boto3.client(
            's3',
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
        )
        self.bucket_name = settings.AWS_STORAGE_BUCKET_NAME
        self.base_url = f"https://{self.bucket_name}.s3.{settings.AWS_S3_REGION_NAME}.amazonaws.com/"
    
    def upload_file(self, file_data: BinaryIO, file_name: str, content_type: str) -> str:
        """Upload a file to S3 and return its URL"""
        # Generate a unique file name to avoid collisions
        file_extension = os.path.splitext(file_name)[1]
        unique_filename = f"product_images/{uuid.uuid4()}{file_extension}"
        
        try:
            # Upload the file
            self.s3_client.upload_fileobj(
                file_data,
                self.bucket_name,
                unique_filename,
                ExtraArgs={
                    'ContentType': content_type,
                    'ACL': 'public-read'  # Make the file publicly accessible
                }
            )
            
            # Return the URL
            return f"{self.base_url}{unique_filename}"
        except ClientError as e:
            # Log the error and re-raise
            print(f"Error uploading file to S3: {str(e)}")
            raise ValueError(f"Failed to upload file: {str(e)}")
    
    def delete_file(self, file_url: str) -> bool:
        """Delete a file from S3"""
        try:
            # Extract the key from the URL
            if file_url.startswith(self.base_url):
                key = file_url[len(self.base_url):]
            else:
                # If URL format is different, try to extract the path
                key = file_url.split('/')[-1]
                if not key:
                    return False
            
            # Delete the file
            self.s3_client.delete_object(
                Bucket=self.bucket_name,
                Key=key
            )
            
            return True
        except ClientError as e:
            print(f"Error deleting file from S3: {str(e)}")
            return False
    
    def generate_presigned_url(self, file_name: str, content_type: str, 
                              expiration: int = 3600) -> Tuple[str, dict]:
        """Generate a presigned URL for direct client-side uploads"""
        file_extension = os.path.splitext(file_name)[1]
        unique_filename = f"product_images/{uuid.uuid4()}{file_extension}"
        
        try:
            # Generate presigned URL for PUT operation
            presigned_url = self.s3_client.generate_presigned_url(
                'put_object',
                Params={
                    'Bucket': self.bucket_name,
                    'Key': unique_filename,
                    'ContentType': content_type,
                    'ACL': 'public-read'
                },
                ExpiresIn=expiration
            )
            
            # The URL where the file will be accessible after upload
            public_url = f"{self.base_url}{unique_filename}"
            
            return presigned_url, {'public_url': public_url}
        except ClientError as e:
            print(f"Error generating presigned URL: {str(e)}")
            raise ValueError(f"Failed to generate presigned URL: {str(e)}")
