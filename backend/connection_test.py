import socket
import requests
import json
import os
import sys

# Add the project root to Python path
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, project_root)

# Django setup
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from django.contrib.auth import get_user_model

def get_test_user_credentials():
    User = get_user_model()
    try:
        # Try to find an existing test user
        user = User.objects.filter(email__startswith='test').first()
        if user:
            return user.email, 'testpassword'
        
        # If no test user, create one
        user = User.objects.create_user(
            email='test@example.com', 
            password='testpassword'
        )
        return user.email, 'testpassword'
    except Exception as e:
        print(f"Error creating test user: {e}")
        return None, None

def test_local_connection():
    print("Local Connection Test:")
    try:
        # Test socket connection
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        result = sock.connect_ex(('172.20.10.10', 8000))
        
        if result == 0:
            print(" Port 8000 is open and listening")
        else:
            print(" Port 8000 is not accessible")
        
        sock.close()
    except Exception as e:
        print(f"Socket Connection Error: {e}")

def test_http_connection():
    print("\nHTTP Connection Test:")
    base_url = 'http://172.20.10.10:8000/api/auth'
    
    # Get test user credentials
    email, password = get_test_user_credentials()
    
    if not email or not password:
        print(" Could not obtain test user credentials")
        return
    
    # Test GET request
    try:
        get_response = requests.get(f'{base_url}/login/', timeout=5)
        print(f"GET Request Status: {get_response.status_code}")
        print(f"GET Response Content: {get_response.text}")
    except requests.exceptions.RequestException as e:
        print(f"GET Request Error: {e}")
    
    # Test POST request with login credentials
    try:
        login_data = {
            'email': email,
            'password': password
        }
        
        headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
        
        post_response = requests.post(
            f'{base_url}/login/', 
            data=json.dumps(login_data), 
            headers=headers,
            timeout=5
        )
        
        print(f"\nPOST Login Request Status: {post_response.status_code}")
        print(f"POST Response Content: {post_response.text}")
    except requests.exceptions.RequestException as e:
        print(f"POST Request Error: {e}")

def test_network_interfaces():
    print("\nNetwork Interface Test:")
    try:
        import netifaces
        interfaces = netifaces.interfaces()
        print("Available Network Interfaces:")
        for interface in interfaces:
            try:
                addresses = netifaces.ifaddresses(interface)
                if netifaces.AF_INET in addresses:
                    print(f"{interface}: {addresses[netifaces.AF_INET][0]['addr']}")
            except ValueError:
                pass
    except ImportError:
        print("netifaces module not available. Skipping interface details.")

if __name__ == "__main__":
    test_local_connection()
    test_http_connection()
    test_network_interfaces()
