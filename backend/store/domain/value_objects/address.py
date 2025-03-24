from dataclasses import dataclass

@dataclass(frozen=True)
class Address:
    """Value object representing a physical address"""
    street_number: str
    route: str  # Street name
    city: str
    postal_code: str
    country: str
    
    def get_full_address(self) -> str:
        """Returns the full formatted address"""
        return f"{self.street_number} {self.route}, {self.city}, {self.postal_code}, {self.country}"
    
    def get_short_address(self) -> str:
        """Returns a shorter version of the address"""
        return f"{self.street_number} {self.route}, {self.city}"