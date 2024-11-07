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

SELECT
	purchased_on_date_adjusted_mp
	, FORMAT(COUNT(CASE
        WHEN LOWER(new_member_category_6_sa) LIKE '%silver%' AND LOWER(origin_flag_ma) LIKE '%subscription%' THEN 1
        ELSE NULL
    END), 0) AS 'silver'
	, FORMAT(COUNT(CASE
        WHEN LOWER(new_member_category_6_sa) LIKE '%3-year%' AND LOWER(origin_flag_ma) LIKE '%subscription%' THEN 1
        ELSE NULL
    END), 0) AS '3-year'
	, FORMAT(COUNT(CASE
        WHEN LOWER(new_member_category_6_sa) LIKE '%1-Year%' AND LOWER(origin_flag_ma) LIKE '%subscription%' THEN 1
        ELSE NULL
    END), 0) AS '1-year'
	, FORMAT(COUNT(CASE
        WHEN LOWER(new_member_category_6_sa) LIKE '%elite%' AND LOWER(origin_flag_ma) LIKE '%subscription%' THEN 1
        ELSE NULL
    END), 0) AS 'elist'
	, FORMAT(COUNT(CASE
        WHEN LOWER(origin_flag_ma) LIKE '%subscription%' THEN 1
        ELSE NULL
    END), 0) AS 'source_subscription_total'
	, COUNT(*)
FROM all_membership_sales_data_2015_left
WHERE
    purchased_on_year_adjusted_mp IN ('2024')
    AND purchased_on_month_adjusted_mp IN ('10', '11')
GROUP BY 1 WITH ROLLUP
-- LIMIT 10
;

-- view total 3 year sales with a column for subscription renewal and total count
SELECT 
    IFNULL(purchased_on_date_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
    SUM(CASE WHEN origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 1 ELSE 0 END) AS subscription_purchase,
    COUNT(*) AS total_count
FROM all_membership_sales_data_2015_left 
WHERE 
    purchased_on_year_adjusted_mp IN ('2024')
    AND purchased_on_month_adjusted_mp IN ('10', '11')
    AND new_member_category_6_sa IN ('3-Year')
GROUP BY purchased_on_date_adjusted_mp
WITH ROLLUP
ORDER BY purchased_on_date_adjusted_mp 
LIMIT 100;