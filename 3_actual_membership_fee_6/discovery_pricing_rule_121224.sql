SELECT 
    id_membership_periods_sa,
    new_member_category_6_sa,
    real_membership_types_sa,
    name_events,
    payment_type_ma,
    origin_flag_ma,
    created_at_mp,
    purchased_on_mp,
    purchased_on_adjusted_mp,
	SUM(actual_membership_fee_6_sa),
    COUNT(id_membership_periods_sa)
FROM usat_sales_db.all_membership_sales_data_2015_left
WHERE id_membership_periods_sa IN (4833284, 4833253)
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9;

SELECT 
    id_membership_periods_sa,
    new_member_category_6_sa,
    real_membership_types_sa,
    name_events,
    payment_type_ma,
    origin_flag_ma,
    created_at_mp,
    purchased_on_mp,
    purchased_on_adjusted_mp,
	SUM(actual_membership_fee_6_sa),
    COUNT(id_membership_periods_sa)
FROM usat_sales_db.all_membership_sales_data_2015_left
WHERE 
	new_member_category_6_sa LIKE ('%Bronze%')
    AND purchased_on_date_adjusted_mp IN (2024-12-04)
    AND origin_flag_ma LIKE ('%Bulk%')
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9;

SELECT 
    id_membership_periods_sa,
    new_member_category_6_sa,
    real_membership_types_sa,
    name_events,
    payment_type_ma,
    origin_flag_ma,
    created_at_mp,
    purchased_on_mp,
    purchased_on_adjusted_mp,
	SUM(actual_membership_fee_6_sa),
    COUNT(id_membership_periods_sa)
FROM usat_sales_db.all_membership_sales_data_2015_left
WHERE 
	(	new_member_category_6_sa LIKE '%Silver%'
		OR new_member_category_6_sa LIKE '%Bronze%'
		OR new_member_category_6_sa LIKE '%Gold%')
    AND purchased_on_year_adjusted_mp IN (2024)
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9;

SELECT 
    sales_revenue,
	COUNT(DISTINCT CASE WHEN new_member_category_6_sa LIKE '%Gold%' THEN id_membership_periods_sa END) AS count_gold_distinct,
    COUNT(DISTINCT CASE WHEN new_member_category_6_sa LIKE '%Silver%' THEN id_membership_periods_sa END) AS count_silver_distinct,
    COUNT(DISTINCT CASE WHEN new_member_category_6_sa LIKE '%Bronze%' THEN id_membership_periods_sa END) AS count_bronze_distinct,
    COUNT(DISTINCT id_membership_periods_sa) AS count_membership_periods_distinct
FROM usat_sales_db.sales_key_stats_2015
WHERE 
    purchased_on_year_adjusted_mp IN (2024)
    -- AND origin_flag_ma LIKE ('%Bulk%')
GROUP BY sales_revenue
ORDER BY count_membership_periods_distinct DESC
;
