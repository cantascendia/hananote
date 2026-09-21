// HanaNote v2 — account-wipe edge function.
// Cascade-deletes ALL user data: profile, devices, encrypted records,
// achievement unlocks, flower collections, shared posters, and the
// auth user itself.
//
// POST /functions/v1/account-wipe
// Authorization: Bearer <user-jwt>
// Body: { confirm: 'YES_DELETE_FOREVER' }
// Returns: { wiped: true }
//
// This is the "紧急清除" emergency-wipe action from Profile.
// Triggered by triple-tap confirmation in the UI.

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

    const { confirm } = await req.json();
    if (confirm !== 'YES_DELETE_FOREVER') {
      return new Response(JSON.stringify({ error: 'missing confirmation' }), { status: 400, headers: corsHeaders });
    }

    const userId = userData.user.id;

    // Delete from all tables (RLS will scope automatically; we run
    // service-role anyway to ensure the cascade succeeds).
    // ON DELETE CASCADE on profiles + the trigger means deleting the
    // auth.users row will sweep everything.
    const { error: deleteUserErr } =
      await supabase.auth.admin.deleteUser(userId);
    if (deleteUserErr) {
      return new Response(JSON.stringify({ error: deleteUserErr.message }), { status: 500, headers: corsHeaders });
    }

    return new Response(
      JSON.stringify({ wiped: true }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: corsHeaders });
  }
});
