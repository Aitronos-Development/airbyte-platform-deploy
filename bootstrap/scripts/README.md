# Bootstrap Scripts

Automated setup scripts for Airbyte instance configuration.

## Quick Start - Development Mode

**Interactive testing and development:**

```bash
./start-dev.sh
```

Features:
- 🧪 Test connector registration
- 🔌 Check API connectivity
- 📝 Edit catalog interactively
- 🐍 Python shell for debugging
- ⚡ Virtual environment management

## Overview

Bootstrap scripts:
- Register custom connectors from catalog
- Configure workspace settings
- Create initial sources/destinations (optional)

## Usage

### Option 1: Python Script (Recommended)

```bash
# Install dependencies
pip install -r requirements.txt

# Run bootstrap
./register-connectors.py https://airbyte-stage.yourdomain.com \
  --catalog ../../airbyte-connectors/catalog.yaml
```

### Option 2: Shell Script

```bash
./bootstrap.sh stage https://airbyte-stage.yourdomain.com
```

## What Gets Bootstrapped

1. **Custom Connector Definitions**: Registers all connectors from `catalog.yaml`
2. **Workspace Configuration**: Uses default workspace

## Catalog Format

`airbyte-connectors/catalog.yaml`:
```yaml
connectors:
  source-myapi:
    image: us-central1-docker.pkg.dev/PROJECT/airbyte-connectors/source-myapi
    tag: 1.0.0
    description: "Custom API source"
  
  destination-mydb:
    image: us-central1-docker.pkg.dev/PROJECT/airbyte-connectors/destination-mydb
    tag: 1.0.0
    description: "Custom database destination"
```

## Authentication

Scripts use Airbyte's public API. If authentication is required:

1. Get API token from Airbyte UI
2. Add to requests:
```python
headers = {"Authorization": f"Bearer {token}"}
```

## CI/CD Integration

In GitHub Actions:
```yaml
- name: Bootstrap Airbyte
  run: |
    pip install -r requirements.txt
    ./register-connectors.py ${{ secrets.AIRBYTE_URL }}
```

## Troubleshooting

**Connection refused:**
- Check Airbyte URL
- Verify ingress/IAP configuration
- Test with curl: `curl https://airbyte-url/api/v1/health`

**Connector registration fails:**
- Verify image exists in Artifact Registry
- Check Workload Identity permissions
- Ensure catalog.yaml format is correct

**Workspace not found:**
- Verify Airbyte is fully initialized
- Check logs: `kubectl logs -n airbyte -l app=airbyte-server`

