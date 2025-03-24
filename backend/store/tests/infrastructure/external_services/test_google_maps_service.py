import unittest
from unittest.mock import Mock, patch, MagicMock
import uuid
from typing import List, Dict, Any, Optional, Tuple
import os

from backend.store.domain.value_objects.coordinates import Coordinates
from backend.store.domain.value_objects.address import Address
from backend.store.infrastructure.external_services.google_maps_service import GoogleMapsService


class TestGoogleMapsService(unittest.TestCase):
    """Test cases for the GoogleMapsService"""
    
    def setUp(self):
        """Set up test dependencies"""
        # Create a mock Google Maps client
        self.mock_client = MagicMock()
        
        # Create the service with the mock client
        with patch('googlemaps.Client', return_value=self.mock_client):
            self.service = GoogleMapsService(test_mode=True)
        
        # Set up common test data
        self.test_coordinates = Coordinates(latitude=37.7749, longitude=-122.4194)
        self.test_address_str = "123 Main St, San Francisco, CA 94105"
        
        # Sample geocode response from Google Maps API
        self.geocode_response = [{
            'address_components': [
                {'long_name': '123', 'short_name': '123', 'types': ['street_number']},
                {'long_name': 'Main Street', 'short_name': 'Main St', 'types': ['route']},
                {'long_name': 'San Francisco', 'short_name': 'SF', 'types': ['locality', 'political']},
                {'long_name': 'California', 'short_name': 'CA', 'types': ['administrative_area_level_1', 'political']},
                {'long_name': '94105', 'short_name': '94105', 'types': ['postal_code']},
                {'long_name': 'United States', 'short_name': 'US', 'types': ['country', 'political']}
            ],
            'formatted_address': '123 Main St, San Francisco, CA 94105, USA',
            'geometry': {
                'location': {'lat': 37.7749, 'lng': -122.4194}
            },
            'place_id': 'ChIJIQBpAG2ahYAR_6128GcTUEo'
        }]
        
        # Sample nearby places response from Google Maps API
        self.nearby_places_response = {
            'results': [
                {
                    'place_id': 'ChIJIQBpAG2ahYAR_6128GcTUEo',
                    'name': 'Test Store 1',
                    'vicinity': '123 Main St, San Francisco',
                    'geometry': {
                        'location': {'lat': 37.7749, 'lng': -122.4194}
                    }
                },
                {
                    'place_id': 'ChIJIQBpAG2ahYAR_6128GcTUEo2',
                    'name': 'Test Store 2',
                    'vicinity': '456 Market St, San Francisco',
                    'geometry': {
                        'location': {'lat': 37.7850, 'lng': -122.4100}
                    }
                }
            ],
            'status': 'OK'
        }
        
        # Sample place details response from Google Maps API
        self.place_details_response = {
            'result': {
                'place_id': 'ChIJIQBpAG2ahYAR_6128GcTUEo',
                'name': 'Test Store 1',
                'formatted_address': '123 Main St, San Francisco, CA 94105, USA',
                'geometry': {
                    'location': {'lat': 37.7749, 'lng': -122.4194}
                },
                'formatted_phone_number': '(415) 555-1234',
                'website': 'https://example.com',
                'opening_hours': {
                    'weekday_text': [
                        'Monday: 9:00 AM – 5:00 PM',
                        'Tuesday: 9:00 AM – 5:00 PM',
                        'Wednesday: 9:00 AM – 5:00 PM',
                        'Thursday: 9:00 AM – 5:00 PM',
                        'Friday: 9:00 AM – 5:00 PM',
                        'Saturday: 10:00 AM – 4:00 PM',
                        'Sunday: Closed'
                    ]
                }
            }
        }

    def test_geocode_address_success(self):
        """Test geocoding an address successfully"""
        # Set up mock client to return test geocode response
        self.mock_client.geocode.return_value = self.geocode_response
        
        # Call the method under test
        result = self.service.geocode_address(self.test_address_str)
        
        # Verify the client was called correctly
        self.mock_client.geocode.assert_called_once_with(self.test_address_str)
        
        # Verify the result
        coordinates, address = result
        self.assertEqual(coordinates.latitude, 37.7749)
        self.assertEqual(coordinates.longitude, -122.4194)
        self.assertEqual(address.street_number, '123')
        self.assertEqual(address.route, 'Main Street')
        self.assertEqual(address.city, 'San Francisco')
        self.assertEqual(address.postal_code, '94105')
        self.assertEqual(address.country, 'United States')
    
    def test_geocode_address_failure(self):
        """Test geocoding an address with failure"""
        # Set up mock client to return empty response
        self.mock_client.geocode.return_value = []
        
        # Call the method under test
        result = self.service.geocode_address(self.test_address_str)
        
        # Verify the client was called correctly
        self.mock_client.geocode.assert_called_once_with(self.test_address_str)
        
        # Verify the result is None
        self.assertIsNone(result)
    
    def test_find_places_nearby_success(self):
        """Test finding places nearby successfully"""
        # Set up mock client to return test nearby places response
        self.mock_client.places_nearby.return_value = self.nearby_places_response
        
        # Call the method under test
        result = self.service.find_places_nearby(
            coordinates=self.test_coordinates,
            radius_m=5000,
            keyword="Test Store",
            type="store"
        )
        
        # Verify the client was called correctly
        self.mock_client.places_nearby.assert_called_once_with(
            location=(37.7749, -122.4194),
            radius=5000,
            keyword="Test Store",
            type="store"
        )
        
        # Verify the result
        self.assertEqual(len(result), 2)
        self.assertEqual(result[0]['place_id'], 'ChIJIQBpAG2ahYAR_6128GcTUEo')
        self.assertEqual(result[0]['name'], 'Test Store 1')
        self.assertEqual(result[1]['place_id'], 'ChIJIQBpAG2ahYAR_6128GcTUEo2')
        self.assertEqual(result[1]['name'], 'Test Store 2')
    
    def test_find_places_nearby_empty_results(self):
        """Test finding places nearby with empty results"""
        # Set up mock client to return empty response
        self.mock_client.places_nearby.return_value = {'results': [], 'status': 'ZERO_RESULTS'}
        
        # Call the method under test
        result = self.service.find_places_nearby(
            coordinates=self.test_coordinates,
            radius_m=5000,
            keyword="Nonexistent Store",
            type="store"
        )
        
        # Verify the client was called correctly
        self.mock_client.places_nearby.assert_called_once_with(
            location=(37.7749, -122.4194),
            radius=5000,
            keyword="Nonexistent Store",
            type="store"
        )
        
        # Verify the result is an empty list
        self.assertEqual(result, [])
    
    def test_get_place_details_success(self):
        """Test getting place details successfully"""
        # Set up mock client to return test place details response
        self.mock_client.place.return_value = self.place_details_response
        
        # Call the method under test
        result = self.service.get_place_details('ChIJIQBpAG2ahYAR_6128GcTUEo')
        
        # Verify the client was called correctly
        self.mock_client.place.assert_called_once()
        
        # Verify the result
        self.assertEqual(result['place_id'], 'ChIJIQBpAG2ahYAR_6128GcTUEo')
        self.assertEqual(result['name'], 'Test Store 1')
        self.assertEqual(result['formatted_address'], '123 Main St, San Francisco, CA 94105, USA')
    
    def test_find_place_by_name_success(self):
        """Test finding a place by name successfully"""
        # Set up mock to return places
        self.mock_client.places_nearby.return_value = self.nearby_places_response
        
        # Call the method under test
        result = self.service.find_place_by_name(
            name="Test Store",
            coordinates=self.test_coordinates,
            radius_km=5.0
        )
        
        # Verify the client was called correctly
        self.mock_client.places_nearby.assert_called_once_with(
            location=(37.7749, -122.4194),
            radius=5000,  # 5km converted to meters
            keyword="Test Store",
            type="store"
        )
        
        # Verify the result is the first place
        self.assertEqual(result['place_id'], 'ChIJIQBpAG2ahYAR_6128GcTUEo')
        self.assertEqual(result['name'], 'Test Store 1')
    
    def test_find_place_by_name_no_results(self):
        """Test finding a place by name with no results"""
        # Set up mock to return empty results
        self.mock_client.places_nearby.return_value = {'results': [], 'status': 'ZERO_RESULTS'}
        
        # Call the method under test
        result = self.service.find_place_by_name(
            name="Nonexistent Store",
            coordinates=self.test_coordinates,
            radius_km=5.0
        )
        
        # Verify the client was called correctly
        self.mock_client.places_nearby.assert_called_once()
        
        # Verify the result is None
        self.assertIsNone(result)


if __name__ == '__main__':
    unittest.main()
