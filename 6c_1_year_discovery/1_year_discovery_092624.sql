USE usat_sales_db;

SET @member_category_1year = '1-Year $50';
SET @member_category_silver = 'Silver';
SET @member_category_gold = 'Gold';

SELECT * FROM all_membership_sales_data LIMIT 100;

SELECT DISTINCT(real_membership_types_sa) FROM all_membership_sales_data;

SELECT DISTINCT(new_member_category_6_sa) FROM all_membership_sales_data;

-- #1) SALES BY PURCHASE ON YEAR
    SELECT 
        purchased_on_year_mp,
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE new_member_category_6_sa IN (@member_category_1year, @member_category_silver, @member_category_gold)
    GROUP BY purchased_on_year_mp WITH ROLLUP 
    ORDER BY purchased_on_year_mp;
-- ==================================================

-- #2) SALES BY PURCHASE ON YEAR & MONTH
    SELECT 
        purchased_on_year_mp, 
        purchase_on_month_mp,
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE new_member_category_6_sa IN (@member_category_1year, @member_category_silver, @member_category_gold)
    GROUP BY purchased_on_year_mp, purchase_on_month_mp WITH ROLLUP 
    ORDER BY purchased_on_year_mp, purchase_on_month_mp;
-- ==================================================

-- #3A) SALES BY PURCHASE ON YEAR, MONNTH... START YEAR, QUARTER
    SELECT 
        purchased_on_year_mp, 
        purchase_on_month_mp,
        YEAR(starts_mp),
        QUARTER(starts_mp),
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE new_member_category_6_sa IN (@member_category_1year, @member_category_silver, @member_category_gold)
    GROUP BY purchased_on_year_mp, purchase_on_month_mp, YEAR(starts_mp), QUARTER(starts_mp) WITH ROLLUP
    ORDER BY purchased_on_year_mp, purchase_on_month_mp;
-- ==================================================

-- #3B) SALES BY START YEAR
    SELECT 
        YEAR(starts_mp),
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE new_member_category_6_sa IN (@member_category_1year, @member_category_silver, @member_category_gold)
    GROUP BY YEAR(starts_mp) WITH ROLLUP
    ORDER BY YEAR(starts_mp);
-- ==================================================

-- #3C) SALES BY START YEAR, END YEAR
    SELECT 
        YEAR(starts_mp),
        YEAR(ends_mp),
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE new_member_category_6_sa IN (@member_category_1year, @member_category_silver, @member_category_gold)
    GROUP BY YEAR(starts_mp), YEAR(ends_mp) WITH ROLLUP
    ORDER BY YEAR(starts_mp), YEAR(ends_mp);
-- ==================================================

-- #4A) QUERY SHOWS MEMBERSHIP END PERIOD COUNT BY YEAR OF END DATE
    SELECT 
        YEAR(ends_mp),
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE new_member_category_6_sa IN (@member_category_1year, @member_category_silver, @member_category_gold)
    GROUP BY YEAR(ends_mp) WITH ROLLUP
    ORDER BY YEAR(ends_mp);
-- ==================================================

-- #4B) QUERY SHOWS MEMBERSHIP END PERIOD COUNT BY YEAR, QUAARTER, MONTH OF END DATE
    SELECT 
        YEAR(ends_mp),
        QUARTER(ends_mp),
        MONTH(ends_mp),
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE new_member_category_6_sa IN (@member_category_1year, @member_category_silver, @member_category_gold)
    GROUP BY YEAR(ends_mp), QUARTER(ends_mp), MONTH(ends_mp) WITH ROLLUP
    ORDER BY YEAR(ends_mp), QUARTER(ends_mp), MONTH(ends_mp);
-- ==================================================

-- #5) QUERY SHOWS MEMBERS WITH ADVANCE PURCHASES. PURCHASED IN 2023 BUT STARTS >= 2025
    SELECT 
        member_number_members_sa,
        id_membership_periods_sa,
        purchased_on_mp,
        starts_mp,
        ends_mp
    FROM all_membership_sales_data
    WHERE 
        new_member_category_6_sa IN (@member_category_1year, @member_category_silver, @member_category_gold)
        AND
        -- purchased_on_year_mp IN (2022)
        purchased_on_year_mp IN (2023)
        AND 
        YEAR(starts_mp) >= 2025
    ORDER BY purchased_on_year_mp, purchase_on_month_mp;
-- ==================================================