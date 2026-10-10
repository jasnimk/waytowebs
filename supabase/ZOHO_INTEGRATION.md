# Zoho Workbook Integration Guide

## Overview
This document explains how to integrate Zoho Workbook with the Way to Webs mobile app for:
- Product synchronization (name, price, stock)
- Dealer verification
- Order management

## Prerequisites

1. **Zoho Workbook Account**
   - Active Zoho Workbook subscription
   - Admin access to create/manage workbooks

2. **Zoho API Credentials**
   - Client ID
   - Client Secret
   - Organization ID
   - Workbook ID

## Setup Steps

### 1. Create Zoho API Application

1. Go to [Zoho API Console](https://api-console.zoho.com/)
2. Click "Add Client" → "Server-based Applications"
3. Fill in details:
   - Client Name: `Way to Webs Mobile App`
   - Homepage URL: `https://your-domain.com`
   - Authorized Redirect URIs: `https://your-domain.com/oauth/callback`
4. Note down:
   - Client ID
   - Client Secret

### 2. Zoho Workbook Structure

Create workbooks with these tables:

#### **Products Workbook**
Columns:
- `product_id` (Text) - Unique identifier
- `product_name` (Text)
- `category` (Text)
- `sku` (Text)
- `price` (Number)
- `mrp` (Number)
- `dealer_price` (Number)
- `stock_quantity` (Number)
- `description` (Long Text)
- `image_urls` (Text) - Comma-separated URLs
- `is_active` (Checkbox)
- `last_updated` (Date Time)

#### **Dealers Workbook**
Columns:
- `dealer_id` (Text)
- `phone_number` (Text)
- `full_name` (Text)
- `email` (Email)
- `is_verified` (Checkbox)
- `credit_limit` (Number)
- `credit_30_days` (Checkbox)
- `credit_90_days` (Checkbox)
- `registration_date` (Date)

#### **Orders Workbook**
Columns:
- `order_id` (Text)
- `order_number` (Text)
- `customer_phone` (Text)
- `customer_name` (Text)
- `order_date` (Date Time)
- `total_amount` (Number)
- `payment_method` (Text)
- `payment_status` (Text)
- `order_status` (Text)
- `items` (Long Text) - JSON string

## API Integration

### Authentication Flow

1. **Get Authorization Code**
```
https://accounts.zoho.com/oauth/v2/auth?
  response_type=code&
  client_id=YOUR_CLIENT_ID&
  scope=ZohoAnalytics.data.read,ZohoAnalytics.data.create,ZohoAnalytics.data.update&
  redirect_uri=YOUR_REDIRECT_URI&
  access_type=offline
```

2. **Exchange Code for Access Token**
```bash
POST https://accounts.zoho.com/oauth/v2/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&
client_id=YOUR_CLIENT_ID&
client_secret=YOUR_CLIENT_SECRET&
redirect_uri=YOUR_REDIRECT_URI&
code=AUTHORIZATION_CODE
```

3. **Refresh Access Token**
```bash
POST https://accounts.zoho.com/oauth/v2/token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&
client_id=YOUR_CLIENT_ID&
client_secret=YOUR_CLIENT_SECRET&
refresh_token=YOUR_REFRESH_TOKEN
```

### API Endpoints

#### 1. Fetch Products
```bash
GET https://analyticsapi.zoho.com/restapi/v2/bulk/workspaces/{workspace_id}/views/{view_id}/data
Headers:
  Authorization: Zoho-oauthtoken {access_token}
```

#### 2. Update Stock
```bash
POST https://analyticsapi.zoho.com/restapi/v2/bulk/workspaces/{workspace_id}/views/{view_id}/rows
Headers:
  Authorization: Zoho-oauthtoken {access_token}
Content-Type: application/json

{
  "updateColumn": "product_id",
  "updateValue": "PROD123",
  "columns": {
    "stock_quantity": 50
  }
}
```

#### 3. Verify Dealer
```bash
GET https://analyticsapi.zoho.com/restapi/v2/bulk/workspaces/{workspace_id}/views/{view_id}/data
Headers:
  Authorization: Zoho-oauthtoken {access_token}
Parameters:
  criteria: phone_number='9995343268'
```

#### 4. Create Order
```bash
POST https://analyticsapi.zoho.com/restapi/v2/bulk/workspaces/{workspace_id}/views/{view_id}/rows
Headers:
  Authorization: Zoho-oauthtoken {access_token}
Content-Type: application/json

{
  "rows": [
    {
      "order_id": "uuid",
      "order_number": "ORD-20261010-000001",
      "customer_phone": "9995343268",
      "total_amount": 5000,
      "order_status": "pending"
    }
  ]
}
```

## Sync Strategy

### 1. Products Sync (Every 6 hours)
- Fetch all active products from Zoho
- Compare with Supabase data
- Update/Insert changed products
- Log sync status

### 2. Stock Sync (Real-time after order)
- When order is placed, reduce stock in Supabase
- Push stock update to Zoho immediately
- Verify sync success

### 3. Dealer Verification (On Login)
- User enters phone number
- Check if dealer exists in Supabase
- If not found or verification needed, query Zoho
- Update Supabase with Zoho data

### 4. Order Sync (Real-time)
- Order created in Supabase
- Immediately push to Zoho
- Store Zoho order ID in Supabase

## Error Handling

1. **API Rate Limits**
   - Zoho allows ~200 requests/minute
   - Implement exponential backoff
   - Queue requests if limit reached

2. **Network Failures**
   - Retry up to 3 times with delay
   - Store failed syncs in `zoho_sync_log` table
   - Manual retry option in admin panel

3. **Data Conflicts**
   - Zoho data is source of truth for products/dealers
   - Supabase is source of truth for orders
   - Last-write-wins for conflicts

## Security

1. **Store credentials securely**
   - Use environment variables
   - Never commit tokens to git
   - Rotate refresh tokens periodically

2. **Validate data**
   - Sanitize all data from Zoho before inserting
   - Validate phone numbers, prices, quantities

3. **Audit logs**
   - Log all Zoho API calls
   - Track sync successes/failures
   - Monitor for anomalies

## Configuration File

Create `.env` file with:
```
ZOHO_CLIENT_ID=your_client_id
ZOHO_CLIENT_SECRET=your_client_secret
ZOHO_REFRESH_TOKEN=your_refresh_token
ZOHO_ORGANIZATION_ID=your_org_id
ZOHO_WORKSPACE_ID=your_workspace_id
ZOHO_PRODUCTS_VIEW_ID=products_view_id
ZOHO_DEALERS_VIEW_ID=dealers_view_id
ZOHO_ORDERS_VIEW_ID=orders_view_id
```
