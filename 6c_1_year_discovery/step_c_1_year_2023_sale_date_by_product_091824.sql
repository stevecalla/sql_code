USE usat_sales_db;

SET @member_category = '1-Year $50';

SET @year_2023 = 2023;   
SET @year_2024 = 2024;   

-- SECTION: #1) SALES BY PURCHASE ON YEAR
    SELECT 
        purchased_on_year_adjusted_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS members_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data_2015_left
    WHERE new_member_category_6_sa IN (@member_category)
    GROUP BY purchased_on_year_adjusted_mp WITH ROLLUP 
    ORDER BY purchased_on_year_adjusted_mp;
-- ##################################################

-- SECTION: #2) - SALES BY PURCHASE ON YEAR BY MONTH
    SELECT 
        purchased_on_year_adjusted_mp,
        purchased_on_month_adjusted_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS members_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data_2015_left
    WHERE new_member_category_6_sa IN (@member_category)
    GROUP BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp WITH ROLLUP 
    ORDER BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp;
-- ##################################################

-- SECTION: #3) - ROLLUP = WHAT IS THE PRODUCT PURCHASED PRIOR TO THE 3-YEAR 2023 PURCHASE?
    WITH members_with_purchase_in_2023 AS (
        SELECT 
            DISTINCT member_number_members_sa,
            ends_mp,
            purchased_on_adjusted_mp
            -- purchased_on_year_adjusted_mp
            -- new_member_category_6_sa,
            -- purchased_on_adjusted_mp,
            -- starts_mp,
        FROM all_membership_sales_data_2015_left
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND purchased_on_year_adjusted_mp IN (@year_2023) -- purchased in 2023
        )
        
        -- SELECT COUNT(DISTINCT(member_number_members_sa)) AS unique_member_count, COUNT(member_number_members_sa) AS sales_units FROM members_with_purchase_in_2023;
        -- SELECT * FROM members_with_purchase_in_2023 WHERE member_number_members_sa IN (893515390); -- TIME ZONE ISSUE; ADJUSTED ALL DATES BACK TO MTN

        -- CTE to purchase history prior to the 3-year expiration date only; not a complete history
        , purchase_history AS (
            SELECT
                mw.member_number_members_sa,
                mw.purchased_on_adjusted_mp AS purchased_on_adjusted_mp_mw,
                mw.ends_mp AS ends_mp_mw, -- 2024 ends date
                sa.new_member_category_6_sa, 
                sa.id_membership_periods_sa,
                sa.purchased_on_adjusted_mp AS purchased_on_adjusted_mp_sa,
                sa.starts_mp,
                sa.ends_mp AS ends_mp_sa, -- end date for membership period

                MAX(sa.ends_mp) OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.ends_mp DESC) AS max_ends_mp,
                ROW_NUMBER() OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.purchased_on_adjusted_mp ASC) AS rn,
                COUNT(mw.member_number_members_sa) OVER (PARTITION BY mw.member_number_members_sa) AS member_purchase_count, -- count of purchases for each member

                CASE   
                    WHEN 
                        ROW_NUMBER() OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.purchased_on_adjusted_mp ASC) 
                        = 
                        (COUNT(mw.member_number_members_sa) OVER (PARTITION BY mw.member_number_members_sa) - 1) THEN 1 -- if more than 1 purchase then flag 2nd most recent
                    WHEN COUNT(mw.member_number_members_sa) OVER (PARTITION BY mw.member_number_members_sa) = 1 THEN 1 -- only 1 purchase
                    ELSE 0
                END AS is_previous_to_last_purchase -- in most instances the last purchase is 3-Year based on the where clause below

            FROM members_with_purchase_in_2023 AS mw
                LEFT JOIN all_membership_sales_data_2015_left AS sa ON mw.member_number_members_sa = sa.member_number_members_sa
            WHERE sa.purchased_on_adjusted_mp <= mw.purchased_on_adjusted_mp -- filters for purchases with purchase date less than the 2023 3-year purchase
            ORDER BY mw.member_number_members_sa, sa.purchased_on_adjusted_mp
        )

        -- SELECT * FROM purchase_history;
        -- SELECT COUNT(DISTINCT(member_number_members_sa)) AS unique_member_count, COUNT(id_membership_periods_sa) AS sales_units FROM purchase_history;
        -- SELECT * FROM purchase_history WHERE rn = 1;
        -- SELECT * FROM purchase_history WHERE rn = 1 AND member_purchase_count = 3 ORDER BY new_member_category_6_sa;
        -- SELECT * FROM purchase_history WHERE member_purchase_count = 10;   
        -- SELECT * FROM purchase_history WHERE member_purchase_count = 1 OR (rn = member_purchase_count - 1 AND is_previous_to_last_purchase = 1); -- VERIFIES THAT 2ND TO LAST ROW IS FLAGGED     
        -- SELECT * FROM purchase_history WHERE member_number_members_sa IN (127636);

        -- SELECT * FROM purchase_history WHERE member_number_members_sa IN (893515390);
        -- SELECT 
        --     m.member_number_members_sa,
        --     m.new_member_category_6_sa,
        --     m.purchased_on_adjusted_mp,
        --     m.starts_mp,
        --     m.ends_mp_sa,
        --     m.ends_mp_mw,
        --     m.max_ends_mp,
        --     m.rn
        -- FROM purchase_history AS m
        -- WHERE 
        --     m.rn = 1  -- Only take the most recent purchase prior to the 3-year ending in 2023
        --     -- AND m.ends_mp_sa < '2023-01-01'  -- Ensure the end date is prior to the start of 2023
		-- 	-- 100299 = 1-Year $50, 100690993 = 1-Year $50, 103153053 = One Day $15
		-- 	AND m.member_number_members_sa IN (100299, 100690993, 103153053)
        -- ORDER BY m.member_number_members_sa;

        SELECT 
            new_member_category_6_sa,
            
            COUNT(DISTINCT CASE WHEN YEAR(purchased_on_adjusted_mp_sa) < @year_2023 THEN member_number_members_sa END) AS 'sale_<2023',
            COUNT(DISTINCT CASE WHEN YEAR(purchased_on_adjusted_mp_sa) = @year_2023 THEN member_number_members_sa END) AS 'sale_2023',
            COUNT(DISTINCT CASE WHEN YEAR(purchased_on_adjusted_mp_sa) > @year_2023 THEN member_number_members_sa END) AS 'Other',

            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 1 THEN member_number_members_sa END) AS January,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 2 THEN member_number_members_sa END) AS February,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 3 THEN member_number_members_sa END) AS March,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 4 THEN member_number_members_sa END) AS April,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 5 THEN member_number_members_sa END) AS May,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 6 THEN member_number_members_sa END) AS June,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 7 THEN member_number_members_sa END) AS July,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 8 THEN member_number_members_sa END) AS August,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 9 THEN member_number_members_sa END) AS September,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 10 THEN member_number_members_sa END) AS October,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 11 THEN member_number_members_sa END) AS November,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 12 THEN member_number_members_sa END) AS December,

            FORMAT(COUNT(DISTINCT member_number_members_sa), 0) AS member_count,
            SUM(member_purchase_count)
        FROM purchase_history
        WHERE is_previous_to_last_purchase = 1
        GROUP BY new_member_category_6_sa WITH ROLLUP
        ORDER BY new_member_category_6_sa; -- total 6,040
    ;
-- ##################################################

-- SECTION: #4) - ROLLUP = WHAT IS THE PRODUCT PURCHASED PRIOR TO THE 3-YEAR 2023 PURCHASE BY NUMBER OF PURCHASES?
-- SAME AS QUERY ABOVE EXCEPT LAST SELECT STATEMENT
    WITH members_with_purchase_in_2023 AS (
        SELECT 
            DISTINCT member_number_members_sa,
            ends_mp,
            purchased_on_adjusted_mp
            -- purchased_on_year_adjusted_mp
            -- new_member_category_6_sa,
            -- purchased_on_adjusted_mp,
            -- starts_mp,
        FROM all_membership_sales_data_2015_left
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND purchased_on_year_adjusted_mp IN (@year_2023)                    -- Only include members with end date in 2024
        )

        -- CTE to purchase history prior to the 3-year expiration date only; not a complete history
        , purchase_history AS (
            SELECT
                mw.member_number_members_sa,
                mw.purchased_on_adjusted_mp AS purchased_on_adjusted_mp_mw,
                mw.ends_mp AS ends_mp_mw, -- 2024 ends date
                sa.new_member_category_6_sa, 
                sa.id_membership_periods_sa,
                sa.purchased_on_adjusted_mp AS purchased_on_adjusted_mp_sa,
                sa.starts_mp,
                sa.ends_mp AS ends_mp_sa, -- end date for membership period

                MAX(sa.ends_mp) OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.ends_mp DESC) AS max_ends_mp, -- max end date
                ROW_NUMBER() OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.purchased_on_adjusted_mp ASC) AS rn, -- orders max end date = row 1
                COUNT(mw.member_number_members_sa) OVER (PARTITION BY mw.member_number_members_sa) AS member_purchase_count, -- count of purchases for each member

                CASE   
                    WHEN 
                        ROW_NUMBER() OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.purchased_on_adjusted_mp ASC) 
                        = 
                        (COUNT(mw.member_number_members_sa) OVER (PARTITION BY mw.member_number_members_sa) - 1) THEN 1 -- if more than 1 purchase then flag 2nd most recent
                    WHEN COUNT(mw.member_number_members_sa) OVER (PARTITION BY mw.member_number_members_sa) = 1 THEN 1 -- only 1 purchase
                    ELSE 0
                END AS is_previous_to_last_purchase -- in most instances the last purchase is 3-Year based on the where clause below

            FROM members_with_purchase_in_2023 AS mw
                LEFT JOIN all_membership_sales_data_2015_left AS sa ON mw.member_number_members_sa = sa.member_number_members_sa
            WHERE sa.purchased_on_adjusted_mp <= mw.purchased_on_adjusted_mp -- filters for purchases with purchase date less than the 2023 3-year purchase
            ORDER BY mw.member_number_members_sa, sa.purchased_on_adjusted_mp
        )

        SELECT
            member_purchase_count,
            new_member_category_6_sa,
            
            COUNT(DISTINCT CASE WHEN YEAR(purchased_on_adjusted_mp_sa) < @year_2023 THEN member_number_members_sa END) AS 'sale_<2023',
            COUNT(DISTINCT CASE WHEN YEAR(purchased_on_adjusted_mp_sa) = @year_2023 THEN member_number_members_sa END) AS 'sale_2023',
            COUNT(DISTINCT CASE WHEN YEAR(purchased_on_adjusted_mp_sa) > @year_2023 THEN member_number_members_sa END) AS 'Other',

            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 1 THEN member_number_members_sa END) AS January,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 2 THEN member_number_members_sa END) AS February,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 3 THEN member_number_members_sa END) AS March,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 4 THEN member_number_members_sa END) AS April,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 5 THEN member_number_members_sa END) AS May,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 6 THEN member_number_members_sa END) AS June,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 7 THEN member_number_members_sa END) AS July,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 8 THEN member_number_members_sa END) AS August,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 9 THEN member_number_members_sa END) AS September,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 10 THEN member_number_members_sa END) AS October,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 11 THEN member_number_members_sa END) AS November,
            COUNT(DISTINCT CASE WHEN MONTH(purchased_on_adjusted_mp_mw) = 12 THEN member_number_members_sa END) AS December,

            FORMAT(COUNT(DISTINCT member_number_members_sa), 0) AS member_count,
            SUM(member_purchase_count)
        FROM purchase_history 
        WHERE is_previous_to_last_purchase = 1
        GROUP BY member_purchase_count, new_member_category_6_sa
        ORDER BY member_purchase_count; -- total 6,040
;
-- ##################################################