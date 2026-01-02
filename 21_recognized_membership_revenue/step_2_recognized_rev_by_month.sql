USE usat_sales_db;

-- **************
-- Step 2: Pivot Query – Revenue by Month, Membership Type, and Category
-- *************
-- SELECT * FROM rev_recognition_allocated_data LIMIT 10;
-- SELECT * FROM rev_recognition_allocated_data WHERE months_mp_allocation_recursive IN (349) AND real_membership_types_sa LIKE "one_day";
-- SELECT * FROM rev_recognition_allocated_data WHERE months_mp_allocation_recursive NOT IN (12, 13, 24, 25, 36, 37) AND real_membership_types_sa LIKE "adult_annual" AND revenue_year_month LIKE "%2025%";
-- SELECT * FROM rev_recognition_allocated_data WHERE real_membership_types_sa LIKE "%youth%" AND revenue_year_month LIKE "%2025%" LIMIT 100;
-- SELECT * FROM rev_recognition_allocated_data WHERE new_member_category_6_sa LIKE "%Youth Premier%" AND revenue_year_month LIKE "%2025%" LIMIT 100;

 -- **************
-- a) All Months 2024+
 -- *************
SELECT
	"revenue_year_month",
    revenue_year_month,

	SUM(sales_units) AS all_sales_units, -- SUM(sales_units) → counts the full original unit on every month row, so it overcounts once you aggregate.
	SUM(monthly_sales_units) AS allocated_sales_units, -- SUM(monthly_sales_units) → counts the pro-rated fraction per month, so totals across the months = original sales units, and each month shows the right share of recognition.
    AVG(monthly_revenue) AS average_rev_per_all_sales_units,
    SUM(monthly_revenue) AS allocated_monthly_revenue
FROM rev_recognition_allocation_data
WHERE 1 = 1
    -- AND real_membership_types_sa = "one_day"
    -- AND real_membership_types_sa = "adult_annual"
    -- AND real_membership_types_sa = "elite_annual"
    -- AND real_membership_types_sa = "youth_annual"
    -- AND sales_revenue <= 0
GROUP BY
    revenue_year_month
--     real_membership_types_sa,
--     new_member_category_6_sa
    WITH ROLLUP
-- ORDER BY revenue_year_month, real_membership_types_sa, new_member_category_6_sa
ORDER BY 1
;

-- **************
-- b) March 2025 Only
 -- *************
SELECT
	"months_mp_allocation_recursive",
    months_mp_allocation_recursive,
    real_membership_types_sa,

	SUM(sales_units) AS all_sales_units, -- SUM(sales_units) → counts the full original unit on every month row, so it overcounts once you aggregate.
	SUM(monthly_sales_units) AS allocated_sales_units, -- SUM(monthly_sales_units) → counts the pro-rated fraction per month, so totals across the months = original sales units, and each month shows the right share of recognition.
    AVG(monthly_revenue) AS average_rev_per_all_sales_units,
    SUM(monthly_revenue) AS allocated_monthly_revenue
    
FROM rev_recognition_allocation_data
WHERE 1 = 1
    -- AND revenue_year_month = '2025-03'
GROUP BY
    months_mp_allocation_recursive,
    real_membership_types_sa
ORDER BY 3, 2, 1
;

-- **************
-- c) By Allocated month
 -- *************
SELECT
	"months_mp_allocation_recursive",
    months_mp_allocation_recursive,
    real_membership_types_sa,
    new_member_category_6_sa,

	SUM(sales_units) AS all_sales_units, -- SUM(sales_units) → counts the full original unit on every month row, so it overcounts once you aggregate.
	SUM(monthly_sales_units) AS allocated_sales_units, -- SUM(monthly_sales_units) → counts the pro-rated fraction per month, so totals across the months = original sales units, and each month shows the right share of recognition.
    AVG(monthly_revenue) AS average_rev_per_all_sales_units,
    SUM(monthly_revenue) AS allocated_monthly_revenue
FROM rev_recognition_allocation_data
WHERE 1 = 1
    -- AND revenue_year_month = '2025-03'
GROUP BY
    months_mp_allocation_recursive,
    real_membership_types_sa,
    new_member_category_6_sa
ORDER BY 3, 4, 2, 1
;

-- **************
-- d) By purchased month
 -- *************
SELECT
	"revenue_year_month_by_purchased_month",
    revenue_year_month,
    purchased_on_date_adjusted_mp_month,

	SUM(sales_units),
	SUM(monthly_sales_units),
    AVG(monthly_revenue) AS avg_monthly_revenue,
    SUM(monthly_revenue) AS total_monthly_revenue

FROM rev_recognition_allocation_data
WHERE 1 = 1
    -- and revenue_year_month = '2025-03'
GROUP BY
	revenue_year_month,
    purchased_on_date_adjusted_mp_month
    WITH ROLLUP
ORDER BY 2, 3
;

 -- **************
-- e) By Revenue Month
 -- *************
SELECT
    *
FROM rev_recognition_allocation_data
WHERE 1 = 1
    AND id_profiles = 54
ORDER BY 1
;

 -- **************
-- f) Recognized by Profile 54
 -- *************
SELECT
    *
FROM rev_recognition_allocation_data
WHERE 1 = 1
    AND id_profiles = 54
ORDER BY 1
;

 -- **************
-- g) Membership by Profile 54
 -- *************
SELECT
    *
FROM rev_recognition_base_data
WHERE 1 = 1
    AND id_profiles = 54
ORDER BY 1
;

 -- **************
-- h) Review updated_from_id
 -- *************
-- SELECT 
-- 	COUNT(*)
-- FROM rev_recognition_base_data
-- WHERE upgraded_from_id IS NOT NULL
-- ;
 
 -- (1) profile id: 2599832; Gold starts 1/16/24 to 1/15/25 $39 upgrade from 4578013 Silver start 1/16/24 to 1/15/24 $60; same date for both $60 & $39; current allocation rules $60 1/2024 then $39 1/24 to 1/25
 -- (2) profile id: 2737677; 4578372 Team USA $303.57 2/21/26-2/20/27 upgrade from 3996148 3-Year 2/21/23-2/20/26 $135; current allocation rules work fine as 3-year completed entire term then team usa starts
 -- (3) 
SELECT 
	*
FROM rev_recognition_base_data
-- WHERE id_membership_periods_sa = 4578015 -- (1) Silver to Gold
WHERE id_membership_periods_sa = 4578372 -- (2) 3-Year to Platinum - Team USA
;

SELECT 
    id_profiles,
    id_membership_periods_sa,
    real_membership_types_sa,
    new_member_category_6_sa,
    created_at_mp,
    purchased_on_date_adjusted_mp,
    starts_mp,
    ends_mp,
    sales_revenue
FROM rev_recognition_base_data
-- WHERE id_profiles = 2599832 -- (1)
WHERE id_profiles = 2737677 -- (2)
ORDER BY id_membership_periods_sa, starts_mp
;

