# Supabase Database Setup

## Files in this directory:
1. **schema.sql** - Complete database schema with all tables, indexes, RLS policies
2. **sample_data.sql** - Sample data for testing
3. **ZOHO_INTEGRATION.md** - Zoho Workbook API integration guide

## How to Setup

### Step 1: Run Schema
1. Go to your Supabase project: https://supabase.com/dashboard
2. Navigate to **SQL Editor**
3. Copy contents of `schema.sql`
4. Paste and click **Run**

### Step 2: Add Sample Data (Optional)
1. Copy contents of `sample_data.sql`
2. Paste in SQL Editor
3. Click **Run**

### Step 3: Configure Zoho Integration
1. Read `ZOHO_INTEGRATION.md`
2. Create Zoho API credentials
3. Set up Zoho Workbooks with required structure
4. Add credentials to `.env` file

## Database Tables Overview

### Core Tables:
- **users** - User profiles (extends Supabase Auth)
- **categories** - Product categories
- **products** - Product catalog with pricing and stock
- **cart_items** - Shopping cart
- **orders** - Order management
- **order_items** - Order line items
- **plumber_jobs** - Job assignments for plumbers
- **notifications** - User notifications
- **zoho_sync_log** - Zoho synchronization logs

### Key Features:
✅ Row Level Security (RLS) enabled on all tables
✅ Automatic timestamp updates
✅ Order number auto-generation
✅ Optimized indexes for performance
✅ JSON support for flexible specifications
✅ Zoho integration fields

## Important Notes

1. **User Roles**: customer, dealer, plumber, admin
2. **Order Statuses**: pending, confirmed, processing, shipped, delivered, cancelled, refunded
3. **Payment Methods**: online, cod, credit_30, credit_90
4. **Dealer Credit**: Managed via credit_limit, credit_30_days_enabled, credit_90_days_enabled

## Next Steps

After database setup:
1. Test authentication with Supabase
2. Build API services in Flutter app
3. Implement Zoho sync logic
4. Test product catalog
5. Build shopping cart
6. Implement checkout flow
