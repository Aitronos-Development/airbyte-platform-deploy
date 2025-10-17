# Aitronos Connectors Platform

Data integration platform for building and managing custom connectors.

## 🌐 Environments

### Staging
- **Platform UI**: https://connectors-staging.aitronos.com
- **API Endpoint**: https://connectors-api-staging.aitronos.com
- **GCP Project**: `airbyte-backend-staging` (828187884021)
- **Region**: `europe-west6` (Zürich, Switzerland)
- **Branch**: `staging`

### Production
- **Platform UI**: https://connectors.aitronos.com
- **API Endpoint**: https://connectors-api.aitronos.com
- **GCP Project**: `airbyte-backend-production` (178980378559)
- **Region**: `europe-west6` (Zürich, Switzerland)
- **Branch**: `main`

## 🔐 Access

Both environments are protected by Google Cloud IAP (Identity-Aware Proxy).

**Authorized Users:**
- phillip.loacker@aitronos.com
- raoul.perenzin@aitronos.com

To add more users, see [IAP_ACCESS_CONTROL.md](./IAP_ACCESS_CONTROL.md)

## 💻 Local Development

### Prerequisites

```bash
# Install required tools
brew install kind helm kubectl nvm pnpm

# Install Node.js 20.19.0
nvm install 20.19.0
nvm use 20.19.0
```

### Option 1: Full Local Stack

Run entire platform locally (UI + Backend + Database):

```bash
cd /Users/philliploacker/Documents/GitHub/airbyte-platform
./start-dev.sh
```

Access at: http://localhost:2000

**What this does:**
- Starts local Kind cluster
- Deploys Airbyte services locally
- Runs frontend on port 2000 with hot-reload
- Backend runs in Kubernetes

### Option 2: Local UI + Staging Backend

Develop UI locally while using staging backend:

```bash
cd /Users/philliploacker/Documents/GitHub/airbyte-platform/airbyte-webapp

# Set staging backend URL
export VITE_AIRBYTE_API_URL=https://connectors-api-staging.aitronos.com

# Start UI dev server
pnpm install
pnpm start
```

Access at: http://localhost:2000

**When to use:**
- UI/UX development
- Frontend changes without backend modifications
- Testing against real staging data

### Option 3: Local Backend + Staging UI

Develop backend locally while using staging UI:

```bash
# 1. Start local Kind cluster with Airbyte backend
cd /Users/philliploacker/Documents/GitHub/airbyte-platform
kind create cluster --name airbyte-local
helm install airbyte airbyte/airbyte -n airbyte

# 2. Port forward backend services
kubectl port-forward -n airbyte svc/airbyte-server 8001:8001
kubectl port-forward -n airbyte svc/airbyte-api-server 8006:8006

# 3. Use staging UI, pointing to local backend
# (Configure in staging UI settings or use browser dev tools to override API URL)
```

**When to use:**
- Backend API development
- Connector protocol changes
- Database schema modifications

### Option 4: Hybrid Development

Mix local and remote services as needed:

```bash
# Start only specific services locally
cd /Users/philliploacker/Documents/GitHub/airbyte-platform

# Example: Local UI + Local Worker + Staging Server
export VITE_AIRBYTE_API_URL=https://connectors-api-staging.aitronos.com
pnpm --filter airbyte-webapp start &
kubectl port-forward -n airbyte svc/airbyte-worker 9000:9000
```

## 🚀 Deployment

### Automatic Deployment (Recommended)

Push to respective branch triggers automatic deployment:

```bash
# Deploy to Staging
git push origin staging

# Deploy to Production
git push origin main
```

Monitor deployment: https://github.com/Aitronos-Development/airbyte-platform-deploy/actions

### Manual Deployment

#### Staging

```bash
# Authenticate
gcloud auth login
gcloud container clusters get-credentials airbyte-stage-gke \
  --region europe-west6 \
  --project airbyte-backend-staging

# Deploy
helm upgrade --install airbyte airbyte/airbyte \
  --version 0.49.24 \
  -n airbyte \
  -f helm/values-stage-ultra-minimal.yaml

# Apply ingress
kubectl apply -f ingress/iap-backend-config.yaml
kubectl apply -f ingress/dual-domain-ingress.yaml
```

#### Production

```bash
# Authenticate
gcloud container clusters get-credentials airbyte-prod-gke \
  --region europe-west6 \
  --project airbyte-backend-production

# Deploy
helm upgrade --install airbyte airbyte/airbyte \
  --version 0.49.24 \
  -n airbyte \
  -f helm/values-prod-minimal.yaml

# Apply ingress
kubectl apply -f ingress/iap-backend-config.yaml
kubectl apply -f ingress/dual-domain-ingress-prod.yaml
```

## 🛠️ Common Tasks

### Check Deployment Status

```bash
# Staging
kubectl get pods -n airbyte --context=gke_airbyte-backend-staging_europe-west6_airbyte-stage-gke

# Production
kubectl get pods -n airbyte --context=gke_airbyte-backend-production_europe-west6_airbyte-prod-gke
```

### View Logs

```bash
# Specific pod
kubectl logs -n airbyte <pod-name> -f

# All server logs
kubectl logs -n airbyte -l app.kubernetes.io/component=server -f
```

### Access Database

```bash
# Staging
gcloud sql connect airbyte-stage-postgres --user=airbyte --project=airbyte-backend-staging

# Production
gcloud sql connect airbyte-prod-postgres --user=airbyte --project=airbyte-backend-production
```

### Restart Services

```bash
# Restart specific deployment
kubectl rollout restart deployment/airbyte-server -n airbyte

# Restart all
kubectl rollout restart deployment -n airbyte
```

## 🔧 Troubleshooting

### Frontend Not Loading

```bash
# Check if port 2000 is available
lsof -i :2000

# Clear node modules and reinstall
cd airbyte-platform/airbyte-webapp
rm -rf node_modules .pnpm-store
pnpm install
```

### Backend Connection Issues

```bash
# Test API connectivity
curl https://connectors-api-staging.aitronos.com/api/v1/health

# Check backend logs
kubectl logs -n airbyte deployment/airbyte-server --tail=100
```

### Authentication Issues

IAP authentication fails:
1. Ensure you're logged into correct Google account
2. Check you're in authorized users list
3. Try incognito mode to clear cookies
4. Contact admin to verify IAP settings

### SSL Certificate Issues

```bash
# Check certificate status
kubectl describe managedcertificate -n airbyte

# Certificate takes 15-30 minutes to provision
# Status should show: Active
```

## 📁 Repository Structure

```
airbyte-platform-deploy/
├── helm/                      # Helm values for deployments
│   ├── values-stage-ultra-minimal.yaml
│   └── values-prod-minimal.yaml
├── ingress/                   # Kubernetes ingress configs
│   ├── iap-backend-config.yaml
│   ├── dual-domain-ingress.yaml
│   └── dual-domain-ingress-prod.yaml
├── .github/workflows/         # CI/CD pipelines
│   ├── deploy-staging.yml
│   └── deploy-production.yml
├── setup-iap.sh              # IAP setup automation
└── README.md                 # This file

airbyte-platform/             # Platform source code
├── airbyte-webapp/           # React frontend
├── airbyte-server/           # Java/Kotlin backend
├── airbyte-worker/           # Connector execution engine
└── start-dev.sh              # Local dev environment

airbyte-infra/                # Terraform infrastructure
├── envs/stage/               # Staging environment
├── envs/prod/                # Production environment
└── modules/                  # Reusable Terraform modules
```

## 🔗 Related Documentation

- [IAP Authentication Setup](./IAP_AUTHENTICATION.md)
- [IAP Access Control](./IAP_ACCESS_CONTROL.md)
- [Infrastructure Setup](../airbyte-infra/README.md)

## 📞 Support

- **Team Email**: connectors-platform@aitronos.com
- **Admin**: phillip.loacker@aitronos.com
