-- ==============================================================================
-- Complete Schema for StyleAI Flutter App
-- Run this entire script in Supabase SQL Editor
-- ==============================================================================

-- 1. CREATE PROFILES TABLE
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  updated_at timestamp with time zone,
  full_name text,
  avatar_url text,
  registered_at timestamp with time zone default now(),
  
  constraint username_length check (char_length(full_name) >= 3)
);

-- Enable RLS on profiles
alter table public.profiles enable row level security;

-- Profiles Policies
drop policy if exists "Public profiles are viewable by everyone." on profiles;
create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

drop policy if exists "Users can insert their own profile." on profiles;
create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

drop policy if exists "Users can update their own profile." on profiles;
create policy "Users can update their own profile."
  on profiles for update
  using ( auth.uid() = id );

-- 2. USER CREATION TRIGGER
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url, registered_at)
  values (
    new.id, 
    coalesce(new.raw_user_meta_data->>'full_name', 'User'), 
    new.raw_user_meta_data->>'avatar_url',
    now()
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 3. STORAGE BUCKET FOR AVATARS
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Storage Policies for Avatars
drop policy if exists "Avatar images are publicly accessible." on storage.objects;
create policy "Avatar images are publicly accessible."
  on storage.objects for select
  using ( bucket_id = 'avatars' );

drop policy if exists "Anyone can upload an avatar." on storage.objects;
create policy "Anyone can upload an avatar."
  on storage.objects for insert
  with check ( bucket_id = 'avatars' and auth.role() = 'authenticated' );

drop policy if exists "Users can update their own avatar." on storage.objects;
create policy "Users can update their own avatar."
  on storage.objects for update
  using ( bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1] );

drop policy if exists "Users can delete their own avatar." on storage.objects;
create policy "Users can delete their own avatar."
  on storage.objects for delete
  using ( bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1] );

-- 4. TRY ON HISTORY TABLE
create table if not exists public.try_on_history (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  image_path text,
  analysis_result text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on try_on_history
alter table public.try_on_history enable row level security;

-- Try On History Policies
drop policy if exists "Users can see their own history" on try_on_history;
create policy "Users can see their own history"
  on try_on_history for select
  using ( auth.uid() = user_id );

drop policy if exists "Users can save their own history" on try_on_history;
create policy "Users can save their own history"
  on try_on_history for insert
  with check ( auth.uid() = user_id );

drop policy if exists "Users can delete their own history" on try_on_history;
create policy "Users can delete their own history"
  on try_on_history for delete
  using ( auth.uid() = user_id );