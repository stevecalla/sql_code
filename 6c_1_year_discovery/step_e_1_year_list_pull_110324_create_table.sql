USE usat_sales_db;
SET @member_category = '1-Year $50';

SET @year_1 = 2023;
SET @year_2 = 2024;
SET @year_2023 = 2023;   
SET @year_2024 = 2024;   
SET @year_2025 = 2025;    

-- use create for the first data set
-- use insert for additional data sets
-- remove the order by cast statement as it causes an error
-- replace CTE with the appropriate version
-- LEFT(new_member_category_6_sa, 255)

-- DROP TABLE IF EXISTS relaunch_3_year_110324;

INSERT INTO relaunch_3_year_110324 (
    member_number_members_sa, 
    id_profiles, 
    test_group, 
    list_pull, 
    max_end_mp_sa, 
    purchase_count 
    -- member_categories
)
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
            ORDER BY mw.member_number_members_sa, sa.ends_mp ASC
        )
        
		, list_pull AS (
            SELECT
                ph.member_number_members_sa
                , ph.id_profiles
                , CASE WHEN RAND() < 0.2 THEN 'Control' ELSE 'Experiment' END AS test_group
                , '1_Year_2024_End' AS list_pull
                -- , new_member_category_6_sa
                , MAX(ph.ends_mp_sa) AS max_end_mp_sa
                , COUNT(ph.id_profiles)
                -- , GROUP_CONCAT(LEFT(ph.new_member_category_6_sa, 255))
            FROM purchase_history AS ph
                LEFT JOIN sales_key_stats_2015 AS sa ON ph.member_number_members_sa = sa.member_number_members_sa
            WHERE sa.age_as_year_end_bin IN ('40-49', '50-59')
            GROUP BY 1, 2
            HAVING YEAR(max_end_mp_sa) < 2025
            ORDER BY ph.member_number_members_sa, ph.id_profiles
        )

        SELECT * FROM list_pull;
-- ########################################

INSERT INTO relaunch_3_year_110324 (
    member_number_members_sa, 
    id_profiles, 
    test_group, 
    list_pull, 
    max_end_mp_sa, 
    purchase_count 
    -- member_categories
)
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
                sa.age_as_year_end_bin,

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
            ORDER BY mw.member_number_members_sa, sa.purchased_on_adjusted_mp DESC
        )

        , list_pull AS (
            SELECT
                ph.member_number_members_sa
                , ph.id_profiles
                , CASE WHEN RAND() < 0.2 THEN 'Control' ELSE 'Experiment' END AS test_group
                , '1_Year_2023_End' AS list_pull
                -- , new_member_category_6_sa
                , MAX(ph.ends_mp_sa) AS max_end_mp_sa
                , COUNT(ph.id_profiles)
                -- , GROUP_CONCAT(LEFT(ph.new_member_category_6_sa, 255))
            FROM purchase_history AS ph
                LEFT JOIN sales_key_stats_2015 AS sa ON ph.member_number_members_sa = sa.member_number_members_sa
            WHERE sa.age_as_year_end_bin IN ('40-49', '50-59')
            GROUP BY 1, 2   
            HAVING YEAR(max_end_mp_sa) < 2024
            ORDER BY ph.member_number_members_sa, ph.id_profiles
        )

        SELECT * FROM list_pull;
        
-- ########################################