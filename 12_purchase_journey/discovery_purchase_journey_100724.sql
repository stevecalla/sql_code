USE usat_sales_db;

SET @year_2019 = 2019;  
SET @year_2021 = 2021;   
SET @year_2022 = 2022;  
SET @year_2023 = 2023;    
SET @year_2024 = 2024; 

-- SELECT * FROM sales_key_stats_2015 LIMIT 10;

-- CREATE INDEX idx_sales_key_stats ON sales_key_stats_2015 (
--     member_number_members_sa,
--     id_membership_periods_sa,
--     purchased_on_year_adjusted_mp,
--     starts_events,
--     starts_year_events,
--     real_membership_types_sa,
--     new_member_category_6_sa
-- );
-- CREATE INDEX idx_member_number ON sales_key_stats_2015 (member_number_members_sa);

WITH purchase_journey AS (
    SELECT         
        member_number_members_sa
        -- , id_membership_periods_sa

        , FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units_lifetime
        , FORMAT(SUM(sales_revenue), 0) AS sales_revenue_lifetime

        , MIN(purchased_on_year_adjusted_mp)
        , MAX(purchased_on_year_adjusted_mp) AS max_purchased_on_year_adjusted_mp
        , GROUP_CONCAT(purchased_on_adjusted_mp ORDER BY purchased_on_adjusted_mp) AS purchased_on_values
        , GROUP_CONCAT(DISTINCT purchased_on_adjusted_mp ORDER BY purchased_on_adjusted_mp) AS purchased_on_values_distinct

        , MIN(starts_events)
        , MAX(starts_year_events)

        , GROUP_CONCAT(id_membership_periods_sa ORDER BY purchased_on_adjusted_mp ASC  SEPARATOR ', ') AS member_period_values
        , GROUP_CONCAT(name_events ORDER BY purchased_on_adjusted_mp ASC  SEPARATOR ', ') AS event_values

        , GROUP_CONCAT(real_membership_types_sa ORDER BY purchased_on_adjusted_mp ASC  SEPARATOR ', ') as real_type_values
        , GROUP_CONCAT(DISTINCT real_membership_types_sa ORDER BY purchased_on_adjusted_mp ASC  SEPARATOR ', ') as real_type_values_distinct
        , GROUP_CONCAT(new_member_category_6_sa ORDER BY purchased_on_adjusted_mp ASC  SEPARATOR ', ') as member_category_6_values
        , GROUP_CONCAT(DISTINCT new_member_category_6_sa ORDER BY purchased_on_adjusted_mp ASC  SEPARATOR ', ') as member_category_6_values_distinct

    FROM sales_key_stats_2015
    -- WHERE purchased_on_year_adjusted_mp < @year_2024 
    GROUP BY 1
    -- ORDER BY 2
    )

    -- SELECT * FROM purchase_journey
    -- WHERE member_number_members_sa IN ('100253962')

    -- PURCHASE JOURNEY - FOR ALL PATHS WITH MAX PURCHASE YEAR = 2024
    SELECT
        -- member_number_members_sa
        -- , id_membership_periods_sa
        -- , sales_units_lifetime
        -- , member_category_6_values
        -- , purchased_on_values_distinct
        ROW_NUMBER() OVER (ORDER BY CAST(COUNT(member_number_members_sa) AS UNSIGNED) DESC) AS line_number -- Add line number
        , member_category_6_values_distinct
        , FORMAT(COUNT(member_number_members_sa), 0) as member_count
    FROM purchase_journey
    WHERE max_purchased_on_year_adjusted_mp IN (@year_2024)
    -- WHERE 
    --     LOWER(member_category_6_values_distinct) LIKE '%bronze%'
    --     AND member_number_members_sa IN ('100253962')
    GROUP BY member_category_6_values_distinct WITH ROLLUP
    ORDER BY CAST(COUNT(member_number_members_sa) AS UNSIGNED) DESC; -- Convert count to a number for sorting

    -- PURCHASE JOURNEY - WHEN 3-YEAR IS THE LAST PRODUCT IN THE PURCHASE PATH
    -- SELECT
        --     member_category_6_values_distinct
        --     , member_category_6_values
        --     , CASE WHEN LOWER(RIGHT(member_category_6_values_distinct, LENGTH('3-year'))) = '3-year' THEN 1 ELSE 0 END AS last_purchase_is_three_year
        --     , CASE WHEN member_category_6_values_distinct IS NULL THEN 1 ELSE 0 END AS rollup
        --     , COUNT(member_number_members_sa) as member_count
        -- FROM purchase_journey
        -- WHERE max_purchased_on_year_adjusted_mp IN (@year_2023)
        --     -- AND LOWER(member_category_6_values_distinct) LIKE '%3-year%'
        --     -- AND RIGHT(member_category_6_values_distinct, LENGTH('3-year')) = '3-year'  
        --     AND LOWER(RIGHT(member_category_6_values_distinct, LENGTH('3-year'))) = '3-year' -- Ensure '3-year' is at the end
        -- GROUP BY member_category_6_values_distinct, 2 WITH ROLLUP
        -- HAVING 
        --     last_purchase_is_three_year = 1 -- where clause above for right length = 3-year not working
        --     OR
        --     rollup = 1
        -- ORDER BY member_count DESC
    ;
