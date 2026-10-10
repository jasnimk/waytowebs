# Way to Webs - Quick Start Guide (For APK Testing)

## 📱 Install APK

1. Download the APK file from the email attachment
2. Install on your Android device
3. Open the app

**That's it!** The app is already configured and ready to use.

---

## 👥 Test Users (Login Ready)

**All users use OTP: `123456`**

### 📱 How to Login

1. Open the app
2. **Select your role** (Customer/Dealer/Plumber/Admin)
3. Enter phone number (from table below)
4. Enter OTP: **123456**
5. Click "Verify OTP"

### Test Accounts

| Role | Phone Number | Features to Test |
|------|--------------|------------------|
| **Customer** | 9995343268 | Browse products, add to cart, checkout, track orders |
| **Dealer (30-day)** | 9999000001 | Wholesale prices, stock visibility, 30-day credit payment |
| **Dealer (90-day)** | 9999000002 | All dealer features + 90-day credit option |
| **Plumber** | 9999000004 | Job management, mark jobs complete, product catalog |
| **Admin** | 9999000005 | User management, product sync, orders, payments, reports |

---

## ✨ What to Test

### 🛒 Customer Flow (Phone: 9995343268)
1. Login with customer role
2. Browse categories and products
3. View product details (notice: **no stock quantity visible**)
4. Add products to cart
5. Go to checkout
6. Place order (COD or Online Payment)
7. Track order status
8. View order history

### 🏢 Dealer Flow (Phone: 9999000001 or 9999000002)
1. Login with dealer role
2. Dashboard shows business stats
3. View products (notice: **dealer prices shown**)
4. View products (notice: **stock quantity IS visible**)
5. Add to cart
6. Checkout with payment options:
   - Upfront Payment
   - 30-day Credit (both dealers)
   - 90-day Credit (only 9999000002 - has "Approved" badge)
7. View order history

### 🔧 Plumber Flow (Phone: 9999000004)
1. Login with plumber role
2. Dashboard shows assigned jobs
3. View tabs: Active, Scheduled, Completed
4. Click on an active job
5. Click "Mark as Complete"
6. Job moves to Completed tab
7. Browse product catalog

### 👨‍💼 Admin Flow (Phone: 9999000005)
1. Login with admin role
2. Dashboard with system overview
3. **Users Management**:
   - View all users
   - Create new user
   - Edit user credit settings
   - Enable/disable 30-day or 90-day credit
4. **Products Management**:
   - View all products
   - Click "Sync from Zoho" button
   - View Zoho integration info
5. **Orders Management**: View all orders
6. **Payments**: Track payment status
7. **Reports**: View analytics

---

## 🎯 Key Features to Notice

### Role-Based Access
- ✅ Each role has unique dashboard
- ✅ Different navigation options per role
- ✅ Specific features per user type

### Customer vs Dealer
| Feature | Customer | Dealer |
|---------|----------|--------|
| Product Price | Regular price | Wholesale/dealer price |
| Stock Visibility | ❌ Hidden | ✅ Visible |
| Payment | COD, Online | Upfront, 30-day, 90-day credit |
| Bulk Orders | No | Yes |

### Zoho Integration
- ✅ Admin can sync products from Zoho Books
- ✅ Dealer verification (already configured)
- ✅ Credit settings synced from Zoho CRM

### Credit System
- **9999000001**: 30-day credit only
- **9999000002**: 30-day + 90-day credit (shows "Approved" badge)
- Admin can enable/disable credit for any dealer

---

## 📱 Screenshots to Take

1. **Login Screen** - Role selection
2. **Customer Dashboard** - Product catalog
3. **Dealer Dashboard** - With stock quantity visible
4. **Dealer Checkout** - Showing 30-day/90-day credit options
5. **Plumber Jobs** - Active/Scheduled/Completed tabs
6. **Admin Dashboard** - User management
7. **Admin Products** - Zoho sync button

---

## 🐛 Troubleshooting

### Login not working?
- Make sure you selected the correct role before entering phone number
- OTP is: **123456**

### Can't see features?
- Check you're logged in with the correct role
- Customer cannot see stock, Dealer can

### App crashes?
- The app is connected to live Supabase database
- All data is already loaded
- Just install APK and login

---

## 📧 Questions?

Contact: support@waytowebs.com

---

## 🎉 Ready to Test!

Just install the APK and login with any test user above. Everything is already set up and ready to go!

**No setup required. No configuration needed. Just install and test!**

---

**Built with Flutter** ❤️
