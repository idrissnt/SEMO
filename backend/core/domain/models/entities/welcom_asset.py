from dataclasses import dataclass
from uuid import UUID
from typing import Optional

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
    card_title_one: str
    card_title_two: str
    store_title: str
    store_logo_one_url: str
    store_logo_two_url: str
    store_logo_three_url: str

@dataclass
class TaskAsset:
    """Domain entity representing a task asset"""
    id: UUID
    title: Optional[str]
    task_image_url: str
    tasker_profile_image_url : Optional[str] 
    tasker_profile_title : Optional[str]
