USE usat_sales_db;
SET @member_category = '3-Year';

SET @year_1 = 2023;
SET @year_2 = 2024;
SET @year_2023 = 2023;   
SET @year_2024 = 2024;   
SET @year_2025 = 2025;   

-- #1) SECTION: STATS = TOTALS
    SELECT 
		new_member_category_6_sa,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(sales_revenue), 0) AS sales_revenue
    FROM sales_key_stats_2015
    WHERE new_member_category_6_sa IN (@member_category)
    GROUP BY new_member_category_6_sa;
-- ==================================================

-- #3) SECTION: STATS = BY MEMBERSHIP END PERIOD DATE = YEAR
    SELECT 
        YEAR(ends_mp),
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(sales_revenue), 0) AS sales_revenue
    FROM sales_key_stats_2015
    WHERE new_member_category_6_sa IN (@member_category)
    GROUP BY YEAR(ends_mp) WITH ROLLUP
    ORDER BY YEAR(ends_mp);
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- #14) SECTION: ROLLUP = MEMBERS BY MAX END PERIOD BY 2024 3-YEAR END
    WITH members_with_ends_in_2024 AS (
        SELECT 
            DISTINCT member_number_members_sa,
            ends_mp,
            purchased_on_adjusted_mp
            -- purchased_on_year_adjusted_mp
            -- new_member_category_6_sa,
            -- purchased_on_adjusted_mp,
            -- starts_mp,
        FROM sales_key_stats_2015
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND YEAR(ends_mp) = @year_2024 -- ends in 2024
        )

        -- SELECT COUNT(DISTINCT member_number_members_sa) FROM members_with_ends_in_2024;

        -- CTE to purchase history after the 3-year expiration date only; not a complete history
        , purchase_history AS (
            SELECT
                mw.member_number_members_sa,
                sa.id_profiles,
                mw.ends_mp AS ends_mp_mw, -- 2024 ends date
                sa.new_member_category_6_sa, 
                sa.id_membership_periods_sa,
                sa.purchased_on_adjusted_mp,
                sa.starts_mp,
                sa.ends_mp AS ends_mp_sa, -- end date for membership period

                MAX(sa.ends_mp) OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.ends_mp DESC) AS max_ends_mp,
                ROW_NUMBER() OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.ends_mp) AS rn,
                COUNT(mw.member_number_members_sa) OVER (PARTITION BY mw.member_number_members_sa) AS member_purchase_count, -- count of purchases for each member

                CASE   
                    WHEN 
                        sa.ends_mp = MAX(sa.ends_mp) OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.ends_mp DESC) THEN 1
                        -- ROW_NUMBER() OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.purchased_on_adjusted_mp DESC) = 1 THEN 1 -- only 1 purchase
                    ELSE 0
                END AS is_max_end_after_2024_end -- in most instances the last purchase is 3-Year based on the where clause below

            FROM members_with_ends_in_2024 AS mw
                LEFT JOIN sales_key_stats_2015 AS sa ON mw.member_number_members_sa = sa.member_number_members_sa
            WHERE 
				sa.ends_mp >= mw.ends_mp
				AND sa.purchased_on_year_adjusted_mp < 2025
            ORDER BY CAST(mw.member_number_members_sa AS UNSIGNED), sa.ends_mp ASC
        )

        -- SELECT * FROM purchase_history;

        -- SELECT
        --     member_number_members_sa
        --     , id_profiles
        --     , new_member_category_6_sa
        --     , ends_mp_sa
        --     , COUNT(id_profiles)
        --     -- , MAX(ends_mp_sa) AS max_end_mp_sa
        -- FROM purchase_history
        -- GROUP BY 1, 2, 3, 4
        -- -- HAVING YEAR(max_end_mp_sa) < 2025
        -- ORDER BY CAST(member_number_members_sa AS UNSIGNED), id_profiles, ends_mp_sa;
        
		, list_pull AS (
            SELECT
                member_number_members_sa
                , id_profiles
                , CASE WHEN RAND() < 0.2 THEN 'Control' ELSE 'Experiment' END AS test_group
                , '3_Year_2024_End' AS list_pull
                -- , new_member_category_6_sa
                , MAX(ends_mp_sa) AS max_end_mp_sa
                , COUNT(id_profiles)
                , GROUP_CONCAT(new_member_category_6_sa)
            FROM purchase_history
            GROUP BY 1, 2
            HAVING YEAR(max_end_mp_sa) < 2025
            ORDER BY CAST(member_number_members_sa AS UNSIGNED), id_profiles
        )

        SELECT * FROM list_pull
        
        -- SELECT 
        --     YEAR(max_ends_mp),
            
        --     COUNT(DISTINCT CASE WHEN YEAR(ends_mp_sa) = @year_2024 THEN member_number_members_sa END) AS 'ends_2024',
        --     COUNT(DISTINCT CASE WHEN YEAR(ends_mp_sa) > @year_2024 THEN member_number_members_sa END) AS 'ends_2025+',
        --     COUNT(DISTINCT CASE WHEN YEAR(ends_mp_sa) < @year_2024 THEN member_number_members_sa END) AS 'Other',

        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 1 THEN member_number_members_sa END) AS January,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 2 THEN member_number_members_sa END) AS February,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 3 THEN member_number_members_sa END) AS March,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 4 THEN member_number_members_sa END) AS April,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 5 THEN member_number_members_sa END) AS May,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 6 THEN member_number_members_sa END) AS June,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 7 THEN member_number_members_sa END) AS July,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 8 THEN member_number_members_sa END) AS August,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 9 THEN member_number_members_sa END) AS September,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 10 THEN member_number_members_sa END) AS October,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 11 THEN member_number_members_sa END) AS November,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 12 THEN member_number_members_sa END) AS December,
            
        --     FORMAT(COUNT(DISTINCT member_number_members_sa), 0) AS member_count,
        --     SUM(member_purchase_count)
        -- FROM purchase_history
        -- WHERE is_max_end_after_2024_end = 1
        -- GROUP BY YEAR(max_ends_mp) WITH ROLLUP
        -- ORDER BY YEAR(max_ends_mp);  -- 4847
    ;
-- ##################################################

-- #20) SECTION: ROLLUP = WHAT IS THE MAX EXPIRATION PRODUCT AFTER 2023 3-YEAR END (without purchase date restriction as in #18)?
    WITH members_with_ends_in_2023 AS (
        SELECT 
            DISTINCT member_number_members_sa,
            ends_mp,
            purchased_on_adjusted_mp
            -- purchased_on_year_adjusted_mp
            -- new_member_category_6_sa,
            -- purchased_on_adjusted_mp,
            -- starts_mp,
        FROM sales_key_stats_2015
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND YEAR(ends_mp) = @year_2023 -- ends in 2023
        )

        -- SELECT * FROM members_with_ends_in_2023;

        -- CTE to purchase history after the 3-year expiration date only; not a complete history
        , purchase_history AS (
            SELECT
                mw.member_number_members_sa,
                sa.id_profiles,
                mw.ends_mp AS ends_mp_mw, -- 2024 ends date
                sa.new_member_category_6_sa, 
                sa.id_membership_periods_sa,
                sa.purchased_on_adjusted_mp,
                sa.starts_mp,
                sa.ends_mp AS ends_mp_sa, -- end date for membership period

                MAX(sa.ends_mp) OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.ends_mp DESC) AS max_ends_mp,
                ROW_NUMBER() OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.purchased_on_adjusted_mp DESC) AS rn,
                COUNT(mw.member_number_members_sa) OVER (PARTITION BY mw.member_number_members_sa) AS member_purchase_count, -- count of purchases for each member

                CASE   
                    WHEN 
                        sa.ends_mp = MAX(sa.ends_mp) OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.ends_mp DESC) THEN 1
                        -- ROW_NUMBER() OVER (PARTITION BY mw.member_number_members_sa ORDER BY sa.purchased_on_adjusted_mp DESC) = 1 THEN 1 -- only 1 purchase
                    ELSE 0
                END AS is_max_end_after_2023_end -- in most instances the last purchase is 3-Year based on the where clause below

            FROM members_with_ends_in_2023 AS mw
                LEFT JOIN sales_key_stats_2015 AS sa ON mw.member_number_members_sa = sa.member_number_members_sa
            WHERE 
                -- sa.purchased_on_adjusted_mp >= mw.purchased_on_adjusted_mp -- filters for purchases with purchase date greater than the 2023 3-year end date
                sa.ends_mp >= mw.ends_mp
                -- AND sa.purchased_on_year_adjusted_mp < @year_2024
            ORDER BY CAST(mw.member_number_members_sa AS UNSIGNED), sa.purchased_on_adjusted_mp DESC
        )

        -- SELECT * FROM purchase_history;

        -- SELECT
        --     member_number_members_sa
        --     , id_profiles
        --     , new_member_category_6_sa
        --     , ends_mp_sa
        --     , COUNT(id_profiles)
        --     -- , MAX(ends_mp_sa) AS max_end_mp_sa
        -- FROM purchase_history
        -- GROUP BY 1, 2, 3, 4
        -- -- HAVING YEAR(max_end_mp_sa) < 2024
        -- ORDER BY member_number_members_sa, id_profiles, ends_mp_sa;
        
		, list_pull AS (
            SELECT
                member_number_members_sa
                , id_profiles
                , CASE WHEN RAND() < 0.2 THEN 'Control' ELSE 'Experiment' END AS test_group
                , '3_Year_2023_End' AS list_pull
                -- , new_member_category_6_sa
                , MAX(ends_mp_sa) AS max_end_mp_sa
                , COUNT(id_profiles)
                , GROUP_CONCAT(new_member_category_6_sa)
            FROM purchase_history
            GROUP BY 1, 2
            HAVING YEAR(max_end_mp_sa) < 2024
            ORDER BY CAST(member_number_members_sa AS UNSIGNED), id_profiles
        )

        SELECT * FROM list_pull
        
        -- SELECT 
        --     new_member_category_6_sa,
            
        --     COUNT(DISTINCT CASE WHEN YEAR(ends_mp_sa) = @year_2023 THEN member_number_members_sa END) AS 'ends_2023',
        --     COUNT(DISTINCT CASE WHEN YEAR(ends_mp_sa) > @year_2023 THEN member_number_members_sa END) AS 'ends_2024+',
        --     COUNT(DISTINCT CASE WHEN YEAR(ends_mp_sa) < @year_2023 THEN member_number_members_sa END) AS 'Other',

        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 1 THEN member_number_members_sa END) AS January,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 2 THEN member_number_members_sa END) AS February,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 3 THEN member_number_members_sa END) AS March,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 4 THEN member_number_members_sa END) AS April,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 5 THEN member_number_members_sa END) AS May,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 6 THEN member_number_members_sa END) AS June,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 7 THEN member_number_members_sa END) AS July,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 8 THEN member_number_members_sa END) AS August,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 9 THEN member_number_members_sa END) AS September,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 10 THEN member_number_members_sa END) AS October,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 11 THEN member_number_members_sa END) AS November,
        --     COUNT(DISTINCT CASE WHEN MONTH(ends_mp_mw) = 12 THEN member_number_members_sa END) AS December,

        --     FORMAT(COUNT(DISTINCT member_number_members_sa), 0) AS member_count,
        --     SUM(member_purchase_count)
        -- FROM purchase_history
        -- WHERE is_max_end_after_2023_end = 1
        -- GROUP BY new_member_category_6_sa WITH ROLLUP
        -- ORDER BY new_member_category_6_sa; -- 1,265
    ;
-- ##################################################