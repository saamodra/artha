# Artha Database Setup Guide

## 📋 Overview

This guide will help you set up your Supabase database for the Artha finance app.

---

## 🚀 Quick Start

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in:
   - **Name**: artha
   - **Database Password**: (save this!)
   - **Region**: Choose closest to you
4. Wait 2-3 minutes for setup

### Step 2: Run Main Setup Script

1. In Supabase Dashboard → **SQL Editor**
2. Click "New Query"
3. Copy entire contents of `supabase_setup.sql`
4. Click **Run** (or press Cmd/Ctrl + Enter)

✅ This creates:
- All 11 tables (profiles, wallets, categories, labels, etc.)
- All indexes for performance
- **30 master categories** (pre-populated)
- Database triggers for auto-creating profiles

### Step 3: Sign Up Your First User

1. In Supabase Dashboard → **Authentication** → **Users**
2. Click "Add User" → "Create new user"
3. Enter:
   - **Email**: your-email@example.com
   - **Password**: (your password)
4. Click "Create User"
5. **Copy the User ID** (UUID format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

### Step 4: Insert Sample Data (Optional)

1. Open `supabase_insert_sample_data.sql`
2. **Replace** `'YOUR_USER_ID_HERE'` with your actual User ID from Step 3
3. Copy entire script
4. Paste in Supabase **SQL Editor**
5. Click **Run**

✅ This creates sample data:
- 3 wallets (BCA Checking, Cash, GoPay)
- 3 labels (Important, Recurring, Business)
- 4 wallet records (expenses, income, transfer)
- 2 templates (Monthly Salary, Daily Lunch)
- 1 debt (Money lent to friend)
- 1 debt record (repayment)

---

## 📊 What Gets Created

### Tables Created (11 total)

| # | Table Name | Purpose | Records |
|---|------------|---------|---------|
| 1 | `profiles` | User profile extension | Created via trigger |
| 2 | `categories` | Transaction categories | **30 pre-populated** |
| 3 | `labels` | Custom tags | Sample: 3 |
| 4 | `wallets` | Financial accounts | Sample: 3 |
| 5 | `wallet_records` | Transactions | Sample: 4 |
| 6 | `wallet_record_labels` | Record-Label links | Sample: 2 |
| 7 | `templates` | Transaction templates | Sample: 2 |
| 8 | `template_labels` | Template-Label links | Sample: 2 |
| 9 | `debts` | Money lent/owed | Sample: 1 |
| 10 | `debt_records` | Debt actions | Sample: 1 |

### Master Categories (30)

The following categories are automatically created:

**Income Categories:**
- Salary
- Freelance Income
- Investment Returns
- Gift Received
- Other Income

**Expense Categories:**
- Food & Dining
- Transportation
- Shopping
- Groceries
- Entertainment
- Bills & Utilities
- Healthcare
- Education
- Rent
- Insurance
- Fitness & Sports
- Travel
- Personal Care
- Clothing
- Electronics
- Home & Garden
- Pets
- Charity & Donations
- Subscriptions
- Business Expenses
- Taxes
- Other Expense

**Special Categories:**
- Transfer
- Debt Repayment
- Debt Increase

---

## 🔍 Verification Queries

Run these in SQL Editor to verify setup:

### Check All Tables Exist
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

### Count Categories
```sql
SELECT COUNT(*) as total_categories FROM categories;
-- Should return: 30
```

### View Sample Data
```sql
SELECT
    (SELECT COUNT(*) FROM wallets) as wallets,
    (SELECT COUNT(*) FROM wallet_records) as records,
    (SELECT COUNT(*) FROM labels) as labels,
    (SELECT COUNT(*) FROM templates) as templates,
    (SELECT COUNT(*) FROM debts) as debts;
```

### Get Your User ID
```sql
SELECT id, email, created_at FROM auth.users;
```

---

## 🛡️ Row Level Security (RLS)

After basic setup, you should enable RLS policies. Run this in SQL Editor:

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE labels ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_record_labels ENABLE ROW LEVEL SECURITY;
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE template_labels ENABLE ROW LEVEL SECURITY;
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE debt_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

-- Wallets policies
CREATE POLICY "Users can manage own wallets"
    ON wallets FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Wallet records policies
CREATE POLICY "Users can manage own wallet records"
    ON wallet_records FOR ALL
    USING (
        wallet_id IN (SELECT id FROM wallets WHERE user_id = auth.uid())
    );

-- Labels policies
CREATE POLICY "Users can manage own labels"
    ON labels FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Wallet record labels policies
CREATE POLICY "Users can manage labels on own records"
    ON wallet_record_labels FOR ALL
    USING (
        wallet_record_id IN (
            SELECT wr.id FROM wallet_records wr
            JOIN wallets w ON wr.wallet_id = w.id
            WHERE w.user_id = auth.uid()
        )
    );

-- Templates policies
CREATE POLICY "Users can manage own templates"
    ON templates FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Template labels policies
CREATE POLICY "Users can manage labels on own templates"
    ON template_labels FOR ALL
    USING (
        template_id IN (SELECT id FROM templates WHERE user_id = auth.uid())
    );

-- Debts policies
CREATE POLICY "Users can manage own debts"
    ON debts FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Debt records policies
CREATE POLICY "Users can manage records on own debts"
    ON debt_records FOR ALL
    USING (
        debt_id IN (SELECT id FROM debts WHERE user_id = auth.uid())
    );

-- Categories policies (read-only for all authenticated users)
CREATE POLICY "Authenticated users can view categories"
    ON categories FOR SELECT
    TO authenticated
    USING (true);
```

---

## 📝 Important Notes

### ⚠️ Do NOT Create `auth.users` Table
- Supabase manages this automatically
- You cannot and should not create it manually
- It's already there when you create your project

### 🔑 UUID vs Integer IDs
- All IDs use **UUID** (not integer)
- More secure (harder to guess)
- Better for distributed systems
- Example: `550e8400-e29b-41d4-a716-446655440000`

### 🔄 Profile Auto-Creation
- When a user signs up via Supabase Auth
- A profile is **automatically created** via database trigger
- You don't need to manually create profiles

### 🎨 Color Format
- Colors are stored as **integers**
- Flutter Color format: `0xFFRRGGBB`
- Example: Red = `0xFFFF0000` = `4294901760`

---

## 🧪 Testing Your Setup

### 1. Sign Up Test User
```dart
final response = await supabase.auth.signUp(
  email: 'test@example.com',
  password: 'your_password',
);
print('User ID: ${response.user!.id}');
```

### 2. Create a Wallet
```dart
await supabase.from('wallets').insert({
  'user_id': supabase.auth.currentUser!.id,
  'name': 'My Wallet',
  'wallet_type': 'manualInput',
  'color': 0xFF2196F3, // Blue
  'initial_value': 1000000.00,
  'account_type': 'Bank Account',
});
```

### 3. Fetch Categories
```dart
final categories = await supabase
    .from('categories')
    .select();
print('Total categories: ${categories.length}'); // Should be 30
```

---

## 📂 File Reference

- `supabase_setup.sql` - Main setup script (run first)
- `supabase_insert_sample_data.sql` - Sample data (run after signup)
- `ERD.md` - Complete database documentation
- `ERD.plantuml` - Visual diagram
- `AGENTS.md` - Architecture guidelines

---

## 🐛 Troubleshooting

### Error: "relation auth.users does not exist"
- **Cause**: Trying to create auth.users manually
- **Solution**: Remove any `CREATE TABLE auth.users` statements - it already exists

### Error: "foreign_key_violation"
- **Cause**: Sample data references non-existent user
- **Solution**: Update `sample_user_id` in insert script with real user ID

### Error: "duplicate key value"
- **Cause**: Running setup script multiple times
- **Solution**: Drop all tables first or create new project

### How to Reset Database
```sql
-- ⚠️ WARNING: This deletes ALL data!
DROP TABLE IF EXISTS debt_records CASCADE;
DROP TABLE IF EXISTS debts CASCADE;
DROP TABLE IF EXISTS template_labels CASCADE;
DROP TABLE IF EXISTS templates CASCADE;
DROP TABLE IF EXISTS wallet_record_labels CASCADE;
DROP TABLE IF EXISTS wallet_records CASCADE;
DROP TABLE IF EXISTS wallets CASCADE;
DROP TABLE IF EXISTS labels CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user CASCADE;
```

Then run `supabase_setup.sql` again.

---

## ✅ Checklist

- [ ] Created Supabase project
- [ ] Saved database password
- [ ] Ran `supabase_setup.sql`
- [ ] Verified 30 categories created
- [ ] Signed up first user via Supabase Auth
- [ ] Copied User ID
- [ ] Updated `supabase_insert_sample_data.sql` with real User ID
- [ ] Ran sample data script
- [ ] Enabled Row Level Security policies
- [ ] Tested queries work
- [ ] Ready to connect Flutter app!

---

## 🎯 Next Steps

1. ✅ **Database is ready!**
2. Add `supabase_flutter` package to Flutter
3. Initialize Supabase in `main.dart`
4. Create repository classes
5. Update models with UUID types
6. Test CRUD operations

See `AGENTS.md` for architecture guidelines.

---

**Database Setup Complete!** 🚀
