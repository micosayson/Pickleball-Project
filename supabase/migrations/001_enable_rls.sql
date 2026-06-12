-- Enable Row Level Security for key tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.court_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rankings ENABLE ROW LEVEL SECURITY;

-- Example policies to add after RLS is enabled.
-- NOTE: RLS without policies blocks all access.

-- Allow users to read their own profile.
-- CREATE POLICY "Users can view own profile"
-- ON public.users
-- FOR SELECT
-- USING (auth.uid() = supabase_user_id);

-- Allow public read access to courts.
-- CREATE POLICY "Anyone can view courts"
-- ON public.courts
-- FOR SELECT
-- USING (true);

-- Allow court owners to update their own courts.
-- CREATE POLICY "Owners update their courts"
-- ON public.courts
-- FOR UPDATE
-- USING (created_by = auth.uid());
