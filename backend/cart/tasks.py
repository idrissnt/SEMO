import logging
from celery import shared_task

from cart.infrastructure.factory import CartFactory

logger = logging.getLogger(__name__)

@shared_task
def process_cart_recoveries():
    """Process abandoned cart recoveries and send recovery emails
    
    This task should be scheduled to run periodically (e.g., every hour)
    """
    logger.info("Starting scheduled cart recovery processing")
    
    # Create recovery service using the factory
    recovery_service = CartFactory.create_cart_recovery_service()
    
    # Process pending recoveries
    total, successful = recovery_service.process_pending_recoveries()
    
    logger.info(f"Processed {total} cart recoveries with {successful} emails sent")
    
    return {
        'total_processed': total,
        'successful_sends': successful
    }
