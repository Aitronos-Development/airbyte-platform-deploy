# ✅ IAP Authentication - ACTIVE

**Status:** Fully configured and operational  
**Date:** October 17, 2025

---

## Configuration Summary

### IAP Enabled On:
- ✅ **Webapp (UI):** `k8s1-5b5bf1cc-airbyte-airbyte-airbyte-webapp-svc-80-f99a493a`
- ✅ **API Server:** `k8s1-5b5bf1cc-airbyte-airbyte-airbyte-server-svc-8001-bf93f503`

### OAuth Configuration:
- ✅ **OAuth Consent Screen:** Configured (External)
- ✅ **OAuth Client ID:** `828187884021-pmhlbvkc0pk5j4nchhbq3q2rt81dtnpt.apps.googleusercontent.com`
- ✅ **Kubernetes Secret:** `iap-oauth-credentials` (stored in airbyte namespace)

### SSL Certificates:
- ✅ **Status:** Active
- ✅ **Domains:** 
  - connectors-staging.aitronos.com
  - connectors-api-staging.aitronos.com

### Authorized Users:
- ✅ phillip.loacker@aitronos.com

---

## Access URLs

**Platform UI (IAP Protected):**
```
https://connectors-staging.aitronos.com
```

**API Endpoint (IAP Protected):**
```
https://connectors-api-staging.aitronos.com
```

---

## How to Test

### Test 1: Incognito Window
1. Open https://connectors-staging.aitronos.com in incognito/private window
2. Should redirect to Google Sign-In
3. Sign in with phillip.loacker@aitronos.com
4. Platform loads ✅

### Test 2: Unauthorized User
1. Try accessing with a different Google account
2. Should see "You don't have access" error ✅

### Test 3: Programmatic Access (Blocked)
```bash
curl https://connectors-staging.aitronos.com
```
Returns 302 redirect to Google login ✅

---

## Managing Access

### Add a User
```bash
WEBAPP_BACKEND="k8s1-5b5bf1cc-airbyte-airbyte-airbyte-webapp-svc-80-f99a493a"

gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --member='user:EMAIL@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging
```

### Remove a User
```bash
gcloud iap web remove-iam-policy-binding \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --member='user:EMAIL@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging
```

### List Authorized Users
```bash
gcloud iap web get-iam-policy \
  --resource-type=backend-services \
  --service="$WEBAPP_BACKEND" \
  --project=airbyte-backend-staging
```

---

## Backend Services

| Service | Backend Service Name | Port | IAP Status |
|---------|---------------------|------|------------|
| Webapp (UI) | `k8s1-5b5bf1cc-airbyte-airbyte-airbyte-webapp-svc-80-f99a493a` | 31373 | ✅ Enabled |
| API Server | `k8s1-5b5bf1cc-airbyte-airbyte-airbyte-server-svc-8001-bf93f503` | 80 | ✅ Enabled |

---

## Notes

- **HTTPS Warning:** You may see a warning about "backend not using HTTPS" - this is normal. External traffic uses HTTPS, internal traffic (load balancer to pods) uses HTTP.
- **OAuth Consent Screen:** Shows a warning because it's in "Testing" mode - this is normal for external apps.
- **Both endpoints protected:** Both the UI and API are now protected by IAP.

---

## Documentation

See `IAP_AUTHENTICATION.md` for complete documentation including:
- Troubleshooting
- Security considerations
- Disabling IAP

---

**IAP is active and protecting your staging environment!** 🔐

