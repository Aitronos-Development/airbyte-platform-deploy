#!/bin/bash
set -e

# Setup Identity-Aware Proxy (IAP) for Aitronos Connectors Platform - Staging
# This script automates IAP setup and provides manual instructions for OAuth configuration

PROJECT_ID="airbyte-backend-staging"
AUTHORIZED_USER="phillip.loacker@aitronos.com"

echo "🔐 Setting up Identity-Aware Proxy (IAP) for Staging"
echo "===================================================="
echo ""

# Step 1: Enable IAP API
echo "Step 1: Enabling IAP API..."
gcloud services enable iap.googleapis.com --project=$PROJECT_ID
echo "✅ IAP API enabled"
echo ""

# Step 2: Apply BackendConfig
echo "Step 2: Applying IAP BackendConfig..."
kubectl apply -f ingress/iap-backend-config.yaml
echo "✅ BackendConfig created"
echo ""

# Step 3: Annotate service
echo "Step 3: Annotating webapp service..."
kubectl annotate service airbyte-airbyte-webapp-svc \
  -n airbyte \
  cloud.google.com/backend-config='{"default": "iap-config"}' \
  --overwrite
echo "✅ Service annotated"
echo ""

# Step 4: Manual OAuth setup instructions
echo "=========================================="
echo "⚠️  MANUAL STEPS REQUIRED"
echo "=========================================="
echo ""
echo "Step 4: Configure OAuth Consent Screen"
echo "---------------------------------------"
echo "1. Open: https://console.cloud.google.com/apis/credentials/consent?project=$PROJECT_ID"
echo "2. Click 'CONFIGURE CONSENT SCREEN'"
echo "3. Select 'External' user type"
echo "4. Fill in:"
echo "   - App name: Aitronos Connectors Platform - Staging"
echo "   - User support email: $AUTHORIZED_USER"
echo "   - Authorized domains: aitronos.com"
echo "   - Developer contact: $AUTHORIZED_USER"
echo "5. Click 'SAVE AND CONTINUE' (skip optional scopes)"
echo "6. Add test user: $AUTHORIZED_USER"
echo "7. Click 'SAVE AND CONTINUE'"
echo ""
read -p "Press Enter after completing OAuth consent screen setup..."
echo ""

echo "Step 5: Create OAuth Client ID"
echo "-------------------------------"
echo "1. Open: https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID"
echo "2. Click 'CREATE CREDENTIALS' → 'OAuth client ID'"
echo "3. Select 'Web application'"
echo "4. Name: IAP OAuth Client - Staging"
echo "5. Click 'CREATE'"
echo "6. SAVE the Client ID and Client Secret shown"
echo ""
read -p "Press Enter after creating OAuth client..."
echo ""

# Step 6: Create Kubernetes secret
echo "Step 6: Creating Kubernetes secret for OAuth credentials"
echo "---------------------------------------------------------"
read -p "Enter OAuth Client ID: " CLIENT_ID
read -sp "Enter OAuth Client Secret: " CLIENT_SECRET
echo ""

kubectl create secret generic iap-oauth-credentials \
  -n airbyte \
  --from-literal=client_id="$CLIENT_ID" \
  --from-literal=client_secret="$CLIENT_SECRET" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ OAuth credentials stored in Kubernetes"
echo ""

# Step 7: Apply updated ingress
echo "Step 7: Applying updated ingress..."
kubectl apply -f ingress/dual-domain-ingress.yaml
echo "✅ Ingress updated"
echo ""

# Wait for backend service to be created
echo "Step 8: Waiting for backend service to be created..."
sleep 30

# Step 9: Get backend service name
echo "Step 9: Getting backend service name..."
BACKEND_SERVICE=$(gcloud compute backend-services list \
  --project=$PROJECT_ID \
  --filter="name~airbyte" \
  --format="value(name)" \
  --limit=1)

if [ -z "$BACKEND_SERVICE" ]; then
  echo "❌ Backend service not found. Wait a few minutes and run:"
  echo "   gcloud compute backend-services list --project=$PROJECT_ID"
  echo ""
  echo "Then manually enable IAP:"
  echo "   gcloud iap web enable \\"
  echo "     --resource-type=backend-services \\"
  echo "     --oauth2-client-id=$CLIENT_ID \\"
  echo "     --oauth2-client-secret=$CLIENT_SECRET \\"
  echo "     --service=BACKEND_SERVICE_NAME \\"
  echo "     --project=$PROJECT_ID"
  exit 1
fi

echo "✅ Found backend service: $BACKEND_SERVICE"
echo ""

# Step 10: Enable IAP on backend service
echo "Step 10: Enabling IAP on backend service..."
gcloud iap web enable \
  --resource-type=backend-services \
  --oauth2-client-id="$CLIENT_ID" \
  --oauth2-client-secret="$CLIENT_SECRET" \
  --service="$BACKEND_SERVICE" \
  --project=$PROJECT_ID

echo "✅ IAP enabled on backend service"
echo ""

# Step 11: Add authorized user
echo "Step 11: Adding authorized user..."
gcloud iap web add-iam-policy-binding \
  --resource-type=backend-services \
  --service="$BACKEND_SERVICE" \
  --member="user:$AUTHORIZED_USER" \
  --role='roles/iap.httpsResourceAccessor' \
  --project=$PROJECT_ID

echo "✅ User $AUTHORIZED_USER authorized"
echo ""

# Summary
echo "=========================================="
echo "✅ IAP SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "📋 Summary:"
echo "  - IAP enabled on staging platform"
echo "  - OAuth configured"
echo "  - Authorized user: $AUTHORIZED_USER"
echo ""
echo "🌐 Access URL:"
echo "  https://connectors-staging.aitronos.com"
echo ""
echo "⏱️  Note: SSL certificate must be provisioned before IAP works"
echo "   Check: kubectl get managedcertificate -n airbyte"
echo ""
echo "📚 To add more users:"
echo "  gcloud iap web add-iam-policy-binding \\"
echo "    --resource-type=backend-services \\"
echo "    --service=$BACKEND_SERVICE \\"
echo "    --member='user:EMAIL@aitronos.com' \\"
echo "    --role='roles/iap.httpsResourceAccessor' \\"
echo "    --project=$PROJECT_ID"
echo ""

