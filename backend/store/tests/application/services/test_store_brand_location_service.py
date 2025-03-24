import unittest
from unittest.mock import Mock, patch, MagicMock
import uuid
from typing import List, Dict, Any, Optional, Tuple

from backend.store.domain.models.entities import StoreBrand
from backend.store.domain.value_objects.coordinates import Coordinates
from backend.store.domain.value_objects.address import Address
from backend.store.application.services.store_brand_location_service import StoreBrandLocationService


class TestStoreBrandLocationService(unittest.TestCase):
    """Test cases for the StoreBrandLocationService"""
    
    def setUp(self):
        """Set up test dependencies"""
        # Create mock repositories and services
        self.store_brand_repository = Mock()
        self.store_location_repository = Mock()
        self.location_service = Mock()
        self.cache_service = Mock()
        
        # Create the service under test
        self.service = StoreBrandLocationService(
            store_brand_repository=self.store_brand_repository,
            store_location_repository=self.store_location_repository,
            location_service=self.location_service,
            cache_service=self.cache_service
        )
        
        # Set up common test data
        self.test_brands = [
            StoreBrand(
                id=uuid.uuid4(),
                name="Test Brand 1",
                slug="test-brand-1",
                image_logo="logo1.png",
                image_banner="banner1.png"
            ),
            StoreBrand(
                id=uuid.uuid4(),
                name="Test Brand 2",
                slug="test-brand-2",
                image_logo="logo2.png",
                image_banner="banner2.png"
            )
        ]
        
        self.test_coordinates = Coordinates(latitude=37.7749, longitude=-122.4194)
        self.test_address = Address(
            street_number="123",
            route="Main St",
            city="San Francisco",
            postal_code="94105",
            country="USA"
        )
        
        # Sample place data returned by Google Maps API
        self.test_place = {
            'place_id': 'ChIJIQBpAG2ahYAR_6128GcTUEo',
            'name': 'Test Brand 1',
            'vicinity': '123 Main St, San Francisco',
            'distance': 1500,  # 1.5 km in meters
            'latitude': 37.7749,
            'longitude': -122.4194
        }
    
    def test_get_all_store_brands(self):
        """Test getting all store brands without locations"""
        # Set up mock repository to return test brands
        self.store_brand_repository.get_all_brands.return_value = self.test_brands
        
        # Call the method under test
        result = self.service.get_all_store_brands()
        
        # Verify the repository was called correctly
        self.store_brand_repository.get_all_brands.assert_called_once_with(None)
        
        # Verify the result
        self.assertEqual(len(result), 2)
        self.assertEqual(result[0].name, "Test Brand 1")
        self.assertEqual(result[1].name, "Test Brand 2")
    
    def test_get_all_store_brands_with_filter(self):
        """Test getting filtered store brands without locations"""
        # Set up mock repository to return filtered test brands
        self.store_brand_repository.get_all_brands.return_value = [self.test_brands[0]]
        
        # Call the method under test with filter
        result = self.service.get_all_store_brands(brand_slugs=["test-brand-1"])
        
        # Verify the repository was called correctly with the filter
        self.store_brand_repository.get_all_brands.assert_called_once_with(["test-brand-1"])
        
        # Verify the result
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0].name, "Test Brand 1")
    
    def test_find_nearby_store_brands_by_address_cache_hit(self):
        """Test finding nearby store brands by address with cache hit"""
        # Set up mock cache to return cached results
        self.cache_service.generate_location_key.return_value = "test_cache_key"
        self.cache_service.get.return_value = self.test_brands
        
        # Set up mock location service to return coordinates and address
        self.location_service.geocode_address.return_value = (self.test_coordinates, self.test_address)
        
        # Call the method under test
        result = self.service.find_nearby_store_brands_by_address(
            address="123 Main St, San Francisco",
            radius_km=5.0,
            brand_slugs=["test-brand-1", "test-brand-2"]
        )
        
        # Verify the cache was checked
        self.cache_service.generate_location_key.assert_called_once()
        self.cache_service.get.assert_called_once_with("test_cache_key")
        
        # Verify the location service was called
        self.location_service.geocode_address.assert_called_once_with("123 Main St, San Francisco")
        
        # Verify we didn't need to search for places
        self.location_service.find_place_by_name.assert_not_called()
        
        # Verify the result
        self.assertEqual(len(result), 2)
        self.assertEqual(result[0].name, "Test Brand 1")
        self.assertEqual(result[1].name, "Test Brand 2")
    
    def test_find_nearby_store_brands_by_address_cache_miss(self):
        """Test finding nearby store brands by address with cache miss"""
        # Set up mock cache to return a miss
        self.cache_service.generate_location_key.return_value = "test_cache_key"
        self.cache_service.get.return_value = None
        
        # Set up mock location service to return coordinates and address
        self.location_service.geocode_address.return_value = (self.test_coordinates, self.test_address)
        
        # Set up mock repository to return test brands
        self.store_brand_repository.get_all_brands.return_value = self.test_brands
        
        # Set up mock location service to return a place for the first brand only
        self.location_service.find_place_by_name.side_effect = [self.test_place, None]
        
        # Call the method under test
        result = self.service.find_nearby_store_brands_by_address(
            address="123 Main St, San Francisco",
            radius_km=5.0,
            brand_slugs=["test-brand-1", "test-brand-2"]
        )
        
        # Verify the cache was checked
        self.cache_service.generate_location_key.assert_called_once()
        self.cache_service.get.assert_called_once_with("test_cache_key")
        
        # Verify the location service was called
        self.location_service.geocode_address.assert_called_once_with("123 Main St, San Francisco")
        
        # Verify we searched for places for each brand
        self.assertEqual(self.location_service.find_place_by_name.call_count, 2)
        
        # Verify the cache was updated
        self.cache_service.set.assert_called_once()
        
        # Verify the result
        self.assertEqual(len(result), 2)
        
        # First brand should have location data
        self.assertEqual(result[0].name, "Test Brand 1")
        self.assertTrue(hasattr(result[0], 'distance_km'))
        self.assertEqual(result[0].distance_km, 1.5)  # 1500m converted to km
        
        # Second brand should not have location data
        self.assertEqual(result[1].name, "Test Brand 2")
        self.assertFalse(hasattr(result[1], 'distance_km'))
    
    def test_find_nearby_store_brands_geocode_failure(self):
        """Test finding nearby store brands with geocoding failure"""
        # Set up mock location service to fail geocoding
        self.location_service.geocode_address.return_value = None
        
        # Set up mock repository to return test brands
        self.store_brand_repository.get_all_brands.return_value = self.test_brands
        
        # Call the method under test
        result = self.service.find_nearby_store_brands_by_address(
            address="Invalid Address",
            radius_km=5.0
        )
        
        # Verify the location service was called
        self.location_service.geocode_address.assert_called_once_with("Invalid Address")
        
        # Verify we didn't search for places
        self.location_service.find_place_by_name.assert_not_called()
        
        # Verify we didn't use the cache
        self.cache_service.get.assert_not_called()
        self.cache_service.set.assert_not_called()
        
        # Verify the result is just the brands without locations
        self.assertEqual(len(result), 2)
        self.assertEqual(result[0].name, "Test Brand 1")
        self.assertEqual(result[1].name, "Test Brand 2")
        self.assertFalse(hasattr(result[0], 'distance_km'))
        self.assertFalse(hasattr(result[1], 'distance_km'))


if __name__ == '__main__':
    unittest.main()
