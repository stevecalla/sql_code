-- C:\Users\calla\development\usat\sql_code\6j_2027_model\step_0_discovery_actual_vs_goal_model_with_post_race_v3.sql
-- SALES MODEL WITH POST RACE

-- #5 CREATE 2027 SALES MODEL
USE usat_sales_db;

-- ======================
-- SAVED MODEL VERSIONS
-- -- stores shared model assumptions
-- ======================
CREATE TABLE IF NOT EXISTS sales_model_2027_versions (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    version_name VARCHAR(150) NULL,
    model_name VARCHAR(100) NULL,
    user_name VARCHAR(50) NOT NULL,
    assumptions_json JSON NOT NULL,
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    UNIQUE KEY uq_sales_model_2027_versions_version_name (version_name),
    KEY idx_sales_model_2027_versions_created_at (created_at),
    KEY idx_sales_model_2027_versions_user_name (user_name)
);

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


-- >>> BUSINESS GOAL LEVERS (MVP): annual goals allocated using this year non-bulk seasonality / mix >>>
    -- VOLUME METHOD
    -- TOP_LEVEL = use business levers: new, repeat, win-back, upgrades/downgrades
    -- PRODUCT   = use product-level @UG_... unit growth assumptions
    SET @volume_method = 'TOP_LEVEL'; -- TOP_LEVEL or PRODUCT
    -- existing @UG_... category variables remain available as a category-level tuning layer

    -- VOLUME — who is buying
    SET @lever_new_members_base = 117801;
    SET @lever_new_members_pct_change = 0.00;

    SET @lever_repeat_one_day_base = 66541;
    SET @lever_repeat_annual_base = 37314;
    SET @lever_repeat_members_base = 103856;
    SET @lever_repeat_members_pct_change = 0.00;

    SET @lever_winback_units_incremental = 0; -- 2000
    SET @lever_winback_one_day_pct = 0.50;
    SET @lever_winback_annual_pct = 0.50;

    -- MIX — members switching between one-day and annual
    SET @lever_upgrades_base = 12570;
    SET @lever_upgrades_pct_change = 0.0;

    SET @lever_downgrades_base = 11013;
    SET @lever_downgrades_pct_change = -0.0;

    -- DERIVED BUSINESS GOAL UNIT IMPACTS
    -- new members = allocated across one_day + adult_annual using this year mix / seasonality
    SET @lever_new_member_units_incremental = ROUND(@lever_new_members_base * @lever_new_members_pct_change,0);

    -- repeat = allocated between one_day and adult_annual using repeat cohort mix
    SET @lever_repeat_one_day_units_incremental = ROUND(@lever_repeat_one_day_base * @lever_repeat_members_pct_change,0);
    SET @lever_repeat_annual_units_incremental = ROUND(@lever_repeat_annual_base * @lever_repeat_members_pct_change,0);
    SET @lever_repeat_units_incremental = @lever_repeat_one_day_units_incremental + @lever_repeat_annual_units_incremental;

    -- win-back = allocated 50/50 between one_day and adult_annual
    SET @lever_winback_one_day_units_incremental = ROUND(@lever_winback_units_incremental * @lever_winback_one_day_pct,0);
    SET @lever_winback_annual_units_incremental = @lever_winback_units_incremental - @lever_winback_one_day_units_incremental;

    -- upgrades + fewer downgrades = transfer units from one_day to adult_annual; total units do not increase
    SET @lever_upgrade_units_incremental = ROUND(@lever_upgrades_base * @lever_upgrades_pct_change,0);
    SET @lever_downgrade_units_saved = ROUND(@lever_downgrades_base * ABS(@lever_downgrades_pct_change),0);
    SET @lever_mix_units_incremental = @lever_upgrade_units_incremental + @lever_downgrade_units_saved;
    
    -- NOTE:
    -- new members = allocated across one_day + adult_annual using this year mix / seasonality
    -- repeat = allocated between one_day + adult_annual using repeat cohort mix
    -- win-back = allocated 50/50 between one_day + adult_annual
    -- upgrades + fewer downgrades = transfer units from one_day to adult_annual; total units do not increase
    -- price = applied to next year effective non-bulk price
    -- @UG_... category variables are used only when @volume_method = 'PRODUCT'

    -- PRICE
    -- price     = applied to next year effective non-bulk price
    -- PRODUCT   = set next-year ACTUAL product price; effective price is calculated
    --             using this year's effective / actual realization rate
    -- TOP_LEVEL = increase this year's effective price by @lever_price_pct_change
    SET @price_method = 'PRODUCT'; -- TODO: PRODUCT or TOP_LEVEL
    SET @lever_price_pct_change = 0.00; -- TODO:

    -- PRODUCT DISCONTINUATION / REDISTRIBUTION
    -- 1 = discontinue product and redistribute its projected units
    SET @discontinue_Platinum_Foundation = 0;
    SET @discontinue_Platinum_USA = 0;

    -- platinum redistribution mix; should total 1.00
    SET @redistribute_Platinum_to_Silver_pct = 0.50;
    SET @redistribute_Platinum_to_Gold_pct = 0.20;
    SET @redistribute_Platinum_to_3_Year_pct = 0.30;
-- <<< BUSINESS GOAL LEVERS (MVP) <<<

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
    -- SET @One_Day_15_effective_next_year = 14.91; -- $14.99
    -- SET @Bronze_Relay_effective_next_year = 8.79; -- $9
    -- SET @Bronze_Sprint_effective_next_year = 14.91; -- $14.99
    -- SET @Bronze_Intermediate_effective_next_year = 24.69; -- $24.99
    -- SET @Bronze_Ultra_effective_next_year = 34.1; -- $34.99
    -- SET @Bronze_$0_effective_next_year = 0; -- $0
    -- SET @Bronze_AO_effective_next_year = 0; -- $0
    -- SET @Bronze_Upgrade_effective_next_year = 5.12; -- $7
    -- SET @Club_effective_next_year = 0; -- $0
    -- SET @Unknown_effective_next_year = 2.2; -- $4
    -- SET @1_Year_50_effective_next_year = 68.59; -- $69.99
    -- SET @Silver_effective_next_year = 68.28; -- $69.99
    -- SET @Gold_effective_next_year = 97.6; -- $99.99
    -- SET @3_Year_effective_next_year = 174.42; -- $178.49
    -- SET @Lifetime_effective_next_year = 0; -- $0
    -- SET @Platinum_Foundation_effective_next_year = 429.33; -- $429.99
    -- SET @Platinum_USA_effective_next_year = 404.07; -- $429.99
    -- SET @Young_Adult_36_effective_next_year = 0; -- $40
    -- SET @Young_Adult_40_effective_next_year = 38.44; -- $40
    -- SET @Youth_Premier_25_effective_next_year = 0; -- $25
    -- SET @Youth_Premier_30_effective_next_year = 29.58; -- $30
    -- SET @Youth_Annual_effective_next_year = 9.38; -- $10
    -- SET @Elite_effective_next_year = 76.07; -- $79.99

    -- -- NEW IN 2027
    -- SET @bronze_bike_effective_next_year = 5.00;
    -- SET @bronze_run_effective_next_year = 5.00;
    -- SET @bronze_swim_effective_next_year = 5.00;
    -- SET @bronze_community_effective_next_year = 0.00;
    -- SET @Elite_2_Year_effective_next_year = 150.00;

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

                -- Post Race helper for business lever allocation
                COALESCE(pr.sales_units_next_year_goal_post_race, 0) AS sales_units_next_year_goal_post_race_base,

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
        -- BUSINESS GOAL LEVERS (MVP)
        -- allocate annual business goals to month/category using this year non-bulk seasonality / mix
        -- ======================
        business_lever_shares AS (
            SELECT
                b.*,

                -- use core non-bulk units for allocation; remove post-race units from the weighting base
                GREATEST(
                    COALESCE(b.sales_units_this_year_estimate_nonbulk, 0)
                    - COALESCE(b.sales_units_next_year_goal_post_race_base, 0)
                , 0) AS lever_unit_base,

                -- NEW MEMBERS: use adult_annual + one_day month/category mix
                CASE
                    WHEN b.type_goal IN ('adult_annual','one_day') THEN
                        GREATEST(
                            COALESCE(b.sales_units_this_year_estimate_nonbulk,0)
                            - COALESCE(b.sales_units_next_year_goal_post_race_base,0)
                        ,0)
                        / NULLIF(
                            SUM(
                                CASE
                                    WHEN b.type_goal IN ('adult_annual','one_day') THEN
                                        GREATEST(
                                            COALESCE(b.sales_units_this_year_estimate_nonbulk,0)
                                            - COALESCE(b.sales_units_next_year_goal_post_race_base,0)
                                        ,0)
                                    ELSE 0
                                END
                            ) OVER ()
                        ,0)
                    ELSE 0
                END AS lever_new_member_allocation_share,

                -- ADULT ANNUAL / ONE-DAY ALLOCATION SHARES
                CASE
                    WHEN b.type_goal = 'adult_annual' THEN
                        GREATEST(
                            COALESCE(b.sales_units_this_year_estimate_nonbulk, 0)
                            - COALESCE(b.sales_units_next_year_goal_post_race_base, 0)
                        , 0)
                        / NULLIF(
                            SUM(
                                CASE
                                    WHEN b.type_goal = 'adult_annual' THEN
                                        GREATEST(
                                            COALESCE(b.sales_units_this_year_estimate_nonbulk, 0)
                                            - COALESCE(b.sales_units_next_year_goal_post_race_base, 0)
                                        , 0)
                                    ELSE 0
                                END
                            ) OVER ()
                        , 0)
                    ELSE 0
                END AS lever_adult_annual_allocation_share,

                -- MIX OFFSET: use one_day month/category mix
                CASE
                    WHEN b.type_goal = 'one_day' THEN
                        GREATEST(
                            COALESCE(b.sales_units_this_year_estimate_nonbulk, 0)
                            - COALESCE(b.sales_units_next_year_goal_post_race_base, 0)
                        , 0)
                        / NULLIF(
                            SUM(
                                CASE
                                    WHEN b.type_goal = 'one_day' THEN
                                        GREATEST(
                                            COALESCE(b.sales_units_this_year_estimate_nonbulk, 0)
                                            - COALESCE(b.sales_units_next_year_goal_post_race_base, 0)
                                        , 0)
                                    ELSE 0
                                END
                            ) OVER ()
                        , 0)
                    ELSE 0
                END AS lever_one_day_allocation_share

            FROM sales_base b
        ),

        business_levers AS (
            SELECT
                bls.*,

                -- NEW MEMBERS
                @lever_new_member_units_incremental
                    * COALESCE(bls.lever_new_member_allocation_share,0) AS lever_new_member_units_incremental,

                -- REPEAT
                CASE
                    WHEN bls.type_goal = 'adult_annual' THEN
                        @lever_repeat_annual_units_incremental
                            * COALESCE(bls.lever_adult_annual_allocation_share,0)
                    WHEN bls.type_goal = 'one_day' THEN
                        @lever_repeat_one_day_units_incremental
                            * COALESCE(bls.lever_one_day_allocation_share,0)
                    ELSE 0
                END AS lever_repeat_units_incremental,

                -- WIN-BACK
                CASE
                    WHEN bls.type_goal = 'adult_annual' THEN
                        @lever_winback_annual_units_incremental
                            * COALESCE(bls.lever_adult_annual_allocation_share,0)
                    WHEN bls.type_goal = 'one_day' THEN
                        @lever_winback_one_day_units_incremental
                            * COALESCE(bls.lever_one_day_allocation_share,0)
                    ELSE 0
                END AS lever_winback_units_incremental,

                -- MIX — move units from one_day to adult_annual
                CASE
                    WHEN bls.type_goal = 'adult_annual' THEN
                        @lever_mix_units_incremental
                            * COALESCE(bls.lever_adult_annual_allocation_share,0)
                    WHEN bls.type_goal = 'one_day' THEN
                        -@lever_mix_units_incremental
                            * COALESCE(bls.lever_one_day_allocation_share,0)
                    ELSE 0
                END AS lever_mix_units_incremental,

                -- NET UNIT IMPACT AT THIS MONTH/CATEGORY ROW
                (
                    @lever_new_member_units_incremental
                        * COALESCE(bls.lever_new_member_allocation_share,0)

                    + CASE
                        WHEN bls.type_goal = 'adult_annual' THEN
                            @lever_repeat_annual_units_incremental
                                * COALESCE(bls.lever_adult_annual_allocation_share,0)
                        WHEN bls.type_goal = 'one_day' THEN
                            @lever_repeat_one_day_units_incremental
                                * COALESCE(bls.lever_one_day_allocation_share,0)
                        ELSE 0
                    END

                    + CASE
                        WHEN bls.type_goal = 'adult_annual' THEN
                            @lever_winback_annual_units_incremental
                                * COALESCE(bls.lever_adult_annual_allocation_share,0)
                        WHEN bls.type_goal = 'one_day' THEN
                            @lever_winback_one_day_units_incremental
                                * COALESCE(bls.lever_one_day_allocation_share,0)
                        ELSE 0
                    END

                    + CASE
                        WHEN bls.type_goal = 'adult_annual' THEN
                            @lever_mix_units_incremental
                                * COALESCE(bls.lever_adult_annual_allocation_share,0)
                        WHEN bls.type_goal = 'one_day' THEN
                            -@lever_mix_units_incremental
                                * COALESCE(bls.lever_one_day_allocation_share,0)
                        ELSE 0
                    END
                ) AS lever_units_incremental

            FROM business_lever_shares bls
        ),

        -- ======================
        -- NOTE [1] & [2]: compute price once; derive units once; bulk units = difference
        -- ======================
        priced_base AS (
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
                -- NEXT YEAR EFFECTIVE PRICE
                -- PRODUCT: next-year actual price × this-year realization rate
                -- TOP_LEVEL: this-year effective price × top-level % change
                CAST(
                    CASE b.category_goal

                        WHEN 'One Day - $15' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @One_Day_15_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @One_Day_15_actual_next_year
                                    * COALESCE(@One_Day_15_effective_this_year / NULLIF(@One_Day_15_actual_this_year, 0), 0)
                            END

                        WHEN 'Bronze Community Membership' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @bronze_community_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @bronze_community_actual_next_year
                                    * COALESCE(@bronze_community_effective_this_year / NULLIF(@bronze_community_actual_this_year, 0), 0)
                            END

                        WHEN 'Bronze - Bike' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @bronze_bike_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @bronze_bike_actual_next_year
                                    * COALESCE(@bronze_bike_effective_this_year / NULLIF(@bronze_bike_actual_this_year, 0), 0)
                            END

                        WHEN 'Bronze - Swim' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @bronze_swim_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @bronze_swim_actual_next_year
                                    * COALESCE(@bronze_swim_effective_this_year / NULLIF(@bronze_swim_actual_this_year, 0), 0)
                            END

                        WHEN 'Bronze - Run' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @bronze_run_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @bronze_run_actual_next_year
                                    * COALESCE(@bronze_run_effective_this_year / NULLIF(@bronze_run_actual_this_year, 0), 0)
                            END

                        WHEN 'Bronze - Relay' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Bronze_Relay_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Bronze_Relay_actual_next_year
                                    * COALESCE(@Bronze_Relay_effective_this_year / NULLIF(@Bronze_Relay_actual_this_year, 0), 0)
                            END

                        WHEN 'Bronze - Sprint' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Bronze_Sprint_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Bronze_Sprint_actual_next_year
                                    * COALESCE(@Bronze_Sprint_effective_this_year / NULLIF(@Bronze_Sprint_actual_this_year, 0), 0)
                            END

                        WHEN 'Bronze - Intermediate' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Bronze_Intermediate_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Bronze_Intermediate_actual_next_year
                                    * COALESCE(@Bronze_Intermediate_effective_this_year / NULLIF(@Bronze_Intermediate_actual_this_year, 0), 0)
                            END

                        WHEN 'Bronze - Ultra' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Bronze_Ultra_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Bronze_Ultra_actual_next_year
                                    * COALESCE(@Bronze_Ultra_effective_this_year / NULLIF(@Bronze_Ultra_actual_this_year, 0), 0)
                            END

                        WHEN 'Bronze - $0' THEN 0
                        WHEN 'Bronze - AO' THEN 0
                        WHEN 'Club' THEN 0

                        WHEN 'Bronze - Distance Upgrade' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Bronze_Upgrade_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Bronze_Upgrade_actual_next_year
                                    * COALESCE(@Bronze_Upgrade_effective_this_year / NULLIF(@Bronze_Upgrade_actual_this_year, 0), 0)
                            END

                        WHEN 'Unknown' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Unknown_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Unknown_actual_next_year
                                    * COALESCE(@Unknown_effective_this_year / NULLIF(@Unknown_actual_this_year, 0), 0)
                            END

                        WHEN '1-Year $50' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @1_Year_50_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @1_Year_50_actual_next_year
                                    * COALESCE(@1_Year_50_effective_this_year / NULLIF(@1_Year_50_actual_this_year, 0), 0)
                            END

                        WHEN 'Silver' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Silver_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Silver_actual_next_year
                                    * COALESCE(@Silver_effective_this_year / NULLIF(@Silver_actual_this_year, 0), 0)
                            END

                        WHEN 'Gold' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Gold_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Gold_actual_next_year
                                    * COALESCE(@Gold_effective_this_year / NULLIF(@Gold_actual_this_year, 0), 0)
                            END

                        WHEN '3-Year' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @3_Year_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @3_Year_actual_next_year
                                    * COALESCE(@3_Year_effective_this_year / NULLIF(@3_Year_actual_this_year, 0), 0)
                            END

                        WHEN 'Lifetime' THEN 0

                        WHEN 'Platinum - Foundation' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Platinum_Foundation_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Platinum_Foundation_actual_next_year
                                    * COALESCE(@Platinum_Foundation_effective_this_year / NULLIF(@Platinum_Foundation_actual_this_year, 0), 0)
                            END

                        WHEN 'Platinum - Team USA' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Platinum_USA_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Platinum_USA_actual_next_year
                                    * COALESCE(@Platinum_USA_effective_this_year / NULLIF(@Platinum_USA_actual_this_year, 0), 0)
                            END

                        WHEN 'Young Adult - $36' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Young_Adult_36_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Young_Adult_36_actual_next_year
                                    * COALESCE(@Young_Adult_36_effective_this_year / NULLIF(@Young_Adult_36_actual_this_year, 0), 0)
                            END

                        WHEN 'Young Adult - $40' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Young_Adult_40_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Young_Adult_40_actual_next_year
                                    * COALESCE(@Young_Adult_40_effective_this_year / NULLIF(@Young_Adult_40_actual_this_year, 0), 0)
                            END

                        WHEN 'Youth Annual' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Youth_Annual_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Youth_Annual_actual_next_year
                                    * COALESCE(@Youth_Annual_effective_this_year / NULLIF(@Youth_Annual_actual_this_year, 0), 0)
                            END

                        WHEN 'Youth Premier - $25' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Youth_Premier_25_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Youth_Premier_25_actual_next_year
                                    * COALESCE(@Youth_Premier_25_effective_this_year / NULLIF(@Youth_Premier_25_actual_this_year, 0), 0)
                            END

                        WHEN 'Youth Premier - $30' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Youth_Premier_30_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Youth_Premier_30_actual_next_year
                                    * COALESCE(@Youth_Premier_30_effective_this_year / NULLIF(@Youth_Premier_30_actual_this_year, 0), 0)
                            END

                        WHEN 'Elite' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Elite_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Elite_actual_next_year
                                    * COALESCE(@Elite_effective_this_year / NULLIF(@Elite_actual_this_year, 0), 0)
                            END

                        WHEN 'Elite 2-Year membership' THEN
                            CASE
                                WHEN @price_method = 'TOP_LEVEL'
                                    THEN @Elite_2_Year_effective_this_year * (1 + @lever_price_pct_change)
                                ELSE @Elite_2_Year_actual_next_year
                                    * COALESCE(@Elite_2_Year_effective_this_year / NULLIF(@Elite_2_Year_actual_this_year, 0), 0)
                            END

                        ELSE NULL

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
                        WHEN @volume_method = 'PRODUCT' THEN
                            CASE b.category_goal
                                WHEN 'One Day - $15'               THEN @UG_One_Day_15
                                WHEN 'Bronze Community Membership' THEN @UG_bronze_community
                                WHEN 'Bronze - Bike'               THEN @UG_Bronze_Bike
                                WHEN 'Bronze - Swim'               THEN @UG_Bronze_Swim
                                WHEN 'Bronze - Run'                THEN @UG_Bronze_Run
                                WHEN 'Bronze - Relay'              THEN @UG_Bronze_Relay
                                WHEN 'Bronze - Sprint'             THEN @UG_Bronze_Sprint
                                WHEN 'Bronze - Intermediate'       THEN @UG_Bronze_Intermediate
                                WHEN 'Bronze - Ultra'              THEN @UG_Bronze_Ultra
                                WHEN 'Bronze - $0'                 THEN @UG_Bronze_$0
                                WHEN 'Bronze - AO'                 THEN @UG_Bronze_AO
                                WHEN 'Bronze - Distance Upgrade'   THEN @UG_Bronze_Upgrade
                                WHEN 'Club'                        THEN @UG_Club
                                WHEN 'Unknown'                     THEN @UG_Unknown
                                WHEN '1-Year $50'                  THEN @UG_1_Year_50
                                WHEN 'Silver'                      THEN @UG_Silver
                                WHEN 'Gold'                        THEN @UG_Gold
                                WHEN '3-Year'                      THEN @UG_3_Year
                                WHEN 'Lifetime'                    THEN @UG_Lifetime
                                WHEN 'Platinum - Foundation'       THEN @UG_Platinum_Foundation
                                WHEN 'Platinum - Team USA'         THEN @UG_Platinum_USA
                                WHEN 'Young Adult - $36'           THEN @UG_Young_Adult_36
                                WHEN 'Young Adult - $40'           THEN @UG_Young_Adult_40
                                WHEN 'Youth Annual'                THEN @UG_Youth_Annual
                                WHEN 'Youth Premier - $25'         THEN @UG_Youth_Premier_25
                                WHEN 'Youth Premier - $30'         THEN @UG_Youth_Premier_30
                                WHEN 'Elite'                       THEN @UG_Elite
                                WHEN 'Elite 2-Year membership'     THEN @UG_Elite_2_Year
                                ELSE NULL
                            END
                        ELSE 0
                    END
                AS DECIMAL(10,2)) AS unit_next_year_pct_change,

                -- >>> UNIT GROWTH (ADDED): apply category growth pct to derived units >>>
                -- Derived next year units for total/nonbulk; bulk = total - nonbulk
                CAST(
                    b.sales_units_this_year_estimate
                    *
                    (
                        1 +
                        CASE
                            WHEN @volume_method = 'PRODUCT' THEN
                                CASE b.category_goal
                                    WHEN 'One Day - $15'                THEN @UG_One_Day_15
                                    WHEN 'Bronze Community Membership' THEN @UG_bronze_community
                                    WHEN 'Bronze - Bike'                THEN @UG_Bronze_Bike
                                    WHEN 'Bronze - Swim'                THEN @UG_Bronze_Swim
                                    WHEN 'Bronze - Run'                 THEN @UG_Bronze_Run
                                    WHEN 'Bronze - Relay'               THEN @UG_Bronze_Relay
                                    WHEN 'Bronze - Sprint'              THEN @UG_Bronze_Sprint
                                    WHEN 'Bronze - Intermediate'        THEN @UG_Bronze_Intermediate
                                    WHEN 'Bronze - Ultra'               THEN @UG_Bronze_Ultra
                                    WHEN 'Bronze - $0'                  THEN @UG_Bronze_$0
                                    WHEN 'Bronze - AO'                  THEN @UG_Bronze_AO
                                    WHEN 'Bronze - Distance Upgrade'    THEN @UG_Bronze_Upgrade
                                    WHEN 'Club'                         THEN @UG_Club
                                    WHEN 'Unknown'                      THEN @UG_Unknown
                                    WHEN '1-Year $50'                   THEN @UG_1_Year_50
                                    WHEN 'Silver'                       THEN @UG_Silver
                                    WHEN 'Gold'                         THEN @UG_Gold
                                    WHEN '3-Year'                       THEN @UG_3_Year
                                    WHEN 'Lifetime'                     THEN @UG_Lifetime
                                    WHEN 'Platinum - Foundation'        THEN @UG_Platinum_Foundation
                                    WHEN 'Platinum - Team USA'          THEN @UG_Platinum_USA
                                    WHEN 'Young Adult - $36'            THEN @UG_Young_Adult_36
                                    WHEN 'Young Adult - $40'            THEN @UG_Young_Adult_40
                                    WHEN 'Youth Annual'                 THEN @UG_Youth_Annual
                                    WHEN 'Youth Premier - $25'          THEN @UG_Youth_Premier_25
                                    WHEN 'Youth Premier - $30'          THEN @UG_Youth_Premier_30
                                    WHEN 'Elite'                        THEN @UG_Elite
                                    WHEN 'Elite 2-Year membership'      THEN @UG_Elite_2_Year
                                    ELSE 0
                                END
                            ELSE 0
                        END
                    )
                    +
                    CASE
                        WHEN @volume_method = 'TOP_LEVEL'
                            THEN COALESCE(b.lever_units_incremental, 0)
                        ELSE 0
                    END
                AS DECIMAL(10,2)) AS units_total_next_year_base,

                CAST(
                    b.sales_units_this_year_estimate_nonbulk
                    *
                    (
                        1 +
                        CASE
                            WHEN @volume_method = 'PRODUCT' THEN
                                CASE b.category_goal
                                    WHEN 'One Day - $15'               THEN @UG_One_Day_15
                                    WHEN 'Bronze Community Membership' THEN @UG_bronze_community
                                    WHEN 'Bronze - Bike'               THEN @UG_bronze_bike
                                    WHEN 'Bronze - Swim'               THEN @UG_bronze_swim
                                    WHEN 'Bronze - Run'                THEN @UG_bronze_run
                                    WHEN 'Bronze - Relay'              THEN @UG_Bronze_Relay
                                    WHEN 'Bronze - Sprint'             THEN @UG_Bronze_Sprint
                                    WHEN 'Bronze - Intermediate'       THEN @UG_Bronze_Intermediate
                                    WHEN 'Bronze - Ultra'              THEN @UG_Bronze_Ultra
                                    WHEN 'Bronze - $0'                 THEN @UG_Bronze_$0
                                    WHEN 'Bronze - AO'                 THEN @UG_Bronze_AO
                                    WHEN 'Bronze - Distance Upgrade'   THEN @UG_Bronze_Upgrade
                                    WHEN 'Club'                        THEN @UG_Club
                                    WHEN 'Unknown'                     THEN @UG_Unknown
                                    WHEN '1-Year $50'                  THEN @UG_1_Year_50
                                    WHEN 'Silver'                      THEN @UG_Silver
                                    WHEN 'Gold'                        THEN @UG_Gold
                                    WHEN '3-Year'                      THEN @UG_3_Year
                                    WHEN 'Lifetime'                    THEN @UG_Lifetime
                                    WHEN 'Platinum - Foundation'       THEN @UG_Platinum_Foundation
                                    WHEN 'Platinum - Team USA'         THEN @UG_Platinum_USA
                                    WHEN 'Young Adult - $36'           THEN @UG_Young_Adult_36
                                    WHEN 'Young Adult - $40'           THEN @UG_Young_Adult_40
                                    WHEN 'Youth Annual'                THEN @UG_Youth_Annual
                                    WHEN 'Youth Premier - $25'         THEN @UG_Youth_Premier_25
                                    WHEN 'Youth Premier - $30'         THEN @UG_Youth_Premier_30
                                    WHEN 'Elite'                       THEN @UG_Elite
                                    WHEN 'Elite 2-Year membership'     THEN @UG_Elite_2_Year
                                    ELSE 0
                                END
                            ELSE 0
                        END
                    )
                    +
                    CASE
                        WHEN @volume_method = 'TOP_LEVEL'
                            THEN COALESCE(b.lever_units_incremental, 0)
                        ELSE 0
                    END
                AS DECIMAL(10,2)) AS units_nonbulk_next_year_base
                -- <<< UNIT GROWTH (ADDED) <<<

            FROM business_levers b
        ),

        -- ======================
        -- DISCONTINUED PRODUCT REDISTRIBUTION
        -- redistribute discontinued Platinum units within the same month
        -- ======================
        platinum_redistribution_pool AS (
            SELECT
                month_goal,

                SUM(
                    CASE
                        WHEN category_goal = 'Platinum - Foundation'
                            AND @discontinue_Platinum_Foundation = 1
                            THEN COALESCE(units_nonbulk_next_year_base,0)

                        WHEN category_goal = 'Platinum - Team USA'
                            AND @discontinue_Platinum_USA = 1
                            THEN COALESCE(units_nonbulk_next_year_base,0)

                        ELSE 0
                    END
                ) AS platinum_units_nonbulk_to_redistribute,

                SUM(
                    CASE
                        WHEN category_goal = 'Platinum - Foundation'
                            AND @discontinue_Platinum_Foundation = 1
                            THEN COALESCE(units_total_next_year_base,0)

                        WHEN category_goal = 'Platinum - Team USA'
                            AND @discontinue_Platinum_USA = 1
                            THEN COALESCE(units_total_next_year_base,0)

                        ELSE 0
                    END
                ) AS platinum_units_total_to_redistribute

            FROM priced_base
            GROUP BY month_goal
        ),

        priced AS (
            SELECT
                pb.*,

                CASE
                    WHEN pb.category_goal = 'Platinum - Foundation'
                        AND @discontinue_Platinum_Foundation = 1 THEN 0

                    WHEN pb.category_goal = 'Platinum - Team USA'
                        AND @discontinue_Platinum_USA = 1 THEN 0

                    WHEN pb.category_goal = 'Silver' THEN
                        COALESCE(pb.units_nonbulk_next_year_base,0)
                        + COALESCE(rp.platinum_units_nonbulk_to_redistribute,0)
                            * @redistribute_Platinum_to_Silver_pct

                    WHEN pb.category_goal = 'Gold' THEN
                        COALESCE(pb.units_nonbulk_next_year_base,0)
                        + COALESCE(rp.platinum_units_nonbulk_to_redistribute,0)
                            * @redistribute_Platinum_to_Gold_pct

                    WHEN pb.category_goal = '3-Year' THEN
                        COALESCE(pb.units_nonbulk_next_year_base,0)
                        + COALESCE(rp.platinum_units_nonbulk_to_redistribute,0)
                            * @redistribute_Platinum_to_3_Year_pct

                    ELSE pb.units_nonbulk_next_year_base
                END AS units_nonbulk_next_year,

                CASE
                    WHEN pb.category_goal = 'Platinum - Foundation'
                        AND @discontinue_Platinum_Foundation = 1 THEN 0

                    WHEN pb.category_goal = 'Platinum - Team USA'
                        AND @discontinue_Platinum_USA = 1 THEN 0

                    WHEN pb.category_goal = 'Silver' THEN
                        COALESCE(pb.units_total_next_year_base,0)
                        + COALESCE(rp.platinum_units_total_to_redistribute,0)
                            * @redistribute_Platinum_to_Silver_pct

                    WHEN pb.category_goal = 'Gold' THEN
                        COALESCE(pb.units_total_next_year_base,0)
                        + COALESCE(rp.platinum_units_total_to_redistribute,0)
                            * @redistribute_Platinum_to_Gold_pct

                    WHEN pb.category_goal = '3-Year' THEN
                        COALESCE(pb.units_total_next_year_base,0)
                        + COALESCE(rp.platinum_units_total_to_redistribute,0)
                            * @redistribute_Platinum_to_3_Year_pct

                    ELSE pb.units_total_next_year_base
                END AS units_total_next_year

            FROM priced_base pb
                LEFT JOIN platinum_redistribution_pool rp
                    ON pb.month_goal = rp.month_goal
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
            @price_method AS price_method,
            @lever_price_pct_change AS lever_price_pct_change,

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
            ROUND(ABS(
                (e.sales_rev_next_year_goal_nonbulk
                 + e.sales_rev_next_year_goal_bulk
                 + e.sales_rev_next_year_goal_post_race)   -- post-race carved out of non-bulk; add it back for the tie-out
                - e.sales_rev_next_year_goal
            ), 6) AS recon_delta,

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

-- 1) BY MONTH
SELECT
    "1_by_month_sales_model_2027" AS query_label,
    month_goal,
    COUNT(*) AS row_count,
    FORMAT(SUM(sales_units_this_year_estimate),0) AS sales_units_this_year_estimate,
    FORMAT(SUM(sales_rev_this_year_estimate),0) AS sales_rev_this_year_estimate,
    FORMAT(SUM(sales_units_this_year_estimate_nonbulk),0) AS sales_units_this_year_estimate_nonbulk,
    FORMAT(SUM(sales_rev_this_year_estimate_nonbulk),0) AS sales_rev_this_year_estimate_nonbulk,
    FORMAT(SUM(sales_rev_this_year_estimate_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0),2) AS non_bulk_price_this_year_effective,
    FORMAT(SUM(sales_units_next_year_goal_nonbulk),0) AS sales_units_next_year_goal_nonbulk,
    FORMAT(SUM(sales_rev_next_year_goal_nonbulk),0) AS sales_rev_next_year_goal_nonbulk,
    FORMAT(SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_next_year_goal_nonbulk),0),2) AS non_bulk_price_next_year_effective,
    FORMAT(SUM(sales_units_next_year_goal_post_race),0) AS sales_units_next_year_goal_post_race,
    FORMAT(SUM(sales_rev_next_year_goal_post_race),0) AS sales_rev_next_year_goal_post_race,
    MIN(month_goal) AS min_month,
    MAX(month_goal) AS max_month
FROM sales_model_2027
GROUP BY month_goal WITH ROLLUP
ORDER BY month_goal;

-- 2) BY CATEGORY
SELECT
    "2_by_catogory_sales_model_2027" AS query_label,
    type_goal,
    category_goal,
    MIN(category_sort_order_goal) AS category_sort_order_goal,
    COUNT(*) AS row_count,
    FORMAT(SUM(sales_units_this_year_estimate),0) AS sales_units_this_year_estimate,
    FORMAT(SUM(sales_rev_this_year_estimate),0) AS sales_rev_this_year_estimate,
    FORMAT(SUM(sales_units_this_year_estimate_nonbulk),0) AS sales_units_this_year_estimate_nonbulk,
    FORMAT(SUM(sales_rev_this_year_estimate_nonbulk),0) AS sales_rev_this_year_estimate_nonbulk,
    MAX(price_this_year_actual) AS price_this_year_actual,
    FORMAT(SUM(sales_rev_this_year_estimate_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0),2) AS non_bulk_price_this_year_effective,
    FORMAT(SUM(sales_units_next_year_goal_nonbulk),0) AS sales_units_next_year_goal_nonbulk,
    FORMAT(SUM(sales_rev_next_year_goal_nonbulk),0) AS sales_rev_next_year_goal_nonbulk,
    MAX(price_next_year_actual) AS price_next_year_actual,
    FORMAT(SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_next_year_goal_nonbulk),0),2) AS non_bulk_price_next_year_effective,
    FORMAT(SUM(sales_units_next_year_goal_post_race),0) AS sales_units_next_year_goal_post_race,
    FORMAT(SUM(sales_rev_next_year_goal_post_race),0) AS sales_rev_next_year_goal_post_race,
    MIN(month_goal) AS min_month,
    MAX(month_goal) AS max_month
FROM sales_model_2027
GROUP BY type_goal,category_goal WITH ROLLUP
ORDER BY type_goal,MIN(category_sort_order_goal),category_goal;

-- 3) THIS YEAR SALES ESTIMATE (NON-BULK)
SELECT
    "3_this_year_sales_estimate_nonbulk" AS query_label,
    COALESCE(type_goal,'Grand Total') AS type_goal,
    "Revenue" AS metric,
    ROUND(SUM(CASE WHEN month_goal=1 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `1`,
    ROUND(SUM(CASE WHEN month_goal=2 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `2`,
    ROUND(SUM(CASE WHEN month_goal=3 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `3`,
    ROUND(SUM(CASE WHEN month_goal=4 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `4`,
    ROUND(SUM(CASE WHEN month_goal=5 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `5`,
    ROUND(SUM(CASE WHEN month_goal=6 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `6`,
    ROUND(SUM(CASE WHEN month_goal=7 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `7`,
    ROUND(SUM(CASE WHEN month_goal=8 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `8`,
    ROUND(SUM(CASE WHEN month_goal=9 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `9`,
    ROUND(SUM(CASE WHEN month_goal=10 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `10`,
    ROUND(SUM(CASE WHEN month_goal=11 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `11`,
    ROUND(SUM(CASE WHEN month_goal=12 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `12`,
    ROUND(SUM(sales_rev_this_year_estimate_nonbulk),2) AS Grand_Total
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP

UNION ALL

SELECT
    "3_this_year_sales_estimate_nonbulk",
    COALESCE(type_goal,'Grand Total'),
    "Units",
    ROUND(SUM(CASE WHEN month_goal=1 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=2 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=3 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=4 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=5 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=6 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=7 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=8 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=9 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=10 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=11 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=12 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(sales_units_this_year_estimate_nonbulk),0)
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP

UNION ALL

SELECT
    "3_this_year_sales_estimate_nonbulk",
    COALESCE(type_goal,'Grand Total'),
    "Effective Price",
    ROUND(SUM(CASE WHEN month_goal=1 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=1 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=2 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=2 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=3 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=3 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=4 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=4 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=5 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=5 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=6 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=6 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=7 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=7 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=8 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=8 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=9 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=9 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=10 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=10 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=11 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=11 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=12 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=12 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(sales_rev_this_year_estimate_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0),2)
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP;

-- 4) NEXT YEAR SALES GOAL (NON-BULK)
SELECT
    "4_next_year_sales_goal_nonbulk" AS query_label,
    COALESCE(type_goal,'Grand Total') AS type_goal,
    "Revenue" AS metric,
    ROUND(SUM(CASE WHEN month_goal=1 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `1`,
    ROUND(SUM(CASE WHEN month_goal=2 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `2`,
    ROUND(SUM(CASE WHEN month_goal=3 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `3`,
    ROUND(SUM(CASE WHEN month_goal=4 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `4`,
    ROUND(SUM(CASE WHEN month_goal=5 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `5`,
    ROUND(SUM(CASE WHEN month_goal=6 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `6`,
    ROUND(SUM(CASE WHEN month_goal=7 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `7`,
    ROUND(SUM(CASE WHEN month_goal=8 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `8`,
    ROUND(SUM(CASE WHEN month_goal=9 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `9`,
    ROUND(SUM(CASE WHEN month_goal=10 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `10`,
    ROUND(SUM(CASE WHEN month_goal=11 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `11`,
    ROUND(SUM(CASE WHEN month_goal=12 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END),2) AS `12`,
    ROUND(SUM(sales_rev_next_year_goal_nonbulk),2) AS Grand_Total
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP

UNION ALL

SELECT
    "4_next_year_sales_goal_nonbulk",
    COALESCE(type_goal,'Grand Total'),
    "Units",
    ROUND(SUM(CASE WHEN month_goal=1 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=2 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=3 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=4 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=5 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=6 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=7 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=8 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=9 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=10 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=11 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=12 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),
    ROUND(SUM(sales_units_next_year_goal_nonbulk),0)
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP

UNION ALL

SELECT
    "4_next_year_sales_goal_nonbulk",
    COALESCE(type_goal,'Grand Total'),
    "Effective Price",
    ROUND(SUM(CASE WHEN month_goal=1 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=1 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=2 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=2 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=3 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=3 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=4 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=4 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=5 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=5 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=6 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=6 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=7 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=7 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=8 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=8 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=9 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=9 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=10 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=10 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=11 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=11 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(CASE WHEN month_goal=12 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=12 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0),2),
    ROUND(SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_next_year_goal_nonbulk),0),2)
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP;

-- 5) VARIANCE: NEXT YEAR - THIS YEAR
SELECT
    "5_variance_next_year_vs_this_year_nonbulk" AS query_label,
    COALESCE(type_goal,'Grand Total') AS type_goal,
    "Revenue" AS metric,
    ROUND(SUM(CASE WHEN month_goal=1 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `1`,
    ROUND(SUM(CASE WHEN month_goal=2 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `2`,
    ROUND(SUM(CASE WHEN month_goal=3 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `3`,
    ROUND(SUM(CASE WHEN month_goal=4 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `4`,
    ROUND(SUM(CASE WHEN month_goal=5 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `5`,
    ROUND(SUM(CASE WHEN month_goal=6 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `6`,
    ROUND(SUM(CASE WHEN month_goal=7 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `7`,
    ROUND(SUM(CASE WHEN month_goal=8 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `8`,
    ROUND(SUM(CASE WHEN month_goal=9 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `9`,
    ROUND(SUM(CASE WHEN month_goal=10 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `10`,
    ROUND(SUM(CASE WHEN month_goal=11 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `11`,
    ROUND(SUM(CASE WHEN month_goal=12 THEN sales_rev_next_year_goal_nonbulk-sales_rev_this_year_estimate_nonbulk ELSE 0 END),2) AS `12`,
    ROUND(SUM(sales_rev_next_year_goal_nonbulk)-SUM(sales_rev_this_year_estimate_nonbulk),2) AS Grand_Total
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP

UNION ALL

SELECT
    "5_variance_next_year_vs_this_year_nonbulk",
    COALESCE(type_goal,'Grand Total'),
    "Units",
    ROUND(SUM(CASE WHEN month_goal=1 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=2 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=3 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=4 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=5 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=6 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=7 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=8 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=9 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=10 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=11 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(CASE WHEN month_goal=12 THEN sales_units_next_year_goal_nonbulk-sales_units_this_year_estimate_nonbulk ELSE 0 END),0),
    ROUND(SUM(sales_units_next_year_goal_nonbulk)-SUM(sales_units_this_year_estimate_nonbulk),0)
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP

UNION ALL

SELECT
    "5_variance_next_year_vs_this_year_nonbulk",
    COALESCE(type_goal,'Grand Total'),
    "Effective Price",
    ROUND(
        SUM(CASE WHEN month_goal=1 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=1 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=1 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=1 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=2 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=2 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=2 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=2 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=3 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=3 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=3 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=3 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=4 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=4 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=4 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=4 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=5 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=5 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=5 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=5 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=6 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=6 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=6 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=6 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=7 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=7 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=7 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=7 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=8 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=8 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=8 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=8 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=9 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=9 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=9 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=9 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=10 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=10 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=10 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=10 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=11 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=11 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=11 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=11 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(CASE WHEN month_goal=12 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=12 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0)
        - SUM(CASE WHEN month_goal=12 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=12 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0),2
    ),
    ROUND(
        SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_next_year_goal_nonbulk),0)
        - SUM(sales_rev_this_year_estimate_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0),2
    )
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP;

-- 6) % VARIANCE
SELECT
    "6_pct_variance_next_year_vs_this_year_nonbulk" AS query_label,
    COALESCE(type_goal,'Grand Total') AS type_goal,
    "Revenue" AS metric,
    ROUND((SUM(CASE WHEN month_goal=1 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=1 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `1`,
    ROUND((SUM(CASE WHEN month_goal=2 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=2 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `2`,
    ROUND((SUM(CASE WHEN month_goal=3 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=3 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `3`,
    ROUND((SUM(CASE WHEN month_goal=4 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=4 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `4`,
    ROUND((SUM(CASE WHEN month_goal=5 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=5 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `5`,
    ROUND((SUM(CASE WHEN month_goal=6 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=6 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `6`,
    ROUND((SUM(CASE WHEN month_goal=7 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=7 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `7`,
    ROUND((SUM(CASE WHEN month_goal=8 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=8 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `8`,
    ROUND((SUM(CASE WHEN month_goal=9 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=9 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `9`,
    ROUND((SUM(CASE WHEN month_goal=10 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=10 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `10`,
    ROUND((SUM(CASE WHEN month_goal=11 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=11 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `11`,
    ROUND((SUM(CASE WHEN month_goal=12 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=12 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1) AS `12`,
    ROUND((SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_rev_this_year_estimate_nonbulk),0)-1)*100,1) AS Grand_Total
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP

UNION ALL

SELECT
    "6_pct_variance_next_year_vs_this_year_nonbulk",
    COALESCE(type_goal,'Grand Total'),
    "Units",
    ROUND((SUM(CASE WHEN month_goal=1 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=1 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=2 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=2 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=3 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=3 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=4 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=4 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=5 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=5 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=6 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=6 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=7 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=7 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=8 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=8 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=9 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=9 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=10 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=10 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=11 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=11 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(CASE WHEN month_goal=12 THEN sales_units_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=12 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)-1)*100,1),
    ROUND((SUM(sales_units_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0)-1)*100,1)
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP

UNION ALL

SELECT
    "6_pct_variance_next_year_vs_this_year_nonbulk",
    COALESCE(type_goal,'Grand Total'),
    "Effective Price",
    ROUND(((SUM(CASE WHEN month_goal=1 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=1 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=1 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=1 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=2 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=2 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=2 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=2 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=3 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=3 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=3 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=3 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=4 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=4 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=4 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=4 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=5 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=5 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=5 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=5 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=6 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=6 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=6 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=6 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=7 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=7 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=7 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=7 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=8 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=8 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=8 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=8 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=9 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=9 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=9 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=9 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=10 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=10 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=10 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=10 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=11 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=11 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=11 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=11 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(CASE WHEN month_goal=12 THEN sales_rev_next_year_goal_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=12 THEN sales_units_next_year_goal_nonbulk ELSE 0 END),0))/NULLIF((SUM(CASE WHEN month_goal=12 THEN sales_rev_this_year_estimate_nonbulk ELSE 0 END)/NULLIF(SUM(CASE WHEN month_goal=12 THEN sales_units_this_year_estimate_nonbulk ELSE 0 END),0)),0)-1)*100,1),
    ROUND(((SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_next_year_goal_nonbulk),0))/NULLIF((SUM(sales_rev_this_year_estimate_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0)),0)-1)*100,1)
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP;

-- 7A) EFFECTIVE PRICE
SELECT
    "7a_effective_price_table" AS query_label,
    type_goal,category_goal,category_sort_order_goal,
    MAX(price_this_year_actual) AS this_year_actual,
    MAX(price_this_year_effective_nonbulk) AS this_year_effective,
    MAX(price_next_year_actual) AS next_year_actual,
    MAX(price_next_year_effective_nonbulk) AS next_year_effective,
    MAX(price_method) AS price_method,
    FORMAT(MAX(lever_price_pct_change),3) AS lever_price_pct_change
FROM sales_model_2027
GROUP BY type_goal,category_goal,category_sort_order_goal
ORDER BY type_goal,MIN(category_sort_order_goal),category_goal;

-- 7B) UNITS
SELECT
    "7b_units_table" AS query_label,
    type_goal,category_goal,category_sort_order_goal,
    ROUND(SUM(sales_units_this_year_estimate_nonbulk),0) AS this_year_units,
    ROUND(SUM(sales_units_next_year_goal_nonbulk),0) AS next_year_units,
    ROUND(SUM(sales_units_next_year_goal_nonbulk)-SUM(sales_units_this_year_estimate_nonbulk),0) AS unit_change,
    ROUND((SUM(sales_units_next_year_goal_nonbulk)/NULLIF(SUM(sales_units_this_year_estimate_nonbulk),0)-1)*100,1) AS unit_pct_change,
    @volume_method AS volume_method,
    MAX(unit_next_year_pct_change) AS product_unit_pct_change
FROM sales_model_2027
GROUP BY type_goal,category_goal,category_sort_order_goal
ORDER BY type_goal,MIN(category_sort_order_goal),category_goal;

-- 7C) REVENUE
SELECT
    "7c_revenue_table" AS query_label,
    type_goal,category_goal,category_sort_order_goal,
    ROUND(SUM(sales_rev_this_year_estimate_nonbulk),2) AS this_year_revenue,
    ROUND(SUM(sales_rev_next_year_goal_nonbulk),2) AS next_year_revenue,
    ROUND(SUM(sales_rev_next_year_goal_nonbulk)-SUM(sales_rev_this_year_estimate_nonbulk),2) AS revenue_change,
    ROUND((SUM(sales_rev_next_year_goal_nonbulk)/NULLIF(SUM(sales_rev_this_year_estimate_nonbulk),0)-1)*100,1) AS revenue_pct_change,
    @volume_method AS volume_method,
    MAX(price_method) AS price_method,
    FORMAT(MAX(lever_price_pct_change),3) AS lever_price_pct_change
FROM sales_model_2027
GROUP BY type_goal,category_goal,category_sort_order_goal
ORDER BY type_goal,MIN(category_sort_order_goal),category_goal;

-- 8) BUSINESS GOAL LEVERS BY MONTH
SELECT
    "8_business_goal_levers_by_month" AS query_label,
    month_goal,
    FORMAT(SUM(lever_new_member_units_incremental),0) AS lever_new_member_units_incremental,
    FORMAT(SUM(lever_repeat_units_incremental),0) AS lever_repeat_units_incremental,
    FORMAT(SUM(lever_winback_units_incremental),0) AS lever_winback_units_incremental,
    FORMAT(SUM(lever_mix_units_incremental),0) AS lever_mix_units_incremental,
    FORMAT(SUM(lever_units_incremental),0) AS lever_units_incremental
FROM sales_model_2027
GROUP BY month_goal WITH ROLLUP
ORDER BY month_goal;

-- 9) BUSINESS GOAL LEVERS BY TYPE
SELECT
    "9_business_goal_levers_by_type" AS query_label,
    type_goal,
    FORMAT(SUM(lever_new_member_units_incremental),0) AS lever_new_member_units_incremental,
    FORMAT(SUM(lever_repeat_units_incremental),0) AS lever_repeat_units_incremental,
    FORMAT(SUM(lever_winback_units_incremental),0) AS lever_winback_units_incremental,
    FORMAT(SUM(lever_mix_units_incremental),0) AS lever_mix_units_incremental,
    FORMAT(SUM(lever_units_incremental),0) AS lever_units_incremental
FROM sales_model_2027
GROUP BY type_goal WITH ROLLUP
ORDER BY type_goal;

-- 10) PRODUCT REDISTRIBUTION
SELECT
        "10_product_redistribution" AS query_label,
        category_goal,

        ROUND(SUM(units_nonbulk_next_year_base),0) AS units_before_redistribution,
        ROUND(SUM(units_nonbulk_next_year),0) AS units_after_redistribution,

        ROUND(
            SUM(units_nonbulk_next_year)
            - SUM(units_nonbulk_next_year_base)
        ,0) AS redistribution_unit_change,

        @discontinue_Platinum_Foundation AS discontinue_platinum_foundation,
        @discontinue_Platinum_USA AS discontinue_platinum_usa,

        @redistribute_Platinum_to_Silver_pct AS platinum_to_silver_pct,
        @redistribute_Platinum_to_Gold_pct AS platinum_to_gold_pct,
        @redistribute_Platinum_to_3_Year_pct AS platinum_to_3_year_pct

    FROM sales_model_2027
    WHERE category_goal IN (
        'Platinum - Foundation',
        'Platinum - Team USA',
        'Silver',
        'Gold',
        '3-Year'
    )
    GROUP BY category_goal

    UNION ALL

    SELECT
        "10_product_redistribution",
        'Grand Total',

        ROUND(SUM(units_nonbulk_next_year_base),0),
        ROUND(SUM(units_nonbulk_next_year),0),

        ROUND(
            SUM(units_nonbulk_next_year)
            - SUM(units_nonbulk_next_year_base)
        ,0),

        @discontinue_Platinum_Foundation,
        @discontinue_Platinum_USA,

        ROUND(@redistribute_Platinum_to_Silver_pct, 2),
        ROUND(@redistribute_Platinum_to_Gold_pct, 2),
        ROUND(@redistribute_Platinum_to_3_Year_pct, 2)

    FROM sales_model_2027
    WHERE category_goal IN (
        'Platinum - Foundation',
        'Platinum - Team USA',
        'Silver',
        'Gold',
        '3-Year'
);

-- ======================
-- SAVE MODEL VERSION
-- ======================
SET @version_user = 'steve';

SET @next_version = (
    SELECT COALESCE(MAX(id),0) + 1
    FROM sales_model_2027_versions
);

SET @version_name = CONCAT(
    'v',
    @next_version,
    '_',
    DATE_FORMAT(CURRENT_DATE(), '%m%d%y'),
    '_',
    @version_user
);

INSERT INTO sales_model_2027_versions (
    version_name,
    user_name,
    assumptions_json,
    card_order_json
)
VALUES (
    @version_name,
    @version_user,
    JSON_OBJECT(
        'volume_method', @volume_method,
        'price_method', @price_method,

        'lever_new_members_pct_change', @lever_new_members_pct_change,
        'lever_repeat_members_pct_change', @lever_repeat_members_pct_change,
        'lever_winback_units_incremental', @lever_winback_units_incremental,
        'lever_upgrades_pct_change', @lever_upgrades_pct_change,
        'lever_downgrades_pct_change', @lever_downgrades_pct_change,

        'lever_price_pct_change', @lever_price_pct_change,

        'discontinue_Platinum_Foundation', @discontinue_Platinum_Foundation,
        'discontinue_Platinum_USA', @discontinue_Platinum_USA,
        'redistribute_Platinum_to_Silver_pct', @redistribute_Platinum_to_Silver_pct,
        'redistribute_Platinum_to_Gold_pct', @redistribute_Platinum_to_Gold_pct,
        'redistribute_Platinum_to_3_Year_pct', @redistribute_Platinum_to_3_Year_pct
    ),
    JSON_ARRAY(
        'period',
        'volume',
        'price',
        'redistribution',
        'run',
        'summary',
        'reports'
    )
);

SELECT
    id,
    version_name,
    user_name,
    created_at
FROM sales_model_2027_versions
ORDER BY id DESC
LIMIT 1;