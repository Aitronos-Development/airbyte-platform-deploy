#!/bin/bash
# Setup Identity-Aware Proxy for Airbyte

set -e

# Variables - customize these
PROJECT_ID="${1:-your-project-id}"
ENVIRONMENT="${2:-stage}"  # stage or prod
DOMAIN="${3:-airbyte-${ENVIRONMENT}.yourdomain.com}"

echo "Setting up IAP for ${ENVIRONMENT} environment"
echo "Project: ${PROJECT_ID}"
echo "Domain: ${DOMAIN}"

# 1. Reserve static IP
echo "Reserving global static IP..."
gcloud compute addresses create airbyte-${ENVIRONMENT}-ip \
  --global \
  --project=${PROJECT_ID} \
  --ip-version=IPV4 || echo "IP already exists"

IP_ADDRESS=$(gcloud compute addresses describe airbyte-${ENVIRONMENT}-ip \
  --global \
  --project=${PROJECT_ID} \
  --format="value(address)")

echo "Static IP: ${IP_ADDRESS}"
echo "Add this A record to your DNS:"
echo "  ${DOMAIN} -> ${IP_ADDRESS}"

# 2. Create OAuth consent screen (manual step)
echo ""
echo "========================================="
echo "MANUAL STEP 1: Configure OAuth Consent Screen"
echo "========================================="
echo "1. Go to: https://console.cloud.google.com/apis/credentials/consent?project=${PROJECT_ID}"
echo "2. Configure OAuth consent screen:"
echo "   - User Type: Internal (for workspace domains) or External"
echo "   - Application name: Airbyte ${ENVIRONMENT^}"
echo "   - Authorized domains: yourdomain.com"
echo "   - Scopes: email, profile, openid"
echo "3. Save and continue"
echo ""
read -p "Press Enter when OAuth consent screen is configured..."

# 3. Create OAuth credentials
echo ""
echo "========================================="
echo "MANUAL STEP 2: Create OAuth Client ID"
echo "========================================="
echo "1. Go to: https://console.cloud.google.com/apis/credentials?project=${PROJECT_ID}"
echo "2. Create OAuth 2.0 Client ID:"
echo "   - Application type: Web application"
echo "   - Name: Airbyte IAP ${ENVIRONMENT}"
echo "   - Authorized redirect URIs will be added automatically by IAP"
echo "3. Save the Client ID and Client Secret"
echo ""
read -p "Press Enter when OAuth Client ID is created..."
read -p "Enter OAuth Client ID: " CLIENT_ID
read -s -p "Enter OAuth Client Secret: " CLIENT_SECRET
echo ""

# 4. Create Kubernetes secret for IAP credentials
echo "Creating Kubernetes secret..."
kubectl create secret generic airbyte-iap-secret \
  -n airbyte \
  --from-literal=client_id="${CLIENT_ID}" \
  --from-literal=client_secret="${CLIENT_SECRET}" \
  --dry-run=client -o yaml | kubectl apply -f -

# 5. Apply BackendConfig
echo "Applying BackendConfig..."
kubectl apply -f backend-config.yaml

# 6. Apply ManagedCertificate
echo "Applying ManagedCertificate..."
kubectl apply -f managed-certificate.yaml

# 7. Enable IAP on the backend service (after ingress is created)
echo ""
echo "========================================="
echo "MANUAL STEP 3: Enable IAP"
echo "========================================="
echo "After the Ingress is created (via Helm), enable IAP:"
echo ""
echo "1. Deploy Airbyte with Helm (if not already done)"
echo "2. Wait for Ingress to be ready:"
echo "   kubectl get ingress -n airbyte -w"
echo ""
echo "3. Find the backend service:"
echo "   gcloud compute backend-services list --project=${PROJECT_ID} | grep airbyte"
echo ""
echo "4. Enable IAP:"
echo "   gcloud iap web enable \\"
echo "     --resource-type=backend-services \\"
echo "     --oauth2-client-id=${CLIENT_ID} \\"
echo "     --oauth2-client-secret=${CLIENT_SECRET} \\"
echo "     --service=BACKEND_SERVICE_NAME \\"
echo "     --project=${PROJECT_ID}"
echo ""
echo "5. Configure IAP access:"
echo "   gcloud iap web add-iam-policy-binding \\"
echo "     --resource-type=backend-services \\"
echo "     --service=BACKEND_SERVICE_NAME \\"
echo "     --member='user:admin@yourdomain.com' \\"
echo "     --role='roles/iap.httpsResourceAccessor' \\"
echo "     --project=${PROJECT_ID}"
echo ""

echo "========================================="
echo "Setup complete!"
echo "========================================="
echo "DNS Configuration:"
echo "  ${DOMAIN} A ${IP_ADDRESS}"
echo ""
echo "After DNS propagates and Helm deployment completes:"
echo "  https://${DOMAIN}"
echo ""

