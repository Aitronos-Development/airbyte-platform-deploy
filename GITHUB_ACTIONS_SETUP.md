# GitHub Actions Setup for Connectors Platform

## 🚀 Automatic Deployment Workflows

### Configured Workflows

#### 1. Backend Deployment (`.github/workflows/deploy-backend.yml`)
**Triggers:**
- Push to `staging` branch → Deploys to staging environment
- Push to `main` branch → Deploys to production environment
- Manual trigger via GitHub Actions UI

**What it deploys:**
- Helm chart to GKE
- Ingress configuration
- SSL certificates

#### 2. Frontend Deployment (`.github/workflows/deploy-frontend-updated.yml`)
**Triggers:**
- Push to `staging` branch → Deploys to Firebase (staging)
- Push to `main` branch → Deploys to Firebase (production)
- Manual trigger via GitHub Actions UI

**What it deploys:**
- React frontend to Firebase Hosting
- Custom domain configuration

---

## 🔑 Required GitHub Secrets

### Repository Secrets Setup

Go to: **GitHub Repo → Settings → Secrets and variables → Actions**

### Secrets to Add:

#### 1. `GCP_SA_KEY` (Staging)
**Description:** Service account key for GCP staging deployment

**How to create:**
```bash
# Create service account
gcloud iam service-accounts create github-actions-staging \
  --project=airbyte-backend-staging \
  --display-name="GitHub Actions Deployer (Staging)"

# Grant permissions
gcloud projects add-iam-policy-binding airbyte-backend-staging \
  --member="serviceAccount:github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com" \
  --role="roles/container.developer"

gcloud projects add-iam-policy-binding airbyte-backend-staging \
  --member="serviceAccount:github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Create and download key
gcloud iam service-accounts keys create ~/github-actions-staging-key.json \
  --iam-account=github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com \
  --project=airbyte-backend-staging
```

**Value:** Copy entire contents of `~/github-actions-staging-key.json`

---

#### 2. `GCP_SA_KEY_PROD` (Production)
**Description:** Service account key for GCP production deployment

**How to create:**
```bash
# Create service account
gcloud iam service-accounts create github-actions-prod \
  --project=airbyte-backend-production \
  --display-name="GitHub Actions Deployer (Production)"

# Grant permissions
gcloud projects add-iam-policy-binding airbyte-backend-production \
  --member="serviceAccount:github-actions-prod@airbyte-backend-production.iam.gserviceaccount.com" \
  --role="roles/container.developer"

gcloud projects add-iam-policy-binding airbyte-backend-production \
  --member="serviceAccount:github-actions-prod@airbyte-backend-production.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Create and download key
gcloud iam service-accounts keys create ~/github-actions-prod-key.json \
  --iam-account=github-actions-prod@airbyte-backend-production.iam.gserviceaccount.com \
  --project=airbyte-backend-production
```

**Value:** Copy entire contents of `~/github-actions-prod-key.json`

---

#### 3. `DB_PASSWORD` (Optional for secret management)
**Description:** Database password for Cloud SQL (only needed if managing via GitHub)

**Value:** Your Cloud SQL database password

**Note:** Currently handled via `kubectl` in workflow, but can be pre-configured.

---

## 📋 Secrets Summary

| Secret Name | Used By | Environment |
|-------------|---------|-------------|
| `GCP_SA_KEY` | Deploy workflow | Staging |
| `GCP_SA_KEY_PROD` | Deploy workflow | Production |

**Note:** Frontend is served from GKE, no separate deployment needed!

---

## 🎯 How to Use

### Deploy Staging
**Option 1: Automatic**
```bash
git checkout staging
git add .
git commit -m "Update staging"
git push origin staging
```
→ GitHub Actions automatically deploys to staging!

**Option 2: Manual**
1. Go to GitHub → Actions
2. Select "Deploy Connectors Platform Backend"
3. Click "Run workflow"
4. Select "staging"
5. Click "Run workflow"

### Deploy Production
**Option 1: Automatic**
```bash
git checkout main
git merge staging  # Merge tested changes
git push origin main
```
→ GitHub Actions automatically deploys to production!

**Option 2: Manual**
1. Go to GitHub → Actions
2. Select "Deploy Connectors Platform Backend"
3. Click "Run workflow"
4. Select "production"
5. Click "Run workflow"

---

## 🔄 Workflow Behavior

### Staging Branch (`staging`)
- ✅ Auto-deploys backend to GKE staging
- ✅ Auto-deploys frontend to Firebase staging
- ✅ URLs: https://connectors-stage.aitronos.com

### Main Branch (`main`)
- ✅ Auto-deploys backend to GKE production
- ✅ Auto-deploys frontend to Firebase production
- ✅ URLs: https://connectors.aitronos.com

### Other Branches
- ❌ No automatic deployment
- ✅ Can manually trigger deployment via GitHub UI

---

## 📊 Monitoring Deployments

### View Deployment Status
1. Go to your GitHub repository
2. Click **Actions** tab
3. See real-time deployment progress

### Check Deployment History
- **Actions** tab shows all past deployments
- Click on any run to see logs
- Green checkmark = successful
- Red X = failed (click to see logs)

---

## 🧪 Testing Workflows

### Test Without Deploying
Create a feature branch:
```bash
git checkout -b feature/my-change
# Make changes
git push origin feature/my-change
```
This won't trigger deployment, safe for testing!

### Test Staging Deployment
```bash
git checkout staging
git merge feature/my-change
git push origin staging
```
This deploys to staging for testing.

### Promote to Production
```bash
git checkout main
git merge staging
git push origin main
```
This deploys tested changes to production.

---

## ⚠️ Important Notes

1. **Never commit service account keys** to the repository
2. **Always test in staging** before deploying to production
3. **Monitor GitHub Actions** for deployment failures
4. **Service accounts need proper IAM roles** to deploy

---

## 🔧 Troubleshooting

### Deployment Fails: Authentication Error
**Problem:** Service account key missing or invalid  
**Solution:** Re-add `GCP_SA_KEY` or `GCP_SA_KEY_PROD` secret

### Deployment Fails: Permission Denied
**Problem:** Service account lacks permissions  
**Solution:** Add missing IAM roles (see secret setup above)

### Deployment Fails: Timeout
**Problem:** Kubernetes resources taking too long  
**Solution:** Increase `--timeout` in workflow (currently 15m)

### Frontend Build Fails
**Problem:** Node/pnpm version mismatch  
**Solution:** Check `airbyte-platform` compatibility

---

## 📞 Support

**Email:** connectors-platform@aitronos.com

---

## ✅ Setup Checklist

- [ ] Create staging service account
- [ ] Create production service account  
- [ ] Create Firebase service account
- [ ] Add `GCP_SA_KEY` to GitHub secrets
- [ ] Add `GCP_SA_KEY_PROD` to GitHub secrets
- [ ] Add `FIREBASE_SERVICE_ACCOUNT` to GitHub secrets
- [ ] Create `staging` branch
- [ ] Test staging deployment
- [ ] Test production deployment
- [ ] Document workflow for team
- [ ] Done! 🎉

---

*Aitronos Connectors Platform - Automated Deployment*

