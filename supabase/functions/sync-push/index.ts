// HanaNote v2 — sync-push edge function.
// Accepts an array of encrypted records from the client and inserts
// them. The server NEVER sees plaintext — only ciphertext + nonce
// + opaque metadata (kind + occurred_at).
//
// POST /functions/v1/sync-push
// Authorization: Bearer <user-jwt>
// Body: { records: [{ id, device_id, kind, ciphertext_b64,
//   nonce_b64, occurred_at, client_version }] }
//
// Returns: { accepted: number, conflicts: [...] }

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

interface RecordIn {
  id: string;
  device_id?: string | null;
  kind: 'medication' | 'journal' | 'measurement' | 'photo' | 'blood_test';
  ciphertext_b64: string;
  nonce_b64: string;
  occurred_at?: string | null;
  client_version?: string | null;
}

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
    const records: RecordIn[] = body.records ?? [];

    // Convert base64 ciphertext / nonce to bytea for Postgres.
    const rows = records.map((r) => ({
      id: r.id,
      profile_id: userData.user.id,
      device_id: r.device_id ?? null,
      kind: r.kind,
      ciphertext: decodeBase64(r.ciphertext_b64),
      nonce: decodeBase64(r.nonce_b64),
      occurred_at: r.occurred_at ?? null,
      client_version: r.client_version ?? null,
    }));

    const { data, error } = await supabase
      .from('encrypted_records')
      .upsert(rows, { onConflict: 'id' })
      .select('id');

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: corsHeaders });
    }

    // Per SPEC §10.2: response contains EXPLICIT list of accepted IDs (not
    // just a count). Client uses this list to mark only those rows clean —
    // the post-R52 audit (ARE §43) flagged a silent-data-loss path where
    // `markClean(dirty.map(.id))` ran regardless of how many the server
    // actually upserted. Per-id ack is the only safe contract.
    const acceptedIds = (data ?? []).map((row) => row.id);
    const submittedIds = rows.map((r) => r.id);
    const rejectedIds = submittedIds.filter((id) => !acceptedIds.includes(id));

    return new Response(
      JSON.stringify({
        accepted: acceptedIds,
        accepted_count: acceptedIds.length,
        rejected: rejectedIds,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: corsHeaders });
  }
});

function decodeBase64(s: string): Uint8Array {
  const bin = atob(s);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}
