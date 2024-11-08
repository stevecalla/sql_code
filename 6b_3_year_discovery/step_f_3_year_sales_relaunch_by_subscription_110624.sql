USE usat_sales_db;

-- Create an index on the first 255 characters of the `origin_flag_ma` column
-- CREATE INDEX idx_origin_flag_ma ON all_membership_sales_data_2015_left (origin_flag_ma(255));

-- summarize origin flag subscription by new member category
SELECT
	new_member_category_6_sa
	, COUNT(*)
FROM all_membership_sales_data_2015_left
WHERE origin_flag_ma IN ('SUBSCRIPTION_RENEWAL')
GROUP BY 1;

-- view total 3 year sales with a column for subscription renewal and total count
SELECT 
    IFNULL(purchased_on_date_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
    SUM(CASE WHEN origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 1 ELSE 0 END) AS subscription_purchase,
    COUNT(*) AS total_count
FROM all_membership_sales_data_2015_left 
WHERE 
    new_member_category_6_sa IN ('3-Year')
    AND purchased_on_year_adjusted_mp IN ('2024')
    AND purchased_on_month_adjusted_mp IN ('10', '11')
GROUP BY purchased_on_date_adjusted_mp WITH ROLLUP
ORDER BY purchased_on_date_adjusted_mp DESC
LIMIT 100;

-- view total 3 year sales with a column for subscription renewal and total count
SELECT 
    member_number_members_sa,
    id_membership_periods_sa,
    id_profiles,
    actual_membership_fee_6_sa,
    IFNULL(purchased_on_date_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
    purchased_on_adjusted_mp,
    COUNT(*) AS total_count
FROM all_membership_sales_data_2015_left 
WHERE 
    new_member_category_6_sa IN ('3-Year')
    AND purchased_on_year_adjusted_mp IN ('2024')
    AND purchased_on_month_adjusted_mp IN ('10', '11')
    AND purchased_on_date_adjusted_mp = '2024-11-07'
GROUP BY 1, 2, 3, 4
ORDER BY purchased_on_adjusted_mp ASC
LIMIT 100;

-- view sales with purchase date > than today
SELECT 
    member_number_members_sa,
    id_membership_periods_sa,
    id_profiles,
    new_member_category_6_sa
    actual_membership_fee_6_sa,
    IFNULL(purchased_on_date_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
    purchased_on_adjusted_mp,
    purchased_on_mp,
    starts_mp,
    COUNT(*) AS total_count
FROM all_membership_sales_data_2015_left 
WHERE 
    purchased_on_year_adjusted_mp IN ('2024')
    AND purchased_on_month_adjusted_mp IN ('10', '11')
    AND purchased_on_date_adjusted_mp > '2024-11-07'
GROUP BY 1, 2, 3, 4
ORDER BY purchased_on_adjusted_mp ASC
LIMIT 100;