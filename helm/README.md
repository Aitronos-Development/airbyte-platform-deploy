# Airbyte Helm Deployment

Helm values for deploying Airbyte across environments.

## Prerequisites

1. Terraform infrastructure applied (airbyte-infra)
2. kubectl configured for target cluster
3. Helm 3 installed
4. gcloud authenticated

## Setup

### 1. Add Airbyte Helm repository

```bash
helm repo add airbyte https://airbytehq.github.io/helm-charts
helm repo update
```

### 2. Configure environment values

Each values file needs customization:

**Replace these placeholders:**
- `REGION` - GCP region (e.g., us-central1)
- `PROJECT_ID` - Your GCP project ID
- `INSTANCE_NAME` - Cloud SQL instance name (from Terraform)
- `REPLACE_WITH_*_BUCKET` - GCS bucket names (from Terraform)
- `YOUR_DOMAIN.com` - Your domain

**Get Terraform outputs:**
```bash
cd ../airbyte-infra/envs/stage
terraform output
```

### 3. Create Kubernetes secrets

**Cloud SQL credentials:**
```bash
kubectl create secret generic cloudsql-db-credentials \
  -n airbyte \
  --from-literal=password='DB_PASSWORD_FROM_TERRAFORM'
```

**Artifact Registry pull secret:**
```bash
gcloud auth configure-docker REGION-docker.pkg.dev

kubectl create secret docker-registry artifact-registry-secret \
  -n airbyte \
  --docker-server=REGION-docker.pkg.dev \
  --docker-username=_json_key \
  --docker-password="$(cat key.json)"
```

Or use Workload Identity (recommended):
```bash
# Already configured if using Terraform workload-identity module
kubectl annotate serviceaccount airbyte-admin -n airbyte \
  iam.gke.io/gcp-service-account=GSA_EMAIL
```

### 4. Deploy to Stage

```bash
# Pin the chart version for reproducibility
CHART_VERSION="0.50.0"  # Check latest: helm search repo airbyte/airbyte

helm upgrade --install airbyte airbyte/airbyte \
  --version $CHART_VERSION \
  -n airbyte \
  --create-namespace \
  -f values-stage.yaml \
  --wait \
  --timeout 10m
```

### 5. Verify deployment

```bash
kubectl get pods -n airbyte
kubectl logs -n airbyte -l app=airbyte-server --tail=100
```

### 6. Access Airbyte

**Dev (LoadBalancer):**
```bash
kubectl get svc -n airbyte airbyte-webapp-svc
# Access via external IP
```

**Stage/Prod (Ingress + IAP):**
```bash
kubectl get ingress -n airbyte
# Access via configured domain after DNS + IAP setup
```

## Upgrades

### Chart version upgrade

1. Check for new versions:
```bash
helm search repo airbyte/airbyte --versions
```

2. Review release notes:
```bash
# Check https://github.com/airbytehq/helm-charts/releases
```

3. Test in stage first:
```bash
helm upgrade airbyte airbyte/airbyte \
  --version NEW_VERSION \
  -n airbyte \
  -f values-stage.yaml \
  --dry-run --debug
```

4. Apply upgrade:
```bash
helm upgrade airbyte airbyte/airbyte \
  --version NEW_VERSION \
  -n airbyte \
  -f values-stage.yaml
```

5. If successful, promote to prod via PR

### Configuration changes

```bash
# Edit values file, then:
helm upgrade airbyte airbyte/airbyte \
  -n airbyte \
  -f values-stage.yaml
```

## Rollback

```bash
helm history airbyte -n airbyte
helm rollback airbyte REVISION -n airbyte
```

## Troubleshooting

**Pods not starting:**
```bash
kubectl describe pod POD_NAME -n airbyte
kubectl logs POD_NAME -n airbyte
```

**Database connection issues:**
```bash
# Check Cloud SQL Proxy sidecar
kubectl logs POD_NAME -n airbyte -c cloud-sql-proxy
```

**Storage issues:**
```bash
# Check Workload Identity
kubectl describe sa airbyte-admin -n airbyte

# Verify GSA permissions
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:GSA_EMAIL"
```

## Chart Versions

Track pinned versions:
- Dev: Specify in deploy command
- Stage: Specify in deploy command
- Prod: Specify in deploy command

Update via PR after stage validation.

# Test deployment trigger
# Deployment triggered: Fri Oct 17 08:53:38 +04 2025
