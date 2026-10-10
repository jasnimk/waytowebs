-- =============================================================================
-- SAMPLE DATA FOR TESTING
-- Run this after schema.sql to populate test data
-- Using real images from Unsplash and Pexels
-- =============================================================================

-- Sample Categories
INSERT INTO public.categories (name, description, image_url, sort_order) VALUES
('Pipes', 'PVC and metal pipes for plumbing', 'https://images.unsplash.com/photo-1581092918484-8313e1b9b6e7?w=800&q=80', 1),
('Fittings', 'Pipe fittings and connectors', 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=800&q=80', 2),
('Taps & Faucets', 'Kitchen and bathroom taps', 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800&q=80', 3),
('Tanks', 'Water storage tanks', 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800&q=80', 4),
('Bathroom', 'Bathroom fixtures and accessories', 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=800&q=80', 5),
('Tools', 'Plumbing tools and equipment', 'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=800&q=80', 6);

-- Sample Products
INSERT INTO public.products (
  category_id, name, description, sku, price, mrp, dealer_price, stock_quantity,
  images, thumbnail_url, specifications, is_featured
) VALUES
-- PVC Pipes
(
  (SELECT id FROM public.categories WHERE name = 'Pipes'),
  'PVC Pipe 2 inch - 10 feet',
  'High quality PVC pipe suitable for water supply, drainage and irrigation. ISI marked, durable and corrosion resistant.',
  'PVC-2-10',
  450.00,
  550.00,
  400.00,
  150,
  ARRAY[
    'https://images.unsplash.com/photo-1581092918484-8313e1b9b6e7?w=800&q=80',
    'https://images.unsplash.com/photo-1581092335397-9583eb92d232?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1581092918484-8313e1b9b6e7?w=400&q=80',
  '{"material": "PVC", "length": "10 feet", "diameter": "2 inch", "pressure_rating": "150 PSI", "standard": "ISI", "color": "Grey"}'::jsonb,
  true
),
(
  (SELECT id FROM public.categories WHERE name = 'Pipes'),
  'CPVC Pipe 1 inch - 6 feet',
  'Chlorinated PVC pipe for hot and cold water supply. Heat resistant up to 90°C.',
  'CPVC-1-6',
  320.00,
  400.00,
  280.00,
  200,
  ARRAY[
    'https://images.unsplash.com/photo-1581092335397-9583eb92d232?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1581092335397-9583eb92d232?w=400&q=80',
  '{"material": "CPVC", "length": "6 feet", "diameter": "1 inch", "temperature_rating": "90°C", "standard": "ASTM"}'::jsonb,
  false
),

-- Taps & Faucets
(
  (SELECT id FROM public.categories WHERE name = 'Taps & Faucets'),
  'Kitchen Sink Tap - Chrome Finish',
  'Premium chrome finished kitchen tap with single lever operation. 360° swivel spout for convenience.',
  'TAP-KIT-CHR-001',
  1200.00,
  1500.00,
  1000.00,
  50,
  ARRAY[
    'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800&q=80',
    'https://images.unsplash.com/photo-1620626011761-996317b8d101?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400&q=80',
  '{"finish": "Chrome", "type": "Single Lever", "warranty": "2 years", "spout_type": "360° Swivel", "connection": "1/2 inch"}'::jsonb,
  true
),
(
  (SELECT id FROM public.categories WHERE name = 'Taps & Faucets'),
  'Wall Mixer - Matt Black',
  'Contemporary matt black wall mixer for bathroom. Premium brass construction.',
  'TAP-WALL-BLK-002',
  2800.00,
  3500.00,
  2400.00,
  30,
  ARRAY[
    'https://images.unsplash.com/photo-1620626011761-996317b8d101?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1620626011761-996317b8d101?w=400&q=80',
  '{"finish": "Matt Black", "type": "Wall Mixer", "warranty": "5 years", "material": "Brass", "cartridge": "Ceramic Disc"}'::jsonb,
  true
),

-- Water Tanks
(
  (SELECT id FROM public.categories WHERE name = 'Tanks'),
  'Water Tank 500L - Blue',
  'Food grade plastic water storage tank. UV resistant, rust-free and durable. 3 layer protection.',
  'TANK-500-BLU',
  3500.00,
  4000.00,
  3200.00,
  20,
  ARRAY[
    'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=400&q=80',
  '{"capacity": "500 liters", "color": "Blue", "material": "Food Grade Plastic", "layers": "3 Layer", "warranty": "5 years", "uv_resistant": true}'::jsonb,
  false
),
(
  (SELECT id FROM public.categories WHERE name = 'Tanks'),
  'Overhead Tank 1000L - Black',
  'Large capacity overhead water tank. UV stabilized with anti-bacterial properties.',
  'TANK-1000-BLK',
  6500.00,
  7500.00,
  5800.00,
  15,
  ARRAY[
    'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=400&q=80',
  '{"capacity": "1000 liters", "color": "Black", "material": "Virgin Plastic", "layers": "4 Layer", "warranty": "7 years", "antibacterial": true}'::jsonb,
  false
),

-- Bathroom Fixtures
(
  (SELECT id FROM public.categories WHERE name = 'Bathroom'),
  'Wall Mounted Commode - White',
  'European style wall mounted commode. Water efficient dual flush system.',
  'BATH-COM-WHT-001',
  8500.00,
  10000.00,
  7500.00,
  12,
  ARRAY[
    'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=800&q=80',
    'https://images.unsplash.com/photo-1604328698692-f76ea9498e76?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=400&q=80',
  '{"type": "Wall Mounted", "color": "White", "flush_type": "Dual Flush", "water_consumption": "3/6 Liters", "warranty": "10 years"}'::jsonb,
  true
),
(
  (SELECT id FROM public.categories WHERE name = 'Bathroom'),
  'Shower Panel - Stainless Steel',
  'Multi-function shower panel with overhead rain shower, hand shower and body jets.',
  'BATH-SHW-SS-002',
  12000.00,
  15000.00,
  10500.00,
  8,
  ARRAY[
    'https://images.unsplash.com/photo-1604328698692-f76ea9498e76?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1604328698692-f76ea9498e76?w=400&q=80',
  '{"material": "Stainless Steel", "functions": "Rain Shower + Hand Shower + Body Jets", "finish": "Brushed", "warranty": "2 years"}'::jsonb,
  true
),

-- Fittings
(
  (SELECT id FROM public.categories WHERE name = 'Fittings'),
  'PVC Elbow 90° - 2 inch',
  'PVC elbow fitting for 90 degree pipe connections. ISI marked.',
  'FIT-ELB-2-90',
  45.00,
  60.00,
  38.00,
  500,
  ARRAY[
    'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400&q=80',
  '{"material": "PVC", "angle": "90°", "diameter": "2 inch", "standard": "ISI"}'::jsonb,
  false
),
(
  (SELECT id FROM public.categories WHERE name = 'Fittings'),
  'Brass Compression Fitting Set',
  'Set of 10 brass compression fittings. Corrosion resistant.',
  'FIT-BRS-COMP-10',
  850.00,
  1000.00,
  750.00,
  80,
  ARRAY[
    'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=400&q=80',
  '{"material": "Brass", "quantity": "10 pcs", "type": "Compression", "sizes": "1/2, 3/4, 1 inch"}'::jsonb,
  false
),

-- Tools
(
  (SELECT id FROM public.categories WHERE name = 'Tools'),
  'Plumber Tool Kit - 12 Pieces',
  'Professional plumber tool kit with wrench, pliers, tape and essential tools.',
  'TOOL-KIT-12',
  2500.00,
  3000.00,
  2200.00,
  25,
  ARRAY[
    'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=800&q=80',
    'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=400&q=80',
  '{"pieces": "12", "includes": "Wrench, Pliers, Tape, Cutter, Level", "warranty": "1 year", "case": "Plastic Tool Box"}'::jsonb,
  false
),
(
  (SELECT id FROM public.categories WHERE name = 'Tools'),
  'Pipe Wrench - 14 inch',
  'Heavy duty pipe wrench for gripping and turning pipes. Drop forged steel.',
  'TOOL-WRENCH-14',
  680.00,
  850.00,
  600.00,
  40,
  ARRAY[
    'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800&q=80'
  ],
  'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=400&q=80',
  '{"size": "14 inch", "material": "Drop Forged Steel", "jaw_capacity": "2 inch", "handle": "Cushion Grip"}'::jsonb,
  false
);

-- Sample Dealer (for testing - normally synced from Zoho)
INSERT INTO public.users (
  id, phone_number, role, full_name, email,
  dealer_verified, credit_limit, credit_30_days_enabled, credit_90_days_enabled
) VALUES
(
  gen_random_uuid(),
  '9876543210',
  'dealer',
  'Test Dealer',
  'dealer@example.com',
  true,
  100000.00,
  true,
  false
);

-- Sample Plumber
INSERT INTO public.users (
  id, phone_number, role, full_name,
  plumber_verified, expertise_area
) VALUES
(
  gen_random_uuid(),
  '9988776655',
  'plumber',
  'Test Plumber',
  true,
  ARRAY['Residential', 'Commercial']
);
