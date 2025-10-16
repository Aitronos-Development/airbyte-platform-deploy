# DNS Setup Instructions for Hostpoint

## Aitronos Connectors Platform - Custom Domains

### What You Need to Configure

**Domain:** aitronos.com  
**DNS Provider:** Hostpoint

### Stage Environment

**Static IP:** `34.96.91.157`

1. **Login to Hostpoint Control Panel**
   - Go to: https://admin.hostpoint.ch
   - Navigate to: Domains → aitronos.com → DNS

2. **Add A Record for Platform UI**
   ```
   Type: A
   Hostname: connectors-staging
   Points to: 34.96.91.157
   TTL: 3600 (or Auto)
   ```
   
   **Result:** connectors-staging.aitronos.com → 34.96.91.157

3. **Add A Record for API Endpoint**
   ```
   Type: A
   Hostname: connectors-api-staging
   Points to: 34.96.91.157
   TTL: 3600 (or Auto)
   ```
   
   **Result:** connectors-api-staging.aitronos.com → 34.96.91.157

3. **Wait for DNS Propagation** (5-30 minutes)
   Check with: `dig connectors-staging.aitronos.com`

4. **Test Access**
   ```bash
   curl http://connectors-staging.aitronos.com
   ```

### Production Environment (Later)

1. Deploy production infrastructure first
2. Get production Load Balancer IP
3. Add A record:
   ```
   Type: A
   Hostname: connectors
   Points to: [PRODUCTION_IP]
   TTL: 3600
   ```
   
   **Result:** connectors.aitronos.com → [PRODUCTION_IP]

### SSL/HTTPS Setup (After DNS)

Once DNS is working, enable SSL:

```bash
cd /Users/philliploacker/Documents/GitHub/airbyte-platform-deploy/ingress

# Update managed-certificate.yaml with your domain
# Then apply:
kubectl apply -f iap/managed-certificate.yaml -n airbyte
```

Google will automatically provision SSL certificate (takes 15-60 minutes).

### Frontend (Firebase Hosting)

For custom domain on Firebase:

1. **Firebase Console**
   - Go to: https://console.firebase.google.com/project/airbyte-backend-staging/hosting
   - Click "Add custom domain"

2. **For Stage:** connectors-staging.aitronos.com
   - Firebase will show verification TXT record
   - Add TXT record in Hostpoint:
     ```
     Type: TXT
     Hostname: connectors-staging (or _acme-challenge.connectors-staging)
     Value: [VALUE_FROM_FIREBASE]
     TTL: 3600
     ```

3. **Wait for Verification** (can take 24 hours)

4. **Firebase shows A/AAAA records**
   - Add these in Hostpoint to complete setup
   - Firebase will auto-provision SSL

### Verification Commands

```bash
# Check DNS propagation
dig connectors-staging.aitronos.com

# Check if accessible
curl http://connectors-staging.aitronos.com

# Check HTTPS (after SSL setup)
curl https://connectors-staging.aitronos.com
```

### Current Status

✅ **Load Balancer IP:** 34.65.106.202  
⏳ **DNS:** Pending your configuration in Hostpoint  
⏳ **HTTPS:** Will configure after DNS works  

### Quick Reference

| Environment | Subdomain | Current IP | Status |
|-------------|-----------|------------|--------|
| Staging | connectors-staging.aitronos.com | 34.65.106.202 | ⏳ DNS needed |
| Production | connectors.aitronos.com | TBD | ⏳ Not deployed yet |

### Need Help?

Contact: connectors-platform@aitronos.com

