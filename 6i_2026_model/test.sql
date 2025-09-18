USE usat_sales_db;

-- CREATE ACTUAL VS GOAL DATA
    DROP TABLE IF EXISTS sales_model_2026;

-- 2025 EFFECTIVE PRICE LEVELS
    SET @One_Day_15 = 15.27; -- $15
    SET @Bronze_Relay = 9.75; -- $9.99
    SET @Bronze_Sprint = 14.92; -- $15
    SET @Bronze_Intermediate = 22.72; -- $23
    SET @Bronze_Ultra = 28.5; -- $30
    SET @Bronze_$0 = 0; -- $0
    SET @Bronze_AO = 0; -- $0
    SET @Bronze_Upgrade = 5.12; -- $7
    SET @Club = 0; -- $0
    SET @Unknown = 2.2; -- $4
    SET @1_Year_50 = 0; -- $69
    SET @Silver = 67.32; -- $69
    SET @Gold = 97.6; -- $99.99
    SET @3_Year = 171.01; -- $175
    SET @Lifetime = 0; -- $0
    SET @Platinum_Foundation = 409.37; -- $410
    SET @Platinum_USA = 385.29; -- $410
    SET @Young_Adult_36 = 0; -- $42
    SET @Young_Adult_40 = 40.37; -- $42
    SET @Youth_Annual = 10; -- $10
    SET @Youth_Premier_25 = 0; -- $30
    SET @Youth_Premier_30 = 30; -- $30
    SET @Elite = 65.59; -- $69

-- 2025 ACTUAL PRICE LEVELS
    SET @One_Day_15_2025 = 15;
    SET @Bronze_Relay_2025 = 9;
    SET @Bronze_Sprint_2025 = 14;
    SET @Bronze_Intermediate_2025 = 21;
    SET @Bronze_Ultra_2025 = 28;
    SET @Bronze_$0_2025 = 0;
    SET @Bronze_AO_2025 = 0;
    SET @Bronze_Upgrade_2025 = 7;
    SET @Club_2025 = 0;
    SET @Unknown_2025 = 4;
    SET @1_Year_50_2025 = 50;
    SET @Silver_2025 = 64;
    SET @Gold_2025 = 99;
    SET @3_Year_2025 = 165;
    SET @Lifetime_2025 = 0;
    SET @Platinum_Foundation_2025 = 400;
    SET @Platinum_USA_2025 = 400;
    SET @Young_Adult_36_2025 = 40;
    SET @Young_Adult_40_2025 = 40;
    SET @Youth_Annual_2025 = 10;
    SET @Youth_Premier_25_2025 = 30;
    SET @Youth_Premier_30_2025 = 30;
    SET @Elite_2025 = 64;

-- 2026 ACTUAL PRICE LEVELS
    SET @One_Day_15_2026 = 15;
    SET @Bronze_Relay_2026 = 9.99;
    SET @Bronze_Sprint_2026 = 15;
    SET @Bronze_Intermediate_2026 = 23;
    SET @Bronze_Ultra_2026 = 30;
    SET @Bronze_$0_2026 = 0;
    SET @Bronze_AO_2026 = 0;
    SET @Bronze_Upgrade_2026 = 7;
    SET @Club_2026 = 0;
    SET @Unknown_2026 = 4;
    SET @1_Year_50_2026 = 69;
    SET @Silver_2026 = 69;
    SET @Gold_2026 = 99.99;
    SET @3_Year_2026 = 175;
    SET @Lifetime_2026 = 0;
    SET @Platinum_Foundation_2026 = 410;
    SET @Platinum_USA_2026 = 410;
    SET @Young_Adult_36_2026 = 42;
    SET @Young_Adult_40_2026 = 42;
    SET @Youth_Annual_2026 = 10;
    SET @Youth_Premier_25_2026 = 30;
    SET @Youth_Premier_30_2026 = 30;
    SET @Elite_2026 = 69;

-- >>> UNIT GROWTH (ADDED): category-level unit growth pct variables (e.g., 0.05 = +5%) >>>
    SET @UG_One_Day_15 = 0.00;
    SET @UG_Bronze_Relay = 0.00;
    SET @UG_Bronze_Sprint = 0.00;
    SET @UG_Bronze_Intermediate = 0.00;
    SET @UG_Bronze_Ultra = 0.00;
    SET @UG_Bronze_$0 = 0.00;
    SET @UG_Bronze_AO = 0.00;
    SET @UG_Bronze_Upgrade = 0.00;
    SET @UG_Club = 0.00;
    SET @UG_Unknown = 0.00;
    SET @UG_1_Year_50 = 0.00;
    SET @UG_Silver = 0.00;
    SET @UG_Gold = 0.00;
    SET @UG_3_Year = 0.00;
    SET @UG_Lifetime = 0.00;
    SET @UG_Platinum_Foundation = 0.00;
    SET @UG_Platinum_USA = 0.00;
    SET @UG_Young_Adult_36 = 0.00;
    SET @UG_Young_Adult_40 = 0.00;
    SET @UG_Youth_Annual = 0.00;
    SET @UG_Youth_Premier_25 = 0.00;
    SET @UG_Youth_Premier_30 = 0.00;
    SET @UG_Elite = 1.00;
-- <<< UNIT GROWTH (ADDED) <<<

-- GET CURRENT DATE IN MTN (MST OR MDT) & UTC
    SET @created_at_mtn = (         
        SELECT CASE 
            WHEN UTC_TIMESTAMP() >= DATE_ADD(
                    DATE_ADD(CONCAT(YEAR(UTC_TIMESTAMP()), '-03-01'),
                        INTERVAL ((7 - DAYOFWEEK(CONCAT(YEAR(UTC_TIMESTAMP()), '-03-01')) + 1) % 7 + 7) DAY),
                    INTERVAL 2 HOUR)
            AND UTC_TIMESTAMP() < DATE_ADD(
                    DATE_ADD(CONCAT(YEAR(UTC_TIMESTAMP()), '-11-01'),
                        INTERVAL ((7 - DAYOFWEEK(CONCAT(YEAR(UTC_TIMESTAMP()), '-11-01')) + 1) % 7) DAY),
                    INTERVAL 2 HOUR)
            THEN DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL -6 HOUR), '%Y-%m-%d %H:%i:%s')
            ELSE DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL -7 HOUR), '%Y-%m-%d %H:%i:%s')
            END
    );
    SET @created_at_utc = DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d %H:%i:%s');

-- CREATE SALES MODEL 2026
    CREATE TABLE sales_model_2026 AS
    WITH sales_actuals AS (
        SELECT
            MONTH(common_purchased_on_date_adjusted)   AS month_actual,
            QUARTER(common_purchased_on_date_adjusted) AS quarter_actual,
            YEAR(common_purchased_on_date_adjusted)    AS year_actual,

            -- (kept as-is)
            CASE WHEN MONTH(common_purchased_on_date_adjusted) <= MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_year_to_date,
            CASE WHEN MONTH(common_purchased_on_date_adjusted) =  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_current_month,
            CASE WHEN MONTH(common_purchased_on_date_adjusted) <> MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_ytd_before_current_month,

            real_membership_types_sa AS type_actual,
            new_member_category_6_sa AS category_actual,

            -- category sort order (kept)
            CASE
                -- adult_annual
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = '1-Year $50' THEN 1
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = '3-Year' THEN 2
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Silver' THEN 3
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Gold' THEN 4
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Lifetime' THEN 5
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Platinum - Foundation' THEN 6
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Platinum - Team USA' THEN 7
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Young Adult - $36' THEN 8
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Young Adult - $40' THEN 9
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Unknown' THEN 10
                -- elite
                WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Elite' THEN 11
                WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Unknown' THEN 12
                -- one_day
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'One Day - $15' THEN 13
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Relay' THEN 14
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Sprint' THEN 15
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Intermediate' THEN 16
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Ultra' THEN 17
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - AO' THEN 18
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - $0' THEN 19
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Distance Upgrade' THEN 20
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Club' THEN 21
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Unknown' THEN 22
                -- youth_annual
                WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Annual' THEN 23
                WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $25' THEN 24
                WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $30' THEN 25
                WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Unknown' THEN 26
                ELSE 999
            END AS category_sort_order_actual,

            -- Totals
            SUM(revenue_current) AS sales_rev_2025_actual,
            SUM(revenue_prior) AS sales_rev_2024_actual,
            SUM(units_current_year) AS sales_units_2025_actual,
            SUM(units_prior_year) AS sales_units_2024_actual,
            IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year)) AS rev_per_unit_2025_actual,
            IF(SUM(units_prior_year) = 0, 0, SUM(revenue_prior) / SUM(units_prior_year)) AS rev_per_unit_2024_actual,

            -- Splits - Bulk & NonBulk
            SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current     ELSE 0 END) AS sales_rev_2025_actual_bulk,
            SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year  ELSE 0 END) AS sales_units_2025_actual_bulk,
            SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN revenue_current     ELSE 0 END) AS sales_rev_2025_actual_nonbulk,
            SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN units_current_year  ELSE 0 END) AS sales_units_2025_actual_nonbulk,
            MAX(origin_flag_ma = 'ADMIN_BULK_UPLOADER') AS has_bulk_upload,
                    
            -- Bulk unit economics to reuse for 2026 bulk pricing
            IFNULL(
            SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current ELSE 0 END)
            / NULLIF(SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year ELSE 0 END), 0),
            IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year))
            ) AS rev_per_unit_2025_actual_bulk
            
        FROM sales_data_year_over_year AS sa
        GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
    ),
    sales_goals AS (
        SELECT
            purchased_on_month_adjusted_mp AS month_goal,
            CASE 
                WHEN purchased_on_month_adjusted_mp IN (1,2,3) THEN 1
                WHEN purchased_on_month_adjusted_mp IN (4,5,6) THEN 2
                WHEN purchased_on_month_adjusted_mp IN (7,8,9) THEN 3
                ELSE 4
            END as quarter_goal,
            "2025" AS year_goal,
            CASE WHEN purchased_on_month_adjusted_mp =  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_current_month,
            CASE WHEN purchased_on_month_adjusted_mp <= MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_year_to_date,
            CASE WHEN purchased_on_month_adjusted_mp <  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_ytd_before_current_month,

            real_membership_types_sa AS type_goal, 
            new_member_category_6_sa AS category_goal,

            -- category sort order using both type_actual and category_actual
            CASE
                -- adult_annual
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = '1-Year $50' THEN 1
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = '3-Year' THEN 2
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Silver' THEN 3
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Gold' THEN 4
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Lifetime' THEN 5
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Platinum - Foundation' THEN 6
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Platinum - Team USA' THEN 7
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Young Adult - $36' THEN 8
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Young Adult - $40' THEN 9
                WHEN real_membership_types_sa = 'adult_annual' AND new_member_category_6_sa = 'Unknown' THEN 10
                -- elite
                WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Elite' THEN 11
                WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Unknown' THEN 12
                -- one_day
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'One Day - $15' THEN 13
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Relay' THEN 14
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Sprint' THEN 15
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Intermediate' THEN 16
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Ultra' THEN 17
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - AO' THEN 18
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - $0' THEN 19
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Distance Upgrade' THEN 20
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Club' THEN 21
                WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Unknown' THEN 22
                -- youth_annual
                WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Annual' THEN 23
                WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $25' THEN 24
                WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $30' THEN 25
                WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Unknown' THEN 26
                ELSE 999
            END AS category_sort_order_goal,
                
            -- METRICS
            SUM(sales_revenue) AS sales_rev_2025_goal,
            SUM(sales_units) AS sales_units_2025_goal,
            IF(SUM(sales_units) = 0, 0, SUM(sales_revenue) / SUM(sales_units)) AS rev_per_unit_2025_goal

        FROM sales_goal_data AS sg
        GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
        -- ORDER BY 1

        UNION ALL

        -- Add a row for Unknown category per month/type since unknown doesn't exist in goals but might for actual (as it does for 3/2025 & 4/2025)
        SELECT
            purchased_on_month_adjusted_mp AS month_goal,
            CASE 
                WHEN purchased_on_month_adjusted_mp IN (1,2,3) THEN 1
                WHEN purchased_on_month_adjusted_mp IN (4,5,6) THEN 2
                WHEN purchased_on_month_adjusted_mp IN (7,8,9) THEN 3
                ELSE 4
            END AS quarter_goal,
            "2025" AS year_goal,
            CASE WHEN purchased_on_month_adjusted_mp =  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_current_month,
            CASE WHEN purchased_on_month_adjusted_mp <= MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_year_to_date,
            CASE WHEN purchased_on_month_adjusted_mp <  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_ytd_before_current_month,

            real_membership_types_sa AS type_goal,
            'Unknown' AS category_goal,

            "" AS category_sort_order_goal,

            0 AS sales_rev_2025_goal,
            0 AS sales_units_2025_goal,
            0 AS rev_per_unit_2025_goal

        FROM sales_goal_data
        GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
    ),
    sales_base AS (
        SELECT
            -- Goals
            sg.month_goal,
            sg.type_goal,
            sg.category_goal,
            sg.is_ytd_before_current_month,

            -- Actual splits (kept)
            sa.sales_rev_2025_actual,
            sa.sales_rev_2025_actual_bulk,
            sa.sales_rev_2025_actual_nonbulk,

            sa.sales_units_2025_actual,
            sa.sales_units_2025_actual_bulk,
            sa.sales_units_2025_actual_nonbulk,

            sa.rev_per_unit_2025_actual,
            sa.rev_per_unit_2025_actual_bulk,

            -- 2025 estimate TOTAL
            CASE 
                WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_rev_2025_actual
                WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_rev_2025_goal
                ELSE 0
            END AS sales_rev_2025_estimate,
            CASE 
                WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_2025_actual
                WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_2025_goal
                ELSE 0
            END AS sales_units_2025_estimate,

            -- 2025 estimate BULK
            sa.sales_rev_2025_actual_bulk   AS sales_rev_2025_estimate_bulk,
            sa.sales_units_2025_actual_bulk AS sales_units_2025_estimate_bulk,

            -- 2025 estimate NON-BULK (NOTE [5]: keep denominator consistent for period=0)
            CASE 
                WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_rev_2025_actual_nonbulk
                WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_rev_2025_goal  -- total revenue available only at goal level
                ELSE 0
            END AS sales_rev_2025_estimate_nonbulk,
            CASE 
                WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_2025_actual_nonbulk
                WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_2025_goal
                ELSE 0
            END AS sales_units_2025_estimate_nonbulk

        FROM sales_goals AS sg
        LEFT JOIN sales_actuals AS sa ON sg.month_goal   = sa.month_actual
            AND sg.type_goal      = sa.type_actual
            AND sg.category_goal  = sa.category_actual

        -- This clause preserves everything except when: (a) The goal is "Unknown", and (b) The actual data shows no meaningful performance (0 revenue and 0 units).
        WHERE NOT (
            sg.category_goal = 'Unknown'
            AND IFNULL(sa.sales_rev_2025_actual, 0) = 0
            AND IFNULL(sa.sales_units_2025_actual, 0) = 0
        )

            ORDER BY month_goal, category_sort_order_actual
    ),
    -- ======================
    -- NOTE [1] & [2]: compute price once; derive units once; bulk units = difference
    -- ======================
    priced AS (
        SELECT
            b.*,

            -- NOTE [1]: single source of truth for the 2026 price (DECIMAL avoids float drift)
            -- 2026 EFFECTIVE PRICE LEVELS
            CAST(
                CASE b.category_goal
                WHEN 'One Day - $15'              THEN @One_Day_15
                WHEN 'Bronze - Relay'             THEN @Bronze_Relay
                WHEN 'Bronze - Sprint'            THEN @Bronze_Sprint
                WHEN 'Bronze - Intermediate'      THEN @Bronze_Intermediate
                WHEN 'Bronze - Ultra'             THEN @Bronze_Ultra
                WHEN 'Bronze - $0'                THEN @Bronze_$0
                WHEN 'Bronze - AO'                THEN @Bronze_AO
                WHEN 'Bronze - Distance Upgrade'  THEN @Bronze_Upgrade
                WHEN 'Club'                       THEN @Club
                WHEN 'Unknown'                    THEN @Unknown
                WHEN '1-Year $50'                 THEN @1_Year_50
                WHEN 'Silver'                     THEN @Silver
                WHEN 'Gold'                       THEN @Gold
                WHEN '3-Year'                     THEN @3_Year
                WHEN 'Lifetime'                   THEN @Lifetime
                WHEN 'Platinum - Foundation'      THEN @Platinum_Foundation
                WHEN 'Platinum - Team USA'        THEN @Platinum_USA
                WHEN 'Young Adult - $36'          THEN @Young_Adult_36
                WHEN 'Young Adult - $40'          THEN @Young_Adult_40
                WHEN 'Youth Annual'               THEN @Youth_Annual
                WHEN 'Youth Premier - $25'        THEN @Youth_Premier_25
                WHEN 'Youth Premier - $30'        THEN @Youth_Premier_30
                WHEN 'Elite'                      THEN @Elite
                ELSE NULL  -- guardrail if a new category appears
                END
            AS DECIMAL(10,2)) AS price_2026_nonbulk,
            
            -- Price for BULK: use actual bulk unit economics from 2025 / use fallback of 0 if null
            CAST(
                COALESCE(
                    b.rev_per_unit_2025_actual_bulk,
                    0
                )
            AS DECIMAL(10,2)) AS price_2026_bulk,

            -- 2025 ACTUAL PRICE LEVELS
            CAST(
                CASE
                    WHEN b.category_goal = 'One Day - $15'              THEN @One_Day_15_2025
                    WHEN b.category_goal = 'Bronze - Relay'             THEN @Bronze_Relay_2025
                    WHEN b.category_goal = 'Bronze - Sprint'            THEN @Bronze_Sprint_2025
                    WHEN b.category_goal = 'Bronze - Intermediate'      THEN @Bronze_Intermediate_2025
                    WHEN b.category_goal = 'Bronze - Ultra'             THEN @Bronze_Ultra_2025
                    WHEN b.category_goal = 'Bronze - $0'                THEN @Bronze_$0_2025
                    WHEN b.category_goal = 'Bronze - AO'                THEN @Bronze_AO_2025
                    WHEN b.category_goal = 'Bronze - Distance Upgrade'  THEN @Bronze_Upgrade_2025
                    WHEN b.category_goal = 'Club'                       THEN @Club_2025
                    WHEN b.category_goal = 'Unknown'                    THEN @Unknown_2025
                    WHEN b.category_goal = '1-Year $50'                 THEN @1_Year_50_2025
                    WHEN b.category_goal = 'Silver'                     THEN @Silver_2025
                    WHEN b.category_goal = 'Gold'                       THEN @Gold_2025
                    WHEN b.category_goal = '3-Year'                     THEN @3_Year_2025
                    WHEN b.category_goal = 'Lifetime'                   THEN @Lifetime_2025
                    WHEN b.category_goal = 'Platinum - Foundation'      THEN @Platinum_Foundation_2025
                    WHEN b.category_goal = 'Platinum - Team USA'        THEN @Platinum_USA_2025
                    WHEN b.category_goal = 'Young Adult - $36'          THEN @Young_Adult_36_2025
                    WHEN b.category_goal = 'Young Adult - $40'          THEN @Young_Adult_40_2025
                    WHEN b.category_goal = 'Youth Annual'               THEN @Youth_Annual_2025
                    WHEN b.category_goal = 'Youth Premier - $25'        THEN @Youth_Premier_25_2025
                    WHEN b.category_goal = 'Youth Premier - $30'        THEN @Youth_Premier_30_2025
                    WHEN b.category_goal = 'Elite'                      THEN @Elite_2025
                    ELSE NULL
                END
            AS DECIMAL(10,2)) AS price_2025_actual,

            -- 2026 ACTUAL PRICE LEVELS
            CAST(
                CASE
                    WHEN b.category_goal = 'One Day - $15'              THEN @One_Day_15_2026
                    WHEN b.category_goal = 'Bronze - Relay'             THEN @Bronze_Relay_2026
                    WHEN b.category_goal = 'Bronze - Sprint'            THEN @Bronze_Sprint_2026
                    WHEN b.category_goal = 'Bronze - Intermediate'      THEN @Bronze_Intermediate_2026
                    WHEN b.category_goal = 'Bronze - Ultra'             THEN @Bronze_Ultra_2026
                    WHEN b.category_goal = 'Bronze - $0'                THEN @Bronze_$0_2026
                    WHEN b.category_goal = 'Bronze - AO'                THEN @Bronze_AO_2026
                    WHEN b.category_goal = 'Bronze - Distance Upgrade'  THEN @Bronze_Upgrade_2026
                    WHEN b.category_goal = 'Club'                       THEN @Club_2026
                    WHEN b.category_goal = 'Unknown'                    THEN @Unknown_2026
                    WHEN b.category_goal = '1-Year $50'                 THEN @1_Year_50_2026
                    WHEN b.category_goal = 'Silver'                     THEN @Silver_2026
                    WHEN b.category_goal = 'Gold'                       THEN @Gold_2026
                    WHEN b.category_goal = '3-Year'                     THEN @3_Year_2026
                    WHEN b.category_goal = 'Lifetime'                   THEN @Lifetime_2026
                    WHEN b.category_goal = 'Platinum - Foundation'      THEN @Platinum_Foundation_2026
                    WHEN b.category_goal = 'Platinum - Team USA'        THEN @Platinum_USA_2026
                    WHEN b.category_goal = 'Young Adult - $36'          THEN @Young_Adult_36_2026
                    WHEN b.category_goal = 'Young Adult - $40'          THEN @Young_Adult_40_2026
                    WHEN b.category_goal = 'Youth Annual'               THEN @Youth_Annual_2026
                    WHEN b.category_goal = 'Youth Premier - $25'        THEN @Youth_Premier_25_2026
                    WHEN b.category_goal = 'Youth Premier - $30'        THEN @Youth_Premier_30_2026
                    WHEN b.category_goal = 'Elite'                      THEN @Elite_2026
                    ELSE NULL
                END
            AS DECIMAL(10,2)) AS price_2026_actual,


            -- 2026 ACTUAL PRICE LEVELS
            CAST(
                CASE
                    b.category_goal
                        WHEN 'One Day - $15'              THEN @UG_One_Day_15
                        WHEN 'Bronze - Relay'             THEN @UG_Bronze_Relay
                        WHEN 'Bronze - Sprint'            THEN @UG_Bronze_Sprint
                        WHEN 'Bronze - Intermediate'      THEN @UG_Bronze_Intermediate
                        WHEN 'Bronze - Ultra'             THEN @UG_Bronze_Ultra
                        WHEN 'Bronze - $0'                THEN @UG_Bronze_$0
                        WHEN 'Bronze - AO'                THEN @UG_Bronze_AO
                        WHEN 'Bronze - Distance Upgrade'  THEN @UG_Bronze_Upgrade
                        WHEN 'Club'                       THEN @UG_Club
                        WHEN 'Unknown'                    THEN @UG_Unknown
                        WHEN '1-Year $50'                 THEN @UG_1_Year_50
                        WHEN 'Silver'                     THEN @UG_Silver
                        WHEN 'Gold'                       THEN @UG_Gold
                        WHEN '3-Year'                     THEN @UG_3_Year
                        WHEN 'Lifetime'                   THEN @UG_Lifetime
                        WHEN 'Platinum - Foundation'      THEN @UG_Platinum_Foundation
                        WHEN 'Platinum - Team USA'        THEN @UG_Platinum_USA
                        WHEN 'Young Adult - $36'          THEN @UG_Young_Adult_36
                        WHEN 'Young Adult - $40'          THEN @UG_Young_Adult_40
                        WHEN 'Youth Annual'               THEN @UG_Youth_Annual
                        WHEN 'Youth Premier - $25'        THEN @UG_Youth_Premier_25
                        WHEN 'Youth Premier - $30'        THEN @UG_Youth_Premier_30
                        WHEN 'Elite'                      THEN @UG_Elite
                        ELSE NULL
                END
            AS DECIMAL(10,2)) AS unit_2026_pct_change,

            -- >>> UNIT GROWTH (ADDED): apply category growth pct to derived units >>>
            -- Derived 2026 units for total/nonbulk; bulk = total - nonbulk
            CAST(
                CASE 
                    WHEN b.is_ytd_before_current_month = 1 THEN b.sales_units_2025_actual
                    ELSE b.sales_units_2025_estimate
                END * (1 + 
                        CASE b.category_goal
                            WHEN 'One Day - $15'              THEN @UG_One_Day_15
                            WHEN 'Bronze - Relay'             THEN @UG_Bronze_Relay
                            WHEN 'Bronze - Sprint'            THEN @UG_Bronze_Sprint
                            WHEN 'Bronze - Intermediate'      THEN @UG_Bronze_Intermediate
                            WHEN 'Bronze - Ultra'             THEN @UG_Bronze_Ultra
                            WHEN 'Bronze - $0'                THEN @UG_Bronze_$0
                            WHEN 'Bronze - AO'                THEN @UG_Bronze_AO
                            WHEN 'Bronze - Distance Upgrade'  THEN @UG_Bronze_Upgrade
                            WHEN 'Club'                       THEN @UG_Club
                            WHEN 'Unknown'                    THEN @UG_Unknown
                            WHEN '1-Year $50'                 THEN @UG_1_Year_50
                            WHEN 'Silver'                     THEN @UG_Silver
                            WHEN 'Gold'                       THEN @UG_Gold
                            WHEN '3-Year'                     THEN @UG_3_Year
                            WHEN 'Lifetime'                   THEN @UG_Lifetime
                            WHEN 'Platinum - Foundation'      THEN @UG_Platinum_Foundation
                            WHEN 'Platinum - Team USA'        THEN @UG_Platinum_USA
                            WHEN 'Young Adult - $36'          THEN @UG_Young_Adult_36
                            WHEN 'Young Adult - $40'          THEN @UG_Young_Adult_40
                            WHEN 'Youth Annual'               THEN @UG_Youth_Annual
                            WHEN 'Youth Premier - $25'        THEN @UG_Youth_Premier_25
                            WHEN 'Youth Premier - $30'        THEN @UG_Youth_Premier_30
                            WHEN 'Elite'                      THEN @UG_Elite
                            ELSE 0
                        END) 
            AS DECIMAL(10,2)) units_total_2026,

            CAST(
                CASE    
                    WHEN b.is_ytd_before_current_month = 1 THEN b.sales_units_2025_actual_nonbulk
                    ELSE b.sales_units_2025_estimate_nonbulk
                END * (1 + 
                        CASE b.category_goal
                            WHEN 'One Day - $15'              THEN @UG_One_Day_15
                            WHEN 'Bronze - Relay'             THEN @UG_Bronze_Relay
                            WHEN 'Bronze - Sprint'            THEN @UG_Bronze_Sprint
                            WHEN 'Bronze - Intermediate'      THEN @UG_Bronze_Intermediate
                            WHEN 'Bronze - Ultra'             THEN @UG_Bronze_Ultra
                            WHEN 'Bronze - $0'                THEN @UG_Bronze_$0
                            WHEN 'Bronze - AO'                THEN @UG_Bronze_AO
                            WHEN 'Bronze - Distance Upgrade'  THEN @UG_Bronze_Upgrade
                            WHEN 'Club'                       THEN @UG_Club
                            WHEN 'Unknown'                    THEN @UG_Unknown
                            WHEN '1-Year $50'                 THEN @UG_1_Year_50
                            WHEN 'Silver'                     THEN @UG_Silver
                            WHEN 'Gold'                       THEN @UG_Gold
                            WHEN '3-Year'                     THEN @UG_3_Year
                            WHEN 'Lifetime'                   THEN @UG_Lifetime
                            WHEN 'Platinum - Foundation'      THEN @UG_Platinum_Foundation
                            WHEN 'Platinum - Team USA'        THEN @UG_Platinum_USA
                            WHEN 'Young Adult - $36'          THEN @UG_Young_Adult_36
                            WHEN 'Young Adult - $40'          THEN @UG_Young_Adult_40
                            WHEN 'Youth Annual'               THEN @UG_Youth_Annual
                            WHEN 'Youth Premier - $25'        THEN @UG_Youth_Premier_25
                            WHEN 'Youth Premier - $30'        THEN @UG_Youth_Premier_30
                            WHEN 'Elite'                      THEN @UG_Elite
                            ELSE 0
                     END) 
            AS  DECIMAL(10,2)) units_nonbulk_2026
            -- <<< UNIT GROWTH (ADDED) <<<

        FROM sales_base b
    ),
    -- ======================
    -- NOTE [3]: price all three consistently => exact reconciliation
    -- ======================
    sales_estimate_2026 AS (
        SELECT
            p.*,

            -- bulk units = total - nonbulk (never mix splits from different bases)
            -- (p.units_total_2026 - p.units_nonbulk_2026)                       AS units_bulk_2026,

            -- Revenues: units × price_2026 (consistent for total/nonbulk/bulk)
            -- Bulk Units + Non-bulk Units
            CAST(
                ROUND(((p.units_total_2026 - p.units_nonbulk_2026) * p.price_2026_bulk) + 
                (p.units_nonbulk_2026 * p.price_2026_nonbulk)
                , 2) 
            AS  DECIMAL(10,2)) sales_rev_2026_goal,

            -- FORMULA ABOVE WAS NOT DISPLAYING VALUES FOR Q4 2026 REV GOAL; FIXED BUT KEEING FORMULA IF NECESSARY
            -- ROUND(
            --     GREATEST(COALESCE(p.units_total_2026,0) - COALESCE(p.units_nonbulk_2026,0), 0) * COALESCE(p.price_2026_bulk,0)
            --         + COALESCE(p.units_nonbulk_2026,0) * COALESCE(p.price_2026_nonbulk,0)
            --         , 2) AS sales_rev_2026_goal,

            -- Revenues (price each split with its own price)
            CAST((p.units_nonbulk_2026 * p.price_2026_nonbulk)                      AS DECIMAL(10,2)) sales_rev_2026_goal_nonbulk,
            CAST(((p.units_total_2026 - p.units_nonbulk_2026) * p.price_2026_bulk)  AS DECIMAL(10,2)) sales_rev_2026_goal_bulk,

            -- Units outputs (for parity with your original names)
            CAST(p.units_total_2026   AS DECIMAL(10,2)) sales_units_2026_goal,
            CAST((p.units_total_2026 - p.units_nonbulk_2026) AS  DECIMAL(10,2)) sales_units_2026_goal_bulk,
            CAST(p.units_nonbulk_2026 AS DECIMAL(10,2)) sales_units_2026_goal_nonbulk

        FROM priced p
    )
    SELECT 
        e.*,

        -- Diff vs 2025 estimate (non-bulk basis, kept)
        IFNULL(e.sales_rev_2026_goal_nonbulk - e.sales_rev_2025_estimate_nonbulk, 0) AS goal_v_actual_rev_diff_abs,
        IFNULL(e.sales_units_2026_goal_nonbulk - e.sales_units_2025_estimate_nonbulk, 0) AS goal_v_actual_units_diff_abs,

        -- PRICE VS UNIT CHANGE IMPACT: NON BULK ONLY
        ROUND(
            (IFNULL(e.price_2026_nonbulk, IFNULL(IF(e.sales_units_2025_estimate_nonbulk = 0, 0, e.sales_rev_2025_estimate_nonbulk / NULLIF(e.sales_units_2025_estimate_nonbulk, 0)), 0))
             - IFNULL(IF(e.sales_units_2025_estimate_nonbulk = 0, 0, e.sales_rev_2025_estimate_nonbulk / NULLIF(e.sales_units_2025_estimate_nonbulk, 0)), 0))
            * ((IFNULL(e.sales_units_2025_estimate_nonbulk, 0) + IFNULL(e.sales_units_2026_goal_nonbulk, 0)) / 2)
        , 2) AS price_impact_abs,

        ROUND(
            (IFNULL(e.sales_units_2026_goal_nonbulk, 0) - IFNULL(e.sales_units_2025_estimate_nonbulk, 0))
            * ((
                 IFNULL(IF(e.sales_units_2025_estimate_nonbulk = 0, 0, e.sales_rev_2025_estimate_nonbulk / NULLIF(e.sales_units_2025_estimate_nonbulk, 0)), 0)
                 + IFNULL(e.price_2026_nonbulk, IFNULL(IF(e.sales_units_2025_estimate_nonbulk = 0, 0, e.sales_rev_2025_estimate_nonbulk / NULLIF(e.sales_units_2025_estimate_nonbulk, 0)), 0))
               ) / 2)
        , 2) AS unit_impact_abs,
        
        -- PRICE VS UNIT CHANGE IMPACT (BULK)
        ROUND(
            (COALESCE(e.price_2026_bulk, 0)
            - COALESCE(NULLIF(e.sales_rev_2025_estimate_bulk,0)/NULLIF(e.sales_units_2025_estimate_bulk,0), 0))
            * ((COALESCE(e.sales_units_2025_estimate_bulk,0)
                + COALESCE(e.units_total_2026 - e.units_nonbulk_2026,0)) / 2)
        , 2) AS price_impact_abs_bulk,

        ROUND(
            (COALESCE(e.units_total_2026 - e.units_nonbulk_2026,0) - COALESCE(e.sales_units_2025_estimate_bulk,0))
            * ((COALESCE(NULLIF(e.sales_rev_2025_estimate_bulk,0)/NULLIF(e.sales_units_2025_estimate_bulk,0), 0)
                + COALESCE(e.price_2026_bulk,0)) / 2)
        , 2) AS unit_impact_abs_bulk,

        -- PRICE VS UNIT CHANGE IMPACT (TOTAL)
        ROUND(
            (COALESCE(NULLIF(e.sales_rev_2026_goal,0)/NULLIF(e.sales_units_2026_goal,0), 0)
            - COALESCE(NULLIF(e.sales_rev_2025_estimate,0)/NULLIF(e.sales_units_2025_estimate,0), 0))
            * ((COALESCE(e.sales_units_2025_estimate,0) + COALESCE(e.sales_units_2026_goal,0)) / 2)
        , 2) AS price_impact_abs_total,

        ROUND(
            (COALESCE(e.sales_units_2026_goal,0) - COALESCE(e.sales_units_2025_estimate,0))
            * ((COALESCE(NULLIF(e.sales_rev_2025_estimate,0)/NULLIF(e.sales_units_2025_estimate,0), 0)
                + COALESCE(NULLIF(e.sales_rev_2026_goal,0)/NULLIF(e.sales_units_2026_goal,0), 0)) / 2)
        , 2) AS unit_impact_abs_total,


        -- NOTE [6]: optional reconciliation check (0.00 means perfect tie-out). Comment out if not needed.
        ROUND(ABS((e.sales_rev_2026_goal_nonbulk + e.sales_rev_2026_goal_bulk) - e.sales_rev_2026_goal), 6) AS recon_delta,

        -- Created at timestamps:
        @created_at_mtn AS created_at_mtn,
        @created_at_utc AS created_at_utc

    FROM sales_estimate_2026 AS e
    -- WHERE e.price_2026_bulk IS NULL
;

-- GENERAL QUERY
    SELECT * FROM sales_model_2026;
