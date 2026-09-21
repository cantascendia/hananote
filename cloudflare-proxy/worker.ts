// HanaNote · Cloudflare Worker reverse-proxy to Supabase Cloud.
// Goal: provide CN users with an anycast endpoint that bypasses
// the GFW reset of *.supabase.co IPs. No ICP filing needed —
// traffic terminates at CF edge (overseas) and routes onward to
// Supabase us-east.
//
// Path mapping (transparent passthrough):
//   /auth/v1/*       → ${SUPABASE_URL}/auth/v1/*
//   /rest/v1/*       → ${SUPABASE_URL}/rest/v1/*
//   /storage/v1/*    → ${SUPABASE_URL}/storage/v1/*
//   /functions/v1/*  → ${SUPABASE_URL}/functions/v1/*
//   /realtime/v1/*   → ${SUPABASE_URL}/realtime/v1/*  (websocket)
//
// Headers:
//   - apikey forwarded as-is
//   - Authorization (user JWT) forwarded as-is
//   - CORS handled here so the SDK doesn't choke
//
// Deploy:
//   wrangler deploy
//   (env SUPABASE_URL set via wrangler.toml [vars] or `wrangler secret put`)

export interface Env {
  SUPABASE_URL: string;          // e.g. https://abcdef.supabase.co
  ALLOWED_ORIGINS?: string;      // comma-separated, e.g. "https://hrtyaku.com,https://app.hrtyaku.com"
}

const PROXY_PREFIXES = [
  '/auth/v1',
  '/rest/v1',
  '/storage/v1',
  '/functions/v1',
  '/realtime/v1',
];

function corsHeaders(req: Request, env: Env): Record<string, string> {
  const origin = req.headers.get('Origin') ?? '*';
  const allowed = (env.ALLOWED_ORIGINS ?? '').split(',').map((s) => s.trim()).filter(Boolean);
  const allowOrigin =
    allowed.length === 0 || allowed.includes(origin) ? origin : 'null';
  return {
    'Access-Control-Allow-Origin': allowOrigin,
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
      'authorization, apikey, content-type, x-client-info, x-supabase-api-version, prefer',
    'Access-Control-Max-Age': '86400',
    'Access-Control-Allow-Credentials': 'true',
    Vary: 'Origin',
  };
}

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);

    // Health check.
    if (url.pathname === '/' || url.pathname === '/health') {
      return new Response(
        JSON.stringify({
          ok: true,
          name: 'hananote-cn-proxy',
          upstream: env.SUPABASE_URL,
        }),
        {
          headers: {
            'content-type': 'application/json',
            ...corsHeaders(req, env),
          },
        },
      );
    }

    // CORS preflight.
    if (req.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders(req, env),
      });
    }

    // Only proxy known Supabase prefixes — otherwise reject so we
    // don't accidentally become an open relay.
    const isProxiable = PROXY_PREFIXES.some((p) =>
      url.pathname.startsWith(p),
    );
    if (!isProxiable) {
      return new Response(
        JSON.stringify({ error: 'not_proxiable', path: url.pathname }),
        {
          status: 404,
          headers: {
            'content-type': 'application/json',
            ...corsHeaders(req, env),
          },
        },
      );
    }

    if (!env.SUPABASE_URL) {
      return new Response(
        JSON.stringify({ error: 'misconfigured: SUPABASE_URL missing' }),
        {
          status: 500,
          headers: {
            'content-type': 'application/json',
            ...corsHeaders(req, env),
          },
        },
      );
    }

    // Build upstream URL.
    const upstream = new URL(env.SUPABASE_URL);
    upstream.pathname = url.pathname;
    upstream.search = url.search;

    // Clone headers; strip Host so fetch() sets it correctly.
    const headers = new Headers(req.headers);
    headers.delete('host');
    headers.delete('x-forwarded-host');
    headers.delete('x-forwarded-proto');

    // Forward.
    const upstreamReq = new Request(upstream.toString(), {
      method: req.method,
      headers,
      body:
        req.method === 'GET' || req.method === 'HEAD'
          ? undefined
          : req.body,
      redirect: 'manual',
    });

    const upstreamRes = await fetch(upstreamReq);

    // Re-inject CORS for browser clients.
    const resHeaders = new Headers(upstreamRes.headers);
    const cors = corsHeaders(req, env);
    for (const [k, v] of Object.entries(cors)) resHeaders.set(k, v);

    return new Response(upstreamRes.body, {
      status: upstreamRes.status,
      statusText: upstreamRes.statusText,
      headers: resHeaders,
    });
  },
};
