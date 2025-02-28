-- ****************************
-- GET BULK SALES SUMMARY DATA
-- ****************************
SELECT 	
	DATE(created_at_mp)
    , origin_flag_mp
    , source_2_sa
	, COUNT(id_membership_periods_sa)
    , SUM(actual_membership_fee_6_sa)
    , SUM(CASE WHEN purchased_on_year_adjusted_mp = 2025 THEN 1 ELSE 0 END) AS count_2025_purchase
    , SUM(CASE WHEN purchased_on_year_adjusted_mp = 2024 THEN 1 ELSE 0 END) AS count_2024_purchase
    , SUM(CASE WHEN purchased_on_year_adjusted_mp < 2024 THEN 1 ELSE 0 END) AS 'count_<_2023_purchase'

FROM usat_sales_db.all_membership_sales_data_2015_left 
WHERE origin_flag_ma IN ('ADMIN_BULK_UPLOADER')
GROUP BY DATE(created_at_mp), 2, 3
ORDER BY DATE(created_at_mp) DESC
LIMIT 100000
;
-- ****************************
-- GET BULK SALES BY MEMBERSHIP PERIOD ID
-- ****************************
SELECT 	
	DATE(created_at_mp)
    , origin_flag_mp
    , source_2_sa
    , id_membership_periods_sa
	, COUNT(id_membership_periods_sa)
    , SUM(actual_membership_fee_6_sa)

FROM usat_sales_db.all_membership_sales_data_2015_left 
WHERE origin_flag_ma IN ('ADMIN_BULK_UPLOADER')
GROUP BY DATE(created_at_mp), 2, 3, 4
ORDER BY DATE(created_at_mp) DESC
LIMIT 100000
;

SELECT 	
	DATE(created_at_mp)
    , origin_flag_mp
    , source_2_sa
    , id_membership_periods_sa
	, COUNT(id_membership_periods_sa)
    , SUM(actual_membership_fee_6_sa)

FROM usat_sales_db.all_membership_sales_data_2015_left 
WHERE id_membership_periods_sa IN ('4890891', '4890628')
GROUP BY DATE(created_at_mp), 2, 3, 4
ORDER BY DATE(created_at_mp) DESC
LIMIT 100000
;


