# Aitronos Connectors Platform - Complete DNS Setup

## 🌐 All Custom Domains

### Staging Environment
| Domain | Purpose | Static IP | Status |
|--------|---------|-----------|--------|
| `connectors-stage.aitronos.com` | Platform UI | **34.96.91.157** | ✅ Configured |
| `connectors-api-stage.aitronos.com` | API Endpoint | **34.96.91.157** | ✅ Configured |

### Production Environment
| Domain | Purpose | Static IP | Status |
|--------|---------|-----------|--------|
| `connectors.aitronos.com` | Platform UI | **35.201.104.8** | ⏳ Ready (deploy prod first) |
| `connectors-api.aitronos.com` | API Endpoint | **35.201.104.8** | ⏳ Ready (deploy prod first) |

---

## 📋 Hostpoint DNS Configuration

### Login to Hostpoint
1. Go to: https://admin.hostpoint.ch
2. Navigate to: **Domains → aitronos.com → DNS Management**

---

## 🔵 Stage Environment DNS (Add Now)

**Static IP:** `34.96.91.157`

### Add These 2 A Records:

#### Record 1: Platform UI (Stage)
```
Type: A
Hostname: connectors-stage
Points to: 34.96.91.157
TTL: 3600
```

#### Record 2: API (Stage)
```
Type: A
Hostname: connectors-api-stage
Points to: 34.96.91.157
TTL: 3600
```

**Result:**
- ✅ connectors-stage.aitronos.com → 34.96.91.157
- ✅ connectors-api-stage.aitronos.com → 34.96.91.157

---

## 🟢 Production Environment DNS (Add Now, Use Later)

**Static IP:** `35.201.104.8`

### Add These 2 A Records:

#### Record 3: Platform UI (Production)
```
Type: A
Hostname: connectors
Points to: 35.201.104.8
TTL: 3600
```

#### Record 4: API (Production)
```
Type: A
Hostname: connectors-api
Points to: 35.201.104.8
TTL: 3600
```

**Result:**
- ⏳ connectors.aitronos.com → 35.201.104.8 (will work after prod deployment)
- ⏳ connectors-api.aitronos.com → 35.201.104.8 (will work after prod deployment)

---

## 🎯 All 4 DNS Records Summary

**Add all 4 of these A records in Hostpoint:**

| # | Hostname | Points To | Environment |
|---|----------|-----------|-------------|
| 1 | `connectors-stage` | `34.96.91.157` | Staging |
| 2 | `connectors-api-stage` | `34.96.91.157` | Staging |
| 3 | `connectors` | `35.201.104.8` | Production |
| 4 | `connectors-api` | `35.201.104.8` | Production |

**All with TTL: 3600**

---

## ⏱️ Timeline

### Staging (Active Now)
| Time | What Happens |
|------|--------------|
| **Now** | Add DNS records #1 and #2 |
| **5-30 min** | DNS propagates |
| **+30-60 min** | SSL auto-provisions |
| **Result** | ✅ Staging domains live with HTTPS |

### Production (Later)
| Time | What Happens |
|------|--------------|
| **Now** | Add DNS records #3 and #4 (safe to add early) |
| **Later** | Deploy production infrastructure |
| **Deploy** | Apply production ingress |
| **+5-30 min** | DNS already propagated (instant!) |
| **+30-60 min** | SSL auto-provisions |
| **Result** | ✅ Production domains live with HTTPS |

---

## 🧪 Testing After Setup

### Staging Domains (Test After DNS Propagates)
```bash
# Check DNS
dig connectors-stage.aitronos.com
dig connectors-api-stage.aitronos.com

# Test HTTP (immediate after DNS)
curl http://connectors-stage.aitronos.com
curl http://connectors-api-stage.aitronos.com/api/v1/health

# Test HTTPS (after SSL, ~1 hour)
curl https://connectors-stage.aitronos.com
curl https://connectors-api-stage.aitronos.com/api/v1/health
```

### Production Domains (Test After Prod Deployment)
```bash
# Check DNS
dig connectors.aitronos.com
dig connectors-api.aitronos.com

# Test HTTPS
curl https://connectors.aitronos.com
curl https://connectors-api.aitronos.com/api/v1/health
```

---

## 🔐 SSL/HTTPS Status

### Check Staging SSL
```bash
kubectl get managedcertificate -n airbyte

# Detailed view
kubectl describe managedcertificate connectors-platform-cert -n airbyte
```

### Check Production SSL (After Prod Deployment)
```bash
# On production cluster
kubectl get managedcertificate -n airbyte

# Detailed view
kubectl describe managedcertificate connectors-platform-prod-cert -n airbyte
```

---

## 📊 Final URLs

### Staging
- **Platform UI:** https://connectors-stage.aitronos.com
- **API Endpoint:** https://connectors-api-stage.aitronos.com
- **Temporary:** http://34.65.106.202 (until DNS works)

### Production
- **Platform UI:** https://connectors.aitronos.com
- **API Endpoint:** https://connectors-api.aitronos.com
- **Status:** ⏳ Ready for deployment

---

## 🚀 Deployment Commands

### Stage (Already Deployed)
```bash
# Already running!
kubectl get ingress -n airbyte connectors-platform-ingress
kubectl get managedcertificate -n airbyte connectors-platform-cert
```

### Production (When Ready)
```bash
# 1. Deploy production infrastructure
cd /Users/philliploacker/Documents/GitHub/airbyte-infra/envs/prod
terraform apply

# 2. Deploy Airbyte to production
helm install airbyte airbyte/airbyte \
  --namespace airbyte \
  --values /Users/philliploacker/Documents/GitHub/airbyte-platform-deploy/helm/values-prod-minimal.yaml

# 3. Apply production ingress
kubectl apply -f /Users/philliploacker/Documents/GitHub/airbyte-platform-deploy/ingress/production-ingress.yaml
```

---

## ✅ DNS Setup Checklist

**Add all 4 records now (safe to add early):**

- [ ] Login to Hostpoint: https://admin.hostpoint.ch
- [ ] Navigate to: Domains → aitronos.com → DNS
- [ ] Add Record 1: `connectors-stage` → `34.96.91.157`
- [ ] Add Record 2: `connectors-api-stage` → `34.96.91.157`
- [ ] Add Record 3: `connectors` → `34.96.30.35`
- [ ] Add Record 4: `connectors-api` → `34.96.30.35`
- [ ] Save all changes
- [ ] Wait 5-30 minutes for DNS propagation
- [ ] Test staging domains
- [ ] Wait for staging SSL (~1 hour total)
- [ ] Access staging via HTTPS ✨
- [ ] Deploy production (later)
- [ ] Production domains work instantly (DNS already set!) ✨

---

## 💡 Pro Tip

**Add all 4 DNS records now** - even if production isn't deployed yet. This way:
1. DNS propagates while you work on other things
2. When you deploy production, domains work **instantly**
3. No waiting for DNS propagation on prod launch day!

---

## 📞 Support

**Email:** connectors-platform@aitronos.com

---

*Aitronos Connectors Platform - Staging & Production Ready*

