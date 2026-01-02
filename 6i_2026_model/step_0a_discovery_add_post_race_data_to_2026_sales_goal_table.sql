-- 2025 ACTUAL PRICE LEVELS
    SET @One_Day_15_2025 = 14;
    SET @Bronze_Relay_2025 = 9;
    SET @Bronze_Sprint_2025 = 14;
    SET @Bronze_Intermediate_2025 = 21;
    SET @Bronze_Ultra_2025 = 28;
    SET @Bronze_$0_2025 = 0;
    SET @Bronze_AO_2025 = 0;
    SET @Bronze_Upgrade_2025 = 7;
    SET @Club_2025 = 0;
    SET @Unknown_2025 = 4;
    SET @1_Year_50_2025 = 64;
    SET @Silver_2025 = 64;
    SET @Gold_2025 = 99;
    SET @3_Year_2025 = 165;
    SET @Lifetime_2025 = 0;
    SET @Platinum_Foundation_2025 = 400;
    SET @Platinum_USA_2025 = 400;
    SET @Young_Adult_36_2025 = 40;
    SET @Young_Adult_40_2025 = 40;
    SET @Youth_Premier_25_2025 = 25;
    SET @Youth_Premier_30_2025 = 30;
    SET @Youth_Annual_2025 = 10;
    SET @Elite_2025 = 64;

-- 2026 ACTUAL PRICE LEVELS
    SET @One_Day_15_2026 = 14.99; -- todo:
    SET @Bronze_Relay_2026 = 9;
    SET @Bronze_Sprint_2026 = 14.99; -- todo:
    SET @Bronze_Intermediate_2026 = 24.99; -- todo:
    SET @Bronze_Ultra_2026 = 34.99; -- todo:
    SET @Bronze_$0_2026 = 0;
    SET @Bronze_AO_2026 = 0;
    SET @Bronze_Upgrade_2026 = 7;
    SET @Club_2026 = 0;
    SET @Unknown_2026 = 4;
    SET @1_Year_50_2026 = 69.99;
    SET @Silver_2026 = 69.99;
    SET @Gold_2026 = 99.99;
    SET @3_Year_2026 = 178.49;
    SET @Lifetime_2026 = 0;
    SET @Platinum_Foundation_2026 = 429.99; -- todo:
    SET @Platinum_USA_2026 = 429.99; -- todo:
    SET @Young_Adult_36_2026 = 40;
    SET @Young_Adult_40_2026 = 40;
    SET @Youth_Premier_25_2026 = 25;
    SET @Youth_Premier_30_2026 = 30;
    SET @Youth_Annual_2026 = 10;
    SET @Elite_2026 = 79.99;

-- TODO: Find calc for effective rate assumptions in "assumptions" sheet in the 2026 sales model
-- 2026 EFFECTIVE PRICE LEVELS
    SET @One_Day_15 = 14.91; -- $14.99
    SET @Bronze_Relay = 8.79; -- $9
    SET @Bronze_Sprint = 14.91; -- $14.99
    SET @Bronze_Intermediate = 24.69; -- $24.99
    SET @Bronze_Ultra = 34.1; -- $34.99
    SET @Bronze_$0 = 0; -- $0
    SET @Bronze_AO = 0; -- $0
    SET @Bronze_Upgrade = 5.12; -- $7
    SET @Club = 0; -- $0
    SET @Unknown = 2.2; -- $4
    SET @1_Year_50 = 68.59; -- $69.99
    SET @Silver = 68.28; -- $69.99
    SET @Gold = 97.6; -- $99.99
    SET @3_Year = 174.42; -- $178.49
    SET @Lifetime = 0; -- $0
    SET @Platinum_Foundation = 429.33; -- $429.99
    SET @Platinum_USA = 404.07; -- $429.99
    SET @Young_Adult_36 = 0; -- $40
    SET @Young_Adult_40 = 38.44; -- $40
    SET @Youth_Premier_25 = 0; -- $25
    SET @Youth_Premier_30 = 29.58; -- $30
    SET @Youth_Annual = 9.38; -- $10
    SET @Elite = 76.07; -- $79.99

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
    SET @UG_Elite = 0.00;
/* -----------------------------------------------------------------------------
   0) (Optional) reset temp table if you re-run in same session
----------------------------------------------------------------------------- */
DROP TEMPORARY TABLE IF EXISTS test;

/* -----------------------------------------------------------------------------
   1) Create the temp table from your CTE query
      IMPORTANT: MySQL syntax is "CREATE TEMPORARY TABLE ... AS WITH ... SELECT ..."
----------------------------------------------------------------------------- */
CREATE TEMPORARY TABLE test AS
WITH
sales_actuals AS (
    SELECT
        MONTH(common_purchased_on_date_adjusted)   AS month_actual,
        QUARTER(common_purchased_on_date_adjusted) AS quarter_actual,
        YEAR(common_purchased_on_date_adjusted)    AS year_actual,

        CASE WHEN MONTH(common_purchased_on_date_adjusted) =  9 THEN 1 ELSE 0 END AS is_current_month,
        CASE WHEN MONTH(common_purchased_on_date_adjusted) <= 9 THEN 1 ELSE 0 END AS is_year_to_date,
        CASE WHEN MONTH(common_purchased_on_date_adjusted) <  9 THEN 1 ELSE 0 END AS is_ytd_before_current_month,

        real_membership_types_sa AS type_actual,
        new_member_category_6_sa AS category_actual,

        CASE
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
            WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Elite' THEN 11
            WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Unknown' THEN 12
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
            WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Annual' THEN 23
            WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $25' THEN 24
            WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $30' THEN 25
            WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Unknown' THEN 26
            ELSE 999
        END AS category_sort_order_actual,

        SUM(revenue_current) AS sales_rev_2025_actual,
        SUM(revenue_prior) AS sales_rev_2024_actual,
        SUM(units_current_year) AS sales_units_2025_actual,
        SUM(units_prior_year) AS sales_units_2024_actual,
        IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year)) AS rev_per_unit_2025_actual,
        IF(SUM(units_prior_year) = 0, 0, SUM(revenue_prior) / SUM(units_prior_year)) AS rev_per_unit_2024_actual,

        SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current     ELSE 0 END) AS sales_rev_2025_actual_bulk,
        SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year  ELSE 0 END) AS sales_units_2025_actual_bulk,

        SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN revenue_current     ELSE 0 END) AS sales_rev_2025_actual_nonbulk,
        SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN units_current_year  ELSE 0 END) AS sales_units_2025_actual_nonbulk,

        MAX(origin_flag_ma = 'ADMIN_BULK_UPLOADER') AS has_bulk_upload,

        IFNULL(
          SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current ELSE 0 END)
          / NULLIF(SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year ELSE 0 END), 0),
          IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year))
        ) AS rev_per_unit_2025_actual_bulk

    FROM sales_data_year_over_year AS sa
    GROUP BY 1,2,3,4,5,6,7,8,9
),
sales_goals AS (
    SELECT
        purchased_on_month_adjusted_mp AS month_goal,
        CASE
            WHEN purchased_on_month_adjusted_mp IN (1,2,3) THEN 1
            WHEN purchased_on_month_adjusted_mp IN (4,5,6) THEN 2
            WHEN purchased_on_month_adjusted_mp IN (7,8,9) THEN 3
            ELSE 4
        END AS quarter_goal,
        '2025' AS year_goal,

        CASE WHEN purchased_on_month_adjusted_mp =  9 THEN 1 ELSE 0 END AS is_current_month,
        CASE WHEN purchased_on_month_adjusted_mp <= 9 THEN 1 ELSE 0 END AS is_year_to_date,
        CASE WHEN purchased_on_month_adjusted_mp <  9 THEN 1 ELSE 0 END AS is_ytd_before_current_month,

        real_membership_types_sa AS type_goal,
        new_member_category_6_sa AS category_goal,

        CASE
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
            WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Elite' THEN 11
            WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Unknown' THEN 12
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
            WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Annual' THEN 23
            WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $25' THEN 24
            WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $30' THEN 25
            WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Unknown' THEN 26
            ELSE 999
        END AS category_sort_order_goal,

        SUM(sales_revenue) AS sales_rev_2025_goal,
        SUM(sales_units)   AS sales_units_2025_goal,
        IF(SUM(sales_units)=0,0,SUM(sales_revenue)/SUM(sales_units)) AS rev_per_unit_2025_goal

    FROM sales_goal_data AS sg
    GROUP BY 1,2,3,4,5,6,7,8,9

    UNION ALL

    SELECT
        purchased_on_month_adjusted_mp AS month_goal,
        CASE
            WHEN purchased_on_month_adjusted_mp IN (1,2,3) THEN 1
            WHEN purchased_on_month_adjusted_mp IN (4,5,6) THEN 2
            WHEN purchased_on_month_adjusted_mp IN (7,8,9) THEN 3
            ELSE 4
        END AS quarter_goal,
        '2025' AS year_goal,

--         CASE WHEN purchased_on_month_adjusted_mp =  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_current_month,
--         CASE WHEN purchased_on_month_adjusted_mp <= MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_year_to_date,
--         CASE WHEN purchased_on_month_adjusted_mp <  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_ytd_before_current_month,

                -- TODO: HARD CODE TO SEPTEMBER GIVEN THAT'S WHEN THE ORIGINAL MODEL WAS GENERATED
                -- CASE WHEN purchased_on_month_adjusted_mp =  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_current_month,
                -- CASE WHEN purchased_on_month_adjusted_mp <= MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_year_to_date,
                -- CASE WHEN purchased_on_month_adjusted_mp <  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                CASE WHEN purchased_on_month_adjusted_mp =  9 THEN 1 ELSE 0 END AS is_current_month,
                CASE WHEN purchased_on_month_adjusted_mp <= 9 THEN 1 ELSE 0 END AS is_year_to_date,
                CASE WHEN purchased_on_month_adjusted_mp <  9 THEN 1 ELSE 0 END AS is_ytd_before_current_month,

        real_membership_types_sa AS type_goal,
        'Unknown' AS category_goal,

        '' AS category_sort_order_goal,

        0 AS sales_rev_2025_goal,
        0 AS sales_units_2025_goal,
        0 AS rev_per_unit_2025_goal

    FROM sales_goal_data
    GROUP BY 1,2,3,4,5,6,7,8
)
        -- ======================
        -- POST RACE OVERLAY (non-bulk add-on)
        -- Grain must match: month_goal + type_goal + category_goal
        -- ======================
, post_race AS (
            SELECT
                pr.month  AS month_post_race,
                pr.type   AS type_post_race,

                -- IMPORTANT:
                -- If pr.category already exactly matches your category_goal values, use:
                -- pr.category AS category_goal
                --
                -- If it’s a prefix / partial, keep LIKE join later (below).
                pr.category AS category_post_race,

				SUM(COALESCE(pr.sales_units, 0))   AS sales_units_2026_goal_post_race,
				SUM(COALESCE(pr.sales_revenue, 0)) AS sales_rev_2026_goal_post_race
            
            FROM sales_model_2026_post_race_data pr
            GROUP BY 1, 2, 3
        )
--  * FROM post_race AS pr WHERE pr.sales_units_2026_goal_post_race <> 0;
, sales_base AS (
    SELECT
        sg.month_goal,
        sg.type_goal,
        sg.category_goal,
        sg.is_ytd_before_current_month,

        sa.sales_rev_2025_actual,
        sa.sales_rev_2025_actual_bulk,
        sa.sales_rev_2025_actual_nonbulk,

        sa.sales_units_2025_actual,
        sa.sales_units_2025_actual_bulk,
        sa.sales_units_2025_actual_nonbulk,

        sa.rev_per_unit_2025_actual,
        sa.rev_per_unit_2025_actual_bulk,

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

        sa.sales_rev_2025_actual_bulk   AS sales_rev_2025_estimate_bulk,
        sa.sales_units_2025_actual_bulk AS sales_units_2025_estimate_bulk,

        CASE
            WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_rev_2025_actual_nonbulk
            WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_rev_2025_goal
            ELSE 0
        END AS sales_rev_2025_estimate_nonbulk,

--         CASE
--             WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_2025_actual_nonbulk
--             WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_2025_goal
--             ELSE 0
--         END AS sales_units_2025_estimate_nonbulk

        CASE
            WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_2025_actual_nonbulk + COALESCE(pr.sales_units_2026_goal_post_race, 0)
            WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_2025_goal + COALESCE(pr.sales_units_2026_goal_post_race, 0)
            ELSE 0
        END AS sales_units_2025_estimate_nonbulk
        
    FROM sales_goals sg
		LEFT JOIN sales_actuals sa ON sg.month_goal     = sa.month_actual
			AND sg.type_goal      = sa.type_actual
			AND sg.category_goal  = sa.category_actual
            
		LEFT JOIN post_race AS pr ON pr.month_post_race = sg.month_goal
			AND sg.type_goal = pr.type_post_race
			AND sg.category_goal = pr.category_post_race

    WHERE NOT (
        sg.category_goal = 'Unknown'
        AND IFNULL(sa.sales_rev_2025_actual, 0) = 0
        AND IFNULL(sa.sales_units_2025_actual, 0) = 0
    )
)
, priced AS (
    SELECT
        b.*,

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
                ELSE NULL
            END
        AS DECIMAL(10,2)) AS price_2026_nonbulk,

        CAST(COALESCE(b.rev_per_unit_2025_actual_bulk, 0) AS DECIMAL(10,2)) AS price_2026_bulk,

        CAST(
            CASE b.category_goal
                WHEN 'One Day - $15'              THEN @One_Day_15_2025
                WHEN 'Bronze - Relay'             THEN @Bronze_Relay_2025
                WHEN 'Bronze - Sprint'            THEN @Bronze_Sprint_2025
                WHEN 'Bronze - Intermediate'      THEN @Bronze_Intermediate_2025
                WHEN 'Bronze - Ultra'             THEN @Bronze_Ultra_2025
                WHEN 'Bronze - $0'                THEN @Bronze_$0_2025
                WHEN 'Bronze - AO'                THEN @Bronze_AO_2025
                WHEN 'Bronze - Distance Upgrade'  THEN @Bronze_Upgrade_2025
                WHEN 'Club'                       THEN @Club_2025
                WHEN 'Unknown'                    THEN @Unknown_2025
                WHEN '1-Year $50'                 THEN @1_Year_50_2025
                WHEN 'Silver'                     THEN @Silver_2025
                WHEN 'Gold'                       THEN @Gold_2025
                WHEN '3-Year'                     THEN @3_Year_2025
                WHEN 'Lifetime'                   THEN @Lifetime_2025
                WHEN 'Platinum - Foundation'      THEN @Platinum_Foundation_2025
                WHEN 'Platinum - Team USA'        THEN @Platinum_USA_2025
                WHEN 'Young Adult - $36'          THEN @Young_Adult_36_2025
                WHEN 'Young Adult - $40'          THEN @Young_Adult_40_2025
                WHEN 'Youth Annual'               THEN @Youth_Annual_2025
                WHEN 'Youth Premier - $25'        THEN @Youth_Premier_25_2025
                WHEN 'Youth Premier - $30'        THEN @Youth_Premier_30_2025
                WHEN 'Elite'                      THEN @Elite_2025
                ELSE NULL
            END
        AS DECIMAL(10,2)) AS price_2025_actual,

        CAST(
            CASE b.category_goal
                WHEN 'One Day - $15'              THEN @One_Day_15_2026
                WHEN 'Bronze - Relay'             THEN @Bronze_Relay_2026
                WHEN 'Bronze - Sprint'            THEN @Bronze_Sprint_2026
                WHEN 'Bronze - Intermediate'      THEN @Bronze_Intermediate_2026
                WHEN 'Bronze - Ultra'             THEN @Bronze_Ultra_2026
                WHEN 'Bronze - $0'                THEN @Bronze_$0_2026
                WHEN 'Bronze - AO'                THEN @Bronze_AO_2026
                WHEN 'Bronze - Distance Upgrade'  THEN @Bronze_Upgrade_2026
                WHEN 'Club'                       THEN @Club_2026
                WHEN 'Unknown'                    THEN @Unknown_2026
                WHEN '1-Year $50'                 THEN @1_Year_50_2026
                WHEN 'Silver'                     THEN @Silver_2026
                WHEN 'Gold'                       THEN @Gold_2026
                WHEN '3-Year'                     THEN @3_Year_2026
                WHEN 'Lifetime'                   THEN @Lifetime_2026
                WHEN 'Platinum - Foundation'      THEN @Platinum_Foundation_2026
                WHEN 'Platinum - Team USA'        THEN @Platinum_USA_2026
                WHEN 'Young Adult - $36'          THEN @Young_Adult_36_2026
                WHEN 'Young Adult - $40'          THEN @Young_Adult_40_2026
                WHEN 'Youth Annual'               THEN @Youth_Annual_2026
                WHEN 'Youth Premier - $25'        THEN @Youth_Premier_25_2026
                WHEN 'Youth Premier - $30'        THEN @Youth_Premier_30_2026
                WHEN 'Elite'                      THEN @Elite_2026
                ELSE NULL
            END
        AS DECIMAL(10,2)) AS price_2026_actual,

        CAST(
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
                ELSE NULL
            END
        AS DECIMAL(10,2)) AS unit_2026_pct_change,

        CAST(
            (CASE WHEN b.is_ytd_before_current_month = 1 THEN b.sales_units_2025_actual
                  ELSE b.sales_units_2025_estimate END)
            * (1 + COALESCE(
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
                END, 0))
        AS DECIMAL(10,2)) AS units_total_2026,

        CAST(
			-- CASE    
				--     WHEN b.is_ytd_before_current_month = 1 THEN b.sales_units_2025_actual_nonbulk
				--     ELSE b.sales_units_2025_estimate_nonbulk
			sales_units_2025_estimate_nonbulk *
				-- END * 
			(1 + 
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
        AS DECIMAL(10,2)) AS units_nonbulk_2026
    FROM sales_base b
)
, sales_estimate_2026 AS (
    SELECT
        p.*,

        COALESCE(pr.sales_units_2026_goal_post_race, 0) AS sales_units_2026_goal_post_race,
        COALESCE(pr.sales_units_2026_goal_post_race, 0) * COALESCE(p.price_2026_nonbulk, 0)  AS sales_rev_2026_goal_post_race, -- did not include b/c sales rev doesn't include post race revenue

        CAST(
            ROUND(
                (
					(p.units_total_2026 - p.units_nonbulk_2026) * p.price_2026_bulk)
					+ (p.units_nonbulk_2026 * p.price_2026_nonbulk)
                    + (pr.sales_units_2026_goal_post_race * p.price_2026_nonbulk)
            , 2)
        AS DECIMAL(10,2)) AS sales_rev_2026_goal,

        -- CAST((p.units_nonbulk_2026 * p.price_2026_nonbulk) AS DECIMAL(10,2)) AS sales_rev_2026_goal_nonbulk,
        CAST(
			(COALESCE(p.units_nonbulk_2026, 0)
			- COALESCE(pr.sales_units_2026_goal_post_race, 0) -- did not include b/c sales rev doesn't include post race revenue
            ) 
			* COALESCE(p.price_2026_nonbulk, 0)
		AS DECIMAL(10,2)) AS sales_rev_2026_goal_nonbulk,
        
        CAST(((p.units_total_2026 - p.units_nonbulk_2026) * p.price_2026_bulk) AS DECIMAL(10,2)) AS sales_rev_2026_goal_bulk,

        CAST(p.units_total_2026 AS DECIMAL(10,2)) AS sales_units_2026_goal,
        CAST((p.units_total_2026 - p.units_nonbulk_2026) AS DECIMAL(10,2)) AS sales_units_2026_goal_bulk,
        
        CAST(p.units_nonbulk_2026 AS DECIMAL(10,2)) AS sales_units_2026_goal_nonbulk
        -- CAST((COALESCE(p.units_nonbulk_2026, 0) + COALESCE(pr.sales_units_2026_goal_post_race, 0)) AS DECIMAL(10,2)) AS sales_units_2026_goal_nonbulk
        
    FROM priced p
		LEFT JOIN post_race AS pr ON pr.month_post_race = p.month_goal
			AND p.type_goal = pr.type_post_race
			AND p.category_goal = pr.category_post_race
)
SELECT
    e.*,

    IFNULL(e.sales_rev_2026_goal_nonbulk - e.sales_rev_2025_estimate_nonbulk, 0) AS goal_v_actual_rev_diff_abs,
    IFNULL(e.sales_units_2026_goal_nonbulk - e.sales_units_2025_estimate_nonbulk, 0) AS goal_v_actual_units_diff_abs,

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

    ROUND(ABS((e.sales_rev_2026_goal_nonbulk + e.sales_rev_2026_goal_bulk) - e.sales_rev_2026_goal), 6) AS recon_delta,

    @created_at_mtn AS created_at_mtn,
    @created_at_utc AS created_at_utc

FROM sales_estimate_2026 e
;

/* -----------------------------------------------------------------------------
   2) View results
----------------------------------------------------------------------------- */
SELECT * FROM test LIMIT 300;
SELECT * FROM test WHERE sales_units_2026_goal_post_race = 0 LIMIT 200;
SELECT * FROM test WHERE sales_units_2026_goal_post_race <> 0 LIMIT 200;

SELECT
  "test" AS query_label,
  month_goal,
  COUNT(*) AS row_count,
  FORMAT(SUM(sales_units_2025_estimate_nonbulk), 0),
  FORMAT(SUM(sales_units_2026_goal_nonbulk), 0), 
  FORMAT(SUM(sales_rev_2026_goal_nonbulk), 0), 
  FORMAT(SUM(sales_units_2026_goal_post_race), 0), 
  FORMAT(SUM(sales_rev_2026_goal_post_race), 0), 
  MIN(month_goal) AS min_month,
  MAX(month_goal) AS max_month
FROM test
GROUP BY month_goal WITH ROLLUP
ORDER BY month_goal
;
/* -----------------------------------------------------------------------------
   2) View results
----------------------------------------------------------------------------- */
SELECT * FROM sales_model_2026 LIMIT 200;

SELECT
  "sales_model_2026" AS query_label,
  month_goal,
  COUNT(*) AS row_count,
  FORMAT(SUM(sales_units_2026_goal_nonbulk), 0), 
  FORMAT(SUM(sales_rev_2026_goal_nonbulk), 0), 
  MIN(month_goal) AS min_month,
  MAX(month_goal) AS max_month
FROM sales_model_2026
GROUP BY month_goal WITH ROLLUP
ORDER BY month_goal
;

/* -----------------------------------------------------------------------------
   3) Diff
----------------------------------------------------------------------------- */
-- In test but not in sales_model_2026
SELECT 'ONLY_IN_TEST' AS diff_type, t.*
FROM test t
LEFT JOIN sales_model_2026 s
  ON s.month_goal = t.month_goal
 AND s.type_goal  = t.type_goal
 AND s.category_goal = t.category_goal
WHERE s.month_goal IS NULL
;

-- UNION ALL

-- In sales_model_2026 but not in test
SELECT 'ONLY_IN_SALES_MODEL' AS diff_type, s.*
FROM sales_model_2026 s
LEFT JOIN test t
  ON t.month_goal = s.month_goal
 AND t.type_goal  = s.type_goal
 AND t.category_goal = s.category_goal
WHERE t.month_goal IS NULL
ORDER BY diff_type, month_goal, type_goal, category_goal
;

