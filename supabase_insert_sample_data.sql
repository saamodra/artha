-- ============================================
-- INSERT SAMPLE DATA FOR ARTHA
-- ============================================
-- Run this AFTER you have signed up a user via Supabase Auth
-- Replace 'YOUR_USER_ID_HERE' with your actual user ID from auth.users

-- To get your user ID, run this query first:
-- SELECT id, email FROM auth.users;

DO $$
DECLARE
    -- ⚠️ REPLACE THIS WITH YOUR ACTUAL USER ID FROM auth.users
    sample_user_id UUID := 'ec292560-c2ec-414a-b721-f94e37263c39';

    -- Variables for storing created IDs
    wallet_bca UUID;
    wallet_cash UUID;
    wallet_gopay UUID;
    category_food UUID;
    category_transport UUID;
    category_salary UUID;
    label_important UUID;
    label_recurring UUID;
    label_business UUID;
    record_lunch UUID;
    record_transport UUID;
    template_salary UUID;
    debt_john UUID;
BEGIN
    -- Verify user exists
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = sample_user_id) THEN
        RAISE EXCEPTION 'User ID % not found in auth.users. Please update sample_user_id variable with a valid user ID.', sample_user_id;
    END IF;

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Creating sample data for user: %', sample_user_id;
    RAISE NOTICE '========================================';

    -- Clean up any existing sample data for this user
    -- (In case script is run multiple times)
    RAISE NOTICE 'Cleaning up existing sample data...';
    DELETE FROM debt_records WHERE debt_id IN (SELECT id FROM debts WHERE user_id = sample_user_id);
    DELETE FROM debts WHERE user_id = sample_user_id;
    DELETE FROM template_labels WHERE template_id IN (SELECT id FROM templates WHERE user_id = sample_user_id);
    DELETE FROM templates WHERE user_id = sample_user_id;
    DELETE FROM wallet_record_labels WHERE wallet_record_id IN (
        SELECT wr.id FROM wallet_records wr
        JOIN wallets w ON wr.wallet_id = w.id
        WHERE w.user_id = sample_user_id
    );
    DELETE FROM wallet_records WHERE wallet_id IN (SELECT id FROM wallets WHERE user_id = sample_user_id);
    DELETE FROM wallets WHERE user_id = sample_user_id;
    DELETE FROM labels WHERE user_id = sample_user_id;
    RAISE NOTICE '✓ Cleanup complete';
    RAISE NOTICE '';

    -- Get category IDs
    SELECT id INTO category_food FROM categories WHERE name = 'Food & Dining' LIMIT 1;
    SELECT id INTO category_transport FROM categories WHERE name = 'Transportation' LIMIT 1;
    SELECT id INTO category_salary FROM categories WHERE name = 'Salary' LIMIT 1;

    -- ============================================
    -- 1. CREATE SAMPLE LABELS
    -- ============================================
    RAISE NOTICE 'Creating labels...';

    -- Insert labels individually to capture each ID
    INSERT INTO labels (user_id, name, color)
    VALUES (sample_user_id, 'Important', 16711680) -- Red
    RETURNING id INTO label_important;

    INSERT INTO labels (user_id, name, color)
    VALUES (sample_user_id, 'Recurring', 255) -- Blue
    RETURNING id INTO label_recurring;

    INSERT INTO labels (user_id, name, color)
    VALUES (sample_user_id, 'Business', 65280) -- Green
    RETURNING id INTO label_business;

    RAISE NOTICE '✓ Created 3 labels';

    -- ============================================
    -- 2. CREATE SAMPLE WALLETS
    -- ============================================
    RAISE NOTICE 'Creating wallets...';

    -- BCA Checking Account
    INSERT INTO wallets (user_id, name, wallet_type, color, initial_value, account_number, account_type, display_order)
    VALUES (sample_user_id, 'BCA Checking', 'manualInput', 4280091135, 5000000.00, '1234567890', 'Bank Account', 1)
    RETURNING id INTO wallet_bca;

    -- Cash Wallet
    INSERT INTO wallets (user_id, name, wallet_type, color, initial_value, account_type, display_order)
    VALUES (sample_user_id, 'Cash', 'manualInput', 4287137928, 500000.00, 'Cash', 2)
    RETURNING id INTO wallet_cash;

    -- GoPay E-Wallet
    INSERT INTO wallets (user_id, name, wallet_type, color, initial_value, account_type, display_order)
    VALUES (sample_user_id, 'GoPay', 'manualInput', 4294198070, 250000.00, 'E-Wallet', 3)
    RETURNING id INTO wallet_gopay;

    RAISE NOTICE '✓ Created 3 wallets';

    -- ============================================
    -- 3. CREATE SAMPLE WALLET RECORDS
    -- ============================================
    RAISE NOTICE 'Creating wallet records...';

    -- Expense: Lunch
    INSERT INTO wallet_records (record_type, category_id, wallet_id, amount, date_time, note)
    VALUES ('expense', category_food, wallet_cash, 50000.00, NOW() - INTERVAL '1 day', 'Lunch at Padang restaurant')
    RETURNING id INTO record_lunch;

    -- Expense: Transportation
    INSERT INTO wallet_records (record_type, category_id, wallet_id, amount, date_time, note)
    VALUES ('expense', category_transport, wallet_gopay, 25000.00, NOW() - INTERVAL '2 hours', 'GoJek to office')
    RETURNING id INTO record_transport;

    -- Income: Salary
    INSERT INTO wallet_records (record_type, category_id, wallet_id, amount, date_time, note)
    VALUES ('income', category_salary, wallet_bca, 10000000.00, NOW() - INTERVAL '5 days', 'Monthly salary');

    -- Transfer: BCA to Cash
    INSERT INTO wallet_records (record_type, category_id, wallet_id, transfer_to_wallet_id, amount, date_time, note)
    VALUES ('transfer', (SELECT id FROM categories WHERE name = 'Transfer'), wallet_bca, wallet_cash, 1000000.00, NOW() - INTERVAL '3 days', 'Cash withdrawal');

    RAISE NOTICE '✓ Created 4 wallet records';

    -- ============================================
    -- 4. LINK LABELS TO WALLET RECORDS
    -- ============================================
    RAISE NOTICE 'Linking labels to records...';

    INSERT INTO wallet_record_labels (wallet_record_id, label_id) VALUES
        (record_lunch, label_business),
        (record_transport, label_recurring);

    RAISE NOTICE '✓ Linked labels to records';

    -- ============================================
    -- 5. CREATE SAMPLE TEMPLATES
    -- ============================================
    RAISE NOTICE 'Creating templates...';

    -- Template: Monthly Salary
    INSERT INTO templates (user_id, name, record_type, category_id, wallet_id, amount, note)
    VALUES (sample_user_id, 'Monthly Salary', 'income', category_salary, wallet_bca, 10000000.00, 'Salary deposit every month')
    RETURNING id INTO template_salary;

    -- Template: Daily Lunch
    INSERT INTO templates (user_id, name, record_type, category_id, wallet_id, amount, note)
    VALUES (sample_user_id, 'Daily Lunch', 'expense', category_food, wallet_cash, 30000.00, 'Average lunch expense');

    RAISE NOTICE '✓ Created 2 templates';

    -- ============================================
    -- 6. LINK LABELS TO TEMPLATES
    -- ============================================
    RAISE NOTICE 'Linking labels to templates...';

    INSERT INTO template_labels (template_id, label_id) VALUES
        (template_salary, label_recurring),
        (template_salary, label_important);

    RAISE NOTICE '✓ Linked labels to templates';

    -- ============================================
    -- 7. CREATE SAMPLE DEBT
    -- ============================================
    RAISE NOTICE 'Creating debts...';

    -- Debt: Money lent to friend
    INSERT INTO debts (user_id, debt_type, name, description, wallet_id, original_amount, current_amount, date_created, due_date)
    VALUES (sample_user_id, 'iLent', 'John Doe', 'Borrowed for business capital', wallet_bca, 2000000.00, 1500000.00, NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days')
    RETURNING id INTO debt_john;

    RAISE NOTICE '✓ Created 1 debt';

    -- ============================================
    -- 8. CREATE SAMPLE DEBT RECORDS
    -- ============================================
    RAISE NOTICE 'Creating debt records...';

    -- Debt Record: First repayment
    INSERT INTO debt_records (debt_id, action, wallet_id, amount, date_time, note)
    VALUES (debt_john, 'repay', wallet_bca, 500000.00, NOW() - INTERVAL '5 days', 'First installment payment');

    RAISE NOTICE '✓ Created 1 debt record';

    -- ============================================
    -- SUMMARY
    -- ============================================
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Sample data created successfully!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Summary:';
    RAISE NOTICE '- Labels: 3';
    RAISE NOTICE '- Wallets: 3';
    RAISE NOTICE '- Wallet Records: 4';
    RAISE NOTICE '- Templates: 2';
    RAISE NOTICE '- Debts: 1';
    RAISE NOTICE '- Debt Records: 1';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'You can now test your Flutter app with this data!';

END $$;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to see your sample data:

-- View all wallets
SELECT id, name, wallet_type, initial_value, account_type
FROM wallets
ORDER BY created_at;

-- View all wallet records with details
SELECT
    wr.id,
    wr.record_type,
    c.name as category,
    w.name as wallet,
    wr.amount,
    wr.date_time,
    wr.note
FROM wallet_records wr
JOIN categories c ON wr.category_id = c.id
JOIN wallets w ON wr.wallet_id = w.id
ORDER BY wr.date_time DESC;

-- View all labels
SELECT id, name, color
FROM labels
ORDER BY name;

-- View all templates
SELECT
    t.id,
    t.name,
    t.record_type,
    c.name as category,
    t.amount
FROM templates t
JOIN categories c ON t.category_id = c.id
ORDER BY t.name;

-- View all debts
SELECT
    d.id,
    d.debt_type,
    d.name,
    d.original_amount,
    d.current_amount,
    d.due_date,
    w.name as wallet
FROM debts d
JOIN wallets w ON d.wallet_id = w.id
ORDER BY d.created_at;

-- Calculate total balance across all wallets
SELECT
    SUM(initial_value) as total_balance
FROM wallets;
