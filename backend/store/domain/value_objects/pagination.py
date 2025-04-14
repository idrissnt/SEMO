"""
Pagination value object for domain layer.
"""
from dataclasses import dataclass
from typing import TypeVar, Generic, List, Optional

T = TypeVar('T')

@dataclass(frozen=True)
class PaginationParams:
    """Value object representing pagination parameters"""
    page: int = 1
    page_size: int = 10
    
    def __post_init__(self):
        """Validate pagination parameters"""
        if self.page < 1:
            object.__setattr__(self, 'page', 1)
        if self.page_size < 1:
            object.__setattr__(self, 'page_size', 10)
        elif self.page_size > 20:
            object.__setattr__(self, 'page_size', 20)
    
    @property
    def offset(self) -> int:
        """Calculate offset based on page and page_size"""
        return (self.page - 1) * self.page_size
    
    @property
    def limit(self) -> int:
        """Return the page size as limit"""
        return self.page_size


@dataclass(frozen=True)
class PagedResult(Generic[T]):
    """Value object representing a paginated result set"""
    items: List[T]
    total_items: int
    page: int
    page_size: int
    
    @property
    def total_pages(self) -> int:
        """Calculate total pages based on total items and page size"""
        return (self.total_items + self.page_size - 1) // self.page_size
    
    @property
    def has_next(self) -> bool:
        """Check if there is a next page"""
        return self.page < self.total_pages
    
    @property
    def has_previous(self) -> bool:
        """Check if there is a previous page"""
        return self.page > 1
    
    @property
    def next_page(self) -> Optional[int]:
        """Get next page number if it exists"""
        return self.page + 1 if self.has_next else None
    
    @property
    def previous_page(self) -> Optional[int]:
        """Get previous page number if it exists"""
        return self.page - 1 if self.has_previous else None
