from dataclasses import dataclass
from uuid import UUID

@dataclass
class CompanyAsset:
    """Domain entity representing a welcome asset"""
    id: UUID
    name: str
    logo_url: str

@dataclass
class StoreAsset:
    """Domain entity representing a store asset"""
    id: UUID
    title_one: str
    title_two: str
    first_logo_url: str
    second_logo_url: str
    third_logo_url: str

@dataclass
class TaskAsset:
    """Domain entity representing a task asset"""
    id: UUID
    title_one: str
    title_two: str
    first_image_url: str
    second_image_url: str
    third_image_url: str
    fourth_image_url: str
    fifth_image_url: str
