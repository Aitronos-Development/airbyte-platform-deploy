# Airbyte Platform Deploy

Helm values and cluster bootstrap configuration for Airbyte platform.

## Structure

```
helm/
  values-dev.yaml      - Dev environment values
  values-stage.yaml    - Stage environment values
  values-prod.yaml     - Production environment values
ingress/
  iap/                 - Identity-Aware Proxy config
bootstrap/
  octavia/             - Declarative source/destination definitions
  scripts/             - Bootstrap automation scripts
```

## Deployment

```bash
# Add Airbyte Helm repo
helm repo add airbyte https://airbytehq.github.io/helm-charts
helm repo update

# Deploy to Stage
helm upgrade --install airbyte airbyte/airbyte \
  -n airbyte --create-namespace \
  -f helm/values-stage.yaml

# Run bootstrap
./bootstrap/scripts/bootstrap.sh stage
```

## Helm Chart Pinning

Chart versions are explicitly pinned in values files. Update via PR after testing.

