# Way to Webs - Plumbing E-Commerce App

A comprehensive multi-role Flutter e-commerce application for plumbing supplies with integrated Zoho CRM and Books sync.

## 🎯 Overview

This application provides a complete e-commerce solution with four distinct user roles:
- **Customer**: Browse products, place orders, track deliveries
- **Dealer**: Access wholesale pricing, credit payment options, bulk ordering
- **Plumber**: Manage jobs, view product catalog, track assignments
- **Admin**: Complete management dashboard for users, products, orders, payments, and reports

## ✨ Features

### Authentication
- ✅ OTP-based login (no passwords)
- ✅ Role-based access control
- ✅ Zoho CRM integration for dealer verification
- ✅ Automatic session management

### Customer Features
- ✅ Browse products by categories
- ✅ Search and filter products
- ✅ Product details with image gallery
- ✅ Shopping cart with quantity management
- ✅ Checkout with direct payment
- ✅ Order tracking and history
- ✅ Profile management

### Dealer Features
- ✅ Zoho CRM verification on login
- ✅ Wholesale pricing display
- ✅ Stock quantity visibility
- ✅ Multiple payment options:
  - Upfront payment
  - 30-day credit (if approved)
  - 90-day credit (for selected dealers)
- ✅ Credit limit tracking
- ✅ Order history with credit status

### Plumber Features
- ✅ Job management dashboard
- ✅ Active, Scheduled, and Completed job views
- ✅ Product catalog access
- ✅ Job completion workflow
- ✅ Profile and notifications

### Admin Features
- ✅ User management (Customers, Dealers, Plumbers)
- ✅ Product management with Zoho Books sync
- ✅ Order management and tracking
- ✅ Payment tracking and verification
- ✅ Dealer credit eligibility management
- ✅ Credit permissions (30-day/90-day)
- ✅ Reports and analytics

### Zoho Integration
- ✅ **Zoho CRM**: Dealer verification, credit settings sync
- ✅ **Zoho Books**: Product catalog sync, pricing, stock levels
- ✅ OAuth token management with auto-refresh
- ✅ India data center support (zoho.in)

## 🛠️ Tech Stack

- **Framework**: Flutter 3.11.0
- **Language**: Dart 3.5.4
- **State Management**: Provider
- **Backend**: Supabase (PostgreSQL)
- **External APIs**: Zoho CRM & Books
- **Authentication**: Supabase Auth + OTP

## 📋 Prerequisites

- Flutter SDK 3.11.0 or higher
- Dart SDK 3.5.4 or higher
- Android Studio / Xcode (for mobile development)
- Supabase account
- Zoho CRM & Books account

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd way_to_webs
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

Update `lib/core/config/supabase_config.dart` with your Supabase credentials:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 4. Set Up Database

Execute the following SQL scripts in your Supabase SQL Editor (in order):

1. **Schema**: `supabase/schema.sql` - Creates all tables and relationships
2. **Sample Data**: `supabase/sample_data.sql` - Adds test products and categories
3. **Plumber Jobs**: `supabase/plumber_dummy_data.sql` - Adds sample plumber jobs

### 5. Configure Test OTP (Optional)

In Supabase Dashboard → Authentication → Providers → Phone, add test numbers:
```
9995343268=123456,9999000001=123456,9999000002=123456,9999000004=123456,9999000005=123456
```

### 6. Run the Application

```bash
flutter run
```

## 👥 Test Users

Test users are created through OTP authentication. Use these phone numbers to login:

### Customer
- **Phone**: Any 10-digit number (auto-creates customer account)
- **OTP**: Check Supabase Auth logs or use the OTP sent to the number

### Dealer
- **Phone**: `9876543210`
- **Role**: Dealer
- **Credit**: 30-day credit enabled
- **Credit Limit**: ₹100,000
- **Note**: Must be verified in Zoho CRM

### Plumber
- **Phone**: `9988776655`
- **Role**: Plumber
- **Verified**: Yes
- **Expertise**: Residential, Commercial

### Admin
- **Phone**: `1234567890`
- **Role**: Admin
- **Access**: Full system access

### Creating Test Users in Supabase

Users are automatically created when they complete OTP login. To manually create users:

1. Go to Supabase Dashboard → Authentication → Users
2. Click "Invite user" or use SQL:

```sql
-- Create a test user
INSERT INTO public.users (
  phone_number, role, full_name, email,
  dealer_verified, credit_30_days_enabled, credit_90_days_enabled
) VALUES (
  '1234567890',
  'customer',
  'Test Customer',
  'customer@example.com',
  false,
  false,
  false
);
```

## 📱 App Structure

```
lib/
├── core/               # Core configurations, theme, routing
├── features/          # Feature-based modules
│   ├── admin/        # Admin dashboard and management
│   ├── auth/         # Authentication & OTP
│   ├── customer/     # Customer features
│   ├── dealer/       # Dealer features
│   ├── plumber/      # Plumber features
│   └── shared/       # Shared widgets & utilities
└── services/         # External services (Zoho)
```

## 🔐 Security Notes

- Zoho credentials are hardcoded in `lib/services/zoho/zoho_service.dart` for testing
- Supabase RLS (Row Level Security) is configured per role
- Zoho OAuth tokens auto-refresh every hour
- OTP-based authentication only (no password storage)

**Note:** For production, move Zoho credentials to environment variables or secure storage.

## 🐛 Troubleshooting

### OTP not received
- Check Supabase Auth settings
- Verify phone number format (10 digits)
- Check Supabase Auth logs

### Zoho integration not working
- Verify refresh token is valid (regenerate if needed)
- Check organization ID in Zoho Books
- Ensure dealer exists in Zoho CRM

### Build issues
```bash
flutter clean
flutter pub get
flutter run
```

## 📄 License

Proprietary - Way to Webs Interview Task

## 📞 Support

For any issues or questions, contact: support@waytowebs.com

---

**Built with Flutter** ❤️
