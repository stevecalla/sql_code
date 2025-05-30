USE usat_sales_db;

-- **************
-- Step 1: Create a Table and Insert the Result    
-- *************
DROP TABLE IF EXISTS monthly_membership_revenue;

CREATE TABLE monthly_membership_revenue AS
WITH RECURSIVE membership_months AS (
    SELECT
        id_profiles,
        id_membership_periods_sa,
        real_membership_types_sa,
        new_member_category_6_sa,
        origin_flag_ma,
        starts_mp,
        ends_mp,
        sales_revenue,
        sales_units,
        DATE_FORMAT(starts_mp, '%Y-%m-01') AS current_month
    FROM sales_key_stats_2015
    WHERE starts_mp >= '2020-01-01'

    UNION ALL

    SELECT
        m.id_profiles,
        m.id_membership_periods_sa,
        m.real_membership_types_sa,
        m.new_member_category_6_sa,
        m.origin_flag_ma,
        m.starts_mp,
        m.ends_mp,
        m.sales_revenue,
        m.sales_units,
        DATE_ADD(m.current_month, INTERVAL 1 MONTH)
    FROM membership_months m
    WHERE DATE_ADD(m.current_month, INTERVAL 1 MONTH) <= m.ends_mp
)
SELECT
    mm.id_profiles,
    mm.id_membership_periods_sa,
    mm.real_membership_types_sa,
    mm.new_member_category_6_sa,
    mm.origin_flag_ma,
    mm.starts_mp,
    mm.ends_mp,
    DATE_FORMAT(mm.current_month, '%Y-%m') AS revenue_month,
    mc.total_months,
    mm.sales_units,
    ROUND(mm.sales_units / mc.total_months, 4) AS monthly_sales_units,
    mm.sales_revenue,
    ROUND(mm.sales_revenue / mc.total_months, 2) AS monthly_revenue,
    CONVERT_TZ(UTC_TIMESTAMP(), 'UTC', 'America/Denver') AS created_at_mtn,
    UTC_TIMESTAMP() AS created_at_utc
FROM membership_months mm
JOIN (
    SELECT
        id_profiles,
        id_membership_periods_sa,
        COUNT(*) AS total_months
    FROM membership_months
    GROUP BY id_profiles, id_membership_periods_sa
) AS mc
ON mm.id_profiles = mc.id_profiles
   AND mm.id_membership_periods_sa = mc.id_membership_periods_sa
;

SELECT * FROM monthly_membership_revenue LIMIT 10;
SELECT COUNT(*) FROM monthly_membership_revenue LIMIT 10; -- 8,959,451
SELECT COUNT(*) FROM monthly_membership_revenue WHERE revenue_month LIKE '%2024%' LIMIT 10; -- 1,667,717
SELECT COUNT(*) FROM monthly_membership_revenue WHERE revenue_month LIKE '%2025-04%' LIMIT 10; -- 130,615
SELECT COUNT(*) FROM monthly_membership_revenue WHERE revenue_month LIKE '%2025%' LIMIT 10; -- 1,246,299
   
   
