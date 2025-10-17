# Fix OAuth Redirect URI

## The Issue

You're seeing: **Error 400: redirect_uri_mismatch**

This means the OAuth client doesn't have the IAP redirect URI configured.

---

## Quick Fix (2 minutes)

### Step 1: Go to OAuth Client Settings

**Open:** https://console.cloud.google.com/apis/credentials?project=airbyte-backend-staging

### Step 2: Edit Your OAuth Client

1. Find **"IAP OAuth Client - Staging"** in the list
2. Click the **edit icon** (pencil) on the right

### Step 3: Add Authorized Redirect URI

In the "Authorized redirect URIs" section, click **"+ ADD URI"** and add:

```
https://iap.googleapis.com/v1/oauth/clientIds/828187884021-pmhlbvkc0pk5j4nchhbq3q2rt81dtnpt.apps.googleusercontent.com:handleRedirect
```

**Copy this EXACTLY** (it's the full redirect URI that IAP uses)

### Step 4: Save

Click **"SAVE"** at the bottom

---

## Test Again

Wait 10 seconds, then try accessing:

```
https://connectors-staging.aitronos.com
```

Should work now! ✅

---

## What This Does

IAP uses a specific redirect URI pattern:
```
https://iap.googleapis.com/v1/oauth/clientIds/YOUR_CLIENT_ID:handleRedirect
```

This needs to be explicitly added to the OAuth client's allowed redirect URIs.

---

## If Still Not Working

Try in incognito/private window to avoid cached redirects.

---

*That's it! Just add that one redirect URI and you're done.* 🔐

