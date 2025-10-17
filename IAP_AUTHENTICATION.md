# Identity-Aware Proxy (IAP) Authentication

## Overview

The Aitronos Connectors Platform staging environment is protected by Google Cloud Identity-Aware Proxy (IAP). This means users must authenticate with their Google account before accessing the platform.

**Current authorized user:** phillip.loacker@aitronos.com

---

## How IAP Works

1. User navigates to https://connectors-staging.aitronos.com
2. IAP intercepts the request
3. User is redirected to Google Sign-In
4. After authentication, IAP checks if user is authorized
5. If authorized, user accesses the platform
6. If not authorized, user sees "You don't have access" error

**Security:** IAP runs at the load balancer level, before traffic reaches your application.

---

## Requirements

- ✅ Google account (any Gmail or Google Workspace account)
- ✅ Explicitly granted access via IAM policy
- ✅ HTTPS enabled (IAP requires SSL)

---

## Managing Access

### Add a User

```bash
# Get backend service name
BACKEND_SERVICE=$(gcloud compute backend-services list \
  --project=airbyte-backend-staging \
  --filter="name~airbyte" \
  --format="value(name)" \
  --limit=1)

# Add user
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service=$BACKEND_SERVICE \
  --member='user:EMAIL@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging
```

### Remove a User

```bash
# Remove user
gcloud iap web remove-iam-policy-binding \
  --resource-type=backend-services \
  --service=$BACKEND_SERVICE \
  --member='user:EMAIL@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging
```

### List Authorized Users

```bash
# List all users with IAP access
gcloud iap web get-iam-policy \
  --resource-type=backend-services \
  --service=$BACKEND_SERVICE \
  --project=airbyte-backend-staging
```

---

## Troubleshooting

### "You don't have access" Error

**Cause:** User's email is not in the authorized list.

**Solution:** Add the user with the `add-iam-policy-binding` command above.

### IAP Not Prompting for Login

**Possible causes:**
1. **SSL not provisioned yet** - IAP requires HTTPS
   ```bash
   # Check SSL status
   kubectl get managedcertificate -n airbyte
   ```
   Wait until status shows "Active" for all domains.

2. **BackendConfig not applied**
   ```bash
   # Check if BackendConfig exists
   kubectl get backendconfig -n airbyte
   
   # Verify service annotation
   kubectl get service airbyte-airbyte-webapp-svc -n airbyte -o yaml | grep backend-config
   ```

3. **IAP not enabled on backend service**
   ```bash
   # Check IAP status
   gcloud iap web get-iam-policy \
     --resource-type=backend-services \
     --service=$BACKEND_SERVICE \
     --project=airbyte-backend-staging
   ```

### Redirect Loop or "ERR_TOO_MANY_REDIRECTS"

**Cause:** Backend service doesn't have the IAP enabled flag.

**Solution:** Re-run IAP enable command:
```bash
gcloud iap web enable \
  --resource-type=backend-services \
  --oauth2-client-id=YOUR_CLIENT_ID \
  --oauth2-client-secret=YOUR_CLIENT_SECRET \
  --service=$BACKEND_SERVICE \
  --project=airbyte-backend-staging
```

### OAuth Consent Screen Shows Warning

**Cause:** OAuth consent screen is in "Testing" mode (normal for external apps).

**Options:**
1. Keep in testing mode (works fine, just shows warning)
2. Publish the app (requires Google verification)
3. Switch to Internal (only if you have a Google Workspace organization)

---

## Configuration Details

### OAuth Consent Screen
- **Type:** External
- **App name:** Aitronos Connectors Platform - Staging
- **Support email:** phillip.loacker@aitronos.com
- **Authorized domains:** aitronos.com

### OAuth Client
- **Type:** Web application
- **Name:** IAP OAuth Client - Staging
- **Project:** airbyte-backend-staging

### Kubernetes Resources
- **BackendConfig:** `iap-config` (namespace: airbyte)
- **Secret:** `iap-oauth-credentials` (namespace: airbyte)
- **Ingress:** `connectors-platform-ingress` (namespace: airbyte)

---

## Security Considerations

### What IAP Protects
- ✅ All HTTP(S) traffic to the platform
- ✅ Runs before traffic reaches your application
- ✅ Cannot be bypassed (enforced at load balancer)

### What IAP Doesn't Protect
- ❌ Direct access to Kubernetes pods (use network policies)
- ❌ GKE API access (use GKE RBAC)
- ❌ Cloud SQL access (use Cloud SQL IAM)

### Best Practices
1. **Use group-based access** for teams:
   ```bash
   --member='group:team@aitronos.com'
   ```

2. **Regular access reviews** - Remove users who no longer need access

3. **Monitor access logs** in Cloud Logging:
   ```bash
   gcloud logging read "resource.type=gce_backend_service AND protoPayload.resourceName=~\"$BACKEND_SERVICE\""
   ```

4. **Use service accounts for automation**:
   ```bash
   --member='serviceAccount:automation@PROJECT.iam.gserviceaccount.com'
   ```

---

## API Access

The API endpoint (`connectors-api-staging.aitronos.com`) is currently **not protected** by IAP. 

To protect it:
1. Create a separate BackendConfig for the API service
2. Apply it to `airbyte-airbyte-server-svc`
3. Update ingress with the backend config annotation for the API path

**Note:** API access usually requires programmatic access (service accounts, not user accounts).

---

## Disabling IAP

If you need to temporarily disable IAP:

```bash
# Disable IAP
gcloud iap web disable \
  --resource-type=backend-services \
  --service=$BACKEND_SERVICE \
  --project=airbyte-backend-staging

# Remove BackendConfig annotation
kubectl annotate service airbyte-airbyte-webapp-svc \
  -n airbyte \
  cloud.google.com/backend-config-
```

To re-enable, run the setup script again.

---

## Support

**Platform:** Aitronos Connectors Platform  
**Email:** connectors-platform@aitronos.com  
**Documentation:** See repository README

---

## Quick Reference

### Check IAP Status
```bash
# Get backend service name
gcloud compute backend-services list --project=airbyte-backend-staging

# Check IAP enabled
gcloud iap web get-iam-policy \
  --resource-type=backend-services \
  --service=BACKEND_SERVICE \
  --project=airbyte-backend-staging
```

### Check SSL Status
```bash
kubectl get managedcertificate -n airbyte
kubectl describe managedcertificate connectors-platform-cert -n airbyte
```

### View IAP Logs
```bash
gcloud logging read "resource.type=gce_backend_service" --limit=50
```

### Test Access
1. Open https://connectors-staging.aitronos.com in incognito/private window
2. Sign in with authorized Google account
3. Should see platform UI

---

*Last updated: October 2025*

