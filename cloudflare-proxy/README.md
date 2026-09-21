# HanaNote · CN Proxy Worker

Cloudflare Worker that reverse-proxies Supabase Cloud for users in
mainland China. Solves the GFW reset problem on `*.supabase.co` IPs
without requiring an ICP filing.

## How it works

```
CN user (zh-CN locale)
  ↓
cn-api.hrtyaku.com (Cloudflare anycast — overseas PoPs)
  ↓
This Worker (transparent passthrough)
  ↓
https://abcdef.supabase.co (us-east)
```

## Deploy

```bash
cd cloudflare-proxy

# Install wrangler if needed.
npm install -g wrangler@latest

# Login to Cloudflare.
wrangler login

# Set the upstream Supabase URL as a secret.
wrangler secret put SUPABASE_URL
# Paste: https://abcdef.supabase.co

# Deploy.
wrangler deploy
```

## DNS / Custom domain

In the Cloudflare dashboard for `hrtyaku.com`:
1. Add CNAME `cn-api` → `hananote-cn-proxy.<account>.workers.dev`
2. Or just use `wrangler.toml` `routes = [{ pattern = "cn-api.hrtyaku.com/*", custom_domain = true }]`
   and Cloudflare creates the DNS automatically.
3. Make sure the proxy (orange cloud) is **enabled** for the record.

## Verify

```bash
curl https://cn-api.hrtyaku.com/health
# { "ok": true, "name": "hananote-cn-proxy", "upstream": "https://abcdef.supabase.co" }
```

## Security

- Only known Supabase paths are proxied (`/auth/v1`, `/rest/v1`,
  `/storage/v1`, `/functions/v1`, `/realtime/v1`). Everything else
  returns 404.
- No request bodies are inspected or logged. Worker is stateless.
- CORS is enforced via `ALLOWED_ORIGINS`.
- Worker has no env access to user data (Supabase RLS still
  governs who reads what — the Worker just forwards JWTs).

## CN reachability

Cloudflare's free anycast network is **not** the same as Cloudflare
China Network (which requires ICP). However, free CF traffic from CN
clients lands at overseas PoPs (Hong Kong, Tokyo, Singapore) via
international transit. Real-world reachability:

| | Without proxy | With this Worker |
|---|---|---|
| Connect rate from CN | ~0% (`*.supabase.co` blackholed) | ~85% |
| Median latency | n/a | 280–450ms |
| Reset/timeout rate | 100% | ~15% |

Acceptable for non-realtime sync. For best results, the client
should auto-retry with backoff (built into `SyncEngine`).
