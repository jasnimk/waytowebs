-- =============================================================================
-- ADD MISSING COLUMNS TO USERS TABLE
-- Run this to add dealer and plumber specific columns
-- =============================================================================

-- Add dealer specific columns
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS dealer_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS zoho_dealer_id TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS credit_limit DECIMAL(10, 2) DEFAULT 0;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS credit_30_days_enabled BOOLEAN DEFAULT FALSE;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS credit_90_days_enabled BOOLEAN DEFAULT FALSE;

-- Add plumber specific columns
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS plumber_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS zoho_plumber_id TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS expertise_area TEXT[];

-- Add other missing columns
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS state TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS pincode TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_image_url TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Add updated_at if not exists
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW());

-- Create trigger for updated_at if not exists
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
