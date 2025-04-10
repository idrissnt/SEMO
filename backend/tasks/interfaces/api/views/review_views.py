from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from ....infrastructure.factory import ServiceFactory
from ..serializers import ReviewSerializer
from ....domain.models import TaskStatus

class ReviewViewSet(viewsets.ViewSet):
    """ViewSet for reviews"""
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.review_service = ServiceFactory.get_review_service()
    
    def create(self, request):
        """Create a review for a completed task
        url: /tasks/reviews/"""
        serializer = ReviewSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            reviewer_id = uuid.UUID(str(request.user.id))
            task_id = serializer.validated_data["task_id"]
            reviewee_id = serializer.validated_data["reviewee_id"]
            
            # Check if reviewer and reviewee are the same
            if reviewer_id == reviewee_id:
                return Response(
                    {"error": "You cannot review yourself"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Get task and assignment services
            task_service = ServiceFactory.get_task_service()
            assignment_service = ServiceFactory.get_assignment_service()
            
            # Validate task exists and is completed
            task = task_service.get_task_by_id(task_id)
            if not task:
                return Response(
                    {"error": "Task not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            if task.status.value != TaskStatus.COMPLETED.value:
                return Response(
                    {"error": "Task must be completed before it can be reviewed"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Validate assignment exists
            assignment = assignment_service.get_assignment_by_task(task_id)
            if not assignment:
                return Response(
                    {"error": "No assignment found for this task"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Validate reviewer and reviewee are involved in the task
            if (reviewer_id != task.requester_id and reviewer_id != assignment.performer_id) or \
               (reviewee_id != task.requester_id and reviewee_id != assignment.performer_id):
                return Response(
                    {"error": "Both reviewer and reviewee must be involved in the task"},
                    status=status.HTTP_403_FORBIDDEN
                )

            # Validate reviewer and reviewee are not the same
            if reviewer_id == reviewee_id:
                return Response(
                    {"error": "You cannot review yourself"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Create review data dictionary
            review_data = {
                'task_id': task_id,
                'reviewer_id': reviewer_id,
                'reviewee_id': reviewee_id,
                'rating': serializer.validated_data["rating"],
                'comment': serializer.validated_data.get("comment")
            }
            
            # Create review
            review = self.review_service.create_review(review_data)
            
            # Return serialized response
            response_serializer = ReviewSerializer(review)
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["get"], url_path="my-reviews")
    def my_reviews(self, request):
        """Get all reviews made by the authenticated user
        url: /tasks/reviews/my-reviews/"""
        user_id = uuid.UUID(str(request.user.id))
        reviews = self.review_service.get_reviews_for_reviewer(user_id)
        return Response(reviews)

    @action(detail=False, methods=["get"], url_path="my-reviews-received")
    def my_reviews_received(self, request):
        """Get all reviews received by the authenticated user
        url: /tasks/reviews/my-reviews-received/"""
        user_id = uuid.UUID(str(request.user.id))
        reviews = self.review_service.get_reviews_for_reviewee(user_id)
        return Response(reviews)

    @action(detail=False, methods=["get"], url_path="user-reviews")
    def user_reviews(self, request, pk=None):
        """Get all reviews for a specific user
        url: /tasks/reviews/user-reviews/{user_id}/"""
        try:
            user_id = uuid.UUID(pk)
            reviews = self.review_service.get_reviews_for_reviewee(user_id)
            return Response(reviews)
        except ValueError:
            return Response(
                {"error": "Invalid user ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
