USE usat_sales_db;

SET @member_category_1year = '1-Year $50';
SET @member_category_silver = 'Silver';
SET @member_category_gold = 'Gold';

-- #1) SALES BY PURCHASE ON YEAR 2023
        SELECT 
            purchased_on_year_mp,
            FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS members_count,
            FORMAT(COUNT(*), 0) AS sales_units,
            FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
        FROM all_membership_sales_data
        WHERE new_member_category_6_sa IN (@member_category_1year, @member_category_silver, @member_category_gold)
        GROUP BY purchased_on_year_mp WITH ROLLUP 
        ORDER BY purchased_on_year_mp;
    -- *******************************************

    -- CTE = DETERMINE PRODUCT PURCHASED FOR 2023 PURCHASE ON DATE
    WITH members_purchase_on AS (
        SELECT    
            DISTINCT member_number_members_sa
        FROM all_membership_sales_data
        WHERE 
            new_member_category_6_sa IN (@member_category)
            AND
            purchased_on_year_mp IN (2023)
        ORDER BY member_number_members_sa
    )

    -- SELECT * FROM members_purchase_on ORDER BY member_number_members_sa;
        
    -- SELECT DISTINCT(member_number_members_sa) FROM members_purchase_on ORDER BY member_number_members_sa;

    -- PROVIDES COUNT SUMMARY TO MATCH #1 ABOVE
    -- ,
    -- summary_stats AS (
    --     SELECT 
    --         sa.purchased_on_year_mp,
    --         FORMAT(COUNT(DISTINCT(sa.member_number_members_sa)), 0) AS members_count,
    --         FORMAT(COUNT(*), 0) AS sales_units,
    --         FORMAT(SUM(sa.actual_membership_fee_6_sa), 0) AS sales_revenue
    --     FROM all_membership_sales_data sa
    -- 		LEFT JOIN members_purchase_on AS mp ON sa.member_number_members_sa = mp.member_number_members_sa
    --     WHERE    
    --         sa.new_member_category_6_sa IN (@member_category)
    --         AND
    --         sa.purchased_on_year_mp IN (2023)
    --     GROUP BY sa.purchased_on_year_mp WITH ROLLUP 
    --     ORDER BY sa.purchased_on_year_mp
    -- )

    -- ,
    -- summary_stats AS (
    --     SELECT 
    --         DISTINCT
    --         sa.member_number_members_sa AS sa_member_number,
    --         mp.member_number_members_sa AS mp_member_number,
    --         sa.id_membership_periods_sa,
    --         sa.real_membership_types_sa,
    --         sa.new_member_category_6_sa,
    --         YEAR(sa.purchased_on_mp),
    --         sa.starts_mp,
    --         sa.ends_mp

    --     FROM all_membership_sales_data sa
    -- 		LEFT JOIN members_purchase_on AS mp ON sa.member_number_members_sa = mp.member_number_members_sa
    --     WHERE    
    --         sa.new_member_category_6_sa IN (@member_category)
    --         AND
    --         sa.purchased_on_year_mp IN (2023)
    --     ORDER BY sa_member_number
    -- )

    -- SELECT * FROM summary_stats;

    ,
    purchases AS (
        SELECT
            DISTINCT
            sa.member_number_members_sa,
            sa.id_membership_periods_sa,
            sa.real_membership_types_sa,
            sa.new_member_category_6_sa,
            sa.purchased_on_mp,
            sa.starts_mp,
            sa.ends_mp
        FROM all_membership_sales_data AS sa
            RIGHT JOIN members_purchase_on AS mp ON sa.member_number_members_sa = mp.member_number_members_sa
    )

    -- SELECT
    --     FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS members_count,
    --     FORMAT(COUNT(*), 0) AS sales_units
    -- FROM purchases;    

    -- SELECT
    --     -- DISTINCT
    --     YEAR(purchased_on_mp),
    --     FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS members_count,
    --     FORMAT(COUNT(*), 0) AS sales_units
    -- FROM purchases
    -- GROUP BY YEAR(purchased_on_mp) WITH ROLLUP
    -- ORDER BY YEAR(purchased_on_mp);    

    -- SELECT * FROM purchases;

    -- COUNT PURCHASES OF OTHER MEMBERSHIP TYPES IN ADDITION TO THREE YEAR
    SELECT 
        DISTINCT
        new_member_category_6_sa, 
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2020 THEN member_number_members_sa END) AS year_2020,
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2021 THEN member_number_members_sa END) AS year_2021,
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2022 THEN member_number_members_sa END) AS year_2022,
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2023 THEN member_number_members_sa END) AS year_2023,
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2024 THEN member_number_members_sa END) AS year_2024,
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2025 THEN member_number_members_sa END) AS year_2025,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS members_count,
        FORMAT(COUNT(*), 0) AS sales_units
    FROM purchases
    WHERE YEAR(purchased_on_mp) < 2024
    GROUP BY new_member_category_6_sa WITH ROLLUP
    ORDER BY new_member_category_6_sa;

-- *******************************************

-- UNIQUE PURCHASES BY MEMBER NUMBER

-- #2) SALES BY PURCHASE ON YEAR 2024
        SELECT 
            purchased_on_year_mp,
            FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS members_count,
            FORMAT(COUNT(*), 0) AS sales_units,
            FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
        FROM all_membership_sales_data
        WHERE new_member_category_6_sa IN (@member_category_1year, @member_category_silver, @member_category_gold)
        GROUP BY purchased_on_year_mp WITH ROLLUP 
        ORDER BY purchased_on_year_mp;
    -- *******************************************

    -- CTE = DETERMINE PRODUCT PURCHASED FOR 2023 PURCHASE ON DATE
    WITH members_purchase_on AS (
        SELECT    
            DISTINCT member_number_members_sa
        FROM all_membership_sales_data
        WHERE 
            new_member_category_6_sa IN (@member_category)
            AND
            purchased_on_year_mp IN (2024)
        ORDER BY member_number_members_sa
    )

    -- SELECT * FROM members_purchase_on ORDER BY member_number_members_sa;
        
    -- SELECT DISTINCT(member_number_members_sa) FROM members_purchase_on ORDER BY member_number_members_sa;

    -- PROVIDES COUNT SUMMARY TO MATCH #1 ABOVE
    -- ,
    -- summary_stats AS (
    --     SELECT 
    --         sa.purchased_on_year_mp,
    --         FORMAT(COUNT(DISTINCT(sa.member_number_members_sa)), 0) AS members_count,
    --         FORMAT(COUNT(*), 0) AS sales_units,
    --         FORMAT(SUM(sa.actual_membership_fee_6_sa), 0) AS sales_revenue
    --     FROM all_membership_sales_data sa
    -- 		LEFT JOIN members_purchase_on AS mp ON sa.member_number_members_sa = mp.member_number_members_sa
    --     WHERE    
    --         sa.new_member_category_6_sa IN (@member_category)
    --         AND
    --         sa.purchased_on_year_mp IN (2023)
    --     GROUP BY sa.purchased_on_year_mp WITH ROLLUP 
    --     ORDER BY sa.purchased_on_year_mp
    -- )

    -- ,
    -- summary_stats AS (
    --     SELECT 
    --         DISTINCT
    --         sa.member_number_members_sa AS sa_member_number,
    --         mp.member_number_members_sa AS mp_member_number,
    --         sa.id_membership_periods_sa,
    --         sa.real_membership_types_sa,
    --         sa.new_member_category_6_sa,
    --         YEAR(sa.purchased_on_mp),
    --         sa.starts_mp,
    --         sa.ends_mp

    --     FROM all_membership_sales_data sa
    -- 		LEFT JOIN members_purchase_on AS mp ON sa.member_number_members_sa = mp.member_number_members_sa
    --     WHERE    
    --         sa.new_member_category_6_sa IN (@member_category)
    --         AND
    --         sa.purchased_on_year_mp IN (2023)
    --     ORDER BY sa_member_number
    -- )

    -- SELECT * FROM summary_stats;

    ,
    purchases AS (
        SELECT
            DISTINCT
            sa.member_number_members_sa,
            sa.id_membership_periods_sa,
            sa.real_membership_types_sa,
            sa.new_member_category_6_sa,
            sa.purchased_on_mp,
            sa.starts_mp,
            sa.ends_mp
        FROM all_membership_sales_data AS sa
            RIGHT JOIN members_purchase_on AS mp ON sa.member_number_members_sa = mp.member_number_members_sa
    )

    -- SELECT
    --     FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS members_count,
    --     FORMAT(COUNT(*), 0) AS sales_units
    -- FROM purchases;    

    -- SELECT
    --     -- DISTINCT
    --     YEAR(purchased_on_mp),
    --     FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS members_count,
    --     FORMAT(COUNT(*), 0) AS sales_units
    -- FROM purchases
    -- GROUP BY YEAR(purchased_on_mp) WITH ROLLUP
    -- ORDER BY YEAR(purchased_on_mp);    

    -- SELECT * FROM purchases;

    -- COUNT PURCHASES OF OTHER MEMBERSHIP TYPES IN ADDITION TO THREE YEAR
    SELECT 
        DISTINCT
        new_member_category_6_sa, 
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2020 THEN member_number_members_sa END) AS year_2020,
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2021 THEN member_number_members_sa END) AS year_2021,
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2022 THEN member_number_members_sa END) AS year_2022,
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2023 THEN member_number_members_sa END) AS year_2023,
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2024 THEN member_number_members_sa END) AS year_2024,
        COUNT(DISTINCT CASE WHEN YEAR(purchased_on_mp) = 2025 THEN member_number_members_sa END) AS year_2025,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS members_count,
        FORMAT(COUNT(*), 0) AS sales_units
    FROM purchases
    WHERE YEAR(purchased_on_mp) < 2025
    GROUP BY new_member_category_6_sa WITH ROLLUP
    ORDER BY new_member_category_6_sa;

-- *******************************************