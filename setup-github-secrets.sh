#!/bin/bash
set -e

# Setup GitHub Actions Secrets for Aitronos Connectors Platform
# Run this script to create service accounts and prepare secrets

echo "🔑 Setting up GitHub Actions Service Accounts"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# 1. Staging Service Account
# ============================================
echo "${BLUE}Step 1: Creating Staging Service Account${NC}"

gcloud iam service-accounts create github-actions-staging \
  --project=airbyte-backend-staging \
  --display-name="GitHub Actions Deployer (Staging)" \
  2>/dev/null || echo "Service account already exists"

# Grant necessary permissions
gcloud projects add-iam-policy-binding airbyte-backend-staging \
  --member="serviceAccount:github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com" \
  --role="roles/container.developer" \
  --condition=None

gcloud projects add-iam-policy-binding airbyte-backend-staging \
  --member="serviceAccount:github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser" \
  --condition=None

# Create key
gcloud iam service-accounts keys create ~/github-actions-staging-key.json \
  --iam-account=github-actions-staging@airbyte-backend-staging.iam.gserviceaccount.com \
  --project=airbyte-backend-staging

echo "${GREEN}✓ Created: ~/github-actions-staging-key.json${NC}"
echo ""

# ============================================
# 2. Production Service Account (if project exists)
# ============================================
echo "${BLUE}Step 2: Creating Production Service Account${NC}"
echo "(Skipping if production project doesn't exist yet)"

# Uncomment when production project is ready:
# gcloud iam service-accounts create github-actions-prod \
#   --project=airbyte-backend-production \
#   --display-name="GitHub Actions Deployer (Production)"
# 
# gcloud projects add-iam-policy-binding airbyte-backend-production \
#   --member="serviceAccount:github-actions-prod@airbyte-backend-production.iam.gserviceaccount.com" \
#   --role="roles/container.developer"
# 
# gcloud projects add-iam-policy-binding airbyte-backend-production \
#   --member="serviceAccount:github-actions-prod@airbyte-backend-production.iam.gserviceaccount.com" \
#   --role="roles/iam.serviceAccountUser"
# 
# gcloud iam service-accounts keys create ~/github-actions-prod-key.json \
#   --iam-account=github-actions-prod@airbyte-backend-production.iam.gserviceaccount.com \
#   --project=airbyte-backend-production

echo "⏳ Production service account: Create when prod project is ready"
echo ""

# ============================================
# 3. Firebase Service Account
# ============================================
echo "${BLUE}Step 3: Firebase Service Account${NC}"
echo "Please create this manually:"
echo "1. Go to: https://console.firebase.google.com/project/airbyte-backend-staging/settings/serviceaccounts/adminsdk"
echo "2. Click 'Generate new private key'"
echo "3. Save as ~/firebase-service-account.json"
echo ""

# ============================================
# Summary
# ============================================
echo ""
echo "${GREEN}============================================${NC}"
echo "${GREEN}✅ Service Accounts Created!${NC}"
echo "${GREEN}============================================${NC}"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Add these 3 secrets to GitHub:"
echo "   Go to: GitHub Repo → Settings → Secrets → Actions"
echo ""
echo "   Secret 1: GCP_SA_KEY"
echo "   Command: cat ~/github-actions-staging-key.json | pbcopy"
echo "   (Paste into GitHub)"
echo ""
echo "   Secret 2: GCP_SA_KEY_PROD"
echo "   (Create when production is ready)"
echo ""
echo "   Secret 3: FIREBASE_SERVICE_ACCOUNT"
echo "   Command: cat ~/firebase-service-account.json | pbcopy"
echo "   (Paste into GitHub after downloading from Firebase Console)"
echo ""
echo "2. Create 'staging' branch:"
echo "   git checkout -b staging"
echo "   git push origin staging"
echo ""
echo "3. Test deployment:"
echo "   git commit --allow-empty -m 'Test deployment'"
echo "   git push origin staging"
echo ""
echo "4. Watch deployment:"
echo "   Go to GitHub → Actions tab"
echo ""
echo "${GREEN}Done! See GITHUB_ACTIONS_SETUP.md for details${NC}"

