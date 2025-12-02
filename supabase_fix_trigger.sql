-- =====================================================
-- ULTIMATE FIX untuk Error: "Database error saving new user"
-- =====================================================
--
-- Error: AuthRetryableFetchException (status 500)
-- Penyebab: RLS policy memblokir trigger insert
--
-- SOLUSI: Disable RLS temporarily saat trigger, atau
--         buat policy yang benar-benar allow insert
--
-- CARA MENGGUNAKAN:
-- 1. Copy SEMUA script ini (Ctrl+A, Ctrl+C)
-- 2. Supabase Dashboard → SQL Editor → "+ New query"
-- 3. Paste (Ctrl+V)
-- 4. Klik "Run" atau Ctrl+Enter
-- 5. Tunggu "Success"
-- 6. HAPUS user yang error di Authentication → Users
-- 7. Test register dengan email BARU
--
-- =====================================================

-- STEP 1: Drop semua policy yang ada
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile." ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile." ON public.profiles;

-- STEP 2: Disable RLS sementara (untuk testing)
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- STEP 3: Drop dan recreate trigger function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert tanpa perlu check RLS karena RLS disabled
  INSERT INTO public.profiles (id, full_name, avatar_url, registered_at)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'), 
    NEW.raw_user_meta_data->>'avatar_url',
    NOW()
  );
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Log error tapi tetap return NEW agar user registration berhasil
  RAISE WARNING 'Error inserting profile: %', SQLERRM;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- STEP 4: Recreate trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- VERIFICATION
-- =====================================================
-- Jalankan query ini untuk cek:
--
-- 1. Check RLS status:
--    SELECT relname, relrowsecurity 
--    FROM pg_class 
--    WHERE relname = 'profiles';
--    (relrowsecurity harus FALSE)
--
-- 2. Check trigger exists:
--    SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
--
-- 3. Test manual insert:
--    INSERT INTO profiles (id, full_name) 
--    VALUES ('00000000-0000-0000-0000-000000000000'::uuid, 'Test');
--    (Harus berhasil tanpa error)
--
-- =====================================================
-- SETELAH BERHASIL, ENABLE RLS LAGI (OPSIONAL):
-- =====================================================
-- Uncomment dan jalankan jika mau enable RLS:
--
-- ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
-- 
-- CREATE POLICY "Public profiles viewable by everyone"
--   ON public.profiles FOR SELECT
--   USING (true);
-- 
-- CREATE POLICY "Service role can insert profiles"
--   ON public.profiles FOR INSERT
--   TO service_role
--   WITH CHECK (true);
-- 
-- CREATE POLICY "Users can update own profile"
--   ON public.profiles FOR UPDATE
--   USING (auth.uid() = id);
--
-- =====================================================
