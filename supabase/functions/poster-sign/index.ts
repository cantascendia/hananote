// HanaNote v2 — poster-sign edge function.
// Issues a signed upload URL for a 9:16 commemorative card PNG and
// records the row in shared_posters with default 7-day expiry.
//
// POST /functions/v1/poster-sign
// Authorization: Bearer <user-jwt>
// Body: { caption?: string, is_public?: boolean }
// Returns: { upload_url, share_token, expires_at }

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const POSTER_BUCKET = 'shared-posters';
const SEVEN_DAYS_MS = 7 * 24 * 60 * 60 * 1000;

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

    const { caption, is_public } = await req.json();
    const userId = userData.user.id;
    const expiresAt = new Date(Date.now() + SEVEN_DAYS_MS);
    const path = `${userId}/${crypto.randomUUID()}.png`;

    // Reserve the storage path with a signed upload URL (60s).
    const { data: signed, error: signErr } = await supabase
      .storage
      .from(POSTER_BUCKET)
      .createSignedUploadUrl(path);

    if (signErr) {
      return new Response(JSON.stringify({ error: signErr.message }), { status: 500, headers: corsHeaders });
    }

    // Insert the poster row.
    const { data: posterRow, error: insertErr } = await supabase
      .from('shared_posters')
      .insert({
        profile_id: userId,
        storage_path: path,
        caption: caption ?? null,
        is_public: is_public ?? false,
        expires_at: expiresAt.toISOString(),
      })
      .select('id')
      .single();

    if (insertErr) {
      return new Response(JSON.stringify({ error: insertErr.message }), { status: 500, headers: corsHeaders });
    }

    return new Response(
      JSON.stringify({
        upload_url: signed?.signedUrl,
        upload_token: signed?.token,
        path,
        share_token: posterRow.id,
        expires_at: expiresAt.toISOString(),
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: corsHeaders });
  }
});
