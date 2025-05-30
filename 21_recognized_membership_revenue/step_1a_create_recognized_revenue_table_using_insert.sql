USE usat_sales_db;

-- Step 1: Drop the table if it already exists
DROP TABLE IF EXISTS monthly_membership_revenue;

-- Step 2: Create the output table
CREATE TABLE monthly_membership_revenue (
    id_profiles BIGINT,
    id_membership_periods_sa BIGINT,
    real_membership_types_sa VARCHAR(255),
    new_member_category_6_sa VARCHAR(255),
    origin_flag_ma VARCHAR(255),
    starts_mp DATE,
    ends_mp DATE,
    created_at_mp DATETIME,
    created_month VARCHAR(7),
    purchased_on_adjusted_mp DATETIME,
    purchased_month VARCHAR(7),
    revenue_month VARCHAR(7),
    total_months INT,
    sales_units DECIMAL(10,4),
    monthly_sales_units DECIMAL(10,4),
    sales_revenue DECIMAL(10,2),
    monthly_revenue DECIMAL(10,2),
    created_at_mtn DATETIME,
    created_at_utc DATETIME
);

-- Step 3: Insert test sample for first 10 unique memberships
WITH RECURSIVE base_memberships AS (
    SELECT s.*
    FROM (
        SELECT id_membership_periods_sa
        FROM sales_key_stats_2015
        WHERE starts_mp >= '2020-01-01'
        GROUP BY id_membership_periods_sa
        LIMIT 10
    ) AS limited
    JOIN sales_key_stats_2015 s USING (id_membership_periods_sa)
),
membership_months AS (
    SELECT
        id_profiles,
        id_membership_periods_sa,
        real_membership_types_sa,
        new_member_category_6_sa,
        origin_flag_ma,
        starts_mp,
        ends_mp,
        created_at_mp,
        purchased_on_adjusted_mp,
        DATE_FORMAT(starts_mp, '%Y-%m-01') AS current_month,
        sales_revenue,
        sales_units,
        1 AS month_number
    FROM base_memberships

    UNION ALL

    SELECT
        m.id_profiles,
        m.id_membership_periods_sa,
        m.real_membership_types_sa,
        m.new_member_category_6_sa,
        m.origin_flag_ma,
        m.starts_mp,
        m.ends_mp,
        m.created_at_mp,
        m.purchased_on_adjusted_mp,
        DATE_ADD(m.current_month, INTERVAL 1 MONTH),
        m.sales_revenue,
        m.sales_units,
        m.month_number + 1
    FROM membership_months m
    WHERE DATE_ADD(m.current_month, INTERVAL 1 MONTH) <= m.ends_mp
)

-- Final insert
INSERT INTO monthly_membership_revenue
SELECT
    mm.id_profiles,
    mm.id_membership_periods_sa,
    mm.real_membership_types_sa,
    mm.new_member_category_6_sa,
    mm.origin_flag_ma,
    mm.starts_mp,
    mm.ends_mp,
    mm.created_at_mp,
    DATE_FORMAT(mm.created_at_mp, '%Y-%m') AS created_month,
    mm.purchased_on_adjusted_mp,
    DATE_FORMAT(mm.purchased_on_adjusted_mp, '%Y-%m') AS purchased_month,
    DATE_FORMAT(mm.current_month, '%Y-%m') AS revenue_month,
    total_months.total_months,
    mm.sales_units,
    ROUND(mm.sales_units / total_months.total_months, 4),
    mm.sales_revenue,
    ROUND(mm.sales_revenue / total_months.total_months, 2),
    CONVERT_TZ(UTC_TIMESTAMP(), 'UTC', 'America/Denver'),
    UTC_TIMESTAMP()
FROM membership_months mm
JOIN (
    SELECT id_membership_periods_sa, MAX(month_number) AS total_months
    FROM membership_months
    GROUP BY id_membership_periods_sa
) AS total_months
  ON mm.id_membership_periods_sa = total_months.id_membership_periods_sa;
