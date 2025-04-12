from dataclasses import dataclass, field
import uuid
from typing import Optional
from datetime import datetime

@dataclass
class ProductCollectionBatch:
    """Domain model representing a batch of products being collected"""
    store_brand_id: uuid.UUID
    collector_id: uuid.UUID  # User ID of the person collecting
    name: str
    status: str  # 'draft', 'in_progress', 'completed', 'processed'
    created_at: datetime = field(default_factory=datetime.now)
    completed_at: Optional[datetime] = None
    id: uuid.UUID = field(default_factory=uuid.uuid4)

@dataclass
class CollectedProduct:
    """Domain model representing a product collected via mobile app"""
    batch_id: uuid.UUID
    name: str
    slug: str
    quantity: int
    unit: str
    description: str
    category_name: str
    category_slug: str
    category_path: str
    price: float
    price_per_unit: float
    image_url: str = None  # Base64 encoded image or URL
    notes: Optional[str] = None
    status: str = 'pending'  # 'pending', 'processed', 'error'
    error_message: Optional[str] = None
    id: uuid.UUID = field(default_factory=uuid.uuid4)
