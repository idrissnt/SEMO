"""
Constants for the order domain model.
This file defines all constants used in the order domain to ensure consistency
across the entire domain and avoid duplication.
"""

# Order status constants
class OrderStatus:
    PENDING = 'pending' 
    PROCESSING = 'processing'
    OUT_FOR_DELIVERY = 'out_for_delivery'
    DELIVERED = 'delivered'
    CANCELLED = 'cancelled'
    
    # List of valid statuses in order of progression
    PROGRESSION = [PENDING, PROCESSING, OUT_FOR_DELIVERY, DELIVERED]
    
    # All valid statuses
    ALL = PROGRESSION + [CANCELLED]
    
    # Human-readable labels for display
    LABELS = {
        PENDING: 'Pending',
        PROCESSING: 'Processing',
        OUT_FOR_DELIVERY: 'Out for Delivery',
        DELIVERED: 'Delivered',
        CANCELLED: 'Cancelled',
    }

# Order timeline event types
class OrderEventType:
    CREATED = 'created'
    PAYMENT_RECEIVED = 'payment_received'
    PROCESSING = 'processing'
    OUT_FOR_DELIVERY = 'out_for_delivery'
    DELIVERED = 'delivered'
    CANCELLED = 'cancelled'
    
    # All valid event types
    ALL = [CREATED, PAYMENT_RECEIVED, PROCESSING, OUT_FOR_DELIVERY, DELIVERED, CANCELLED]
    
    # Human-readable labels for display
    LABELS = {
        CREATED: 'Created',
        PAYMENT_RECEIVED: 'Payment Received',
        PROCESSING: 'Processing',
        OUT_FOR_DELIVERY: 'Out for Delivery',
        DELIVERED: 'Delivered',
        CANCELLED: 'Cancelled',
    }
