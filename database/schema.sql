-- FlowCRM AI Production Database Schema
-- Reverse-engineered directly from backend/src/services/ (dashboard, demo, and ai services)

-- 1. Customers Table (Primary Entity)
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    industry VARCHAR(100),
    company_size VARCHAR(50),
    country VARCHAR(100),
    current_stage VARCHAR(50) DEFAULT 'Lead', -- Lead, Trial, Demo Booked, Negotiation, Closed Won
    status VARCHAR(50) DEFAULT 'Active',
    sales_rep_id INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Free Trials (Tracks usage metrics analyzed by Gemini AI)
CREATE TABLE IF NOT EXISTS free_trials (
    trial_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    trial_start_date DATE NOT NULL,
    trial_end_date DATE NOT NULL,
    trial_status VARCHAR(50) DEFAULT 'Active',
    days_active INT DEFAULT 0,
    current_streak INT DEFAULT 0,
    total_logins INT DEFAULT 0,
    projects_created INT DEFAULT 0,
    collaborators_invited INT DEFAULT 0,
    storage_used_gb NUMERIC(6, 2) DEFAULT 0,
    premium_features_used INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Demo Bookings (Scheduled product demos)
CREATE TABLE IF NOT EXISTS demo_bookings (
    demo_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    demo_date DATE NOT NULL,
    demo_time TIME NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Negotiations (Commercial & pricing discussions)
CREATE TABLE IF NOT EXISTS negotiations (
    negotiation_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    negotiation_date DATE NOT NULL,
    negotiation_time TIME NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Activity Logs (Audit trail of customer actions)
CREATE TABLE IF NOT EXISTS activity_logs (
    log_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    activity_type VARCHAR(100) NOT NULL,
    activity_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);

-- 6. Follow-up History (Past interactions by sales reps)
CREATE TABLE IF NOT EXISTS followup_history (
    followup_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    followup_type VARCHAR(50) NOT NULL, -- Call, Email, Meeting
    followup_status VARCHAR(50) DEFAULT 'Pending',
    followup_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- 7. Follow-up Recommendations (AI inference outputs from Gemini)
CREATE TABLE IF NOT EXISTS followup_recommendations (
    recommendation_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    recommended_action VARCHAR(50) NOT NULL, -- CALL, EMAIL, MEETING
    followup_type VARCHAR(50),
    meeting_type VARCHAR(50),
    priority VARCHAR(20) NOT NULL, -- HIGH, MEDIUM, LOW
    reason TEXT,
    confidence_score NUMERIC(5, 2) NOT NULL,
    estimated_conversion_probability NUMERIC(5, 2) NOT NULL,
    recommended_timeframe VARCHAR(100),
    status VARCHAR(50) DEFAULT 'Active',
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Subscriptions (Conversion tracking)
CREATE TABLE IF NOT EXISTS subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    subscription_status VARCHAR(50) DEFAULT 'Active', -- Active, Cancelled, Expired
    plan_name VARCHAR(50) DEFAULT 'Premium',
    monthly_price NUMERIC(10, 2) DEFAULT 999.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_customers_rep ON customers(sales_rep_id);
CREATE INDEX IF NOT EXISTS idx_customers_stage ON customers(current_stage);
CREATE INDEX IF NOT EXISTS idx_trials_customer ON free_trials(customer_id);
CREATE INDEX IF NOT EXISTS idx_activity_customer ON activity_logs(customer_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_customer ON followup_recommendations(customer_id);
