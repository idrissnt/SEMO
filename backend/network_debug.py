import socket
import subprocess
import platform

def get_network_interfaces():
    system = platform.system()
    
    print("Network Interfaces:")
    if system == "Windows":
        try:
            # Run ipconfig command
            output = subprocess.check_output(["ipconfig"], universal_newlines=True)
            print(output)
        except Exception as e:
            print(f"Error getting network interfaces: {e}")
    elif system in ["Linux", "Darwin"]:  # Linux or macOS
        try:
            output = subprocess.check_output(["ifconfig"], universal_newlines=True)
            print(output)
        except Exception:
            try:
                output = subprocess.check_output(["ip", "addr"], universal_newlines=True)
                print(output)
            except Exception as e:
                print(f"Error getting network interfaces: {e}")

def get_hostname_info():
    print("\nHostname Information:")
    print(f"Hostname: {socket.gethostname()}")
    
    try:
        print("IP Addresses:")
        # Get all IP addresses associated with the hostname
        addresses = socket.getaddrinfo(socket.gethostname(), None)
        unique_ips = set()
        
        for addr in addresses:
            ip = addr[4][0]
            if ':' not in ip and ip not in unique_ips:  # Skip IPv6 and duplicates
                unique_ips.add(ip)
                print(f" - {ip}")
    except Exception as e:
        print(f"Error getting IP addresses: {e}")

def check_port_availability(port=8000):
    print(f"\nChecking availability of port {port}:")
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    result = sock.connect_ex(('127.0.0.1', port))
    
    if result == 0:
        print(f"Port {port} is OPEN and being used")
    else:
        print(f"Port {port} is CLOSED or available")
    sock.close()

if __name__ == "__main__":
    get_network_interfaces()
    get_hostname_info()
    check_port_availability()
