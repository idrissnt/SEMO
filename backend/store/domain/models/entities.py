from dataclasses import dataclass, field
from typing import Optional
import uuid

@dataclass
class StoreBrand:
    """Domain model representing a StoreBrand chain"""
    name: str
    slug: str
    type: str
    image_logo: str
    image_banner: str
    id: uuid.UUID = field(default_factory=uuid.uuid4)

    def generate_slug(self):
        self.slug = self.name.lower().replace(' ', '-')

    def __str__(self) -> str:
        return self.name

@dataclass
class ProductWithDetails:
    """Domain model representing a product with category and price details"""

    # Store fields
    store_name: str
    store_image_logo: str
    store_id: uuid.UUID
    
    # Category fields
    category_name: str
    category_path: str
    category_slug: str  
    
    # Product fields
    product_name: str
    product_slug: str
    quantity: int
    unit: str
    description: str
    image_url: str
    image_thumbnail: Optional[str]
    
    # Store product fields
    price: float
    price_per_unit: float
    
    # IDs for references if needed
    product_id: uuid.UUID = field(default_factory=uuid.uuid4)
    category_id: uuid.UUID = field(default_factory=uuid.uuid4)
    store_product_id: uuid.UUID = field(default_factory=uuid.uuid4)

@dataclass
class ProductName:
    name: str

    def __str__(self) -> str:
        return self.name

@dataclass
class Product:
    """Domain model representing a product"""
    name: str
    slug: str
    quantity: int
    unit: str
    description: str
    image_url: str  # Infrastructure handles processing
    image_thumbnail: Optional[str]
    id: uuid.UUID = field(default_factory=uuid.uuid4)

    def generate_slug(self):
        self.slug = self.name.lower().replace(' ', '-')

    def __str__(self) -> str:
        return f"{self.name} ({self.quantity} {self.unit})"

@dataclass
class Category:
    """Domain model representing a store brand category"""
    name: str
    store_brand_id: uuid.UUID
    path: str  # Hierarchical path (e.g., "Store1.Food.Fruits")
    slug: str
    description: Optional[str] = None
    id: uuid.UUID = field(default_factory=uuid.uuid4)

    def generate_slug(self):
        self.slug = self.name.lower().replace(' ', '-')
    
    def __str__(self) -> str:
        return self.name

@dataclass
class StoreProduct:
    store_brand_id: uuid.UUID
    product_id: uuid.UUID
    category_id: uuid.UUID
    price: float
    price_per_unit: float
    id: uuid.UUID = field(default_factory=uuid.uuid4)

    def __str__(self) -> str:
        return f"{self.product_id.name} at {self.store_brand_id} - ${self.price}"
