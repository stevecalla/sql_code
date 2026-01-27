SELECT * FROM membership_base_data LIMIT 10;
SELECT created_at_mtn, FORMAT(COUNT(*), 0) FROM membership_base_data GROUP BY 1 LIMIT 10;

SELECT year, SUM(unique_profiles), SUM(total_memberships_all_profiles_that_year), SUM(unique_profiles_sales_through_day_of_year), SUM(total_memberships_all_profiles_sales_through_day_of_year), SUM(unique_profiles_sales_ytd), SUM(total_memberships_all_profiles_sales_ytd) FROM membership_base_data GROUP BY 1 ORDER BY 1;

SELECT * FROM membership_detail_data LIMIT 10;
SELECT created_at_mtn, FORMAT(COUNT(*), 0) FROM membership_detail_data GROUP BY 1 LIMIT 10;
SELECT
	year,
	-- real_membership_types_sa,
	-- new_member_category_6_sa,
	COUNT(DISTINCT id_profiles),
	SUM(total_memberships_all_profiles_that_year),

	-- Distinct profiles whose membership purchase date occurred before the same day-of-year cutoff, regardless of calendar year.
	COUNT(DISTINCT CASE WHEN is_sales_through_day_of_year = 1 THEN id_profiles END),
	SUM(total_memberships_all_profiles_sales_through_day_of_year),

	-- Distinct profiles whose membership purchase date falls between January 1 and the same day-of-year cutoff within that year.
	COUNT(DISTINCT CASE WHEN is_sales_ytd = 1 THEN id_profiles END),
	SUM(total_memberships_all_profiles_sales_ytd)

FROM membership_detail_data
GROUP BY 1
;

SELECT year, id_profiles, COUNT(*) AS rows_in_year
FROM membership_detail_data
GROUP BY year, id_profiles
HAVING COUNT(*) > 1
ORDER BY rows_in_year DESC
LIMIT 50;

