# GitHub Secrets Setup

## 🔑 Required Secrets for GitHub Actions

Your organization has **service account key creation disabled** (security best practice).

**Two options:**

---

## Option 1: Use Workload Identity Federation (Recommended)

This is more secure - no keys needed!

### What to Add to GitHub

Go to: https://github.com/Aitronos-Development/airbyte-platform-deploy/settings/secrets/actions

**Add these 2 secrets:**

#### 1. `GCP_PROJECT_ID`
```
Value: airbyte-backend-staging
```

#### 2. `GCP_SERVICE_ACCOUNT`
```
Value: github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com
```

Then I'll need to update the workflow to use Workload Identity Federation instead of service account keys.

---

## Option 2: Request Key Creation Permission

Ask your GCP admin to temporarily disable this constraint:

```bash
# Admin needs to run:
gcloud resource-manager org-policies delete \
  constraints/iam.disableServiceAccountKeyCreation \
  --project=airbyte-backend-staging
```

Then run:
```bash
cd /Users/philliploacker/Documents/GitHub/airbyte-platform-deploy
./setup-github-secrets.sh
```

---

## Option 3: Use Your Personal Credentials (Quick Test Only)

**NOT recommended for production, but works for testing:**

### Step 1: Create a key from your own account
```bash
gcloud auth application-default login
gcloud auth application-default print-access-token > ~/github-token.txt
```

### Step 2: Add to GitHub as `GCP_SA_KEY`
```bash
cat ~/github-token.txt | pbcopy
```

**Note:** This token expires in 1 hour - only for testing!

---

## ✅ Recommended Approach

**Use Workload Identity Federation (Option 1)**

It's more secure and doesn't require keys. I can update the GitHub Actions workflow to use it.

**Would you like me to:**
1. Update the workflow for Workload Identity Federation? (Recommended)
2. Or help you get key creation enabled? (Less secure)

---

## 📋 Current Service Account

**Email:** `github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com`

**Permissions:**
- ✅ `roles/container.developer` - Deploy to GKE
- ✅ `roles/iam.serviceAccountUser` - Use service accounts

**Status:** Service account exists and has correct permissions!

---

*Waiting for your preference on Option 1 or 2*

