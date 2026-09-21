-- HanaNote v2 — initial Supabase schema.
-- Privacy contract: encrypted_records.ciphertext is opaque to the
-- server. Server only sees: profile_id, kind, occurred_at (date),
-- ciphertext bytes. RLS enforces profile_id = auth.uid() everywhere.
-- See docs/ai-cto/CONSTITUTION.md ("默认本地，按需同步 + E2EE").

create extension if not exists pgcrypto;

-- ── PROFILES ──────────────────────────────────────────────────
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '·',
  hrt_start_date date,
  signature_char text,                              -- 「楪」
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles_self_read"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles_self_write"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "profiles_self_update"
  on public.profiles for update
  using (auth.uid() = id);

-- Auto-create a profile row on user signup.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id) values (new.id)
  on conflict do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── DEVICES ───────────────────────────────────────────────────
create table public.devices (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  device_label text not null,
  public_key bytea,                                 -- For optional X25519 envelope crypto.
  last_sync_at timestamptz,
  created_at timestamptz not null default now()
);

create index devices_profile on public.devices (profile_id);

alter table public.devices enable row level security;

create policy "devices_self"
  on public.devices for all
  using (profile_id = auth.uid())
  with check (profile_id = auth.uid());

-- ── ENCRYPTED RECORDS ─────────────────────────────────────────
-- The actual user payload — *opaque ciphertext*.
create type public.record_kind as enum (
  'medication',
  'journal',
  'measurement',
  'photo',
  'blood_test'
);

create table public.encrypted_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  device_id uuid references public.devices(id) on delete set null,
  kind public.record_kind not null,
  ciphertext bytea not null,                        -- AES-256-GCM payload from client.
  nonce bytea not null,                             -- 12-byte GCM nonce.
  occurred_at timestamptz,                          -- Indexable date *only* (no semantic content).
  client_version text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index encrypted_records_sync
  on public.encrypted_records (profile_id, updated_at desc);
create index encrypted_records_kind
  on public.encrypted_records (profile_id, kind, occurred_at desc);

alter table public.encrypted_records enable row level security;

create policy "encrypted_records_self"
  on public.encrypted_records for all
  using (profile_id = auth.uid())
  with check (profile_id = auth.uid());

-- ── ACHIEVEMENT UNLOCKS ───────────────────────────────────────
-- Plaintext (label is non-sensitive). Server validates rule on write.
create table public.achievement_unlocks (
  profile_id uuid not null references public.profiles(id) on delete cascade,
  achievement_key text not null,
  unlocked_at timestamptz not null default now(),
  primary key (profile_id, achievement_key)
);

alter table public.achievement_unlocks enable row level security;

create policy "achievements_self"
  on public.achievement_unlocks for all
  using (profile_id = auth.uid())
  with check (profile_id = auth.uid());

-- ── FLOWER COLLECTIONS ────────────────────────────────────────
-- Plaintext. Tracks which day-N flowers the user has "collected".
create table public.flower_collections (
  profile_id uuid not null references public.profiles(id) on delete cascade,
  day_index int not null check (day_index >= 1 and day_index <= 365),
  collected_at timestamptz not null default now(),
  primary key (profile_id, day_index)
);

alter table public.flower_collections enable row level security;

create policy "flowers_self"
  on public.flower_collections for all
  using (profile_id = auth.uid())
  with check (profile_id = auth.uid());

-- ── SHARED POSTERS ────────────────────────────────────────────
-- 9:16 commemorative card PNG. Storage path is a Supabase Storage
-- bucket key. is_public = true means the row is fetchable
-- anonymously (read-only) for the share link.
create table public.shared_posters (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  storage_path text not null,
  caption text,
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  expires_at timestamptz                            -- Default 7 days set by Edge Function.
);

create index shared_posters_profile on public.shared_posters (profile_id);

alter table public.shared_posters enable row level security;

create policy "shared_posters_self"
  on public.shared_posters for all
  using (profile_id = auth.uid())
  with check (profile_id = auth.uid());

-- Anonymous read of public posters.
create policy "shared_posters_public_read"
  on public.shared_posters for select
  using (is_public = true and (expires_at is null or expires_at > now()));

-- ── updated_at trigger ────────────────────────────────────────
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger profiles_touch
  before update on public.profiles
  for each row execute procedure public.touch_updated_at();

create trigger encrypted_records_touch
  before update on public.encrypted_records
  for each row execute procedure public.touch_updated_at();
