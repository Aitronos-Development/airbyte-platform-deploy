# 🔍 DNS Status Check

## Current DNS Configuration

### ✅ CORRECT
```
connectors-api-staging.aitronos.com → 34.96.91.157
```
**Status:** ✅ Pointing to correct GKE Load Balancer IP

### ❌ INCORRECT
```
connectors-staging.aitronos.com → 217.26.55.9
```
**Status:** ❌ Wrong IP! Should be `34.96.91.157`

---

## 🔧 Fix Required in Hostpoint

**Go to:** https://admin.hostpoint.ch → Domains → aitronos.com → DNS

**Find this record:**
```
Type: A
Hostname: connectors-staging
Value: 217.26.55.9    ← WRONG!
```

**Change to:**
```
Type: A
Hostname: connectors-staging
Value: 34.96.91.157    ← CORRECT!
TTL: 3600
```

---

## 📋 Complete DNS Records for Staging

Both should point to the same IP:

| Record | Hostname | IP Address | Status |
|--------|----------|------------|--------|
| UI | `connectors-staging` | `34.96.91.157` | ❌ Fix needed |
| API | `connectors-api-staging` | `34.96.91.157` | ✅ Correct |

---

## 🧪 Verify After Fix

Wait 5-10 minutes, then test:

```bash
# Should return 34.96.91.157
dig connectors-staging.aitronos.com +short

# Should also return 34.96.91.157
dig connectors-api-staging.aitronos.com +short

# Test UI access
curl -I http://connectors-staging.aitronos.com

# Test API access
curl -I http://connectors-api-staging.aitronos.com
```

---

## ✅ Updated Ingress

I've updated the Kubernetes ingress to match your "staging" naming:
- ✅ `connectors-staging.aitronos.com` → Webapp
- ✅ `connectors-api-staging.aitronos.com` → API Server

**Just fix the DNS IP and you're done!**

---

*Last checked: Just now*

