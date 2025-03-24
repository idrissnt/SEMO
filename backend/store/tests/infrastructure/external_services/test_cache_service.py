import unittest
from unittest.mock import Mock, patch, MagicMock
from typing import List, Dict, Any, Optional

from backend.store.domain.value_objects.coordinates import Coordinates
from backend.store.infrastructure.external_services.cache_service import DjangoCacheService


class TestDjangoCacheService(unittest.TestCase):
    """Test cases for the DjangoCacheService"""
    
    def setUp(self):
        """Set up test dependencies"""
        # Create the service under test
        self.service = DjangoCacheService()
        
        # Set up common test data
        self.test_coordinates = Coordinates(latitude=37.7749, longitude=-122.4194)
        self.test_key = "test_key"
        self.test_value = {"test": "data"}
        self.test_timeout = 3600
    
    @patch('backend.store.infrastructure.external_services.cache_service.cache')
    def test_get(self, mock_cache):
        """Test getting a value from cache"""
        # Set up mock cache to return test value
        mock_cache.get.return_value = self.test_value
        
        # Call the method under test
        result = self.service.get(self.test_key)
        
        # Verify the cache was called correctly
        mock_cache.get.assert_called_once_with(self.test_key)
        
        # Verify the result
        self.assertEqual(result, self.test_value)
    
    @patch('backend.store.infrastructure.external_services.cache_service.cache')
    def test_set(self, mock_cache):
        """Test setting a value in cache"""
        # Call the method under test
        self.service.set(self.test_key, self.test_value, self.test_timeout)
        
        # Verify the cache was called correctly
        mock_cache.set.assert_called_once_with(self.test_key, self.test_value, self.test_timeout)
    
    @patch('backend.store.infrastructure.external_services.cache_service.cache')
    def test_delete(self, mock_cache):
        """Test deleting a value from cache"""
        # Call the method under test
        self.service.delete(self.test_key)
        
        # Verify the cache was called correctly
        mock_cache.delete.assert_called_once_with(self.test_key)
    
    def test_generate_location_key(self):
        """Test generating a location cache key"""
        # Test with coordinates and radius only
        key1 = self.service.generate_location_key(
            coordinates=self.test_coordinates,
            radius_km=5.0
        )
        
        # Verify the key format
        self.assertIn("location:", key1)
        self.assertIn("37.7749", key1)
        self.assertIn("-122.4194", key1)
        self.assertIn("5.0", key1)
        
        # Test with brand slugs
        key2 = self.service.generate_location_key(
            coordinates=self.test_coordinates,
            radius_km=5.0,
            brand_slugs=["brand-1", "brand-2"]
        )
        
        # Verify the key format with brands
        self.assertIn("location:", key2)
        self.assertIn("37.7749", key2)
        self.assertIn("-122.4194", key2)
        self.assertIn("5.0", key2)
        self.assertIn("brand-1-brand-2", key2)
        
        # Test with brand slugs in different order
        key3 = self.service.generate_location_key(
            coordinates=self.test_coordinates,
            radius_km=5.0,
            brand_slugs=["brand-2", "brand-1"]
        )
        
        # Verify the key is the same regardless of brand order
        self.assertEqual(key2, key3)
    
    def test_coordinate_rounding(self):
        """Test that coordinates are properly rounded in the cache key"""
        # Create two nearly identical coordinates
        coords1 = Coordinates(latitude=37.77491, longitude=-122.41942)
        coords2 = Coordinates(latitude=37.77492, longitude=-122.41943)
        
        # Generate keys for both
        key1 = self.service.generate_location_key(coordinates=coords1, radius_km=5.0)
        key2 = self.service.generate_location_key(coordinates=coords2, radius_km=5.0)
        
        # Verify the keys are the same due to rounding
        self.assertEqual(key1, key2)


if __name__ == '__main__':
    unittest.main()
