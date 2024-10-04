USE usat_sales_db;

-- #1.1) SECTION: STATS = TOTAL BY YEAR - 2021 LEFT
    SELECT
        purchased_on_year_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_mp WITH ROLLUP;
-- =================================================

-- #1.2) 2021 RIGHT
    SELECT
        purchased_on_year_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2021_right
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_mp WITH ROLLUP;
-- =================================================

-- #1.3) QUERY: find records that don't exist in either of the two tables (all_membership_sales_data and all_membership_sales_data_2021_right
SELECT
    'left_table' AS source,
    a.id_membership_periods_sa
FROM all_membership_sales_data a
	LEFT JOIN all_membership_sales_data_2021_right b ON a.id_membership_periods_sa = b.id_membership_periods_sa
WHERE b.id_membership_periods_sa IS NULL
GROUP BY a.id_membership_periods_sa

UNION ALL

SELECT
    'right_table' AS source,
    b.id_membership_periods_sa
FROM all_membership_sales_data_2021_right b
	LEFT JOIN all_membership_sales_data a ON a.id_membership_periods_sa = b.id_membership_periods_sa
WHERE a.id_membership_periods_sa IS NULL
GROUP BY b.id_membership_periods_sa;

-- #1.4) SECTION: STATS = TOTAL BY YEAR
    SELECT
        purchased_on_year_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2015_left
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_mp WITH ROLLUP;
-- =================================================

-- #1.5) SECTION: STATS = TOTAL BY YEAR
    SELECT
        purchased_on_year_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2015_left
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_mp WITH ROLLUP;
-- =================================================

-- #1.6) SECTION: STATS = TOTAL BY YEAR
    SELECT
        purchased_on_year_adjusted_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2015_right
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp WITH ROLLUP;
-- =================================================

-- #2) SECTION: STATS = TOTAL BY YEAR BY MONTH
    SELECT
        purchased_on_year_mp,
        purchased_on_month_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_mp, purchased_on_month_mp WITH ROLLUP
    ORDER BY purchased_on_year_mp, purchased_on_month_mp;
-- =================================================

-- #2) SECTION: STATS = TOTAL BY YEAR BY MONTH
    SELECT
        purchased_on_year_adjusted_mp,
        purchased_on_month_adjusted_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2021_right
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp WITH ROLLUP
    ORDER BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp;
-- =================================================

-- #2) SECTION: STATS = TOTAL BY YEAR BY MONTH
    SELECT
        purchased_on_year_mp,
        purchased_on_month_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2015_left
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_mp, purchased_on_month_mp WITH ROLLUP
    ORDER BY purchased_on_year_mp, purchased_on_month_mp;
-- =================================================

-- #2) SECTION: STATS = TOTAL BY YEAR BY MONTH
    SELECT
        purchased_on_year_adjusted_mp,
        purchased_on_month_adjusted_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2015_right
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp WITH ROLLUP
    ORDER BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp;
-- =================================================