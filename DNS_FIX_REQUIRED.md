# 🔧 DNS Configuration Fix Required

## ❌ Current Issue

Your DNS is pointing to the wrong IP address:

```
connectors-staging.aitronos.com → 217.26.55.9 ❌ WRONG
```

## ✅ Required Fix

Update your Hostpoint DNS to point to the correct GKE Load Balancer IP:

```
connectors-stage.aitronos.com → 34.96.91.157 ✅ CORRECT
```

**Note:** Also fix the hostname from `connectors-staging` to `connectors-stage` (dash, not hyphen)

---

## 📋 Exact Steps in Hostpoint

### 1. Login to Hostpoint
**URL:** https://admin.hostpoint.ch  
**Navigate to:** Domains → aitronos.com → DNS Management

### 2. Update/Delete Old Record
**Find and DELETE:**
```
Hostname: connectors-staging
IP: 217.26.55.9
```

### 3. Add Correct Records for Staging

#### Record 1: Platform UI (Staging)
```
Type: A
Hostname: connectors-stage
Value: 34.96.91.157
TTL: 3600
```

#### Record 2: API (Staging)
```
Type: A
Hostname: connectors-api-stage
Value: 34.96.91.157
TTL: 3600
```

### 4. Add Production Records (For Later)

#### Record 3: Platform UI (Production)
```
Type: A
Hostname: connectors
Value: 35.201.104.8
TTL: 3600
```

#### Record 4: API (Production)
```
Type: A
Hostname: connectors-api
Value: 35.201.104.8
TTL: 3600
```

---

## 🧪 Verify After Update

Wait 5-10 minutes, then test:

```bash
# Check DNS propagation
dig connectors-stage.aitronos.com

# Should show:
# connectors-stage.aitronos.com. 3600 IN A 34.96.91.157
```

### Test Access
```bash
# Test UI (HTTP, immediate)
curl -I http://34.96.91.157

# After DNS propagates (5-30 min)
curl -I http://connectors-stage.aitronos.com

# After SSL provisions (30-60 min)
curl -I https://connectors-stage.aitronos.com
```

---

## 📊 Summary of All DNS Records

Add these 4 A records in Hostpoint:

| Hostname | IP Address | Environment | Purpose |
|----------|------------|-------------|---------|
| `connectors-stage` | `34.96.91.157` | Staging | UI |
| `connectors-api-stage` | `34.96.91.157` | Staging | API |
| `connectors` | `35.201.104.8` | Production | UI |
| `connectors-api` | `35.201.104.8` | Production | API |

---

## ⚠️ Important

**Delete any records pointing to `217.26.55.9`** - this is not your GKE Load Balancer!

Your GKE Load Balancer IPs are:
- **Staging:** `34.96.91.157`
- **Production:** `35.201.104.8`

---

*Fix these DNS records and your platform will be accessible!*

