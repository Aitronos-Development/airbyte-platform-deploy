# Identity-Aware Proxy (IAP) Configuration

Secure Airbyte UI/API access with Google Cloud IAP.

## Overview

IAP provides:
- Authentication before reaching Airbyte
- Authorization via IAM
- No VPN required
- Audit logging

## Prerequisites

1. GKE cluster deployed
2. Airbyte ready for Helm deployment
3. Domain name for Airbyte
4. Permissions to manage OAuth and IAP

## Setup

### Automated Script

```bash
./setup-iap.sh PROJECT_ID stage airbyte-stage.yourdomain.com
```

The script will:
1. Reserve static IP
2. Guide you through OAuth setup
3. Create Kubernetes secrets
4. Apply BackendConfig and ManagedCertificate

### Manual Steps

#### 1. Reserve Static IP

```bash
gcloud compute addresses create airbyte-stage-ip \
  --global \
  --project=PROJECT_ID

gcloud compute addresses describe airbyte-stage-ip \
  --global \
  --project=PROJECT_ID \
  --format="value(address)"
```

Update DNS:
```
airbyte-stage.yourdomain.com  A  IP_ADDRESS
```

#### 2. Configure OAuth Consent Screen

Console: APIs & Services → OAuth consent screen

- **User Type**: Internal (for Workspace) or External
- **Application name**: Airbyte Stage
- **Authorized domains**: yourdomain.com
- **Scopes**: email, profile, openid

#### 3. Create OAuth Client ID

Console: APIs & Services → Credentials → Create Credentials → OAuth Client ID

- **Application type**: Web application
- **Name**: Airbyte IAP Stage
- **Authorized redirect URIs**: (IAP adds automatically)

Save Client ID and Secret.

#### 4. Create Kubernetes Secret

```bash
kubectl create secret generic airbyte-iap-secret \
  -n airbyte \
  --from-literal=client_id="YOUR_CLIENT_ID" \
  --from-literal=client_secret="YOUR_CLIENT_SECRET"
```

#### 5. Apply IAP Resources

```bash
kubectl apply -f backend-config.yaml
kubectl apply -f managed-certificate.yaml
```

#### 6. Deploy Airbyte with Helm

```bash
cd ../helm
helm upgrade --install airbyte airbyte/airbyte \
  -n airbyte \
  -f values-stage.yaml
```

Wait for ingress:
```bash
kubectl get ingress -n airbyte -w
```

#### 7. Enable IAP on Backend Service

Find backend service:
```bash
gcloud compute backend-services list --project=PROJECT_ID | grep airbyte
```

Enable IAP:
```bash
gcloud iap web enable \
  --resource-type=backend-services \
  --oauth2-client-id=YOUR_CLIENT_ID \
  --oauth2-client-secret=YOUR_CLIENT_SECRET \
  --service=BACKEND_SERVICE_NAME \
  --project=PROJECT_ID
```

#### 8. Grant IAP Access

Add users/groups:
```bash
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service=BACKEND_SERVICE_NAME \
  --member='user:admin@yourdomain.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=PROJECT_ID
```

Or for a group:
```bash
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service=BACKEND_SERVICE_NAME \
  --member='group:airbyte-users@yourdomain.com' \
  --role='roles/iap.httpsResourceAccessor' \
  --project=PROJECT_ID
```

## Verification

1. **DNS Propagation**:
```bash
dig airbyte-stage.yourdomain.com
```

2. **Certificate Status**:
```bash
kubectl describe managedcertificate airbyte-stage-cert -n airbyte
```
Wait for `Status: Active` (can take 15-60 minutes).

3. **Ingress Status**:
```bash
kubectl get ingress -n airbyte
```

4. **IAP Status**:
```bash
gcloud iap web get-iam-policy \
  --resource-type=backend-services \
  --service=BACKEND_SERVICE_NAME \
  --project=PROJECT_ID
```

5. **Access Test**:
```bash
curl -I https://airbyte-stage.yourdomain.com
```
Should return 302 redirect to Google OAuth.

## Troubleshooting

### Certificate not provisioning

- Verify DNS A record points to correct IP
- Check domain ownership
- Wait up to 60 minutes

```bash
kubectl describe managedcertificate airbyte-stage-cert -n airbyte
```

### IAP redirect loop

- Verify OAuth client ID/secret in Kubernetes secret
- Check OAuth consent screen configuration
- Ensure IAP is enabled on correct backend service

### Access denied after login

- Check IAM policy:
```bash
gcloud iap web get-iam-policy \
  --resource-type=backend-services \
  --service=BACKEND_SERVICE_NAME \
  --project=PROJECT_ID
```

- Add missing users/groups

### Backend service not found

Ingress may not be ready. Wait for:
```bash
kubectl get ingress -n airbyte
```

## Security Best Practices

1. **Restrict access**: Only grant `roles/iap.httpsResourceAccessor` to required users/groups
2. **Enable audit logging**: Enabled by default for IAP
3. **Regular reviews**: Audit IAM policies quarterly
4. **Use groups**: Manage access via Google Groups, not individual users
5. **Context-aware access**: Consider BeyondCorp policies for additional security

## Alternative: IP Allowlist

If IAP is not suitable, use IP allowlist via Cloud Armor:

```bash
gcloud compute security-policies create airbyte-ip-allowlist \
  --project=PROJECT_ID

gcloud compute security-policies rules create 1000 \
  --security-policy=airbyte-ip-allowlist \
  --expression="inIpRange(origin.ip, 'YOUR_OFFICE_IP/32')" \
  --action=allow \
  --project=PROJECT_ID

gcloud compute security-policies rules create 2147483647 \
  --security-policy=airbyte-ip-allowlist \
  --action=deny-403 \
  --project=PROJECT_ID
```

Update `backend-config.yaml`:
```yaml
spec:
  securityPolicy:
    name: "airbyte-ip-allowlist"
```

