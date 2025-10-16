# Aitronos Connectors Platform - Custom Domains Setup

## 🎯 Your Custom Domains

### Stage Environment

**Reserved Static IP:** `34.96.91.157`

| Domain | Purpose | Points To |
|--------|---------|-----------|
| `connectors-stage.aitronos.com` | Platform UI (Web Interface) | 34.96.91.157 |
| `connectors-api-stage.aitronos.com` | API Endpoint (Integrations) | 34.96.91.157 |

### Production Environment (Future)

| Domain | Purpose | Points To |
|--------|---------|-----------|
| `connectors.aitronos.com` | Platform UI | TBD |
| `connectors-api.aitronos.com` | API Endpoint | TBD |

---

## 📋 Hostpoint DNS Configuration

### Step 1: Login to Hostpoint

1. Go to: https://admin.hostpoint.ch
2. Login with your credentials
3. Navigate to: **Domains → aitronos.com → DNS Management**

### Step 2: Add DNS Records for Stage

Add these **2 A records**:

#### Record 1: Platform UI
```
Type: A
Hostname: connectors-stage
Points to: 34.96.91.157
TTL: 3600
```

#### Record 2: API Endpoint
```
Type: A
Hostname: connectors-api-stage
Points to: 34.96.91.157
TTL: 3600
```

### Step 3: Save Changes

Click **Save** or **Add** to apply the DNS records.

### Step 4: Wait for Propagation (5-30 minutes)

DNS changes take time to propagate. You can check status:

```bash
# Check Platform UI
dig connectors-stage.aitronos.com

# Check API
dig connectors-api-stage.aitronos.com
```

### Step 5: Verify Access (After DNS Propagates)

**Platform UI:**
```bash
curl -I http://connectors-stage.aitronos.com
```

**API:**
```bash
curl -I http://connectors-api-stage.aitronos.com
```

---

## 🔐 SSL/HTTPS (Automatic)

Google Cloud will **automatically provision SSL certificates** for both domains!

**Timeline:**
1. DNS records added → 5-30 min for propagation
2. Google verifies domain ownership → 15-60 min
3. SSL certificate issued → Automatic
4. **HTTPS automatically enabled** → Both domains secured!

**Check SSL Status:**
```bash
kubectl describe managedcertificate connectors-platform-cert -n airbyte
```

Look for: `Status: Active` (means SSL is working)

---

## 🧪 Testing After Setup

### Platform UI (Web Interface)
```bash
# HTTP (immediate after DNS)
curl http://connectors-stage.aitronos.com

# HTTPS (after SSL provisioning ~30-60 min)
curl https://connectors-stage.aitronos.com

# Open in browser
open https://connectors-stage.aitronos.com
```

### API Endpoint (Programmatic Access)
```bash
# HTTP (immediate after DNS)
curl http://connectors-api-stage.aitronos.com/api/v1/health

# HTTPS (after SSL provisioning)
curl https://connectors-api-stage.aitronos.com/api/v1/health

# API Documentation
open https://connectors-api-stage.aitronos.com/api/v1/openapi
```

---

## 📊 Current vs Future URLs

### Before Custom Domain (Current)
- Platform: http://34.65.106.202
- API: Not publicly accessible (ClusterIP only)

### After Custom Domain Setup
- Platform: https://connectors-stage.aitronos.com ✨
- API: https://connectors-api-stage.aitronos.com ✨

### Old LoadBalancer
The old LoadBalancer (34.65.106.202) can be removed after custom domains work:
```bash
kubectl patch svc airbyte-airbyte-webapp-svc -n airbyte -p '{"spec":{"type":"ClusterIP"}}'
```

---

## 🎯 What Happens Next

### Immediate (After DNS Setup)
1. ✅ HTTP access works on both domains
2. ✅ Platform UI accessible via browser
3. ✅ API callable from external applications

### Within 1 Hour
1. ✅ Google verifies domain ownership
2. ✅ SSL certificates auto-provisioned
3. ✅ HTTPS enabled automatically
4. ✅ HTTP → HTTPS redirect active
5. ✅ Secure, production-ready setup!

---

## 🔧 Troubleshooting

### DNS Not Propagating?
```bash
# Check if DNS is set correctly
nslookup connectors-stage.aitronos.com

# Force DNS refresh (macOS)
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

### SSL Certificate Pending?
```bash
# Check certificate status
kubectl get managedcertificate -n airbyte

# View detailed status
kubectl describe managedcertificate connectors-platform-cert -n airbyte
```

Common reasons for delay:
- DNS not fully propagated yet (wait longer)
- Typo in DNS records (double-check Hostpoint)
- TTL cache (wait for TTL expiry)

### Ingress Not Working?
```bash
# Check ingress status
kubectl get ingress -n airbyte

# View ingress details
kubectl describe ingress connectors-platform-ingress -n airbyte

# Check ingress logs
kubectl logs -n kube-system -l k8s-app=glbc
```

---

## 📞 Support

**Platform Contact:** connectors-platform@aitronos.com

---

## ✅ Quick Checklist

- [ ] Login to Hostpoint
- [ ] Add A record: `connectors-stage` → `34.96.91.157`
- [ ] Add A record: `connectors-api-stage` → `34.96.91.157`
- [ ] Save DNS changes
- [ ] Wait 5-30 minutes for DNS propagation
- [ ] Test HTTP access
- [ ] Wait 30-60 minutes for SSL
- [ ] Test HTTPS access
- [ ] Celebrate! 🎉

---

*Aitronos Connectors Platform - Professional, Secure, Swiss-Hosted*

