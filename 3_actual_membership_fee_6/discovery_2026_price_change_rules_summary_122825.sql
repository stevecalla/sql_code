USE usat_sales_db;

SELECT 
    actual_membership_fee_6_rule_sa,
    FORMAT(SUM(sales_units), 0) AS sales_units,
    FORMAT(SUM(sales_revenue), 0) AS sales_revenue, 
    GROUP_CONCAT(DISTINCT purchased_on_year_adjusted_mp),
SUM(sales_units) AS sales_units_sort_order
FROM sales_key_stats_2015_old_price_rules_v2
GROUP BY 1
ORDER BY SUM(sales_units) DESC
;

SELECT 
    actual_membership_fee_6_rule_sa,
    FORMAT(SUM(sales_units), 0) AS sales_units,
    FORMAT(SUM(sales_revenue), 0) AS sales_revenue, 
    GROUP_CONCAT(DISTINCT purchased_on_year_adjusted_mp),
	SUM(sales_units) AS sales_units_sort_order
FROM sales_key_stats_2015
GROUP BY 1 WITH ROLLUP
ORDER BY SUM(sales_units) DESC
;

-- SELECT * FROM all_membership_sales_data_2015_left LIMIT 10;
SELECT 
    actual_membership_fee_6_rule_sa,
    FORMAT(COUNT(*), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue, 
    GROUP_CONCAT(DISTINCT purchased_on_year_adjusted_mp),
	COUNT(*) AS sales_units_sort_order
FROM all_membership_sales_data_2015_left
WHERE purchased_on_year_adjusted_mp >= 2010
GROUP BY 1 WITH ROLLUP
ORDER BY COUNT(*) DESC
;

SELECT * FROM sales_key_stats_2015 LIMIT 10;
SELECT id_membership_periods_sa, real_membership_types_sa, new_member_category_6_sa, sales_units, sales_revenue, actual_membership_fee_6_rule_sa FROM sales_key_stats_2015 LIMIT 10;