# IAP Access Control - Who Has Access?

## Current Access

**Only you:** phillip.loacker@aitronos.com

IAP uses **explicit allow-lists**. Just because someone can authenticate with Google doesn't mean they can access the platform.

---

## How IAP Access Works

### Step 1: Google Authentication
Anyone with a Google account can reach the Google Sign-In screen.

### Step 2: IAP Authorization Check
After authentication, IAP checks if the user is in the **IAM allow-list**.

### Step 3: Access Decision
- ✅ **In allow-list:** User accesses the platform
- ❌ **Not in allow-list:** "You don't have access" error

**Currently only phillip.loacker@aitronos.com is in the allow-list.**

---

## Options to Grant Access

### Option 1: Add Individual Users

```bash
WEBAPP_BACKEND="k8s1-5b5bf1cc-airbyte-airbyte-airbyte-webapp-svc-80-f99a493a"

# Add one user
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --member='user:teammate@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging
```

**Repeat for each user.**

---

### Option 2: Add a Google Group (Recommended)

This is the easiest way to manage team access!

#### Step 1: Create a Google Group
1. Go to: https://groups.google.com
2. Create group: `connectors-platform-staging@aitronos.com`
3. Add your team members to the group

#### Step 2: Grant Access to the Group
```bash
WEBAPP_BACKEND="k8s1-5b5bf1cc-airbyte-airbyte-airbyte-webapp-svc-80-f99a493a"

gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --member='group:connectors-platform-staging@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging
```

**Now anyone in the group automatically gets access!**

---

### Option 3: Add Your Entire Domain (If you have Google Workspace)

If you have a Google Workspace organization and want ALL @aitronos.com users to have access:

```bash
WEBAPP_BACKEND="k8s1-5b5bf1cc-airbyte-airbyte-airbyte-webapp-svc-80-f99a493a"

gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --member='domain:aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging
```

**This grants access to everyone with an @aitronos.com email.**

---

## Checking Who Has Access

```bash
WEBAPP_BACKEND="k8s1-5b5bf1cc-airbyte-airbyte-airbyte-webapp-svc-80-f99a493a"

gcloud iap web get-iam-policy \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --project=airbyte-backend-staging
```

---

## Removing Access

```bash
WEBAPP_BACKEND="k8s1-5b5bf1cc-airbyte-airbyte-airbyte-webapp-svc-80-f99a493a"

# Remove a user
gcloud iap web remove-iam-policy-binding \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --member='user:someone@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging

# Remove a group
gcloud iap web remove-iam-policy-binding \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --member='group:team@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging
```

---

## Recommendations

### For Staging:
**Use Option 2 (Google Group)** - Easy to manage, add/remove users in one place.

### For Production:
**Use Option 1 (Individual Users)** - More controlled, explicit list of authorized users.

---

## Quick Commands Reference

```bash
# Set backend service variable
WEBAPP_BACKEND="k8s1-5b5bf1cc-airbyte-airbyte-airbyte-webapp-svc-80-f99a493a"

# Add individual user
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --member='user:EMAIL@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging

# Add Google Group
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --member='group:GROUP@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging

# Add entire domain
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --member='domain:aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging

# List current access
gcloud iap web get-iam-policy \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --project=airbyte-backend-staging
```

---

**Currently only you have access. Choose one of the options above to grant access to others!** 🔐

