#!/usr/bin/env python3
import socket
import json
import http.client
import re
from urllib.parse import urlparse

def get_ip_address():
    """Get the IP address of the eth0 interface."""
    try:
        # Create a socket and connect to an external address to get local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        # We don't actually connect, this is just to get the local IP
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception as e:
        raise RuntimeError(f"Failed to get IP address: {e}")

def create_camera(ip_address):
    """Create a camera configuration via HTTP POST request."""
    # Prepare the request data
    camera_config = {
        "name": "Front",
        "service": "webrtc-crealityk2rtc",
        "stream_url": f"http://{ip_address}:8000/",
        "snapshot_url": "/webcam?action=snapshot"
    }

    # Prepare the connection
    conn = http.client.HTTPConnection(ip_address, 7125)
    headers = {"Content-Type": "application/json"}

    try:
        # Send the POST request
        conn.request(
            "POST",
            "/server/webcams/item",
            body=json.dumps(camera_config),
            headers=headers
        )

        # Get the response
        response = conn.getresponse()

        # Check if the request was successful
        if response.status not in (200, 201):
            raise RuntimeError(
                f"Failed to create camera. Status: {response.status}, "
                f"Response: {response.read().decode()}"
            )

        print("Camera created successfully!")

    except Exception as e:
        raise RuntimeError(f"Failed to create camera: {e}")
    finally:
        conn.close()

def main():
    try:
        # Get the IP address
        ip = get_ip_address()
        print(f"Found IP address: {ip}")

        # Create the camera
        create_camera(ip)

    except Exception as e:
        print(f"Error: {e}")
        exit(1)

if __name__ == "__main__":
    main()
