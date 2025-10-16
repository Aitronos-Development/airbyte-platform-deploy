# Aitronos Connectors Platform - Frontend Deployment

Frontend deployed to Firebase Hosting for global CDN delivery.

**Brand:** Aitronos Connectors Platform  
**Contact:** connectors-platform@aitronos.com

## Setup

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Initialize Firebase (already done)
Project configured in `firebase.json` and `.firebaserc`

### 4. Create Firebase Hosting Sites
```bash
# For staging
firebase hosting:sites:create airbyte-stage

# For production
firebase hosting:sites:create airbyte-prod
```

### 5. Configure Custom Domains (in Firebase Console)
1. Go to Firebase Console: https://console.firebase.google.com/
2. Select project: `airbyte-backend-staging`
3. Hosting → Add custom domain
4. Follow instructions to add DNS records in Hostpoint

## Manual Deployment

```bash
# Deploy staging
cd frontend
./deploy-frontend.sh stage

# Deploy production
./deploy-frontend.sh production
```

## Automatic Deployment

GitHub Actions automatically deploy on push:
- `stage` branch → Firebase Hosting (stage)
- `main` branch → Firebase Hosting (production)

## Required GitHub Secrets

Add these in GitHub repo settings → Secrets and variables → Actions:

1. `FIREBASE_SERVICE_ACCOUNT` - Service account JSON for Firebase
   - Create at: https://console.firebase.google.com/project/airbyte-backend-staging/settings/serviceaccounts/adminsdk
   - Download JSON, copy entire contents

## URLs

- **Staging**: https://airbyte-stage.web.app (before custom domain)
- **Production**: https://airbyte-prod.web.app (before custom domain)

After custom domain setup:
- **Staging**: https://connectors-stage.aitronos.com
- **Production**: https://connectors.aitronos.com

## Cost

Firebase Hosting free tier:
- 10 GB storage
- 360 MB/day transfer
- Custom domain SSL included

Perfect for staging + low-traffic production!

