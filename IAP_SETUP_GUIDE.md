# IAP Authentication - Quick Setup Guide

## ✅ Files Created

All IAP configuration files have been created and committed:

- ✅ `ingress/iap-backend-config.yaml` - Kubernetes BackendConfig for IAP
- ✅ `ingress/dual-domain-ingress.yaml` - Updated with IAP annotation
- ✅ `setup-iap.sh` - Automated setup script
- ✅ `IAP_AUTHENTICATION.md` - Complete documentation

---

## 🚀 Setup Process (10 minutes)

### Prerequisites

1. **SSL must be working first** - IAP requires HTTPS
   ```bash
   # Check SSL status
   kubectl get managedcertificate -n airbyte
   ```
   Wait until status shows "Active" for both domains.

2. **Authentication**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

### Option 1: Automated Setup (Recommended)

Run the setup script which will guide you through the process:

```bash
cd /Users/philliploacker/Documents/GitHub/airbyte-platform-deploy
./setup-iap.sh
```

**The script will:**
1. ✅ Enable IAP API
2. ✅ Apply BackendConfig to Kubernetes
3. ✅ Annotate services
4. ⏸️  Pause for you to configure OAuth consent screen (in browser)
5. ⏸️  Pause for you to create OAuth credentials (in browser)
6. ✅ Create Kubernetes secret with OAuth credentials
7. ✅ Apply updated ingress
8. ✅ Enable IAP on backend service
9. ✅ Add you (phillip.loacker@aitronos.com) as authorized user

---

### Option 2: Manual Setup (Step by Step)

#### Step 1: Enable IAP API
```bash
gcloud services enable iap.googleapis.com --project=airbyte-backend-staging
```

#### Step 2: Apply Kubernetes Resources
```bash
kubectl apply -f ingress/iap-backend-config.yaml
kubectl apply -f ingress/dual-domain-ingress.yaml
kubectl annotate service airbyte-airbyte-webapp-svc \
  -n airbyte \
  cloud.google.com/backend-config='{"default": "iap-config"}' \
  --overwrite
```

#### Step 3: Configure OAuth Consent Screen

**Go to:** https://console.cloud.google.com/apis/credentials/consent?project=airbyte-backend-staging

**Settings:**
- User Type: **External**
- App name: **Aitronos Connectors Platform - Staging**
- User support email: **phillip.loacker@aitronos.com**
- Authorized domains: **aitronos.com**
- Developer contact: **phillip.loacker@aitronos.com**

Click "SAVE AND CONTINUE" (skip optional scopes)

**Add test user:** phillip.loacker@aitronos.com

Click "SAVE AND CONTINUE"

#### Step 4: Create OAuth Credentials

**Go to:** https://console.cloud.google.com/apis/credentials?project=airbyte-backend-staging

1. Click **CREATE CREDENTIALS** → **OAuth client ID**
2. Application type: **Web application**
3. Name: **IAP OAuth Client - Staging**
4. Click **CREATE**
5. **SAVE** the Client ID and Client Secret

#### Step 5: Create Kubernetes Secret

```bash
kubectl create secret generic iap-oauth-credentials \
  -n airbyte \
  --from-literal=client_id="YOUR_CLIENT_ID" \
  --from-literal=client_secret="YOUR_CLIENT_SECRET"
```

#### Step 6: Enable IAP on Backend Service

```bash
# Get backend service name
BACKEND_SERVICE=$(gcloud compute backend-services list \
  --project=airbyte-backend-staging \
  --filter="name~airbyte" \
  --format="value(name)" \
  --limit=1)

# Enable IAP
gcloud iap web enable \
  --resource-type=backend-services \
  --oauth2-client-id="YOUR_CLIENT_ID" \
  --oauth2-client-secret="YOUR_CLIENT_SECRET" \
  --service="$BACKEND_SERVICE" \
  --project=airbyte-backend-staging
```

#### Step 7: Add Authorized User

```bash
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service="$BACKEND_SERVICE" \
  --member='user:phillip.loacker@aitronos.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=airbyte-backend-staging
```

---

## 🧪 Testing

After setup:

1. **Open in incognito/private window:**
   ```
   https://connectors-staging.aitronos.com
   ```

2. **Expected behavior:**
   - Redirects to Google Sign-In
   - Sign in with phillip.loacker@aitronos.com
   - After authentication, platform loads
   - Other users see "You don't have access"

3. **Verify IAP is active:**
   ```bash
   gcloud iap web get-iam-policy \
     --resource-type=backend-services \
     --service=$BACKEND_SERVICE \
     --project=airbyte-backend-staging
   ```

---

## 📚 Documentation

See `IAP_AUTHENTICATION.md` for:
- Complete IAP documentation
- How to add/remove users
- Troubleshooting guide
- Security considerations

---

## ⚠️ Important Notes

1. **SSL Required:** IAP only works with HTTPS. Make sure SSL certificates are provisioned first.

2. **OAuth Consent Warning:** Your consent screen will show a warning because it's in "Testing" mode. This is normal and doesn't affect functionality.

3. **Backend Service Delay:** After applying the ingress, wait 1-2 minutes for the backend service to be created before enabling IAP.

4. **API Endpoint:** The API endpoint (`connectors-api-staging.aitronos.com`) is NOT protected by IAP by default. This allows programmatic access. Protect it separately if needed.

---

## 🆘 Troubleshooting

### IAP not prompting for login
- Check SSL is provisioned: `kubectl get managedcertificate -n airbyte`
- Verify BackendConfig exists: `kubectl get backendconfig -n airbyte`
- Check service annotation: `kubectl describe service airbyte-airbyte-webapp-svc -n airbyte`

### "You don't have access" error
- Add user: See Step 7 above or `IAP_AUTHENTICATION.md`

### Redirect loop
- Re-run IAP enable command (Step 6)

---

## 📞 Support

**Email:** connectors-platform@aitronos.com  
**Documentation:** IAP_AUTHENTICATION.md

---

**Ready to secure your staging environment!** 🔐

