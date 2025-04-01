"""
Constants for the delivery domain model.
This file defines all constants used in the delivery domain to ensure consistency
across the entire domain and avoid duplication.
"""

# Delivery status constants
class DeliveryStatus:
    PENDING = 'pending'
    ASSIGNED = 'assigned'
    OUT_FOR_DELIVERY = 'out_for_delivery'
    DELIVERED = 'delivered'
    CANCELLED = 'cancelled'
    
    # List of valid statuses in order of progression
    PROGRESSION = [PENDING, ASSIGNED, OUT_FOR_DELIVERY, DELIVERED]
    
    # All valid statuses
    ALL = PROGRESSION + [CANCELLED]
    
    # Human-readable labels for display
    LABELS = {
        PENDING: 'Pending',
        ASSIGNED: 'Assigned',
        OUT_FOR_DELIVERY: 'Out for Delivery',
        DELIVERED: 'Delivered',
        CANCELLED: 'Cancelled',
    }
    
    # Valid status transitions
    TRANSITIONS = {
        PENDING: [ASSIGNED, CANCELLED],
        ASSIGNED: [OUT_FOR_DELIVERY, CANCELLED],
        OUT_FOR_DELIVERY: [DELIVERED, CANCELLED],
        DELIVERED: [],  # Terminal state
        CANCELLED: []   # Terminal state
    }


# Delivery timeline event types
class DeliveryEventType:
    CREATED = 'created'
    ASSIGNED = 'assigned'
    PICKED_UP = 'picked_up'
    OUT_FOR_DELIVERY = 'out_for_delivery'
    DELIVERED = 'delivered'
    CANCELLED = 'cancelled'
    LOCATION_UPDATED = 'location_updated'
    
    # All valid event types
    ALL = [CREATED, ASSIGNED, PICKED_UP, OUT_FOR_DELIVERY, DELIVERED, CANCELLED, LOCATION_UPDATED]
    
    # Human-readable labels for display
    LABELS = {
        CREATED: 'Created',
        ASSIGNED: 'Assigned to Driver',
        PICKED_UP: 'Picked Up',
        OUT_FOR_DELIVERY: 'Out for Delivery',
        DELIVERED: 'Delivered',
        CANCELLED: 'Cancelled',
        LOCATION_UPDATED: 'Location Updated',
    }
