#!/usr/bin/env python3
"""
Register custom connectors from catalog.yaml to Airbyte instance
"""

import argparse
import sys
import requests
import yaml
from pathlib import Path


class AirbyteBootstrap:
    def __init__(self, airbyte_url: str, catalog_path: str):
        self.airbyte_url = airbyte_url.rstrip('/')
        self.catalog_path = Path(catalog_path)
        self.api_url = f"{self.airbyte_url}/api/v1"
        self.workspace_id = None
        
    def check_health(self) -> bool:
        """Check if Airbyte is accessible"""
        try:
            response = requests.get(f"{self.api_url}/health", timeout=10)
            return response.status_code == 200
        except requests.RequestException:
            return False
    
    def get_workspace_id(self) -> str:
        """Get the workspace ID (assumes default workspace)"""
        response = requests.post(
            f"{self.api_url}/workspaces/list",
            json={}
        )
        response.raise_for_status()
        workspaces = response.json().get('workspaces', [])
        
        if not workspaces:
            raise ValueError("No workspaces found")
        
        return workspaces[0]['workspaceId']
    
    def get_existing_source_definitions(self) -> dict:
        """Get all existing source definitions"""
        response = requests.post(
            f"{self.api_url}/source_definitions/list",
            json={}
        )
        response.raise_for_status()
        definitions = response.json().get('sourceDefinitions', [])
        return {d['name']: d for d in definitions}
    
    def get_existing_destination_definitions(self) -> dict:
        """Get all existing destination definitions"""
        response = requests.post(
            f"{self.api_url}/destination_definitions/list",
            json={}
        )
        response.raise_for_status()
        definitions = response.json().get('destinationDefinitions', [])
        return {d['name']: d for d in definitions}
    
    def create_or_update_source(self, name: str, image: str, tag: str, description: str = ""):
        """Create or update a source connector definition"""
        existing = self.get_existing_source_definitions()
        
        if name in existing:
            print(f"  Updating source: {name}")
            response = requests.post(
                f"{self.api_url}/source_definitions/update",
                json={
                    "sourceDefinitionId": existing[name]['sourceDefinitionId'],
                    "dockerRepository": image,
                    "dockerImageTag": tag
                }
            )
        else:
            print(f"  Creating source: {name}")
            response = requests.post(
                f"{self.api_url}/source_definitions/create_custom",
                json={
                    "workspaceId": self.workspace_id,
                    "sourceDefinition": {
                        "name": name,
                        "dockerRepository": image,
                        "dockerImageTag": tag,
                        "documentationUrl": "https://github.com/yourorg/airbyte-connectors"
                    }
                }
            )
        
        response.raise_for_status()
        print(f"  ✓ {name} registered successfully")
    
    def create_or_update_destination(self, name: str, image: str, tag: str, description: str = ""):
        """Create or update a destination connector definition"""
        existing = self.get_existing_destination_definitions()
        
        if name in existing:
            print(f"  Updating destination: {name}")
            response = requests.post(
                f"{self.api_url}/destination_definitions/update",
                json={
                    "destinationDefinitionId": existing[name]['destinationDefinitionId'],
                    "dockerRepository": image,
                    "dockerImageTag": tag
                }
            )
        else:
            print(f"  Creating destination: {name}")
            response = requests.post(
                f"{self.api_url}/destination_definitions/create_custom",
                json={
                    "workspaceId": self.workspace_id,
                    "destinationDefinition": {
                        "name": name,
                        "dockerRepository": image,
                        "dockerImageTag": tag,
                        "documentationUrl": "https://github.com/yourorg/airbyte-connectors"
                    }
                }
            )
        
        response.raise_for_status()
        print(f"  ✓ {name} registered successfully")
    
    def load_catalog(self) -> dict:
        """Load connector catalog from YAML file"""
        if not self.catalog_path.exists():
            raise FileNotFoundError(f"Catalog not found: {self.catalog_path}")
        
        with open(self.catalog_path, 'r') as f:
            catalog = yaml.safe_load(f)
        
        return catalog.get('connectors', {})
    
    def bootstrap(self):
        """Main bootstrap process"""
        print(f"Bootstrapping Airbyte at {self.airbyte_url}")
        
        # Check health
        print("Checking Airbyte health...")
        if not self.check_health():
            raise RuntimeError(f"Airbyte is not accessible at {self.airbyte_url}")
        print("✓ Airbyte is healthy")
        
        # Get workspace
        print("Getting workspace ID...")
        self.workspace_id = self.get_workspace_id()
        print(f"✓ Workspace ID: {self.workspace_id}")
        
        # Load catalog
        print("\nLoading connector catalog...")
        connectors = self.load_catalog()
        
        if not connectors:
            print("No connectors found in catalog")
            return
        
        print(f"Found {len(connectors)} connector(s)")
        
        # Register each connector
        print("\nRegistering connectors...")
        for connector_name, config in connectors.items():
            image = config.get('image')
            tag = config.get('tag', 'latest')
            description = config.get('description', '')
            
            if not image:
                print(f"  ⚠ Skipping {connector_name}: no image specified")
                continue
            
            # Determine if source or destination by name prefix
            if connector_name.startswith('source-'):
                self.create_or_update_source(connector_name, image, tag, description)
            elif connector_name.startswith('destination-'):
                self.create_or_update_destination(connector_name, image, tag, description)
            else:
                print(f"  ⚠ Skipping {connector_name}: unknown type (must start with 'source-' or 'destination-')")
        
        print("\n" + "=" * 40)
        print("Bootstrap complete!")
        print("=" * 40)
        print(f"Airbyte URL: {self.airbyte_url}")
        print(f"Workspace ID: {self.workspace_id}")


def main():
    parser = argparse.ArgumentParser(description='Bootstrap Airbyte with custom connectors')
    parser.add_argument('airbyte_url', help='Airbyte URL (e.g., https://airbyte-stage.yourdomain.com)')
    parser.add_argument('--catalog', '-c', 
                       default='../../airbyte-connectors/catalog.yaml',
                       help='Path to catalog.yaml')
    
    args = parser.parse_args()
    
    try:
        bootstrap = AirbyteBootstrap(args.airbyte_url, args.catalog)
        bootstrap.bootstrap()
    except Exception as e:
        print(f"\nError: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()

