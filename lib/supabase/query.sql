-- ================================================================================= --
--                             LOST & FOUND - SUPABASE SCHEMA                        --
-- ================================================================================= --

-- ================================================================================= --
-- 1. TABLES
-- ================================================================================= --

-- Create the profiles table to store user data linked to auth.users
CREATE TABLE public.profiles (
  id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE,
  email varchar(255),
  name varchar(255),
  nim varchar(255),
  program_study varchar(255),
  faculty varchar(255),
  avatar_url TEXT;

  role varchar(50) NOT NULL DEFAULT 'user',
  PRIMARY KEY (id)
);

-- Create the items table for all lost and found items
CREATE TABLE public.items (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  item_name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  -- status can be: 'lost', 'found', 'unverified_found', 'claimed', 'returned'
  status TEXT NOT NULL,
  location TEXT,
  
  CONSTRAINT items_pkey PRIMARY KEY (id)
);

-- Create the claims table for users claiming a found item
CREATE TABLE public.claims (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
  claimer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  finder_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  -- status can be: 'pending', 'approved', 'rejected'
  status TEXT NOT NULL DEFAULT 'pending',
  claimant_message TEXT,
  
  CONSTRAINT claims_pkey PRIMARY KEY (id)
);

-- Create the contacts table for finders contacting owners of lost items
CREATE TABLE public.contacts (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE, -- The finder
  receiver_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE, -- The owner
  message TEXT NOT NULL,
  
  CONSTRAINT contacts_pkey PRIMARY KEY (id)
);

-- --- VIEW TABLE --- 
CREATE VIEW public.public_profiles AS
SELECT
  id,
  name,
  program_study,
  faculty,
  avatar_url
FROM
  public.profiles;

-- ================================================================================= --
-- 2. DATABASE FUNCTIONS & TRIGGERS
-- ================================================================================= --

-- Function to automatically create a profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (new.id, new.email);
  RETURN new;
END;
$$;

-- Trigger to call the function when a new user is created in auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- Function to sync the user's role from their profile into their JWT
CREATE OR REPLACE FUNCTION public.update_user_role_in_jwt()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  UPDATE auth.users
  SET raw_app_meta_data = raw_app_meta_data || jsonb_build_object('role', NEW.role)
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$;

-- Trigger to call the function when a profile is inserted or its role is updated
CREATE TRIGGER on_profile_change_update_jwt
  AFTER INSERT OR UPDATE OF role ON public.profiles
  FOR EACH ROW
  EXECUTE PROCEDURE public.update_user_role_in_jwt();


-- Transactional function to safely approve a claim and update the item's status
CREATE OR REPLACE FUNCTION approve_claim_and_update_item(
  claim_id_to_approve UUID,
  item_id_to_update UUID
)
RETURNS void AS $$
BEGIN
  UPDATE public.claims
  SET status = 'approved'
  WHERE id = claim_id_to_approve;

  UPDATE public.items
  SET status = 'claimed'
  WHERE id = item_id_to_update;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.get_activity_for_item(p_item_id UUID)
RETURNS JSON
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  item_status TEXT;
  result JSON;
BEGIN
  SELECT status INTO item_status FROM public.items WHERE id = p_item_id;

  IF item_status = 'lost' THEN
    SELECT json_agg(
      json_build_object(
        'id', c.id,
        'created_at', c.created_at,
        'message', c.message,
        'public_profiles', json_build_object(
          'id', pp.id,
          'name', pp.name,
          'avatar_url', pp.avatar_url
        )
      )
    )
    INTO result
    FROM public.contacts c
    JOIN public.public_profiles pp ON c.sender_id = pp.id
    WHERE c.item_id = p_item_id;
  ELSE
    SELECT json_agg(
      json_build_object(
        'id', cl.id,
        'created_at', cl.created_at,
        'status', cl.status,
        'claimant_message', cl.claimant_message,
        'public_profiles', json_build_object(
          'id', pp.id,
          'name', pp.name,
          'avatar_url', pp.avatar_url
        )
      )
    )
    INTO result
    FROM public.claims cl
    JOIN public.public_profiles pp ON cl.claimer_id = pp.id
    WHERE cl.item_id = p_item_id;
  END IF;

  RETURN COALESCE(result, '[]');
END;
$$;

-- ================================================================================= --
-- 3. ROW LEVEL SECURITY (RLS)
-- ================================================================================= --

-- --- PROFILES TABLE RLS ---
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Profile Policies" ON public.profiles;
CREATE POLICY "Profile Policies" ON public.profiles
  FOR ALL
  USING (auth.uid() = id OR (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'perantara'))
  WITH CHECK (auth.uid() = id OR (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'perantara'));


-- --- ITEMS TABLE RLS ---
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Admins/Perantara see all, users see approved items only" ON public.items;
DROP POLICY IF EXISTS "Allow authenticated users to insert items" ON public.items;
DROP POLICY IF EXISTS "Owners or Admins/Perantara can update items" ON public.items;
DROP POLICY IF EXISTS "Owners or Admins/Perantara can delete items" ON public.items;

CREATE POLICY "Admins/Perantara see all, users see specified items only"
  ON public.items FOR SELECT
  USING ((auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'perantara') OR status IN ('lost', 'found', 'unverified_found', 'claimed', 'returned'));

CREATE POLICY "Allow authenticated users to insert items"
  ON public.items FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Owners or Admins/Perantara can update items"
  ON public.items FOR UPDATE
  USING (auth.uid() = user_id OR (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'perantara'));

CREATE POLICY "Owners or Admins/Perantara can delete items"
  ON public.items FOR DELETE
  USING (auth.uid() = user_id OR (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'perantara'));


-- --- CLAIMS TABLE RLS ---
ALTER TABLE public.claims ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow authenticated users to insert claims" ON public.claims;
DROP POLICY IF EXISTS "Allow relevant parties to read claims" ON public.claims;
DROP POLICY IF EXISTS "Allow finder or mods to update claims" ON public.claims;

CREATE POLICY "Allow authenticated users to insert claims"
  ON public.claims FOR INSERT
  WITH CHECK (auth.uid() = claimer_id);

CREATE POLICY "Allow relevant parties to read claims"
  ON public.claims FOR SELECT
  USING (auth.uid() = claimer_id OR auth.uid() = finder_id OR (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'perantara'));

CREATE POLICY "Allow finder or mods to update claims"
  ON public.claims FOR UPDATE
  USING (auth.uid() = finder_id OR (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'perantara'));


-- --- CONTACTS TABLE RLS ---
ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow authenticated users to insert contacts" ON public.contacts;
DROP POLICY IF EXISTS "Allow relevant parties to read contacts" ON public.contacts;

CREATE POLICY "Allow authenticated users to insert contacts"
  ON public.contacts FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Allow relevant parties to read contacts"
  ON public.contacts FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id OR (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'perantara'));

-- --- VIEW TABLE RLS ---
ALTER TABLE public.public_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.public_profiles FOR SELECT
  USING (true);

-- ================================================================================= --
--                                  END OF SCRIPT                                    --
-- ================================================================================= --