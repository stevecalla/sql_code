-- C:\Users\calla\development\usat\sql_code\6j_2027_model\step_0_discovery_actual_vs_goal_model_with_post_race_v1
.sql
-- SALES MODEL WITH POST RACE

-- #5 CREATE 2027 SALES MODEL
USE usat_sales_db;

-- MODEL YEARS
    SET @prior_year = 2025;
    SET @this_year = 2026;
    SET @next_year = 2027;

-- CREATE BACKUP OR VERSION OF PRIOR MODELS
    -- CREATE TABLE sales_model_2027_v2_111025 AS
    -- SELECT *
    -- FROM sales_model_2027
    -- ;
    -- RENAME TABLE sales_model_2027 TO sales_model_2027_v2_111025; -- save model_v2_111025
    -- RENAME TABLE sales_model_2027 TO sales_model_2027_v1_100125; -- save model_v1_100125
    -- RENAME TABLE sales_model_2027_v1_100125 TO sales_model_2027; -- rollback if needed

-- CREATE ACTUAL VS GOAL DATA
    DROP TABLE IF EXISTS sales_model_2027;

-- THIS YEAR ACTUAL PRICE LEVELS
    SET @One_Day_15_actual_this_year = 14.99;
    SET @Bronze_Relay_actual_this_year = 9;
    SET @Bronze_Sprint_actual_this_year = 14.99;
    SET @Bronze_Intermediate_actual_this_year = 24.99;
    SET @Bronze_Ultra_actual_this_year = 34.99;
    SET @Bronze_$0_actual_this_year = 0;
    SET @Bronze_AO_actual_this_year = 0;
    SET @Bronze_Upgrade_actual_this_year = 7;
    SET @Club_actual_this_year = 0;
    SET @Unknown_actual_this_year = 4;
    SET @1_Year_50_actual_this_year = 69.99;
    SET @Silver_actual_this_year = 69.99;
    SET @Gold_actual_this_year = 99.99;
    SET @3_Year_actual_this_year = 178.49;
    SET @Lifetime_actual_this_year = 0;
    SET @Platinum_Foundation_actual_this_year = 429.99;
    SET @Platinum_USA_actual_this_year = 429.99;
    SET @Young_Adult_36_actual_this_year = 40;
    SET @Young_Adult_40_actual_this_year = 40;
    SET @Youth_Premier_25_actual_this_year = 25;
    SET @Youth_Premier_30_actual_this_year = 30;
    SET @Youth_Annual_actual_this_year = 10;
    SET @Elite_actual_this_year = 79.99;

    -- NEW IN 2026
    SET @bronze_bike_actual_this_year = 5.00;
    SET @bronze_run_actual_this_year = 5.00;
    SET @bronze_swim_actual_this_year = 5.00;
    SET @bronze_community_actual_this_year = 0.00;
    SET @Elite_2_Year_actual_this_year = 150.00;

-- NEXT YEAR ACTUAL PRICE LEVELS
    SET @One_Day_15_actual_next_year = 14.99; -- todo:
    SET @Bronze_Relay_actual_next_year = 9;
    SET @Bronze_Sprint_actual_next_year = 14.99; -- todo:
    SET @Bronze_Intermediate_actual_next_year = 24.99; -- todo:
    SET @Bronze_Ultra_actual_next_year = 34.99; -- todo:
    SET @Bronze_$0_actual_next_year = 0;
    SET @Bronze_AO_actual_next_year = 0;
    SET @Bronze_Upgrade_actual_next_year = 7;
    SET @Club_actual_next_year = 0;
    SET @Unknown_actual_next_year = 4;
    SET @1_Year_50_actual_next_year = 69.99;
    SET @Silver_actual_next_year = 69.99;
    SET @Gold_actual_next_year = 99.99;
    SET @3_Year_actual_next_year = 178.49;
    SET @Lifetime_actual_next_year = 0;
    SET @Platinum_Foundation_actual_next_year = 429.99; -- todo:
    SET @Platinum_USA_actual_next_year = 429.99; -- todo:
    SET @Young_Adult_36_actual_next_year = 40;
    SET @Young_Adult_40_actual_next_year = 40;
    SET @Youth_Premier_25_actual_next_year = 25;
    SET @Youth_Premier_30_actual_next_year = 30;
    SET @Youth_Annual_actual_next_year = 10;
    SET @Elite_actual_next_year = 79.99;

    -- NEW IN 2027
    SET @bronze_bike_actual_next_year = 5.00;
    SET @bronze_run_actual_next_year = 5.00;
    SET @bronze_swim_actual_next_year = 5.00;
    SET @bronze_community_actual_next_year = 0.00;
    SET @Elite_2_Year_actual_next_year = 150.00;

-- TODO: Find calc for effective rate assumptions in "assumptions" sheet in the 2027 sales model
-- THIS YEAR EFFECTIVE PRICE LEVELS
    SET @One_Day_15_effective_this_year = 14.91; -- $14.99
    SET @Bronze_Relay_effective_this_year = 8.79; -- $9
    SET @Bronze_Sprint_effective_this_year = 14.91; -- $14.99
    SET @Bronze_Intermediate_effective_this_year = 24.69; -- $24.99
    SET @Bronze_Ultra_effective_this_year = 34.1; -- $34.99
    SET @Bronze_$0_effective_this_year = 0; -- $0
    SET @Bronze_AO_effective_this_year = 0; -- $0
    SET @Bronze_Upgrade_effective_this_year = 5.12; -- $7
    SET @Club_effective_this_year = 0; -- $0
    SET @Unknown_effective_this_year = 2.2; -- $4
    SET @1_Year_50_effective_this_year = 68.59; -- $69.99
    SET @Silver_effective_this_year = 68.28; -- $69.99
    SET @Gold_effective_this_year = 97.6; -- $99.99
    SET @3_Year_effective_this_year = 174.42; -- $178.49
    SET @Lifetime_effective_this_year = 0; -- $0
    SET @Platinum_Foundation_effective_this_year = 429.33; -- $429.99
    SET @Platinum_USA_effective_this_year = 404.07; -- $429.99
    SET @Young_Adult_36_effective_this_year = 0; -- $40
    SET @Young_Adult_40_effective_this_year = 38.44; -- $40
    SET @Youth_Premier_25_effective_this_year = 0; -- $25
    SET @Youth_Premier_30_effective_this_year = 29.58; -- $30
    SET @Youth_Annual_effective_this_year = 9.38; -- $10
    SET @Elite_effective_this_year = 76.07; -- $79.99;

    -- NEW IN 2026
    SET @bronze_bike_effective_this_year = 5.00;
    SET @bronze_run_effective_this_year = 5.00;
    SET @bronze_swim_effective_this_year = 5.00;
    SET @bronze_community_effective_this_year = 0.00;
    SET @Elite_2_Year_effective_this_year = 150.00;

-- NEXT YEAR EFFECTIVE PRICE LEVELS
    SET @One_Day_15_effective_next_year = 14.91; -- $14.99
    SET @Bronze_Relay_effective_next_year = 8.79; -- $9
    SET @Bronze_Sprint_effective_next_year = 14.91; -- $14.99
    SET @Bronze_Intermediate_effective_next_year = 24.69; -- $24.99
    SET @Bronze_Ultra_effective_next_year = 34.1; -- $34.99
    SET @Bronze_$0_effective_next_year = 0; -- $0
    SET @Bronze_AO_effective_next_year = 0; -- $0
    SET @Bronze_Upgrade_effective_next_year = 5.12; -- $7
    SET @Club_effective_next_year = 0; -- $0
    SET @Unknown_effective_next_year = 2.2; -- $4
    SET @1_Year_50_effective_next_year = 68.59; -- $69.99
    SET @Silver_effective_next_year = 68.28; -- $69.99
    SET @Gold_effective_next_year = 97.6; -- $99.99
    SET @3_Year_effective_next_year = 174.42; -- $178.49
    SET @Lifetime_effective_next_year = 0; -- $0
    SET @Platinum_Foundation_effective_next_year = 429.33; -- $429.99
    SET @Platinum_USA_effective_next_year = 404.07; -- $429.99
    SET @Young_Adult_36_effective_next_year = 0; -- $40
    SET @Young_Adult_40_effective_next_year = 38.44; -- $40
    SET @Youth_Premier_25_effective_next_year = 0; -- $25
    SET @Youth_Premier_30_effective_next_year = 29.58; -- $30
    SET @Youth_Annual_effective_next_year = 9.38; -- $10
    SET @Elite_effective_next_year = 76.07; -- $79.99

    -- NEW IN 2027
    SET @bronze_bike_effective_next_year = 5.00;
    SET @bronze_run_effective_next_year = 5.00;
    SET @bronze_swim_effective_next_year = 5.00;
    SET @bronze_community_effective_next_year = 0.00;
    SET @Elite_2_Year_effective_next_year = 150.00;

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

    -- NEW 2026
    SET @UG_bronze_bike = 0.00;
    SET @UG_bronze_run = 0.00;
    SET @UG_bronze_swim = 0.00;
    SET @UG_bronze_community = 0.00;
    SET @UG_Elite_2_Year = 0.00;
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

-- CREATE SALES MODEL 2027
    CREATE TABLE sales_model_2027 AS
        WITH sales_actuals AS (
            SELECT
                MONTH(common_purchased_on_date_adjusted)   AS month_actual,
                QUARTER(common_purchased_on_date_adjusted) AS quarter_actual,
                YEAR(common_purchased_on_date_adjusted)    AS year_actual,

                -- CASE WHEN MONTH(common_purchased_on_date_adjusted) <= MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_year_to_date,
                -- CASE WHEN MONTH(common_purchased_on_date_adjusted) =  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_current_month,
                -- CASE WHEN MONTH(common_purchased_on_date_adjusted) <> MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_ytd_before_current_month,

                -- TODO: HARD CODE TO AUGUST GIVEN THAT'S WHEN THE ORIGINAL MODEL WAS GENERATED
                CASE WHEN MONTH(common_purchased_on_date_adjusted) =  8 THEN 1 ELSE 0 END AS is_current_month,
                CASE WHEN MONTH(common_purchased_on_date_adjusted) <= 8 THEN 1 ELSE 0 END AS is_year_to_date,
                CASE WHEN MONTH(common_purchased_on_date_adjusted) <  9 THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                
                -- TODO: HARD CODE TO FULL YEAR TO UNDERSTAND WHAT THAT MIGHT LOOK LIKE
                -- CASE WHEN MONTH(common_purchased_on_date_adjusted) =  12 THEN 1 ELSE 0 END AS is_current_month,
                -- CASE WHEN MONTH(common_purchased_on_date_adjusted) <= 12 THEN 1 ELSE 0 END AS is_year_to_date,
                -- CASE WHEN MONTH(common_purchased_on_date_adjusted) <  13 THEN 1 ELSE 0 END AS is_ytd_before_current_month,

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
                    WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Elite 2-Year membership' THEN 12
                    WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Unknown' THEN 13
                    -- one_day
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'One Day - $15' THEN 14
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Bike' THEN 15
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Swim' THEN 16
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Run' THEN 17
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Relay' THEN 18
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Sprint' THEN 19
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Intermediate' THEN 20
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Ultra' THEN 21
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - AO' THEN 22
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - $0' THEN 23
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Distance Upgrade' THEN 24
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Club' THEN 25
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze Community Membership' THEN 26
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Unknown' THEN 27

                    -- youth_annual
                    WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Annual' THEN 28
                    WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $25' THEN 29
                    WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $30' THEN 30
                    WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Unknown' THEN 31
                    ELSE 999
                END AS category_sort_order_actual,

                -- Totals
                SUM(revenue_current) AS sales_rev_this_year_actual,
                SUM(revenue_prior) AS sales_rev_prior_year_actual,
                SUM(units_current_year) AS sales_units_this_year_actual,
                SUM(units_prior_year) AS sales_units_prior_year_actual,
                IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year)) AS rev_per_unit_this_year_actual,
                IF(SUM(units_prior_year) = 0, 0, SUM(revenue_prior) / SUM(units_prior_year)) AS rev_per_unit_prior_year_actual,

                -- Splits - Bulk & NonBulk
                SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current     ELSE 0 END) AS sales_rev_this_year_actual_bulk,
                SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year  ELSE 0 END) AS sales_units_this_year_actual_bulk,

                -- SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN revenue_current     ELSE 0 END) AS sales_rev_this_year_actual_nonbulk,
                SUM(
                    CASE 
                        WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER'
                            OR origin_flag_ma IS NULL
                            OR new_member_category_6_sa = 'Bronze Community Membership'
                        THEN revenue_current
                        ELSE 0
                    END
                ) AS sales_rev_this_year_actual_nonbulk,

                -- SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN units_current_year  ELSE 0 END) AS sales_units_this_year_actual_nonbulk,
                SUM(
                    CASE 
                        WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER'
                            OR origin_flag_ma IS NULL
                            OR new_member_category_6_sa = 'Bronze Community Membership'
                        THEN units_current_year
                        ELSE 0
                    END
                ) AS sales_units_this_year_actual_nonbulk,

                MAX(origin_flag_ma = 'ADMIN_BULK_UPLOADER') AS has_bulk_upload,
                        
                -- Bulk unit economics to reuse for next year bulk pricing
                IFNULL(
                SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current ELSE 0 END)
                / NULLIF(SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year ELSE 0 END), 0),
                IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year))
                ) AS rev_per_unit_this_year_actual_bulk
                
            FROM sales_data_year_over_year_2026 AS sa
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
                @this_year AS year_goal,

                -- CASE WHEN purchased_on_month_adjusted_mp =  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_current_month,
                -- CASE WHEN purchased_on_month_adjusted_mp <= MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_year_to_date,
                -- CASE WHEN purchased_on_month_adjusted_mp <  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                
                -- TODO: HARD CODE TO AUGUST GIVEN THAT'S WHEN THE ORIGINAL MODEL WAS GENERATED
                CASE WHEN purchased_on_month_adjusted_mp =  8 THEN 1 ELSE 0 END AS is_current_month,
                CASE WHEN purchased_on_month_adjusted_mp <= 8 THEN 1 ELSE 0 END AS is_year_to_date,
                CASE WHEN purchased_on_month_adjusted_mp <  9 THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                
                -- TODO: HARD CODE TO FULL YEAR TO UNDERSTAND WHAT THAT MIGHT LOOK LIKE
                -- CASE WHEN purchased_on_month_adjusted_mp =  12 THEN 1 ELSE 0 END AS is_current_month,
                -- CASE WHEN purchased_on_month_adjusted_mp <= 12 THEN 1 ELSE 0 END AS is_year_to_date,
                -- CASE WHEN purchased_on_month_adjusted_mp <  13 THEN 1 ELSE 0 END AS is_ytd_before_current_month,

                real_membership_types_sa AS type_goal, 
                new_member_category_6_sa AS category_goal,

                -- category SORT ORDER using both type_actual and category_actual
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
                    WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Elite 2-Year membership' THEN 12
                    WHEN real_membership_types_sa = 'elite' AND new_member_category_6_sa = 'Unknown' THEN 13
                    -- one_day
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'One Day - $15' THEN 14
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Bike' THEN 15
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Swim' THEN 16
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Run' THEN 17
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Relay' THEN 18
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Sprint' THEN 19
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Intermediate' THEN 20
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Ultra' THEN 21
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - AO' THEN 22
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - $0' THEN 23
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze - Distance Upgrade' THEN 24
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Club' THEN 25
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Bronze Community Membership' THEN 26
                    WHEN real_membership_types_sa = 'one_day' AND new_member_category_6_sa = 'Unknown' THEN 27

                    -- youth_annual
                    WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Annual' THEN 28
                    WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $25' THEN 29
                    WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Youth Premier - $30' THEN 30
                    WHEN real_membership_types_sa = 'youth_annual' AND new_member_category_6_sa = 'Unknown' THEN 31
                    ELSE 999
                END AS category_sort_order_goal,
                    
                -- METRICS
                SUM(sales_revenue) AS sales_rev_this_year_goal,
                SUM(sales_units) AS sales_units_this_year_goal,
                IF(SUM(sales_units) = 0, 0, SUM(sales_revenue) / SUM(sales_units)) AS rev_per_unit_this_year_goal

            FROM sales_goal_data AS sg
            WHERE purchased_on_year_adjusted_mp = @this_year
            GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
            -- ORDER BY 1

            UNION ALL

            -- Add a row for Unknown category per month/type since unknown doesn't exist in goals but might for actual (as it does for 3/2026 & 4/2026)
            SELECT
                purchased_on_month_adjusted_mp AS month_goal,
                CASE 
                    WHEN purchased_on_month_adjusted_mp IN (1,2,3) THEN 1
                    WHEN purchased_on_month_adjusted_mp IN (4,5,6) THEN 2
                    WHEN purchased_on_month_adjusted_mp IN (7,8,9) THEN 3
                    ELSE 4
                END AS quarter_goal,
                @this_year AS year_goal,

                -- CASE WHEN purchased_on_month_adjusted_mp =  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_current_month,
                -- CASE WHEN purchased_on_month_adjusted_mp <= MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_year_to_date,
                -- CASE WHEN purchased_on_month_adjusted_mp <  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                
                -- TODO: HARD CODE TO AUGUST GIVEN THAT'S WHEN THE ORIGINAL MODEL WAS GENERATED
                CASE WHEN purchased_on_month_adjusted_mp =  8 THEN 1 ELSE 0 END AS is_current_month,
                CASE WHEN purchased_on_month_adjusted_mp <= 8 THEN 1 ELSE 0 END AS is_year_to_date,
                CASE WHEN purchased_on_month_adjusted_mp <  9 THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                
                -- TODO: HARD CODE TO FULL YEAR TO UNDERSTAND WHAT THAT MIGHT LOOK LIKE
                -- CASE WHEN purchased_on_month_adjusted_mp =  12 THEN 1 ELSE 0 END AS is_current_month,
                -- CASE WHEN purchased_on_month_adjusted_mp <= 12 THEN 1 ELSE 0 END AS is_year_to_date,
                -- CASE WHEN purchased_on_month_adjusted_mp <  13 THEN 1 ELSE 0 END AS is_ytd_before_current_month,

                real_membership_types_sa AS type_goal,
                'Unknown' AS category_goal,

                -- "" AS category_sort_order_goal,
                CASE
                    WHEN real_membership_types_sa = 'adult_annual' THEN 10
                    WHEN real_membership_types_sa = 'elite' THEN 13
                    WHEN real_membership_types_sa = 'one_day' THEN 27
                    WHEN real_membership_types_sa = 'youth_annual' THEN 31
                    ELSE 999
                END AS category_sort_order_goal,
                
                0 AS sales_rev_this_year_goal,
                0 AS sales_units_this_year_goal,
                0 AS rev_per_unit_this_year_goal

            FROM sales_goal_data
            WHERE purchased_on_year_adjusted_mp = @this_year
            GROUP BY 1, 2, 3, 4, 5, 6, 7, 8

            UNION ALL

            -- Add rows for actual categories that do not exist in 2026 goals
            SELECT
                sa.month_actual AS month_goal,

                CASE
                    WHEN sa.month_actual IN (1,2,3) THEN 1
                    WHEN sa.month_actual IN (4,5,6) THEN 2
                    WHEN sa.month_actual IN (7,8,9) THEN 3
                    ELSE 4
                END AS quarter_goal,

                -- TODO:
                @this_year AS year_goal,

                CASE WHEN sa.month_actual = 8  THEN 1 ELSE 0 END AS is_current_month,
                CASE WHEN sa.month_actual <= 8 THEN 1 ELSE 0 END AS is_year_to_date,
                CASE WHEN sa.month_actual < 9  THEN 1 ELSE 0 END AS is_ytd_before_current_month,

                sa.type_actual AS type_goal,
                sa.category_actual AS category_goal,

                -- 999 AS category_sort_order_goal,
                CASE
                    -- adult_annual
                    WHEN sa.type_actual = 'adult_annual' AND sa.category_actual = '1-Year $50' THEN 1
                    WHEN sa.type_actual = 'adult_annual' AND sa.category_actual = '3-Year' THEN 2
                    WHEN sa.type_actual = 'adult_annual' AND sa.category_actual = 'Silver' THEN 3
                    WHEN sa.type_actual = 'adult_annual' AND sa.category_actual = 'Gold' THEN 4
                    WHEN sa.type_actual = 'adult_annual' AND sa.category_actual = 'Lifetime' THEN 5
                    WHEN sa.type_actual = 'adult_annual' AND sa.category_actual = 'Platinum - Foundation' THEN 6
                    WHEN sa.type_actual = 'adult_annual' AND sa.category_actual = 'Platinum - Team USA' THEN 7
                    WHEN sa.type_actual = 'adult_annual' AND sa.category_actual = 'Young Adult - $36' THEN 8
                    WHEN sa.type_actual = 'adult_annual' AND sa.category_actual = 'Young Adult - $40' THEN 9
                    WHEN sa.type_actual = 'adult_annual' AND sa.category_actual = 'Unknown' THEN 10
                    -- elite
                    WHEN sa.type_actual = 'elite' AND sa.category_actual = 'Elite' THEN 11
                    WHEN sa.type_actual = 'elite' AND sa.category_actual = 'Elite 2-Year membership' THEN 12
                    WHEN sa.type_actual = 'elite' AND sa.category_actual = 'Unknown' THEN 13
                    -- one_day
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'One Day - $15' THEN 14
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze - Bike' THEN 15
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze - Swim' THEN 16
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze - Run' THEN 17
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze - Relay' THEN 18
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze - Sprint' THEN 19
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze - Intermediate' THEN 20
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze - Ultra' THEN 21
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze - AO' THEN 22
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze - $0' THEN 23
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze - Distance Upgrade' THEN 24
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Club' THEN 25
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Bronze Community Membership' THEN 26
                    WHEN sa.type_actual = 'one_day' AND sa.category_actual = 'Unknown' THEN 27
                    -- youth_annual
                    WHEN sa.type_actual = 'youth_annual' AND sa.category_actual = 'Youth Annual' THEN 28
                    WHEN sa.type_actual = 'youth_annual' AND sa.category_actual = 'Youth Premier - $25' THEN 29
                    WHEN sa.type_actual = 'youth_annual' AND sa.category_actual = 'Youth Premier - $30' THEN 30
                    WHEN sa.type_actual = 'youth_annual' AND sa.category_actual = 'Unknown' THEN 31
                    ELSE 999
                END AS category_sort_order_goal,

                0 AS sales_rev_this_year_goal,
                0 AS sales_units_this_year_goal,
                0 AS rev_per_unit_this_year_goal

            FROM sales_actuals AS sa
                LEFT JOIN sales_goal_data AS sg ON sa.month_actual = sg.purchased_on_month_adjusted_mp
                    AND sa.type_actual = sg.real_membership_types_sa
                    AND sa.category_actual = sg.new_member_category_6_sa    
                    AND sg.purchased_on_year_adjusted_mp = @this_year -- TODO:

            WHERE sg.purchased_on_month_adjusted_mp IS NULL
        ),

        post_race AS (
            SELECT
                pr.month  AS month_post_race,
                pr.type   AS type_post_race,
                pr.category AS category_post_race,

                SUM(COALESCE(pr.sales_units, 0))   AS sales_units_next_year_goal_post_race,
                SUM(COALESCE(pr.sales_revenue, 0)) AS sales_rev_next_year_goal_post_race -- overstated b/c it's not effective price
            
            FROM sales_model_2027_post_race_data pr
            GROUP BY 1, 2, 3
        ),

        sales_base AS (
            SELECT
                -- Goals
                sg.month_goal,
                sg.type_goal,
                sg.category_goal,
                sg.category_sort_order_goal,
                sg.is_ytd_before_current_month,

                -- Actual splits
                sa.sales_rev_this_year_actual,
                sa.sales_rev_this_year_actual_bulk,
                sa.sales_rev_this_year_actual_nonbulk,

                sa.sales_units_this_year_actual,
                sa.sales_units_this_year_actual_bulk,
                sa.sales_units_this_year_actual_nonbulk,

                sa.rev_per_unit_this_year_actual,
                sa.rev_per_unit_this_year_actual_bulk,

                -- sg.sales_rev_this_year_goal,
                -- sg.sales_rev_this_year_goal
                -- pr.sales_rev_next_year_goal_post_race,
                -- pr.sales_units_next_year_goal_post_race,

                -- THIS YEAR estimate TOTAL
                CASE 
                    WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_rev_this_year_actual
                    WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_rev_this_year_goal
                    ELSE 0
                END AS sales_rev_this_year_estimate,

                CASE 
                    WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_this_year_actual
                    WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_this_year_goal
                    ELSE 0
                END AS sales_units_this_year_estimate,

                -- THIS YEAR estimate BULK
                sa.sales_rev_this_year_actual_bulk   AS sales_rev_this_year_estimate_bulk,
                sa.sales_units_this_year_actual_bulk AS sales_units_this_year_estimate_bulk,

                -- THIS YEAR estimate NON-BULK (SOURCE REVENUE; EFFECTIVE PRICE CALC BELOW)
                CASE 
                    WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_rev_this_year_actual_nonbulk
                    WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_rev_this_year_goal
                    ELSE 0
                END AS sales_rev_this_year_estimate_nonbulk_source,

                -- adjust to include this year post race
                -- CASE 
                --     WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_this_year_actual_nonbulk
                --     WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_this_year_goal
                --     ELSE 0
                -- END AS sales_units_this_year_estimate_nonbulk

                CASE
                    WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_this_year_actual_nonbulk + COALESCE(pr.sales_units_next_year_goal_post_race, 0)
                    WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_this_year_goal + COALESCE(pr.sales_units_next_year_goal_post_race, 0)
                    ELSE 0
                END AS sales_units_this_year_estimate_nonbulk

            FROM sales_goals AS sg
                LEFT JOIN sales_actuals AS sa ON sg.month_goal = sa.month_actual
                    AND sg.type_goal      = sa.type_actual
                    AND sg.category_goal  = sa.category_actual
            
                LEFT JOIN post_race AS pr ON pr.month_post_race = sg.month_goal
                    AND sg.type_goal = pr.type_post_race
                    AND sg.category_goal = pr.category_post_race

            -- This clause preserves everything except when: (a) The goal is "Unknown", and (b) The actual data shows no meaningful performance (0 revenue and 0 units).
            -- WHERE NOT (
            --     sg.category_goal = 'Unknown'
            --     AND IFNULL(sa.sales_rev_this_year_actual, 0) = 0
            --     AND IFNULL(sa.sales_units_this_year_actual, 0) = 0
            -- )

                ORDER BY month_goal, category_sort_order_goal
        ),

        -- ======================
        -- NOTE [1] & [2]: compute price once; derive units once; bulk units = difference
        -- ======================
        priced AS (
            SELECT
                b.*,

                -- THIS YEAR EFFECTIVE PRICE LEVELS
                CAST(
                    CASE b.category_goal
                        WHEN 'One Day - $15'              THEN @One_Day_15_effective_this_year
                        WHEN 'Bronze Community Membership'THEN @bronze_community_effective_this_year
                        WHEN 'Bronze - Bike'              THEN @bronze_bike_effective_this_year
                        WHEN 'Bronze - Swim'              THEN @bronze_swim_effective_this_year
                        WHEN 'Bronze - Run'               THEN @bronze_run_effective_this_year
                        WHEN 'Bronze - Relay'             THEN @Bronze_Relay_effective_this_year
                        WHEN 'Bronze - Sprint'            THEN @Bronze_Sprint_effective_this_year
                        WHEN 'Bronze - Intermediate'      THEN @Bronze_Intermediate_effective_this_year
                        WHEN 'Bronze - Ultra'             THEN @Bronze_Ultra_effective_this_year
                        WHEN 'Bronze - $0'                THEN @Bronze_$0_effective_this_year
                        WHEN 'Bronze - AO'                THEN @Bronze_AO_effective_this_year
                        WHEN 'Bronze - Distance Upgrade'  THEN @Bronze_Upgrade_effective_this_year
                        WHEN 'Club'                       THEN @Club_effective_this_year
                        WHEN 'Unknown'                    THEN @Unknown_effective_this_year
                        WHEN '1-Year $50'                 THEN @1_Year_50_effective_this_year
                        WHEN 'Silver'                     THEN @Silver_effective_this_year
                        WHEN 'Gold'                       THEN @Gold_effective_this_year
                        WHEN '3-Year'                     THEN @3_Year_effective_this_year
                        WHEN 'Lifetime'                   THEN @Lifetime_effective_this_year
                        WHEN 'Platinum - Foundation'      THEN @Platinum_Foundation_effective_this_year
                        WHEN 'Platinum - Team USA'        THEN @Platinum_USA_effective_this_year
                        WHEN 'Young Adult - $36'          THEN @Young_Adult_36_effective_this_year
                        WHEN 'Young Adult - $40'          THEN @Young_Adult_40_effective_this_year
                        WHEN 'Youth Annual'               THEN @Youth_Annual_effective_this_year
                        WHEN 'Youth Premier - $25'        THEN @Youth_Premier_25_effective_this_year
                        WHEN 'Youth Premier - $30'        THEN @Youth_Premier_30_effective_this_year
                        WHEN 'Elite'                      THEN @Elite_effective_this_year
                        WHEN 'Elite 2-Year membership'    THEN @Elite_2_Year_effective_this_year
                        ELSE NULL
                    END
                AS DECIMAL(10,2)) AS price_this_year_effective_nonbulk,

                -- NOTE [1]: single source of truth for the next year price (DECIMAL avoids float drift)
                -- NEXT YEAR EFFECTIVE PRICE LEVELS
                CAST(
                    CASE b.category_goal
                        WHEN 'One Day - $15'              THEN @One_Day_15_effective_next_year
                        WHEN 'Bronze Community Membership'THEN @bronze_community_effective_next_year
                        WHEN 'Bronze - Bike'              THEN @bronze_bike_effective_next_year
                        WHEN 'Bronze - Swim'              THEN @bronze_swim_effective_next_year
                        WHEN 'Bronze - Run'               THEN @bronze_run_effective_next_year
                        WHEN 'Bronze - Relay'             THEN @Bronze_Relay_effective_next_year
                        WHEN 'Bronze - Sprint'            THEN @Bronze_Sprint_effective_next_year
                        WHEN 'Bronze - Intermediate'      THEN @Bronze_Intermediate_effective_next_year
                        WHEN 'Bronze - Ultra'             THEN @Bronze_Ultra_effective_next_year
                        WHEN 'Bronze - $0'                THEN @Bronze_$0_effective_next_year
                        WHEN 'Bronze - AO'                THEN @Bronze_AO_effective_next_year
                        WHEN 'Bronze - Distance Upgrade'  THEN @Bronze_Upgrade_effective_next_year
                        WHEN 'Club'                       THEN @Club_effective_next_year
                        WHEN 'Unknown'                    THEN @Unknown_effective_next_year
                        WHEN '1-Year $50'                 THEN @1_Year_50_effective_next_year
                        WHEN 'Silver'                     THEN @Silver_effective_next_year
                        WHEN 'Gold'                       THEN @Gold_effective_next_year
                        WHEN '3-Year'                     THEN @3_Year_effective_next_year
                        WHEN 'Lifetime'                   THEN @Lifetime_effective_next_year
                        WHEN 'Platinum - Foundation'      THEN @Platinum_Foundation_effective_next_year
                        WHEN 'Platinum - Team USA'        THEN @Platinum_USA_effective_next_year
                        WHEN 'Young Adult - $36'          THEN @Young_Adult_36_effective_next_year
                        WHEN 'Young Adult - $40'          THEN @Young_Adult_40_effective_next_year
                        WHEN 'Youth Annual'               THEN @Youth_Annual_effective_next_year
                        WHEN 'Youth Premier - $25'        THEN @Youth_Premier_25_effective_next_year
                        WHEN 'Youth Premier - $30'        THEN @Youth_Premier_30_effective_next_year
                        WHEN 'Elite'                      THEN @Elite_effective_next_year
                        WHEN 'Elite 2-Year membership'    THEN @Elite_2_Year_effective_next_year
                        ELSE NULL                         -- guardrail if a new category appears
                    END
                AS DECIMAL(10,2)) AS price_next_year_effective_nonbulk,
                
                -- Price for BULK: use actual bulk unit economics from this year / use fallback of 0 if null
                CAST(
                    COALESCE(
                        b.rev_per_unit_this_year_actual_bulk,
                        0
                    )
                AS DECIMAL(10,2)) AS price_next_year_bulk,

                -- THIS YEAR ACTUAL PRICE LEVELS
                CAST(
                    CASE b.category_goal
                        WHEN 'One Day - $15'              THEN @One_Day_15_actual_this_year
                        WHEN 'Bronze Community Membership'THEN @bronze_community_actual_this_year
                        WHEN 'Bronze - Bike'              THEN @Bronze_Bike_actual_this_year
                        WHEN 'Bronze - Swim'              THEN @Bronze_Swim_actual_this_year
                        WHEN 'Bronze - Run'               THEN @Bronze_Run_actual_this_year
                        WHEN 'Bronze - Relay'             THEN @Bronze_Relay_actual_this_year
                        WHEN 'Bronze - Sprint'            THEN @Bronze_Sprint_actual_this_year
                        WHEN 'Bronze - Intermediate'      THEN @Bronze_Intermediate_actual_this_year
                        WHEN 'Bronze - Ultra'             THEN @Bronze_Ultra_actual_this_year
                        WHEN 'Bronze - $0'                THEN @Bronze_$0_actual_this_year
                        WHEN 'Bronze - AO'                THEN @Bronze_AO_actual_this_year
                        WHEN 'Bronze - Distance Upgrade'  THEN @Bronze_Upgrade_actual_this_year
                        WHEN 'Club'                       THEN @Club_actual_this_year
                        WHEN 'Unknown'                    THEN @Unknown_actual_this_year
                        WHEN '1-Year $50'                 THEN @1_Year_50_actual_this_year
                        WHEN 'Silver'                     THEN @Silver_actual_this_year
                        WHEN 'Gold'                       THEN @Gold_actual_this_year
                        WHEN '3-Year'                     THEN @3_Year_actual_this_year
                        WHEN 'Lifetime'                   THEN @Lifetime_actual_this_year
                        WHEN 'Platinum - Foundation'      THEN @Platinum_Foundation_actual_this_year
                        WHEN 'Platinum - Team USA'        THEN @Platinum_USA_actual_this_year
                        WHEN 'Young Adult - $36'          THEN @Young_Adult_36_actual_this_year
                        WHEN 'Young Adult - $40'          THEN @Young_Adult_40_actual_this_year
                        WHEN 'Youth Annual'               THEN @Youth_Annual_actual_this_year
                        WHEN 'Youth Premier - $25'        THEN @Youth_Premier_25_actual_this_year
                        WHEN 'Youth Premier - $30'        THEN @Youth_Premier_30_actual_this_year
                        WHEN 'Elite'                      THEN @Elite_actual_this_year
                        WHEN 'Elite 2-Year membership'    THEN @Elite_2_Year_actual_this_year
                        ELSE NULL
                    END
                AS DECIMAL(10,2)) AS price_this_year_actual,

                -- NEXT YEAR ACTUAL PRICE LEVELS
                CAST(
                    CASE b.category_goal
                        WHEN 'One Day - $15'              THEN @One_Day_15_actual_next_year
                        WHEN 'Bronze Community Membership'THEN @bronze_community_actual_next_year
                        WHEN 'Bronze - Bike'              THEN @Bronze_Bike_actual_next_year
                        WHEN 'Bronze - Swim'              THEN @Bronze_Swim_actual_next_year
                        WHEN 'Bronze - Run'               THEN @Bronze_Run_actual_next_year
                        WHEN 'Bronze - Relay'             THEN @Bronze_Relay_actual_next_year
                        WHEN 'Bronze - Sprint'            THEN @Bronze_Sprint_actual_next_year
                        WHEN 'Bronze - Intermediate'      THEN @Bronze_Intermediate_actual_next_year
                        WHEN 'Bronze - Ultra'             THEN @Bronze_Ultra_actual_next_year
                        WHEN 'Bronze - $0'                THEN @Bronze_$0_actual_next_year
                        WHEN 'Bronze - AO'                THEN @Bronze_AO_actual_next_year
                        WHEN 'Bronze - Distance Upgrade'  THEN @Bronze_Upgrade_actual_next_year
                        WHEN 'Club'                       THEN @Club_actual_next_year
                        WHEN 'Unknown'                    THEN @Unknown_actual_next_year
                        WHEN '1-Year $50'                 THEN @1_Year_50_actual_next_year
                        WHEN 'Silver'                     THEN @Silver_actual_next_year
                        WHEN 'Gold'                       THEN @Gold_actual_next_year
                        WHEN '3-Year'                     THEN @3_Year_actual_next_year
                        WHEN 'Lifetime'                   THEN @Lifetime_actual_next_year
                        WHEN 'Platinum - Foundation'      THEN @Platinum_Foundation_actual_next_year
                        WHEN 'Platinum - Team USA'        THEN @Platinum_USA_actual_next_year
                        WHEN 'Young Adult - $36'          THEN @Young_Adult_36_actual_next_year
                        WHEN 'Young Adult - $40'          THEN @Young_Adult_40_actual_next_year
                        WHEN 'Youth Annual'               THEN @Youth_Annual_actual_next_year
                        WHEN 'Youth Premier - $25'        THEN @Youth_Premier_25_actual_next_year
                        WHEN 'Youth Premier - $30'        THEN @Youth_Premier_30_actual_next_year
                        WHEN 'Elite'                      THEN @Elite_actual_next_year
                        WHEN 'Elite 2-Year membership'    THEN @Elite_2_Year_actual_next_year
                        ELSE NULL
                    END
                AS DECIMAL(10,2)) AS price_next_year_actual,

                -- NEXT YEAR UNIT PCT CHANGE
                CAST(
                    CASE
                        b.category_goal
                            WHEN 'One Day - $15'              THEN @UG_One_Day_15
                            WHEN 'Bronze Community Membership'THEN @UG_bronze_community
                            WHEN 'Bronze - Bike'              THEN @UG_Bronze_Bike
                            WHEN 'Bronze - Swim'              THEN @UG_Bronze_Swim
                            WHEN 'Bronze - Run'               THEN @UG_Bronze_Run
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
                            WHEN 'Elite 2-Year membership'    THEN @UG_Elite_2_Year
                            ELSE NULL
                    END
                AS DECIMAL(10,2)) AS unit_next_year_pct_change,

                -- >>> UNIT GROWTH (ADDED): apply category growth pct to derived units >>>
                -- Derived next year units for total/nonbulk; bulk = total - nonbulk
                CAST(
                    -- CASE 
                    --     WHEN b.is_ytd_before_current_month = 1 THEN b.sales_units_this_year_actual
                    --     ELSE b.sales_units_this_year_estimate
                    -- END * 
                    b.sales_units_this_year_estimate * 
                    (1 + 
                            CASE b.category_goal
                                WHEN 'One Day - $15'              THEN @UG_One_Day_15
                                WHEN 'Bronze Community Membership'THEN @UG_bronze_community
                                WHEN 'Bronze - Bike'              THEN @UG_Bronze_Bike
                                WHEN 'Bronze - Swim'              THEN @UG_Bronze_Swim
                                WHEN 'Bronze - Run'               THEN @UG_Bronze_Run
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
                                WHEN 'Elite 2-Year membership'    THEN @UG_Elite_2_Year
                                ELSE 0
                            END) 
                AS DECIMAL(10,2)) units_total_next_year,

                CAST(
                    -- CASE    
                    --     WHEN b.is_ytd_before_current_month = 1 THEN b.sales_units_this_year_actual_nonbulk
                    --     ELSE b.sales_units_this_year_estimate_nonbulk
                    -- END * 
                    
                    -- already calc in "sales_base" CTE
                    b.sales_units_this_year_estimate_nonbulk *
                    (1 + 
                            CASE b.category_goal
                                WHEN 'One Day - $15'              THEN @UG_One_Day_15
                                WHEN 'Bronze Community Membership'THEN @UG_bronze_community
                                WHEN 'Bronze - Bike'              THEN @UG_Bronze_Bike
                                WHEN 'Bronze - Swim'              THEN @UG_Bronze_Swim
                                WHEN 'Bronze - Run'               THEN @UG_Bronze_Run
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
                                WHEN 'Elite 2-Year membership'    THEN @UG_Elite_2_Year
                                ELSE 0
                        END) 
                AS  DECIMAL(10,2)) units_nonbulk_next_year
                -- <<< UNIT GROWTH (ADDED) <<<

            FROM sales_base b
        ),

        -- ======================
        -- NOTE [3]: price all three consistently => exact reconciliation
        -- ======================
        sales_estimate_next_year AS (
            SELECT
                p.*,

                -- POST RACE UNITS & REVENUE
                COALESCE(pr.sales_units_next_year_goal_post_race, 0) AS sales_units_next_year_goal_post_race,
                COALESCE(pr.sales_units_next_year_goal_post_race, 0) * COALESCE(p.price_next_year_effective_nonbulk, 0) AS sales_rev_next_year_goal_post_race, -- did not include b/c sales rev doesn't include post race revenue

                -- THIS YEAR ESTIMATE NON-BULK REVENUE USING THIS YEAR EFFECTIVE PRICE
                CAST(
                    (
                        COALESCE(p.sales_units_this_year_estimate_nonbulk, 0)
                        - COALESCE(pr.sales_units_next_year_goal_post_race, 0)
                    ) 
                        * COALESCE(p.price_this_year_effective_nonbulk, 0)
                AS DECIMAL(10,2)) AS sales_rev_this_year_estimate_nonbulk,

                -- bulk units = total - nonbulk (never mix splits from different bases)
                -- (p.units_total_next_year - p.units_nonbulk_next_year) AS units_bulk_next_year,

                -- Revenues: units × next year price (consistent for total/nonbulk/bulk)
                -- Bulk Units + Non-bulk Units
                CAST(
                    ROUND((
                        (p.units_total_next_year - p.units_nonbulk_next_year) * p.price_next_year_bulk) + 
                        (p.units_nonbulk_next_year * p.price_next_year_effective_nonbulk)
                    , 2) 
                AS DECIMAL(10,2)) sales_rev_next_year_goal,

                -- FORMULA ABOVE WAS NOT DISPLAYING VALUES FOR Q4 2027 REV GOAL; FIXED BUT KEEIPNG FORMULA IF NECESSARY
                -- ROUND(
                --     GREATEST(COALESCE(p.units_total_next_year,0) - COALESCE(p.units_nonbulk_next_year,0), 0) * COALESCE(p.price_next_year_bulk,0)
                --         + COALESCE(p.units_nonbulk_next_year,0) * COALESCE(p.price_next_year_effective_nonbulk,0)
                --         , 2) AS sales_rev_next_year_goal,

                -- REVENUE CALCULATIONS (price each split with its own price)
                -- CAST((p.units_nonbulk_next_year * p.price_next_year_effective_nonbulk) AS DECIMAL(10,2)) sales_rev_next_year_goal_nonbulk,
                CAST(
                    (
                        COALESCE(p.units_nonbulk_next_year, 0)
                        - COALESCE(pr.sales_units_next_year_goal_post_race, 0) -- did not include b/c sales rev doesn't include post race revenue
                    ) 
                        * COALESCE(p.price_next_year_effective_nonbulk, 0)
                AS DECIMAL(10,2)) AS sales_rev_next_year_goal_nonbulk,

                CAST(
                    ((p.units_total_next_year - p.units_nonbulk_next_year) * p.price_next_year_bulk)
                AS DECIMAL(10,2)) sales_rev_next_year_goal_bulk,

                -- UNITS (for parity with your original names)
                CAST(p.units_total_next_year AS DECIMAL(10,2)) sales_units_next_year_goal,
                CAST((p.units_total_next_year - p.units_nonbulk_next_year) AS DECIMAL(10,2)) sales_units_next_year_goal_bulk,
                CAST(p.units_nonbulk_next_year AS DECIMAL(10,2)) sales_units_next_year_goal_nonbulk -- includes post race; added in the sales base cte above

            FROM priced p
                LEFT JOIN post_race AS pr ON pr.month_post_race = p.month_goal
                    AND p.type_goal = pr.type_post_race
                    AND p.category_goal = pr.category_post_race
        )

        SELECT 
            e.*,

            -- Diff vs this year estimate (non-bulk basis, kept)
            IFNULL(e.sales_rev_next_year_goal_nonbulk - e.sales_rev_this_year_estimate_nonbulk, 0) AS goal_v_actual_rev_diff_abs,
            IFNULL(e.sales_units_next_year_goal_nonbulk - e.sales_units_this_year_estimate_nonbulk, 0) AS goal_v_actual_units_diff_abs,

            -- PRICE VS UNIT CHANGE IMPACT: NON BULK ONLY
            ROUND(
                (IFNULL(e.price_next_year_effective_nonbulk, IFNULL(IF(e.sales_units_this_year_estimate_nonbulk = 0, 0, e.sales_rev_this_year_estimate_nonbulk / NULLIF(e.sales_units_this_year_estimate_nonbulk, 0)), 0))
                - IFNULL(IF(e.sales_units_this_year_estimate_nonbulk = 0, 0, e.sales_rev_this_year_estimate_nonbulk / NULLIF(e.sales_units_this_year_estimate_nonbulk, 0)), 0))
                * ((IFNULL(e.sales_units_this_year_estimate_nonbulk, 0) + IFNULL(e.sales_units_next_year_goal_nonbulk, 0)) / 2)
            , 2) AS price_impact_abs,

            ROUND(
                (IFNULL(e.sales_units_next_year_goal_nonbulk, 0) - IFNULL(e.sales_units_this_year_estimate_nonbulk, 0))
                * ((
                    IFNULL(IF(e.sales_units_this_year_estimate_nonbulk = 0, 0, e.sales_rev_this_year_estimate_nonbulk / NULLIF(e.sales_units_this_year_estimate_nonbulk, 0)), 0)
                    + IFNULL(e.price_next_year_effective_nonbulk, IFNULL(IF(e.sales_units_this_year_estimate_nonbulk = 0, 0, e.sales_rev_this_year_estimate_nonbulk / NULLIF(e.sales_units_this_year_estimate_nonbulk, 0)), 0))
                ) / 2)
            , 2) AS unit_impact_abs,
            
            -- PRICE VS UNIT CHANGE IMPACT (BULK)
            ROUND(
                (COALESCE(e.price_next_year_bulk, 0)
                - COALESCE(NULLIF(e.sales_rev_this_year_estimate_bulk,0)/NULLIF(e.sales_units_this_year_estimate_bulk,0), 0))
                * ((COALESCE(e.sales_units_this_year_estimate_bulk,0)
                    + COALESCE(e.units_total_next_year - e.units_nonbulk_next_year,0)) / 2)
            , 2) AS price_impact_abs_bulk,

            ROUND(
                (COALESCE(e.units_total_next_year - e.units_nonbulk_next_year,0) - COALESCE(e.sales_units_this_year_estimate_bulk,0))
                * ((COALESCE(NULLIF(e.sales_rev_this_year_estimate_bulk,0)/NULLIF(e.sales_units_this_year_estimate_bulk,0), 0)
                    + COALESCE(e.price_next_year_bulk,0)) / 2)
            , 2) AS unit_impact_abs_bulk,

            -- PRICE VS UNIT CHANGE IMPACT (TOTAL)
            ROUND(
                (COALESCE(NULLIF(e.sales_rev_next_year_goal,0)/NULLIF(e.sales_units_next_year_goal,0), 0)
                - COALESCE(NULLIF(e.sales_rev_this_year_estimate,0)/NULLIF(e.sales_units_this_year_estimate,0), 0))
                * ((COALESCE(e.sales_units_this_year_estimate,0) + COALESCE(e.sales_units_next_year_goal,0)) / 2)
            , 2) AS price_impact_abs_total,

            ROUND(
                (COALESCE(e.sales_units_next_year_goal,0) - COALESCE(e.sales_units_this_year_estimate,0))
                * ((COALESCE(NULLIF(e.sales_rev_this_year_estimate,0)/NULLIF(e.sales_units_this_year_estimate,0), 0)
                    + COALESCE(NULLIF(e.sales_rev_next_year_goal,0)/NULLIF(e.sales_units_next_year_goal,0), 0)) / 2)
            , 2) AS unit_impact_abs_total,

            -- NOTE [6]: optional reconciliation check (0.00 means perfect tie-out). Comment out if not needed.
            ROUND(ABS((e.sales_rev_next_year_goal_nonbulk + e.sales_rev_next_year_goal_bulk) - e.sales_rev_next_year_goal), 6) AS recon_delta,

            -- Created at timestamps:
            @created_at_mtn AS created_at_mtn,
            @created_at_utc AS created_at_utc

        FROM sales_estimate_next_year AS e
        -- WHERE e.price_next_year_bulk IS NULL
;

/* -----------------------------------------------------------------------------
   2) View results
----------------------------------------------------------------------------- */
SELECT "0_raw_data" AS query_label, s.* FROM sales_model_2027 AS s ORDER BY month_goal ASC LIMIT 500;

SELECT
  "1_by_month_sales_model_2027" AS query_label,
  month_goal,

  COUNT(*) AS row_count,

  FORMAT(SUM(sales_units_this_year_estimate), 0) AS sales_units_this_year_estimate,
  FORMAT(SUM(sales_rev_this_year_estimate), 0) AS sales_rev_this_year_estimate,
  
  FORMAT(SUM(sales_units_this_year_estimate_nonbulk), 0) AS sales_units_this_year_estimate_nonbulk,
  FORMAT(SUM(sales_rev_this_year_estimate_nonbulk), 0) AS sales_rev_this_year_estimate_nonbulk,
  
  -- MAX(price_this_year_actual) AS price_this_year_actual,
  FORMAT(SUM(sales_rev_this_year_estimate_nonbulk) / NULLIF(SUM(sales_units_this_year_estimate_nonbulk) - SUM(sales_units_next_year_goal_post_race), 0),2) AS non_bulk_price_this_year_effective,

  FORMAT(SUM(sales_units_next_year_goal_nonbulk), 0) AS sales_units_next_year_goal_nonbulk, 
  FORMAT(SUM(sales_rev_next_year_goal_nonbulk), 0) AS sales_rev_next_year_goal_nonbulk, 

  -- MAX(price_next_year_actual) AS price_next_year_actual,
  FORMAT(SUM(sales_rev_next_year_goal_nonbulk) / NULLIF(SUM(sales_units_next_year_goal_nonbulk) - SUM(sales_units_next_year_goal_post_race), 0), 2) AS non_bulk_price_next_year_effective,
  
  FORMAT(SUM(sales_units_next_year_goal_post_race), 0) AS sales_units_next_year_goal_post_race, 
  FORMAT(SUM(sales_rev_next_year_goal_post_race), 0) AS sales_rev_next_year_goal_post_race, 

  MIN(month_goal) AS min_month,
  MAX(month_goal) AS max_month
FROM sales_model_2027
GROUP BY month_goal WITH ROLLUP
ORDER BY month_goal
;

SELECT
  "2_by_catogory_sales_model_2027" AS query_label,
  type_goal,
  category_goal,
  MIN(category_sort_order_goal),

  COUNT(*) AS row_count,

  FORMAT(SUM(sales_units_this_year_estimate), 0) AS sales_units_this_year_estimate,
  FORMAT(SUM(sales_rev_this_year_estimate), 0) AS sales_rev_this_year_estimate,
  
  FORMAT(SUM(sales_units_this_year_estimate_nonbulk), 0) AS sales_units_this_year_estimate_nonbulk,
  FORMAT(SUM(sales_rev_this_year_estimate_nonbulk), 0) AS sales_rev_this_year_estimate_nonbulk,
  
  MAX(price_this_year_actual) AS price_this_year_actual,
  FORMAT(SUM(sales_rev_this_year_estimate_nonbulk) / NULLIF(SUM(sales_units_this_year_estimate_nonbulk) - SUM(sales_units_next_year_goal_post_race), 0), 2) AS non_bulk_price_this_year_effective,

  FORMAT(SUM(sales_units_next_year_goal_nonbulk), 0) AS sales_units_next_year_goal_nonbulk, 
  FORMAT(SUM(sales_rev_next_year_goal_nonbulk), 0) AS sales_rev_next_year_goal_nonbulk, 

  MAX(price_next_year_actual) AS price_next_year_actual,
  FORMAT(SUM(sales_rev_next_year_goal_nonbulk) / NULLIF(SUM(sales_units_next_year_goal_nonbulk) - SUM(sales_units_next_year_goal_post_race), 0), 2) AS non_bulk_price_next_year_effective,
  
  FORMAT(SUM(sales_units_next_year_goal_post_race), 0) AS sales_units_next_year_goal_post_race, 
  FORMAT(SUM(sales_rev_next_year_goal_post_race), 0) AS sales_rev_next_year_goal_post_race, 

  MIN(month_goal) AS min_month,
  MAX(month_goal) AS max_month

FROM sales_model_2027
GROUP BY type_goal, category_goal WITH ROLLUP
ORDER BY type_goal, MIN(category_sort_order_goal), category_goal
;

-- THIS YEAR SALES ESTIMATE (NON-BULK)
SELECT
    "3_this_year_sales_estimate_nonbulk" AS query_label,
    COALESCE(type_goal, 'Grand Total') AS type_goal,
    ROUND(SUM(CASE WHEN month_goal = 1  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `1`,
    ROUND(SUM(CASE WHEN month_goal = 2  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `2`,
    ROUND(SUM(CASE WHEN month_goal = 3  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `3`,
    ROUND(SUM(CASE WHEN month_goal = 4  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `4`,
    ROUND(SUM(CASE WHEN month_goal = 5  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `5`,
    ROUND(SUM(CASE WHEN month_goal = 6  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `6`,
    ROUND(SUM(CASE WHEN month_goal = 7  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `7`,
    ROUND(SUM(CASE WHEN month_goal = 8  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `8`,
    ROUND(SUM(CASE WHEN month_goal = 9  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `9`,
    ROUND(SUM(CASE WHEN month_goal = 10 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `10`,
    ROUND(SUM(CASE WHEN month_goal = 11 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `11`,
    ROUND(SUM(CASE WHEN month_goal = 12 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `12`,
    ROUND(SUM(sales_rev_this_year_estimate_nonbulk), 2) AS Grand_Total
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP
;

-- NEXT YEAR SALES GOAL (NON-BULK)
SELECT
    "4_next_year_sales_goal_nonbulk" AS query_label,
    COALESCE(type_goal, 'Grand Total') AS type_goal,
    ROUND(SUM(CASE WHEN month_goal = 1  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `1`,
    ROUND(SUM(CASE WHEN month_goal = 2  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `2`,
    ROUND(SUM(CASE WHEN month_goal = 3  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `3`,
    ROUND(SUM(CASE WHEN month_goal = 4  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `4`,
    ROUND(SUM(CASE WHEN month_goal = 5  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `5`,
    ROUND(SUM(CASE WHEN month_goal = 6  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `6`,
    ROUND(SUM(CASE WHEN month_goal = 7  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `7`,
    ROUND(SUM(CASE WHEN month_goal = 8  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `8`,
    ROUND(SUM(CASE WHEN month_goal = 9  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `9`,
    ROUND(SUM(CASE WHEN month_goal = 10 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `10`,
    ROUND(SUM(CASE WHEN month_goal = 11 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `11`,
    ROUND(SUM(CASE WHEN month_goal = 12 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END), 2) AS `12`,
    ROUND(SUM(sales_rev_next_year_goal_nonbulk), 2) AS Grand_Total
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP
;

-- VARIANCE: NEXT YEAR GOAL - THIS YEAR ESTIMATE
SELECT
    "5_variance_next_year_vs_this_year_nonbulk" AS query_label,
    COALESCE(type_goal, 'Grand Total') AS type_goal,
    ROUND(SUM(CASE WHEN month_goal = 1  THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `1`,
    ROUND(SUM(CASE WHEN month_goal = 2  THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `2`,
    ROUND(SUM(CASE WHEN month_goal = 3  THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `3`,
    ROUND(SUM(CASE WHEN month_goal = 4  THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `4`,
    ROUND(SUM(CASE WHEN month_goal = 5  THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `5`,
    ROUND(SUM(CASE WHEN month_goal = 6  THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `6`,
    ROUND(SUM(CASE WHEN month_goal = 7  THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `7`,
    ROUND(SUM(CASE WHEN month_goal = 8  THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `8`,
    ROUND(SUM(CASE WHEN month_goal = 9  THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `9`,
    ROUND(SUM(CASE WHEN month_goal = 10 THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `10`,
    ROUND(SUM(CASE WHEN month_goal = 11 THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `11`,
    ROUND(SUM(CASE WHEN month_goal = 12 THEN sales_rev_next_year_goal_nonbulk - sales_rev_this_year_estimate_nonbulk ELSE 0 END), 2) AS `12`,
    ROUND(SUM(sales_rev_next_year_goal_nonbulk) - SUM(sales_rev_this_year_estimate_nonbulk), 2) AS Grand_Total
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP
;

-- % VARIANCE: NEXT YEAR GOAL VS THIS YEAR ESTIMATE
SELECT
    "6_pct_variance_next_year_vs_this_year_nonbulk" AS query_label,
    COALESCE(type_goal, 'Grand Total') AS type_goal,
    ROUND((SUM(CASE WHEN month_goal = 1  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 1  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `1`,
    ROUND((SUM(CASE WHEN month_goal = 2  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 2  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `2`,
    ROUND((SUM(CASE WHEN month_goal = 3  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 3  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `3`,
    ROUND((SUM(CASE WHEN month_goal = 4  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 4  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `4`,
    ROUND((SUM(CASE WHEN month_goal = 5  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 5  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `5`,
    ROUND((SUM(CASE WHEN month_goal = 6  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 6  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `6`,
    ROUND((SUM(CASE WHEN month_goal = 7  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 7  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `7`,
    ROUND((SUM(CASE WHEN month_goal = 8  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 8  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `8`,
    ROUND((SUM(CASE WHEN month_goal = 9  THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 9  THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `9`,
    ROUND((SUM(CASE WHEN month_goal = 10 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 10 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `10`,
    ROUND((SUM(CASE WHEN month_goal = 11 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 11 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `11`,
    ROUND((SUM(CASE WHEN month_goal = 12 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END) / NULLIF(SUM(CASE WHEN month_goal = 12 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END), 0) - 1) * 100, 1) AS `12`,
    ROUND((SUM(sales_rev_next_year_goal_nonbulk) / NULLIF(SUM(sales_rev_this_year_estimate_nonbulk), 0) - 1) * 100, 1) AS Grand_Total
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP
;

-- EFFECTIVE PRICE TABLE
SELECT
    "7_effective_price_table" AS query_label,
    type_goal,
    category_goal,
    category_sort_order_goal,

    MAX(price_this_year_actual) AS this_year_actual,
    MAX(price_this_year_effective_nonbulk) AS this_year_effective,
    MAX(price_next_year_actual) AS next_year_actual,
    MAX(price_next_year_effective_nonbulk) AS next_year_effective
FROM sales_model_2027
GROUP BY
    type_goal,
    category_goal,
    category_sort_order_goal
ORDER BY
    type_goal,
    MIN(category_sort_order_goal),
    category_goal
;