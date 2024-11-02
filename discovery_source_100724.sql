USE usat_sales_db;

SELECT * FROM all_membership_sales_data_2015_left LIMIT 10;

SELECT 
	DISTINCT(source_2_sa), 
    FORMAT(SUM(CASE WHEN purchased_on_year_adjusted_mp IN (2024) THEN 1 ELSE 0 END), 0) AS '2024',
    FORMAT(COUNT(DISTINCT member_number_members_sa), 0)
FROM all_membership_sales_data_2015_left 
GROUP BY source_2_sa WITH ROLLUP;