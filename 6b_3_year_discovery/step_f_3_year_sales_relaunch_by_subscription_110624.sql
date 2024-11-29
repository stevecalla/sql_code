USE usat_sales_db;

SET @member_category = '3-Year';
SET @year_1 = 2023;
SET @year_2 = 2024;
SET @year_2023 = 2023;   
SET @year_2024 = 2024;   
SET @year_2025 = 2025;   

-- Create an index on the first 255 characters of the `origin_flag_ma` column
-- CREATE INDEX idx_origin_flag_ma ON all_membership_sales_data_2015_left (origin_flag_ma(255));

-- #1) LIST PULL: AS OF 110524 FOR 3-YEAR RELAUNCH CAMPAIGN
    SELECT * FROM usat_sales_db.relaunch_3_year_110524 LIMIT 10;
    SELECT 		
        list_pull AS as list_pull_segment,
        SUM(CASE WHEN LOWER(test_group) IN ('control') THEN 1 ELSE 0 END) AS control,
        SUM(CASE WHEN LOWER(test_group) IN ('experiment') THEN 1 ELSE 0 END) AS experiment,
        COUNT(*) 
	FROM usat_sales_db.relaunch_3_year_110524 
    GROUP BY 1
    ORDER BY 1 DESC
    ;
-- *****************

-- #2) ORIGIN FLAG: summarize origin flag subscription by new member category
    -- ORIGIN FLAG ONLY GOOD FOR 2023 & 2024
    SELECT
        new_member_category_6_sa, 
        COUNT(*)
    FROM all_membership_sales_data_2015_left
    WHERE origin_flag_ma IN ('SUBSCRIPTION_RENEWAL')
    GROUP BY 1 WITH ROLLUP;
-- *****************

-- #3) 3-YEAR SALES: TREND OVER TIME >= 2021 BY PUrCHASE DATE
    -- ORIGIN FLAG ONLY GOOD FOR 2023 & 2024
    SELECT  
        -- new_member_category_6_sa,
        IFNULL(purchased_on_year_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
        IFNULL(purchased_on_month_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
        IFNULL(purchased_on_date_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,

        SUM(CASE WHEN LOWER(real_membership_types_sa) IN ('adult_annual') THEN 1 ELSE 0 END) AS 'adult_annual',
        SUM(CASE WHEN LOWER(real_membership_types_sa) IN ('one_day') THEN 1 ELSE 0 END) AS 'one_day',
        SUM(CASE WHEN LOWER(real_membership_types_sa) IN ('youth_annual') THEN 1 ELSE 0 END) AS 'youth_annual',
        SUM(CASE WHEN LOWER(real_membership_types_sa) IN ('elite') THEN 1 ELSE 0 END) AS 'elite',
        SUM(CASE WHEN LOWER(real_membership_types_sa) IN ('other') THEN 1 ELSE 0 END) AS 'other',
        SUM(CASE WHEN LOWER(new_member_category_6_sa) IN ('3-year') THEN 1 ELSE 0 END) AS '3-year_sales',
        COUNT(*) as total_sales
    FROM all_membership_sales_data_2015_left      
    WHERE 
        -- new_member_category_6_sa IN ('3-Year')
        -- AND 
        purchased_on_year_adjusted_mp IN ('2022', '2023', '2024')
    GROUP BY 3, 2, 1
    ORDER BY 3 DESC
    -- LIMIT 100
    ;
-- *****************

-- #4) 3-YEAR SALES: by multiple, subscription, new/repeat, control/experiment/other  
    SELECT 
        IFNULL(ks.purchased_on_year_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
        IFNULL(ks.purchased_on_month_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
        IFNULL(ks.purchased_on_date_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
        list_pull,
        new_member_category_6_sa,

        -- by multiple purchases
        SUM(CASE 
            WHEN purchase_count > 1 THEN 1 
            ELSE 0 
        END) AS multiple_purchase_count,

        -- by subscription purchase
        SUM(CASE WHEN ks.origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 1 ELSE 0 END) AS subscription_purchase,

        -- by new/repeat
        SUM(CASE WHEN ks.member_created_at_category IN ('created_year') THEN 1 ELSE 0 END) AS new_member,
        SUM(CASE WHEN ks.member_created_at_category IN ('after_created_year') THEN 1 ELSE 0 END) AS repeat_member,

        -- by control / experiment / not in relaunch
        SUM(CASE WHEN rl.test_group = 'control' THEN 1 ELSE 0 END) AS control_group,
        SUM(CASE WHEN rl.test_group = 'experiment' THEN 1 ELSE 0 END) AS experiment_group,
        -- Members that do not exist in the relaunch table thus not part of the campaign
        SUM(CASE WHEN rl.member_number_members_sa IS NULL THEN 1 ELSE 0 END) AS not_in_relaunch,

        -- counts
        COUNT(*) AS total_count
    FROM sales_key_stats_2015 AS ks
        LEFT JOIN relaunch_3_year_110524 AS rl ON ks.member_number_members_sa = rl.member_number_members_sa
    WHERE 
        new_member_category_6_sa IN ('3-Year')
        -- AND rl.test_group IN ('control', 'experiment')
        AND purchased_on_year_adjusted_mp IN ('2022', '2023', '2024')
        -- AND purchased_on_month_adjusted_mp IN ('10', '11')
        -- AND purchased_on_adjusted_mp >= '2024-10-26'
    GROUP BY 3, 2, 1, 4
    ORDER BY 3 DESC
    -- LIMIT 100
    ;
-- *****************

-- #4a) 3-YEAR SALES: by multiple, subscription, new/repeat, control/experiment/other  
    SELECT 
        IFNULL(ks.purchased_on_date_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,

        -- by multiple purchases
        SUM(CASE 
            WHEN purchase_count > 1 THEN 1 
            ELSE 0 
        END) AS multiple_purchase_count,

        -- by subscription purchase
        SUM(CASE WHEN ks.origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 1 ELSE 0 END) AS subscription_purchase,

        -- by new/repeat
        SUM(CASE WHEN ks.member_created_at_category IN ('created_year') THEN 1 ELSE 0 END) AS new_member,
        SUM(CASE WHEN ks.member_created_at_category IN ('after_created_year') THEN 1 ELSE 0 END) AS repeat_member,

        -- by control / experiment / not in relaunch
        SUM(CASE WHEN rl.test_group = 'control' THEN 1 ELSE 0 END) AS control_group,
        SUM(CASE WHEN rl.test_group = 'experiment' THEN 1 ELSE 0 END) AS experiment_group,
        -- Members that do not exist in the relaunch table thus not part of the campaign
        SUM(CASE WHEN rl.member_number_members_sa IS NULL THEN 1 ELSE 0 END) AS not_in_relaunch,

        -- counts
        COUNT(*) AS total_count
    FROM sales_key_stats_2015 AS ks
        LEFT JOIN relaunch_3_year_110524 AS rl ON ks.member_number_members_sa = rl.member_number_members_sa
    WHERE 
        new_member_category_6_sa IN ('3-Year')
        AND rl.test_group IN ('control', 'experiment')
        AND ks.purchased_on_year_adjusted_mp IN ('2022', '2023', '2024')
        -- AND purchased_on_month_adjusted_mp IN ('10', '11')
        AND ks.purchased_on_adjusted_mp >= '2024-10-26'
    GROUP BY ks.purchased_on_date_adjusted_mp WITH ROLLUP
    ORDER BY ks.purchased_on_date_adjusted_mp DESC
    -- LIMIT 100
    ;
-- *****************

-- #5) PRICE REVIEW: REVIEW PRICING FOR THE MOST RECENT BOOKING DATE AS QUALITY CHECK 
    SELECT
        member_number_members_sa,
        id_membership_periods_sa,
        id_profiles,
        actual_membership_fee_6_sa,
        IFNULL(purchased_on_date_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
        purchased_on_adjusted_mp,
        COUNT(*) AS total_count
    FROM all_membership_sales_data_2015_left 
    WHERE 
        new_member_category_6_sa IN ('3-Year')
        AND purchased_on_year_adjusted_mp IN ('2024')
        AND purchased_on_month_adjusted_mp IN ('10', '11')
        AND purchased_on_date_adjusted_mp = CURDATE() - INTERVAL 1 DAY
    GROUP BY 1, 2, 3, 4
    ORDER BY purchased_on_adjusted_mp ASC
    LIMIT 100;
-- *****************

-- #6) SALES REVIEW: CHECK SALES TO ENSURE NONE IN THE FUTURE
    SELECT 
        member_number_members_sa,
        id_membership_periods_sa,
        id_profiles,
        new_member_category_6_sa
        actual_membership_fee_6_sa,
        IFNULL(purchased_on_date_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
        purchased_on_adjusted_mp,
        purchased_on_mp,
        starts_mp,
        COUNT(*) AS total_count
    FROM all_membership_sales_data_2015_left 
    WHERE 
        purchased_on_date_adjusted_mp > CURRENT_DATE()
    GROUP BY 1, 2, 3, 4
    ORDER BY purchased_on_adjusted_mp ASC
    LIMIT 100;
-- *****************

-- #7) MOST RECENT PURCHASE: what product did those in the control / experiment group have prior to the most recent purchase?
    -- what was the expiration date?
    WITH three_year_campaign_purchasers AS (
        SELECT
			ks.*,
            rl.test_group,
            rl.list_pull,
            rl.max_end_mp_sa
        FROM relaunch_3_year_110524 AS rl
            LEFT JOIN sales_key_stats_2015 ks ON rl.member_number_members_sa = ks.member_number_members_sa
        WHERE 
            ks.new_member_category_6_sa IN (@member_category)
            AND ks.purchased_on_year_adjusted_mp IN (@year_2024)
            AND ks.purchased_on_month_adjusted_mp IN ('10', '11')
            AND rl.test_group IN ('control', 'experiment')
        -- GROUP BY ks.purchased_on_date_adjusted_mp WITH ROLLUP
        ORDER BY ks.purchased_on_date_adjusted_mp DESC
    )

    -- SELECT * FROM three_year_campaign_purchasers;
    
    -- -- ROLLUP BY PURCHASE ON DATE BY CONTROL, EXPERIMENT, NOT IN RELAUNCH CAMPAIGN
    -- SELECT 
	-- 	IFNULL(purchased_on_date_adjusted_mp, 'Total') AS purchased_on_date_adjusted_mp,
	-- 	SUM(CASE WHEN test_group = 'control' THEN 1 ELSE 0 END) AS control_group,
	-- 	SUM(CASE WHEN test_group = 'experiment' THEN 1 ELSE 0 END) AS experiment_group,
	-- 	-- Members that do not exist in the relaunch table thus not part of the campaign
	-- 	SUM(CASE WHEN member_number_members_sa IS NULL THEN 1 ELSE 0 END) AS not_in_relaunch,
	-- 	COUNT(*) AS total_count
	-- FROM three_year_campaign_purchasers
    -- GROUP BY purchased_on_date_adjusted_mp WITH ROLLUP
    -- ORDER BY purchased_on_date_adjusted_mp DESC;

    -- CTE to count purchases in 2024 for those members
    , end_date_in_2024 AS (
        SELECT
            ty.member_number_members_sa,
            ty.test_group,
            ty.list_pull,
            ty.max_end_mp_sa,
            ks.ends_mp,
            ks.ends_year_mp,
            ks.ends_month_mp,
            ks.new_member_category_6_sa,
            ty.age_as_year_end_bin,
            ks.member_created_at_category,
            COUNT(ty.sales_units) AS sales_units,          -- Count of purchases for each member
            SUM(ty.sales_revenue) AS sales_revenue    -- Total revenue from purchases
        FROM three_year_campaign_purchasers AS ty
            LEFT JOIN sales_key_stats_2015 AS ks ON ty.member_number_members_sa = ks.member_number_members_sa
        WHERE YEAR(ty.max_end_mp_sa) = ks.ends_year_mp AND MONTH(ty.max_end_mp_sa) = ks.ends_month_mp
        -- WHERE ty.member_number_members_sa IN (347250) // didn't match ty.max_end_mp_sa to ks.ends_year_mp
        GROUP BY ty.member_number_members_sa, 2, 3, 4, 5, 6, 7, 8, 9, 10     
    )

    SELECT * FROM end_date_in_2024;

    -- Final select with subquery to get the max ends_mp for each member_number_members_sa
    -- SELECT 
    --     e.*,
    --     -- Subquery to get the maximum ends_mp for each member_number_members_sa
    --     (SELECT MAX(ks.ends_mp)
    --     FROM sales_key_stats_2015 ks
    --     WHERE ks.member_number_members_sa = e.member_number_members_sa) AS max_ends_mp
    -- FROM 
    --     end_date_in_2024 e;
    --     ;
-- ***************************************

-- #8) aLL MEMBER TYPE PURCHASES BY RELAUNCH CAMPAIGN AUDIENCES 10/26 FORWARD
	-- what was the expiration date?
    WITH three_year_campaign_purchasers AS (
        SELECT
            rl.test_group,
            rl.list_pull,
            rl.max_end_mp_sa,
			ks.*
        FROM relaunch_3_year_110524 AS rl
            LEFT JOIN sales_key_stats_2015 ks ON rl.member_number_members_sa = ks.member_number_members_sa
        WHERE 
            -- ks.new_member_category_6_sa IN (@member_category)
            ks.purchased_on_date_adjusted_mp >= '2024-10-26'
            AND rl.test_group IN ('control', 'experiment')
        -- GROUP BY ks.purchased_on_date_adjusted_mp WITH ROLLUP
        ORDER BY member_number_members_sa DESC
    )

    SELECT * FROM three_year_campaign_purchasers;
-- ***************************************

-- #8) ANY MEMBER PURCHASES A 3-YEAR: WHAT WAS THE PRIOR PURCHASE / EXPIRATION
    WITH three_year_new_category_purchasers_102624_forward AS (
        SELECT
			ks.member_number_members_sa,
            ks.real_membership_types_sa,
            ks.new_member_category_6_sa,
            IFNULL(rl.test_group, 'Other') AS test_group,
            IFNULL(rl.list_pull, 'Other') as list_pull,
            ks.age_as_year_end_bin,
            ks.member_created_at_category,
            rl.max_end_mp_sa,
            ks.purchased_on_date_adjusted_mp,
            ks.sales_units,
            ks.sales_revenue,        
            MAX(ks.starts_year_mp) AS max_starts_year_mp_overall, -- Max ends_mp from main dataset
            MAX(ks.starts_month_mp) AS max_starts_month_mp_overall, -- Max ends_mp from main dataset
            MAX(ks.starts_mp) AS max_starts_mp_overall, -- Max ends_mp from main dataset
            
            MAX(ks.ends_year_mp) AS max_ends_year_mp_overall, -- Max ends_mp from main dataset
            MAX(ks.ends_month_mp) AS max_ends_month_mp_overall, -- Max ends_mp from main dataset
            MAX(ks.ends_mp) AS max_ends_mp_overall, -- Max ends_mp from main dataset
                (
            SELECT
                MAX(ends_year_mp) -- Subquery to get the maximum ends_mp in 2024
            FROM sales_key_stats_2015
            WHERE ends_year_mp < '2025'
            AND member_number_members_sa = ks.member_number_members_sa
        ) AS max_ends_year_mp_2024,
        (
            SELECT
                MAX(ends_month_mp) -- Subquery to get the maximum ends_mp in 2024
            FROM sales_key_stats_2015
            WHERE ends_year_mp < '2025'
            AND member_number_members_sa = ks.member_number_members_sa
        ) AS max_ends_month_mp_2024,
        (
            SELECT
                MAX(ends_mp) -- Subquery to get the maximum ends_mp in 2024
            FROM sales_key_stats_2015
            WHERE ends_year_mp < '2025'
            AND member_number_members_sa = ks.member_number_members_sa
        ) AS max_ends_mp_2024,
        (
            SELECT
                new_member_category_6_sa -- Column representing the membership type
            FROM sales_key_stats_2015
            WHERE ends_year_mp < '2025'
            AND member_number_members_sa = ks.member_number_members_sa
            ORDER BY ends_month_mp DESC -- Sort to ensure MAX(ends_month_mp) is first
            LIMIT 1 -- Fetch the top membership type corresponding to the max
        ) AS membership_type_max_ends_month_mp_2024
        FROM sales_key_stats_2015 ks
            LEFT JOIN relaunch_3_year_110524 AS rl ON rl.member_number_members_sa = ks.member_number_members_sa
        WHERE 
            ks.new_member_category_6_sa IN (@member_category)
            AND ks.purchased_on_year_adjusted_mp IN (@year_2024)
            AND ks.purchased_on_date_adjusted_mp >= '2024-10-26'
		GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
        ORDER BY ks.purchased_on_date_adjusted_mp DESC
    )

    SELECT * FROM three_year_new_category_purchasers_102624_forward; -- count = 584
-- ***************************************