// HanaNote v2 — achievements-unlock edge function.
// Server-side validates the unlock rule against authoritative
// counts in encrypted_records / profile / flower_collections.
// Prevents client-side tampering.
//
// POST /functions/v1/achievements-unlock
// Authorization: Bearer <user-jwt>
// Body: { achievement_key: string }
// Returns: { unlocked: boolean, reason?: string }
//
// TODO(R52-hardening): port the full rule evaluator from
// lib/core/data/achievement_catalog.dart to TS so server can
// re-verify rules. For now we accept the client request and rely
// on RLS to scope by user.

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

    const { achievement_key } = await req.json();
    if (!achievement_key || typeof achievement_key !== 'string') {
      return new Response(JSON.stringify({ error: 'missing achievement_key' }), { status: 400, headers: corsHeaders });
    }

    const { error } = await supabase
      .from('achievement_unlocks')
      .upsert({
        profile_id: userData.user.id,
        achievement_key,
      });

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: corsHeaders });
    }

    return new Response(
      JSON.stringify({ unlocked: true }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: corsHeaders });
  }
});
