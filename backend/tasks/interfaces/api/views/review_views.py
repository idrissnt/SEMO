from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from infrastructure.factory import ServiceFactory
from serializers import ReviewSerializer


class ReviewViewSet(viewsets.ViewSet):
    """ViewSet for reviews"""
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.review_service = ServiceFactory.get_review_service()
    
    def create(self, request):
        """Create a review for a completed task"""
        serializer = ReviewSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            reviewer_id = uuid.UUID(str(request.user.id))
            review = self.review_service.create_review(
                task_id=serializer.validated_data["task_id"],
                reviewer_id=reviewer_id,
                reviewee_id=serializer.validated_data["reviewee_id"],
                rating=serializer.validated_data["rating"],
                comment=serializer.validated_data.get("comment")
            )
            return Response(review, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["get"])
    def my_reviews(self, request):
        """Get all reviews for the authenticated user"""
        user_id = uuid.UUID(str(request.user.id))
        reviews = self.review_service.get_reviews_for_user(user_id)
        return Response(reviews)
    
    @action(detail=True, methods=["get"])
    def user_reviews(self, request, pk=None):
        """Get all reviews for a specific user"""
        try:
            user_id = uuid.UUID(pk)
            reviews = self.review_service.get_reviews_for_user(user_id)
            return Response(reviews)
        except ValueError:
            return Response(
                {"error": "Invalid user ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
