# 🔑 GitHub Secrets - Quick Setup

## Issue: Cannot Download Existing Key

A service account key exists but **cannot be downloaded** (GCP security feature).

**You have 2 options:**

---

## ✅ Option 1: Create New Key (Simplest)

Since key creation is blocked by policy, ask your admin to allow it temporarily:

### Ask Admin to Run:
```bash
# Temporarily allow key creation
gcloud org-policies reset constraints/iam.disableServiceAccountKeyCreation \
  --project=airbyte-backend-staging
```

### Then You Run:
```bash
# Create new key
gcloud iam service-accounts keys create ~/github-actions-staging-key.json \
  --iam-account=github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com \
  --project=airbyte-backend-staging

# Copy to clipboard
cat ~/github-actions-staging-key.json | pbcopy
```

### Then Add to GitHub:
1. Go to: https://github.com/Aitronos-Development/airbyte-platform-deploy/settings/secrets/actions
2. Click "New repository secret"
3. Name: `GCP_SA_KEY`
4. Value: Paste from clipboard
5. Click "Add secret"

---

## ✅ Option 2: Use JSON Key You May Already Have

If you created this service account before, you might have the JSON key file.

**Look for:**
```bash
# Check your Downloads folder
ls ~/Downloads/*github-actions*.json

# Check home directory
ls ~/*github-actions*.json
```

**If found:**
```bash
cat ~/path/to/github-actions-staging-key.json | pbcopy
```

Then add to GitHub as `GCP_SA_KEY`

---

## ✅ Option 3: Use Your Personal Credentials (Testing Only)

**Quick workaround for testing:**

```bash
# Login with your account
gcloud auth application-default login

# Get your credentials file
cat ~/.config/gcloud/application_default_credentials.json | pbcopy
```

Add to GitHub as `GCP_SA_KEY`

**⚠️ Warning:** This uses YOUR personal account, not recommended for production!

---

## 📋 What You Need to Add to GitHub

**Repository:** https://github.com/Aitronos-Development/airbyte-platform-deploy

**Go to:** Settings → Secrets and variables → Actions → New repository secret

### Required Secret (Just 1):

| Secret Name | Value | Used For |
|-------------|-------|----------|
| `GCP_SA_KEY` | JSON key content | Deploy to staging |

**Optional (for later):**

| Secret Name | Value | Used For |
|-------------|-------|----------|
| `GCP_SA_KEY_PROD` | JSON key for production | Deploy to production |

---

## 🧪 Test After Adding Secret

```bash
# Push to staging to trigger deployment
cd /Users/philliploacker/Documents/GitHub/airbyte-platform-deploy
git commit --allow-empty -m "Test GitHub Actions"
git push origin staging
```

**Watch deployment:**
https://github.com/Aitronos-Development/airbyte-platform-deploy/actions

---

## 💡 Which Option Should You Use?

- **Have JSON key file?** → Use Option 2
- **Admin available?** → Use Option 1  
- **Just testing quickly?** → Use Option 3
- **Production setup?** → Use Option 1 (proper service account key)

---

*Choose the option that works best for you!*

