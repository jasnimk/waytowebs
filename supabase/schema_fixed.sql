-- =============================================================================
-- SUPABASE DATABASE SCHEMA FOR WAY TO WEBS APP
-- Fixed version - handles existing tables
-- =============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- DROP EXISTING TABLES (if you want fresh start - UNCOMMENT BELOW)
-- =============================================================================
-- DROP TABLE IF EXISTS public.zoho_sync_log CASCADE;
-- DROP TABLE IF EXISTS public.notifications CASCADE;
-- DROP TABLE IF EXISTS public.plumber_jobs CASCADE;
-- DROP TABLE IF EXISTS public.order_items CASCADE;
-- DROP TABLE IF EXISTS public.orders CASCADE;
-- DROP TABLE IF EXISTS public.cart_items CASCADE;
-- DROP TABLE IF EXISTS public.products CASCADE;
-- DROP TABLE IF EXISTS public.categories CASCADE;
-- DROP TABLE IF EXISTS public.users CASCADE;
-- DROP SEQUENCE IF EXISTS order_number_seq CASCADE;

-- =============================================================================
-- 1. USERS TABLE (Extends Supabase Auth)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone_number TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('customer', 'dealer', 'plumber', 'admin')),
  full_name TEXT,
  email TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  pincode TEXT,

  -- Dealer specific fields
  dealer_verified BOOLEAN DEFAULT FALSE,
  zoho_dealer_id TEXT,
  credit_limit DECIMAL(10, 2) DEFAULT 0,
  credit_30_days_enabled BOOLEAN DEFAULT FALSE,
  credit_90_days_enabled BOOLEAN DEFAULT FALSE,

  -- Plumber specific fields
  plumber_verified BOOLEAN DEFAULT FALSE,
  zoho_plumber_id TEXT,
  expertise_area TEXT[],

  -- Metadata
  profile_image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================================================
-- 2. CATEGORIES TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,

  -- Zoho integration
  zoho_category_id TEXT UNIQUE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================================================
-- 3. PRODUCTS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,

  name TEXT NOT NULL,
  description TEXT,
  sku TEXT UNIQUE,

  -- Pricing
  price DECIMAL(10, 2) NOT NULL,
  mrp DECIMAL(10, 2),
  dealer_price DECIMAL(10, 2),

  -- Stock
  stock_quantity INTEGER DEFAULT 0,
  low_stock_threshold INTEGER DEFAULT 10,

  -- Media
  images TEXT[], -- Array of image URLs
  thumbnail_url TEXT,

  -- Specifications
  specifications JSONB, -- Flexible JSON for product specs

  -- Metadata
  is_active BOOLEAN DEFAULT TRUE,
  is_featured BOOLEAN DEFAULT FALSE,

  -- Zoho integration
  zoho_product_id TEXT UNIQUE,
  last_synced_at TIMESTAMP WITH TIME ZONE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================================================
-- 4. CART TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL CHECK (quantity > 0),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),

  UNIQUE(user_id, product_id)
);

-- =============================================================================
-- 5. ORDERS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,

  -- Order details
  order_number TEXT UNIQUE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'
  )),

  -- Pricing
  subtotal DECIMAL(10, 2) NOT NULL,
  tax DECIMAL(10, 2) DEFAULT 0,
  shipping_charges DECIMAL(10, 2) DEFAULT 0,
  discount DECIMAL(10, 2) DEFAULT 0,
  total_amount DECIMAL(10, 2) NOT NULL,

  -- Shipping address
  shipping_name TEXT NOT NULL,
  shipping_phone TEXT NOT NULL,
  shipping_address TEXT NOT NULL,
  shipping_city TEXT NOT NULL,
  shipping_state TEXT NOT NULL,
  shipping_pincode TEXT NOT NULL,

  -- Payment
  payment_method TEXT CHECK (payment_method IN (
    'online', 'cod', 'credit_30', 'credit_90'
  )),
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN (
    'pending', 'paid', 'failed', 'refunded'
  )),
  payment_id TEXT, -- Razorpay payment ID

  -- Credit terms (for dealers)
  credit_due_date DATE,

  -- Tracking
  tracking_number TEXT,
  estimated_delivery_date DATE,

  -- Notes
  customer_notes TEXT,
  admin_notes TEXT,

  -- Zoho integration
  zoho_order_id TEXT UNIQUE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================================================
-- 6. ORDER ITEMS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,

  product_name TEXT NOT NULL,
  product_sku TEXT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10, 2) NOT NULL,
  total_price DECIMAL(10, 2) NOT NULL,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================================================
-- 7. PLUMBER JOBS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.plumber_jobs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plumber_id UUID REFERENCES public.users(id) ON DELETE SET NULL,

  title TEXT NOT NULL,
  description TEXT,
  location TEXT,

  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending', 'assigned', 'in_progress', 'completed', 'cancelled'
  )),

  priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),

  -- Customer details
  customer_name TEXT,
  customer_phone TEXT,
  customer_address TEXT,

  -- Dates
  scheduled_date DATE,
  completed_date DATE,

  -- Notes
  plumber_notes TEXT,
  admin_notes TEXT,

  -- Zoho integration
  zoho_job_id TEXT UNIQUE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================================================
-- 8. NOTIFICATIONS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT CHECK (type IN ('order', 'payment', 'job', 'general')),

  is_read BOOLEAN DEFAULT FALSE,

  -- Optional link to related entity
  related_entity_type TEXT, -- 'order', 'job', etc.
  related_entity_id UUID,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================================================
-- 9. ZOHO SYNC LOG TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.zoho_sync_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entity_type TEXT NOT NULL, -- 'product', 'order', 'dealer', etc.
  entity_id UUID,
  zoho_id TEXT,

  sync_type TEXT CHECK (sync_type IN ('import', 'export')),
  status TEXT CHECK (status IN ('success', 'failed', 'pending')),

  error_message TEXT,
  sync_data JSONB,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Users
DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone_number);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
EXCEPTION WHEN others THEN NULL; END $$;

-- Products
DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category_id);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_products_active ON public.products(is_active);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_products_sku ON public.products(sku);
EXCEPTION WHEN others THEN NULL; END $$;

-- Categories
DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_categories_active ON public.categories(is_active);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_categories_sort ON public.categories(sort_order);
EXCEPTION WHEN others THEN NULL; END $$;

-- Orders
DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_orders_user ON public.orders(user_id);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_orders_number ON public.orders(order_number);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_orders_created ON public.orders(created_at DESC);
EXCEPTION WHEN others THEN NULL; END $$;

-- Cart
DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_cart_user ON public.cart_items(user_id);
EXCEPTION WHEN others THEN NULL; END $$;

-- Plumber Jobs
DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_jobs_plumber ON public.plumber_jobs(plumber_id);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_jobs_status ON public.plumber_jobs(status);
EXCEPTION WHEN others THEN NULL; END $$;

-- Notifications
DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
EXCEPTION WHEN others THEN NULL; END $$;

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plumber_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.zoho_sync_log ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Anyone can view active categories" ON public.categories;
DROP POLICY IF EXISTS "Anyone can view active products" ON public.products;
DROP POLICY IF EXISTS "Users can manage own cart" ON public.cart_items;
DROP POLICY IF EXISTS "Users can view own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can create own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can view own order items" ON public.order_items;
DROP POLICY IF EXISTS "Plumbers can view assigned jobs" ON public.plumber_jobs;
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;

-- Users: Can read own data
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Categories: Everyone can read active categories
CREATE POLICY "Anyone can view active categories" ON public.categories
  FOR SELECT USING (is_active = TRUE);

-- Products: Everyone can read active products
CREATE POLICY "Anyone can view active products" ON public.products
  FOR SELECT USING (is_active = TRUE);

-- Cart: Users can manage their own cart
CREATE POLICY "Users can manage own cart" ON public.cart_items
  FOR ALL USING (auth.uid() = user_id);

-- Orders: Users can view their own orders
CREATE POLICY "Users can view own orders" ON public.orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own orders" ON public.orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Order Items: Users can view items from their orders
CREATE POLICY "Users can view own order items" ON public.order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

-- Plumber Jobs: Plumbers can view their assigned jobs
CREATE POLICY "Plumbers can view assigned jobs" ON public.plumber_jobs
  FOR SELECT USING (auth.uid() = plumber_id);

-- Notifications: Users can view their own notifications
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- =============================================================================
-- FUNCTIONS AND TRIGGERS
-- =============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS update_categories_updated_at ON public.categories;
DROP TRIGGER IF EXISTS update_products_updated_at ON public.products;
DROP TRIGGER IF EXISTS update_cart_items_updated_at ON public.cart_items;
DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;
DROP TRIGGER IF EXISTS update_plumber_jobs_updated_at ON public.plumber_jobs;
DROP TRIGGER IF EXISTS generate_order_number_trigger ON public.orders;

-- Apply updated_at trigger to all tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON public.categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cart_items_updated_at BEFORE UPDATE ON public.cart_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plumber_jobs_updated_at BEFORE UPDATE ON public.plumber_jobs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.order_number = 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(NEXTVAL('order_number_seq')::TEXT, 6, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Sequence for order numbers
CREATE SEQUENCE IF NOT EXISTS order_number_seq;

-- Trigger for order number generation
CREATE TRIGGER generate_order_number_trigger BEFORE INSERT ON public.orders
  FOR EACH ROW EXECUTE FUNCTION generate_order_number();
