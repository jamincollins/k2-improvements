#!/usr/bin/env python3
import argparse
import json
import os
import sys
import urllib.request
import urllib.error
from typing import Optional, Dict, Any


def create_request(repo: str, token: Optional[str] = None) -> urllib.request.Request:
    """Create a request object for the GitHub API."""
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    headers = {
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "Python GitHub Release Fetcher"
    }

    if token:
        headers["Authorization"] = f"token {token}"

    return urllib.request.Request(url, headers=headers)


def fetch_latest_release(repo: str, token: Optional[str] = None) -> Dict[str, Any]:
    """Fetch the latest release information from GitHub."""
    try:
        request = create_request(repo, token)
        with urllib.request.urlopen(request) as response:
            return json.loads(response.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"Error: Repository '{repo}' not found or no releases available")
        else:
            print(f"Error: HTTP {e.code} - {e.reason}")
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f"Error: Failed to connect to GitHub API - {e.reason}")
        sys.exit(1)
    except json.JSONDecodeError:
        print("Error: Invalid response from GitHub API")
        sys.exit(1)


def download_file(url: str, filename: str, token: Optional[str] = None) -> None:
    """Download a file from the given URL."""
    headers = {"User-Agent": "Python GitHub Release Downloader"}
    if token:
        headers["Authorization"] = f"token {token}"

    try:
        request = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(request) as response:
            total_size = int(response.headers.get('content-length', 0))
            block_size = 8192
            downloaded = 0

            print(f"\nDownloading {filename}")
            print("[", end="")

            with open(filename, 'wb') as f:
                while True:
                    buffer = response.read(block_size)
                    if not buffer:
                        break

                    downloaded += len(buffer)
                    f.write(buffer)

                    # Update progress bar
                    if total_size:
                        progress = int(50 * downloaded / total_size)
                        sys.stdout.write("\r[" + "=" * progress + " " * (50 - progress) + "]")
                        sys.stdout.write(f" {downloaded}/{total_size} bytes")
                        sys.stdout.flush()

            print("\nDownload complete!")

    except urllib.error.URLError as e:
        print(f"\nError downloading {filename}: {e.reason}")
        if os.path.exists(filename):
            os.remove(filename)
        sys.exit(1)


def download_latest_release(repo: str, token: Optional[str] = None, pattern: Optional[str] = None) -> None:
    """Download the latest release assets from a GitHub repository."""
    release_data = fetch_latest_release(repo, token)

    if not release_data.get('assets'):
        print("No assets found in the latest release")
        return

    # Filter assets if pattern is provided
    assets = release_data['assets']
    if pattern:
        assets = [asset for asset in assets if pattern.lower() in asset['name'].lower()]
        if not assets:
            print(f"No assets found matching pattern: {pattern}")
            return

    # Print release information
    print(f"Latest Release: {release_data.get('tag_name', 'N/A')}")
    print(f"Release Name: {release_data.get('name', 'N/A')}")
    print("\nAvailable assets:")
    for i, asset in enumerate(assets, 1):
        print(f"{i}. {asset['name']} ({asset['size']} bytes)")

    # If there's only one asset, download it automatically
    if len(assets) == 1:
        asset = assets[0]
        download_file(asset['browser_download_url'], asset['name'], token)
    else:
        # Let user choose which asset to download
        while True:
            try:
                choice = input("\nEnter the number of the asset to download (or 'q' to quit): ")
                if choice.lower() == 'q':
                    return

                index = int(choice) - 1
                if 0 <= index < len(assets):
                    asset = assets[index]
                    download_file(asset['browser_download_url'], asset['name'], token)
                    break
                else:
                    print("Invalid selection. Please try again.")
            except ValueError:
                print("Invalid input. Please enter a number or 'q' to quit.")


def main():
    parser = argparse.ArgumentParser(description='Download latest GitHub release')
    parser.add_argument('repository', help='GitHub repository (format: owner/repo)')
    parser.add_argument('-t', '--token', help='GitHub personal access token', default=None)
    parser.add_argument('-p', '--pattern', help='Filter assets by name pattern', default=None)

    args = parser.parse_args()

    if '/' not in args.repository:
        print("Error: Repository must be in format 'owner/repo'")
        sys.exit(1)

    download_latest_release(args.repository, args.token, args.pattern)


if __name__ == '__main__':
    main()
