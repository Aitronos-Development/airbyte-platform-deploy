# 🔧 Fix GitHub Actions Authentication

## Problem
User credentials don't work with GitHub Actions. We need a **service account key**.

---

## ✅ Solution: Temporarily Allow Key Creation

### Step 1: Check Current Constraint
```bash
gcloud resource-manager org-policies describe \
  constraints/iam.disableServiceAccountKeyCreation \
  --project=airbyte-backend-staging
```

### Step 2: Temporarily Disable Constraint
```bash
gcloud resource-manager org-policies delete \
  constraints/iam.disableServiceAccountKeyCreation \
  --project=airbyte-backend-staging
```

### Step 3: Create Service Account Key
```bash
gcloud iam service-accounts keys create ~/github-actions-staging-key.json \
  --iam-account=github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com \
  --project=airbyte-backend-staging
```

### Step 4: Copy to Clipboard
```bash
cat ~/github-actions-staging-key.json | pbcopy
```

### Step 5: Update GitHub Secret
1. Go to: https://github.com/Aitronos-Development/airbyte-platform-deploy/settings/secrets/actions
2. Click on `GCP_SA_KEY`
3. Click **Update**
4. Paste the new key
5. Click **Update secret**

### Step 6: Re-enable Constraint (Optional, for security)
```bash
# Re-enable the constraint after creating the key
gcloud resource-manager org-policies set-policy /dev/stdin <<EOF
name: projects/airbyte-backend-staging/policies/iam.disableServiceAccountKeyCreation
spec:
  rules:
  - enforce: true
EOF
```

---

## 🧪 Test After Update

```bash
cd /Users/philliploacker/Documents/GitHub/airbyte-platform-deploy
git commit --allow-empty -m "Test with service account key"
git push origin staging
```

Watch: https://github.com/Aitronos-Development/airbyte-platform-deploy/actions

---

## 📋 Quick Commands (Run These)

```bash
# 1. Disable constraint
gcloud resource-manager org-policies delete \
  constraints/iam.disableServiceAccountKeyCreation \
  --project=airbyte-backend-staging

# 2. Create key
gcloud iam service-accounts keys create ~/github-actions-staging-key.json \
  --iam-account=github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com \
  --project=airbyte-backend-staging

# 3. Copy to clipboard
cat ~/github-actions-staging-key.json | pbcopy

# 4. Go update GitHub secret (paste from clipboard)
# https://github.com/Aitronos-Development/airbyte-platform-deploy/settings/secrets/actions

# 5. Test
git commit --allow-empty -m "Test deployment" && git push origin staging
```

---

*After creating the key, you can re-enable the constraint for security.*

