from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from rest_framework.parsers import MultiPartParser, FormParser
import base64
import io

from store.infrastructure.factory import StoreFactory


class ImageUploadViewSet(viewsets.ViewSet):
    """ViewSet for handling image uploads to S3"""
    # permission_classes = [IsAdminUser]
    parser_classes = [MultiPartParser, FormParser]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.file_storage_service = StoreFactory.create_file_storage_service()
    
    def list(self, request):
        """List all uploaded images"""
        return Response({"message": "Not implemented"})

    @action(detail=False, methods=['post'])
    def upload(self, request):
        """Upload an image file to S3 and return the URL
        
        Accepts multipart/form-data with an 'image' field containing the file
        """
        if 'image' not in request.FILES:
            return Response(
                {"error": "No image file provided"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            image_file = request.FILES['image']
            
            # Upload to S3
            file_url = self.file_storage_service.upload_file(
                file_data=image_file,
                file_name=image_file.name,
                content_type=image_file.content_type
            )
            
            return Response({
                "url": file_url,
                "message": "Image uploaded successfully"
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['post'])
    def upload_base64(self, request):
        """Upload a base64 encoded image to S3 and return the URL
        
        Accepts JSON with:
        - 'image_data': Base64 encoded image data
        - 'file_name': File name with extension (e.g., 'image.jpg')
        - 'content_type': MIME type (e.g., 'image/jpeg')
        """
        required_fields = ['image_data', 'file_name', 'content_type']
        for field in required_fields:
            if field not in request.data:
                return Response(
                    {"error": f"Missing required field: {field}"},
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        try:
            # Decode base64 data
            image_data = request.data['image_data']
            if image_data.startswith('data:'):
                # Handle data URLs (e.g., 'data:image/jpeg;base64,/9j/4AAQ...')
                image_data = image_data.split(',', 1)[1]
            
            # Convert to file-like object
            file_data = io.BytesIO(base64.b64decode(image_data))
            
            # Upload to S3
            file_url = self.file_storage_service.upload_file(
                file_data=file_data,
                file_name=request.data['file_name'],
                content_type=request.data['content_type']
            )
            
            return Response({
                "url": file_url,
                "message": "Image uploaded successfully"
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['post'], url_path='get-presigned-url')
    def get_presigned_url(self, request):
        """Generate a presigned URL for direct client-side uploads
        
        Accepts JSON with:
        - 'file_name': File name with extension (e.g., 'image.jpg')
        - 'content_type': MIME type (e.g., 'image/jpeg')
        
        Returns a presigned URL and any additional form data needed for the upload
        """
        required_fields = ['file_name', 'content_type']
        for field in required_fields:
            if field not in request.data:
                return Response(
                    {"error": f"Missing required field: {field}"},
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        try:
            # Generate presigned URL
            presigned_url, form_data = self.file_storage_service.generate_presigned_url(
                file_name=request.data['file_name'],
                content_type=request.data['content_type'],
                expiration=3600  # 1 hour
            )
            
            return Response({
                "presigned_url": presigned_url,
                "form_data": form_data,
                "message": "Presigned URL generated successfully"
            })
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
