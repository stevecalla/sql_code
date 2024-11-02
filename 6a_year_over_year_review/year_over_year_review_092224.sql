USE usat_sales_db;

-- SET @member_category = '3-year';
-- SET @year_1 = 2023;
-- SET @year_2 = 2024;

-- #1) SECTION: STATS = UNIQUE MEMBER NUMBERS
    SELECT
        COUNT(DISTINCT(member_number_members_sa)),
        COUNT(member_number_members_sa)
    FROM all_membership_sales_data;
-- =================================================

-- #2) SECTION: STATS = TOTAL BY YEAR
    SELECT
        purchased_on_year_adjusted_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp WITH ROLLUP;
-- =================================================

-- #3) SECTION: STATS = TOTAL BY YEAR BY MONTH
    SELECT
        purchased_on_year_adjusted_mp,
        purchased_on_month_adjusted_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp WITH ROLLUP
    ORDER BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp;
-- =================================================
-- ++++++++++++++++++++++++++++++++++++++++++++++++++

-- #4) SECTION: STATS = TOTAL BY YEAR BY REAL TYPE
    SELECT
        purchased_on_year_adjusted_mp,
        real_membership_types_sa,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp, real_membership_types_sa WITH ROLLUP; 
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- #5) SECTION: STATS = TOTAL BY YEAR BY NEW MEMBER CATEGORY
    SELECT
        purchased_on_year_adjusted_mp,
        new_member_category_6_sa,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp, new_member_category_6_sa WITH ROLLUP; 

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@