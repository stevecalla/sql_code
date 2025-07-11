USE usat_sales_db;

-- **************
-- Step 1: Create a Table and Insert the Result    
-- *************
-- DROP TABLE IF EXISTS rev_recognition_allocated_data;

-- ***********************
-- Parameters
-- ***********************
SET @ends_mp = '2025-01-01';
SET @id_profile_1 = 54;
SET @id_profile_2 = 57;
SET @id_profile_3 = 60;

-- ***********************
-- Revenue Recognition with Using Combined Fix Total Months or Recursion
-- ***********************
-- CREATE TABLE rev_recognition_allocated_data AS
WITH RECURSIVE membership_months AS (
    -- Anchor: first month
    SELECT
        id_profiles,
        id_membership_periods_sa,

        real_membership_types_sa,
        new_member_category_6_sa,
        origin_flag_ma,

        created_at_mp,
        purchased_on_date_adjusted_mp,
        starts_mp,
        ends_mp,

        DATE_FORMAT(starts_mp, '%Y-%m-01') AS current_month,
        0 AS month_index,  -- Adding a month_index column to track recursion step

        -- Standard difference (excludes the first partial month)
        total_months, 
        -- Logic for total_months_recursive based on membership type from base data
        null AS total_months_recursive, -- test null condition
        -- total_months_recursive,

        sales_revenue,
        sales_units

    FROM rev_recognition_base_data
    WHERE 1 = 1
            AND ends_mp >= @ends_mp
            AND id_profiles IN (@id_profile_1, @id_profile_2, @id_profile_3)

            -- NODE VARIABLES
            -- AND ends_mp >= ${ends_mp} -- TODO:
            -- AND id_profiles IN (54, 57, 60) -- TODO:

    UNION ALL

    SELECT
        m.id_profiles,
        m.id_membership_periods_sa,
        
        m.real_membership_types_sa,
        m.new_member_category_6_sa,
        m.origin_flag_ma,

        m.created_at_mp,
        m.purchased_on_date_adjusted_mp,
        m.starts_mp,
        m.ends_mp,

        DATE_ADD(m.current_month, INTERVAL 1 MONTH),
        m.month_index + 1,  -- Increment the month index
        m.total_months,
        m.total_months_recursive,

        m.sales_revenue,
        m.sales_units

    FROM membership_months m
    WHERE DATE_ADD(m.current_month, INTERVAL 1 MONTH) <= m.ends_mp
    
    -- WHERE m.month_index + 1 < COALESCE(m.total_months_recursive, m.total_months)
    -- WHERE
    --     (
    --         m.total_months_recursive IS NOT NULL
    --         AND m.month_index + 1 < m.total_months_recursive
    --     )
    --     OR 
    --     (
    --         m.total_months_recursive IS NULL
    --         AND DATE_ADD(m.current_month, INTERVAL 1 MONTH) <= m.ends_mp
    --     )
)

SELECT
    mm.id_profiles,
    mm.id_membership_periods_sa,

    mm.real_membership_types_sa,
    mm.new_member_category_6_sa,
    mm.origin_flag_ma,

    mm.created_at_mp,
    DATE_FORMAT(mm.created_at_mp, '%Y-%m') AS created_month,
    mm.purchased_on_date_adjusted_mp,
    DATE_FORMAT(mm.purchased_on_date_adjusted_mp, '%Y-%m') AS purchased_on_adjusted_month,

    mm.starts_mp,
    mm.ends_mp,

    DATE_FORMAT(mm.current_month, '%Y-%m') AS revenue_month,

    mm.month_index + 1 AS recursion_month_index,  -- This shows the month used in recursion
    mc.total_months,
    mm.total_months_recursive,

    mm.sales_units, 
    ROUND(mm.sales_units / mc.total_months, 4) AS monthly_sales_units,
    mm.sales_revenue,
    ROUND(mm.sales_revenue / mc.total_months, 2) AS monthly_revenue,

    -- CREATED AT DATES
    CONVERT_TZ(UTC_TIMESTAMP(), 'UTC', 'America/Denver') AS created_at_mtn,
    UTC_TIMESTAMP() AS created_at_utc

    -- NODE VARIABLES
    -- '${created_at_mtn}' AS created_at_mtn,
    -- '${created_at_utc}' AS created_at_utc

FROM membership_months mm
JOIN (
    SELECT
        id_profiles,
        id_membership_periods_sa,
        COUNT(*) AS total_months
    FROM membership_months
    GROUP BY id_profiles, id_membership_periods_sa
) mc
  ON mm.id_profiles = mc.id_profiles
  AND mm.id_membership_periods_sa = mc.id_membership_periods_sa
ORDER BY mm.id_profiles, mm.id_membership_periods_sa, revenue_month
;

-- SELECT * FROM rev_recognition_allocated_data ORDER BY id_profiles, id_membership_periods_sa, revenue_month LIMIT 100;
-- SELECT COUNT(*) FROM rev_recognition_allocated_data LIMIT 10; -- 8,959,451
-- SELECT COUNT(*) FROM rev_recognition_allocated_data WHERE revenue_month LIKE '%2024%' LIMIT 10; -- 1,667,717
-- SELECT COUNT(*) FROM rev_recognition_allocated_data WHERE revenue_month LIKE '%2025-04%' LIMIT 10; -- 130,615
-- SELECT COUNT(*) FROM rev_recognition_allocated_data WHERE revenue_month LIKE '%2025%' LIMIT 10; -- 1,246,299
   