// HanaNote v2 — sync-pull edge function.
// Returns encrypted records updated since the client's last sync
// timestamp. Server still never sees plaintext.
//
// POST /functions/v1/sync-pull
// Authorization: Bearer <user-jwt>
// Body: { since: string (ISO-8601), limit?: number }
// Returns: { records: [...], next_since: string }

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const auth = req.headers.get('Authorization');
    if (!auth) return new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401, headers: corsHeaders });

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      { global: { headers: { Authorization: auth } } },
    );

    const { data: userData, error: userErr } = await supabase.auth.getUser();
    if (userErr || !userData.user) {
      return new Response(JSON.stringify({ error: 'invalid token' }), { status: 401, headers: corsHeaders });
    }

    const body = await req.json();
    const since = body.since ?? new Date(0).toISOString();
    const limit = Math.min(Number(body.limit ?? 500), 1000);

    const { data, error } = await supabase
      .from('encrypted_records')
      .select('id, kind, ciphertext, nonce, occurred_at, updated_at, device_id, client_version')
      .eq('profile_id', userData.user.id)
      .gt('updated_at', since)
      .order('updated_at', { ascending: true })
      .limit(limit);

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: corsHeaders });
    }

    const records = (data ?? []).map((r) => ({
      id: r.id,
      kind: r.kind,
      ciphertext_b64: encodeBase64(r.ciphertext as Uint8Array),
      nonce_b64: encodeBase64(r.nonce as Uint8Array),
      occurred_at: r.occurred_at,
      updated_at: r.updated_at,
      device_id: r.device_id,
      client_version: r.client_version,
    }));

    const nextSince =
      records.length > 0 ? records[records.length - 1].updated_at : since;

    return new Response(
      JSON.stringify({ records, next_since: nextSince }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: corsHeaders });
  }
});

function encodeBase64(bytes: Uint8Array): string {
  let bin = '';
  for (let i = 0; i < bytes.byteLength; i++) bin += String.fromCharCode(bytes[i]);
  return btoa(bin);
}
