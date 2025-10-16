# Aitronos Connectors Platform - Deployment Architecture

## 🏗️ Pure GCP Architecture

**Everything runs on GCP - No external services**

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                   Custom Domains                     │
│  connectors-stage.aitronos.com (Staging)            │
│  connectors.aitronos.com (Production)               │
└──────────────────────┬──────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────┐
│              Google Cloud Load Balancer             │
│              (Global Static IP + SSL)               │
└──────────────────────┬──────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────┐
│                 GKE Ingress                         │
│        (Routes traffic based on hostname)           │
└──────────┬─────────────────────────────┬────────────┘
           │                             │
           ↓                             ↓
┌──────────────────────┐    ┌──────────────────────┐
│   Webapp Service     │    │   Server Service     │
│   (Frontend UI)      │    │   (Backend API)      │
│   Port 80            │    │   Port 8001          │
└──────────┬───────────┘    └──────────┬───────────┘
           │                           │
           ↓                           ↓
┌──────────────────────┐    ┌──────────────────────┐
│  Webapp Pods         │    │  Server Pods         │
│  (Nginx + React)     │    │  (Java/Kotlin API)   │
└──────────────────────┘    └──────────────────────┘
```

---

## 🎯 Key Components

### 1. Frontend (UI)
**What:** React application served by Nginx  
**Where:** GKE pods (`airbyte-webapp`)  
**Access:** https://connectors-stage.aitronos.com  
**How:** Pre-built Docker image from Airbyte Helm chart

### 2. Backend (API)
**What:** Java/Kotlin REST API  
**Where:** GKE pods (`airbyte-server`)  
**Access:** https://connectors-api-stage.aitronos.com  
**How:** Docker image from Airbyte Helm chart

### 3. Ingress
**What:** GKE Ingress (Google Cloud Load Balancer)  
**Where:** GCP global load balancer  
**Features:**
- Automatic SSL certificate provisioning
- Domain-based routing
- Global static IP

### 4. Database
**What:** PostgreSQL  
**Where:** Cloud SQL (europe-west6)  
**Type:** `db-f1-micro` (minimal cost)

### 5. Storage
**What:** Object storage for logs/state  
**Where:** Cloud Storage (GCS)  
**Location:** europe-west6

---

## 🌐 Domain Routing

### Staging
| Domain | Routes To | Service | Purpose |
|--------|-----------|---------|---------|
| `connectors-stage.aitronos.com` | `airbyte-webapp-svc:80` | Frontend | React UI |
| `connectors-api-stage.aitronos.com` | `airbyte-server-svc:8001` | Backend | REST API |

**Static IP:** `34.96.91.157`

### Production
| Domain | Routes To | Service | Purpose |
|--------|-----------|---------|---------|
| `connectors.aitronos.com` | `airbyte-webapp-svc:80` | Frontend | React UI |
| `connectors-api.aitronos.com` | `airbyte-server-svc:8001` | Backend | REST API |

**Static IP:** `35.201.104.8`

---

## 🔐 Security

- ✅ **HTTPS Only:** Automatic SSL certificates via Google-managed certificates
- ✅ **Private GKE:** Nodes on private subnet
- ✅ **Workload Identity:** Secure GCP service access
- ✅ **Secret Manager:** Database credentials stored securely
- ✅ **IAM:** Least-privilege service accounts

---

## 💰 Cost Structure

### Staging (Running)
| Component | Type | Cost/Month |
|-----------|------|------------|
| GKE Cluster | Autopilot | $70 |
| Cloud SQL | db-f1-micro | $15 |
| Cloud Storage | Standard | $5 |
| Load Balancer | Global | $20 |
| Static IP | Reserved | $3 |
| SSL Certificates | Managed | Free |
| **Total** | | **~$113/month** |

### Production (When Deployed)
Similar to staging, scaled for production traffic.

---

## 🚀 Deployment Flow

### 1. Code Push
```bash
git push origin staging  # or main for production
```

### 2. GitHub Actions Triggers
- Authenticates to GCP
- Gets GKE credentials
- Deploys Helm chart
- Applies ingress configuration

### 3. Kubernetes Deploys
- Pulls Docker images
- Creates/updates pods
- Configures services
- Updates ingress

### 4. Load Balancer Updates
- Routes traffic to new pods
- Provisions SSL if needed
- Health checks services

---

## 📦 What's Deployed

### Helm Chart Contents
From `airbyte/airbyte` Helm chart:
- ✅ `webapp` - Frontend (Nginx + React)
- ✅ `server` - Backend API (Java/Kotlin)
- ✅ `worker` - Job processor
- ✅ `cron` - Scheduled tasks
- ✅ `connector-builder-server` - Connector development
- ❌ `temporal` - Disabled (using built-in scheduling)
- ❌ `metrics` - Disabled (minimal cost)

---

## 🔄 CI/CD Workflow

### Staging Branch
```
Developer → Push to 'staging' → GitHub Actions → GKE Staging
```

### Production Branch
```
Developer → Push to 'main' → GitHub Actions → GKE Production
```

### Manual Deployment
```
GitHub UI → Actions → Select Workflow → Run
```

---

## 🧪 Current Status

### ✅ Staging (Active)
- Infrastructure: Deployed
- GKE Cluster: Running
- Pods: Healthy
- Ingress: Configured
- SSL: Auto-provisioning
- DNS: Needs update (see below)

### ⏳ Production (Ready)
- Infrastructure: Can be deployed
- Static IP: Reserved
- Ingress: Configured
- SSL: Pre-configured
- DNS: Ready to set

---

## 📝 DNS Configuration

### Issue Found
Your current DNS points to wrong IP:
```
connectors-staging.aitronos.com → 217.26.55.9 ❌
```

### Should Be
```
connectors-stage.aitronos.com → 34.96.91.157 ✅
```

**Fix in Hostpoint:**
1. Change hostname from `connectors-staging` to `connectors-stage`
2. Change IP from `217.26.55.9` to `34.96.91.157`

---

## 🔍 Verification Commands

### Check Pods
```bash
kubectl get pods -n airbyte
```

### Check Services
```bash
kubectl get svc -n airbyte
```

### Check Ingress
```bash
kubectl get ingress -n airbyte
```

### Check SSL Certificates
```bash
kubectl get managedcertificate -n airbyte
```

### Test Frontend
```bash
curl http://34.96.91.157
```

### Test API
```bash
curl http://34.96.91.157/api/v1/health
```

---

## 📞 Support

**Email:** connectors-platform@aitronos.com

---

*Aitronos Connectors Platform - Pure GCP Architecture*

