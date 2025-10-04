-- ============================================
-- Artha Database Setup Script for Supabase
-- ============================================
-- This script creates all tables, indexes, and sample data
-- Note: auth.users is managed by Supabase - do NOT create it

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. PROFILES TABLE (Extends auth.users)
-- ============================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username VARCHAR(255) UNIQUE,
    full_name VARCHAR(255),
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create trigger to automatically create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, created_at, updated_at)
    VALUES (NEW.id, NOW(), NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 2. CATEGORIES TABLE
-- ============================================
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 3. LABELS TABLE
-- ============================================
CREATE TABLE labels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    color BIGINT, -- Flutter colors are 32-bit unsigned (0 to 4,294,967,295)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, name)
);

-- ============================================
-- 4. WALLETS TABLE
-- ============================================
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    wallet_type VARCHAR(50) NOT NULL, -- 'manualInput' or 'investment'
    color BIGINT NOT NULL, -- Flutter colors are 32-bit unsigned (0 to 4,294,967,295)
    initial_value DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    account_number VARCHAR(255),
    account_type VARCHAR(100), -- 'Bank Account', 'E-Wallet', 'Cash', etc.
    asset_type VARCHAR(50), -- 'stocks' or 'crypto' for investment wallets
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, name)
);

-- ============================================
-- 5. WALLET RECORDS TABLE
-- ============================================
CREATE TABLE wallet_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    record_type VARCHAR(50) NOT NULL, -- 'income', 'expense', 'transfer'
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    transfer_to_wallet_id UUID REFERENCES wallets(id) ON DELETE SET NULL,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    date_time TIMESTAMPTZ NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 6. WALLET RECORD LABELS (Junction Table)
-- ============================================
CREATE TABLE wallet_record_labels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_record_id UUID NOT NULL REFERENCES wallet_records(id) ON DELETE CASCADE,
    label_id UUID NOT NULL REFERENCES labels(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (wallet_record_id, label_id)
);

-- ============================================
-- 7. TEMPLATES TABLE
-- ============================================
CREATE TABLE templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    record_type VARCHAR(50) NOT NULL, -- 'income', 'expense', 'transfer'
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    wallet_id UUID REFERENCES wallets(id) ON DELETE SET NULL,
    transfer_to_wallet_id UUID REFERENCES wallets(id) ON DELETE SET NULL,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, name)
);

-- ============================================
-- 8. TEMPLATE LABELS (Junction Table)
-- ============================================
CREATE TABLE template_labels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id UUID NOT NULL REFERENCES templates(id) ON DELETE CASCADE,
    label_id UUID NOT NULL REFERENCES labels(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (template_id, label_id)
);

-- ============================================
-- 9. DEBTS TABLE
-- ============================================
CREATE TABLE debts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    debt_type VARCHAR(50) NOT NULL, -- 'iLent' or 'iOwe'
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    original_amount DECIMAL(15, 2) NOT NULL CHECK (original_amount > 0),
    current_amount DECIMAL(15, 2) NOT NULL CHECK (current_amount >= 0),
    date_created TIMESTAMPTZ NOT NULL,
    due_date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 10. DEBT RECORDS TABLE
-- ============================================
CREATE TABLE debt_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    debt_id UUID NOT NULL REFERENCES debts(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL, -- 'repay' or 'increaseDebt'
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    date_time TIMESTAMPTZ NOT NULL,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_wallets_user ON wallets(user_id);
CREATE INDEX idx_wallet_records_wallet ON wallet_records(wallet_id);
CREATE INDEX idx_wallet_records_date ON wallet_records(date_time DESC);
CREATE INDEX idx_wallet_records_category ON wallet_records(category_id);
CREATE INDEX idx_wallet_records_transfer ON wallet_records(transfer_to_wallet_id);
CREATE INDEX idx_wallet_record_labels_record ON wallet_record_labels(wallet_record_id);
CREATE INDEX idx_wallet_record_labels_label ON wallet_record_labels(label_id);
CREATE INDEX idx_labels_user ON labels(user_id);
CREATE INDEX idx_templates_user ON templates(user_id);
CREATE INDEX idx_template_labels_template ON template_labels(template_id);
CREATE INDEX idx_template_labels_label ON template_labels(label_id);
CREATE INDEX idx_debts_user ON debts(user_id);
CREATE INDEX idx_debts_wallet ON debts(wallet_id);
CREATE INDEX idx_debt_records_debt ON debt_records(debt_id);
CREATE INDEX idx_debt_records_date ON debt_records(date_time DESC);

-- ============================================
-- MASTER DATA: CATEGORIES
-- ============================================
INSERT INTO categories (name) VALUES
    ('Food & Dining'),
    ('Transportation'),
    ('Shopping'),
    ('Groceries'),
    ('Entertainment'),
    ('Bills & Utilities'),
    ('Healthcare'),
    ('Education'),
    ('Salary'),
    ('Freelance Income'),
    ('Investment Returns'),
    ('Gift Received'),
    ('Debt Repayment'),
    ('Debt Increase'),
    ('Transfer'),
    ('Rent'),
    ('Insurance'),
    ('Fitness & Sports'),
    ('Travel'),
    ('Personal Care'),
    ('Clothing'),
    ('Electronics'),
    ('Home & Garden'),
    ('Pets'),
    ('Charity & Donations'),
    ('Subscriptions'),
    ('Business Expenses'),
    ('Taxes'),
    ('Other Income'),
    ('Other Expense');

-- ============================================
-- SAMPLE DATA (Requires existing auth user)
-- ============================================
-- Note: Replace 'YOUR_USER_ID_HERE' with an actual UUID from auth.users
-- You can get this after signing up a user through Supabase Auth

-- For testing, we'll use a placeholder variable
-- In production, you would replace this with the actual user ID after signup
DO $$
DECLARE
    sample_user_id UUID := '00000000-0000-0000-0000-000000000000'; -- Replace with real user ID
    sample_wallet_id UUID;
    sample_wallet_id_2 UUID;
    sample_category_id UUID;
    sample_label_id UUID;
    sample_record_id UUID;
    sample_template_id UUID;
    sample_debt_id UUID;
BEGIN
    -- NOTE: This is sample data structure
    -- You need to replace sample_user_id with a real UUID from auth.users
    -- Run this block AFTER creating your first user via Supabase Auth

    -- Get sample category ID
    SELECT id INTO sample_category_id FROM categories WHERE name = 'Food & Dining' LIMIT 1;

    -- SAMPLE: Insert a wallet
    INSERT INTO wallets (id, user_id, name, wallet_type, color, initial_value, account_type)
    VALUES (uuid_generate_v4(), sample_user_id, 'BCA Checking', 'manualInput', 255, 1000000.00, 'Bank Account')
    RETURNING id INTO sample_wallet_id;

    -- SAMPLE: Insert second wallet for transfer example
    INSERT INTO wallets (id, user_id, name, wallet_type, color, initial_value, account_type)
    VALUES (uuid_generate_v4(), sample_user_id, 'Cash', 'manualInput', 8421504, 500000.00, 'Cash')
    RETURNING id INTO sample_wallet_id_2;

    -- SAMPLE: Insert a label
    INSERT INTO labels (id, user_id, name, color)
    VALUES (uuid_generate_v4(), sample_user_id, 'Important', 16711680)
    RETURNING id INTO sample_label_id;

    -- SAMPLE: Insert a wallet record
    INSERT INTO wallet_records (id, record_type, category_id, wallet_id, amount, date_time, note)
    VALUES (uuid_generate_v4(), 'expense', sample_category_id, sample_wallet_id, 50000.00, NOW(), 'Lunch at restaurant')
    RETURNING id INTO sample_record_id;

    -- SAMPLE: Link label to wallet record
    INSERT INTO wallet_record_labels (wallet_record_id, label_id)
    VALUES (sample_record_id, sample_label_id);

    -- SAMPLE: Insert a template
    INSERT INTO templates (id, user_id, name, record_type, category_id, wallet_id, amount, note)
    VALUES (uuid_generate_v4(), sample_user_id, 'Monthly Salary', 'income', sample_category_id, sample_wallet_id, 10000000.00, 'Monthly salary deposit')
    RETURNING id INTO sample_template_id;

    -- SAMPLE: Link label to template
    INSERT INTO template_labels (template_id, label_id)
    VALUES (sample_template_id, sample_label_id);

    -- SAMPLE: Insert a debt
    INSERT INTO debts (id, user_id, debt_type, name, description, wallet_id, original_amount, current_amount, date_created, due_date)
    VALUES (uuid_generate_v4(), sample_user_id, 'iLent', 'John Doe', 'Borrowed for business', sample_wallet_id, 500000.00, 500000.00, NOW(), NOW() + INTERVAL '30 days')
    RETURNING id INTO sample_debt_id;

    -- SAMPLE: Insert a debt record (repayment)
    INSERT INTO debt_records (debt_id, action, wallet_id, amount, date_time, note)
    VALUES (sample_debt_id, 'repay', sample_wallet_id, 100000.00, NOW(), 'First payment received');

    RAISE NOTICE 'Sample data inserted successfully!';
    RAISE NOTICE 'Sample Wallet ID: %', sample_wallet_id;
    RAISE NOTICE 'Sample Label ID: %', sample_label_id;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Cannot insert sample data: No user found with ID %', sample_user_id;
        RAISE NOTICE 'Please create a user via Supabase Auth first, then run the sample data insert separately';
END $$;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to verify your setup:

-- Check all tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check categories count
SELECT COUNT(*) as total_categories FROM categories;

-- Check sample data (will be empty until you have a real user)
SELECT
    (SELECT COUNT(*) FROM wallets) as wallets_count,
    (SELECT COUNT(*) FROM wallet_records) as records_count,
    (SELECT COUNT(*) FROM labels) as labels_count,
    (SELECT COUNT(*) FROM templates) as templates_count,
    (SELECT COUNT(*) FROM debts) as debts_count;

-- ============================================
-- SCRIPT COMPLETE
-- ============================================
-- Next steps:
-- 1. Run this entire script in Supabase SQL Editor
-- 2. Sign up your first user via Supabase Auth
-- 3. Get the user ID from auth.users
-- 4. Run the sample data insert block with the real user ID
