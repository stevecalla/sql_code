-- CREATE INDEX idx_original_mp_id ON all_membership_sales_data_2015_left_join_member_application(id_membership_periods_sa);
CREATE INDEX idx_profile_mp_id  ON all_membership_sales_data_2015_left_join_membership_periods(id_membership_periods_sa);

SELECT * FROM all_membership_sales_data_2015_left_join_member_application LIMIT 10;
SELECT * FROM all_membership_sales_data_2015_left_join_member_application WHERE purchased_on_year_adjusted_mp = 2025 AND purchased_on_month_adjusted_mp = 8;
SELECT 'all = ', FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left_join_member_application;
SELECT 'all = ', purchased_on_month_adjusted_mp, FORMAT(COUNT(*), 0), FORMAT(SUM(actual_membership_fee_6_sa), 0) FROM all_membership_sales_data_2015_left_join_member_application WHERE purchased_on_year_adjusted_mp = 2025 GROUP BY 2 WITH ROLLUP ORDER BY 2;
SELECT 'distinct = ', FORMAT(COUNT(DISTINCT id_membership_periods_sa), 0) FROM all_membership_sales_data_2015_left_join_member_application;
SELECT 'null = ', FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left_join_member_application WHERE id_membership_periods_sa IS NULL;
SELECT 'not null = ', FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left_join_member_application WHERE id_membership_periods_sa IS NOT NULL;

SELECT * FROM all_membership_sales_data_2015_left_join_membership_periods LIMIT 10;
SELECT 'all =', FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left_join_membership_periods;
SELECT 'all = ', purchased_on_month_adjusted_mp, FORMAT(COUNT(*), 0), FORMAT(SUM(actual_membership_fee_6_sa), 0)  FROM all_membership_sales_data_2015_left_join_membership_periods WHERE purchased_on_year_adjusted_mp = 2025 GROUP BY 2 WITH ROLLUP ORDER BY 2;
SELECT 'distinct = ', FORMAT(COUNT(DISTINCT id_membership_periods_sa), 0) FROM all_membership_sales_data_2015_left_join_membership_periods;
SELECT 'null =', FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left_join_membership_periods WHERE id_membership_periods_sa IS NULL;
SELECT 'not null = ', FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left_join_membership_periods WHERE id_membership_periods_sa IS NOT NULL;

SELECT * FROM all_membership_sales_data_2015_left_join_member_application WHERE id_membership_periods_sa IN (5131098);
SELECT * FROM all_membership_sales_data_2015_left_join_membership_periods WHERE id_membership_periods_sa IN (5131098);

SELECT
  SUM(side = 'only_in_original') AS only_in_original,
  SUM(side = 'only_in_profile')  AS only_in_profile
FROM (
  SELECT 'only_in_original' AS side
  FROM all_membership_sales_data_2015_left_join_member_application o
	LEFT JOIN all_membership_sales_data_2015_left_join_membership_periods p ON p.id_membership_periods_sa = o.id_membership_periods_sa
  WHERE p.id_membership_periods_sa IS NULL

  UNION ALL

  SELECT 'only_in_profile' AS side
  FROM all_membership_sales_data_2015_left_join_membership_periods p
	LEFT JOIN all_membership_sales_data_2015_left_join_member_application o ON o.id_membership_periods_sa = p.id_membership_periods_sa
  WHERE o.id_membership_periods_sa IS NULL
) x;

-- ============================
-- Rows in ORIGINAL only
SELECT 'only_in_original' AS where_in, o.*
FROM all_membership_sales_data_2015_left_join_member_application o
	LEFT JOIN all_membership_sales_data_2015_left_join_membership_periods p ON p.id_membership_periods_sa = o.id_membership_periods_sa
WHERE p.id_membership_periods_sa IS NULL

UNION ALL

-- Rows in PROFILE only
SELECT 'only_in_profile' AS where_in, p.*
FROM all_membership_sales_data_2015_left_join_membership_periods p
	LEFT JOIN all_membership_sales_data_2015_left_join_member_application o ON o.id_membership_periods_sa = p.id_membership_periods_sa
WHERE o.id_membership_periods_sa IS NULL;

-- ==============================
-- CREATE INDEX idx_profile_mp_id  ON all_membership_sales_data_2015_left(id_membership_periods_sa);
SELECT * FROM all_membership_sales_data_2015_left WHERE purchased_on_year_adjusted_mp = 2025 AND purchased_on_month_adjusted_mp = 8 AND id_membership_periods_sa = 5102220;
SELECT 'all =', FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left WHERE purchased_on_year_mp >= 2024;
SELECT 'all = ', purchased_on_month_adjusted_mp, FORMAT(COUNT(*), 0), FORMAT(SUM(actual_membership_fee_6_sa), 0)  FROM all_membership_sales_data_2015_left WHERE purchased_on_year_adjusted_mp = 2025 GROUP BY 2 WITH ROLLUP ORDER BY 2;

SELECT 'distinct = ', FORMAT(COUNT(DISTINCT id_membership_periods_sa), 0) FROM all_membership_sales_data_2015_left;
SELECT 'null =', FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left WHERE id_membership_periods_sa IS NULL;
SELECT 'not null = ', FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left WHERE id_membership_periods_sa IS NOT NULL;

-- Rows in ORIGINAL only
SELECT 'only_in_original' AS where_in, o.*
FROM all_membership_sales_data_2015_left_join_member_application o
	LEFT JOIN all_membership_sales_data_2015_left p ON p.id_membership_periods_sa = o.id_membership_periods_sa
WHERE p.id_membership_periods_sa IS NULL AND o.purchased_on_year_adjusted_mp >= 2024

UNION ALL

-- Rows in PROFILE only
SELECT 'only_in_left' AS where_in, p.*
FROM all_membership_sales_data_2015_left p
	LEFT JOIN all_membership_sales_data_2015_left_join_member_application o ON o.id_membership_periods_sa = p.id_membership_periods_sa
WHERE o.id_membership_periods_sa IS NULL AND p.purchased_on_year_adjusted_mp >= 2024;

-- CHECKS
SELECT * FROM all_membership_sales_data_2015_left WHERE id_membership_periods_sa IN (5131098, 5102220, 5102455, 5103081, 5103087, 5103090); -- should be in here
SELECT * FROM all_membership_sales_data_2015_left_join_member_application WHERE id_membership_periods_sa IN (5131098, 5102220, 5102455, 5103081, 5103087, 5103090); -- should not be in here
