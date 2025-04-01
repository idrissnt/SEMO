import logging
import uuid
from typing import List, Tuple
from django.utils import timezone
from django.core.cache import cache

from cart.domain.repositories.repository_interfaces import CartRepository
from cart.application.services.cart_service import CartApplicationService

logger = logging.getLogger(__name__)

class CartRecoveryService:
    """Service for handling cart recovery operations
    
    This service is responsible for identifying abandoned carts,
    sending recovery emails, and tracking recovery attempts.
    """
    
    def __init__(self, cart_repository: CartRepository, cart_service: CartApplicationService):
        self.cart_repository = cart_repository
        self.cart_service = cart_service
        
    def get_carts_for_recovery(self) -> List[uuid.UUID]:
        """Get all carts that are marked for recovery and ready to be processed
        
        Returns:
            List of cart IDs that need recovery emails
        """
        recovery_carts = []
        
        # Get all keys from cache that match the pattern
        # Note: This is a simplified implementation using Django's cache
        # In a production environment, you might want to use a more robust solution
        # like a dedicated queue or a scheduled task
        all_keys = cache.keys("cart_recovery:*")
        now = timezone.now()
        
        for key in all_keys:
            # Extract cart ID from key
            try:
                cart_id = uuid.UUID(key.split(":", 1)[1])
                recovery_time_str = cache.get(key)
                
                if not recovery_time_str:
                    continue
                    
                recovery_time = timezone.datetime.fromisoformat(recovery_time_str)
                
                # Check if it's time to send the recovery email
                if now >= recovery_time:
                    # Get the cart to verify it still exists and has items
                    cart = self.cart_repository.get_cart(cart_id=cart_id)
                    if cart and not cart.is_empty():
                        recovery_carts.append(cart_id)
                    
                    # Remove from cache regardless of whether we'll process it
                    # This prevents repeated processing of deleted carts
                    cache.delete(key)
            except (ValueError, IndexError, TypeError) as e:
                logger.error(f"Error processing recovery cart key {key}: {str(e)}")
                # Clean up invalid keys
                cache.delete(key)
                
        return recovery_carts
        
    def send_recovery_email(self, cart_id: uuid.UUID) -> bool:
        """Send a recovery email for an abandoned cart
        
        Args:
            cart_id: UUID of the cart
            
        Returns:
            True if email was sent successfully
        """
        try:
            # Get cart
            cart = self.cart_repository.get_cart(cart_id=cart_id)
            if not cart or cart.is_empty():
                return False
            
            # Here we would implement the actual email sending logic
            # This could involve using Django's email functionality or a third-party service
            
            # For demonstration purposes, we'll just log that we would send an email
            logger.info(f"Would send recovery email for cart {cart_id} to user {cart.user_id}")
            logger.info(f"Cart contains {len(cart.items)} items with total price {cart.total_price}")
            
            # In a real implementation, we would:
            # 1. Generate a recovery URL with a token
            # 2. Create an email template with cart details
            # 3. Send the email
            # 4. Track the email send in your database
            
            return True
        except Exception as e:
            logger.error(f"Error sending recovery email for cart {cart_id}: {str(e)}")
            return False
            
    def process_pending_recoveries(self) -> Tuple[int, int]:
        """Process all pending cart recoveries
        
        Returns:
            Tuple of (total_processed, successful_sends)
        """
        cart_ids = self.get_carts_for_recovery()
        successful = 0
        
        for cart_id in cart_ids:
            if self.send_recovery_email(cart_id):
                successful += 1
                
        return len(cart_ids), successful
