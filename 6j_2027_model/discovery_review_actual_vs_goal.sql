-- #1 SALES & REC REVENUE DATA
    USE usat_sales_db;

    SELECT "" AS query_label, s.* FROM all_membership_sales_data_2015_left AS s LIMIT 10;
    SELECT FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left;
    SELECT purchased_on_year_adjusted_mp, FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left GROUP BY 1 ORDER BY 1;

    SELECT "" AS query_label, s.* FROM sales_key_stats_2015 AS s LIMIT 10;
    SELECT FORMAT(COUNT(*), 0) FROM sales_key_stats_2015;

    SELECT "" AS query_label, s.* FROM sales_data_year_over_year_2026 AS s;
    SELECT "" AS query_label, s.* FROM usat_sales_db.sales_data_actual_v_goal AS s;

    SELECT * FROM rev_recognition_base_data LIMIT 10;
    SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_base_data LIMIT 10;

    SELECT * FROM rev_recognition_allocation_data LIMIT 10;
    SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data LIMIT 10;
    SELECT revenue_year_month, FORMAT(SUM(sales_units), 0), FORMAT(SUM(monthly_revenue_less_deduction), 0) FROM rev_recognition_allocation_data WHERE revenue_year_date IN (2025, 2026) GROUP BY 1 ORDER BY 1;

-- #2 CREATE POST RACE DATA
    USE usat_sales_db;

    SET @table_name = 'sales_model_2027_post_race_data'; -- need prepared statement to use; opted for easy setup

    -- CREATE ACTUAL VS GOAL DATA
        DROP TABLE IF EXISTS sales_model_2027_post_race_data;

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

    -- CREATE sales_model_2027_post_race_data
        CREATE TABLE IF NOT EXISTS sales_model_2027_post_race_data (
            year INT,
            month INT,
            `year_month` VARCHAR(50),

            type VARCHAR(50),
            category VARCHAR(50),

            sales_units INT,
            sales_revenue DECIMAL(10,2),

            -- Created at timestamps:
            created_at_mtn DATETIME,
            created_at_utc DATETIME
        );

    SHOW VARIABLES LIKE 'local_infile';
    SHOW VARIABLES LIKE 'secure_file_priv';

    -- LOAD sales_model_2027_post_race_data
        LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\data\\usat_sales_post_race_data\\2026_post_race_raw_data_010126.csv'
            INTO TABLE sales_model_2027_post_race_data
            FIELDS TERMINATED BY ','
            ENCLOSED BY '"'
            LINES TERMINATED BY '\n'
            IGNORE 1 LINES
            (
                year,
                month,
                `year_month`,
                type,
                category,
                sales_units,
                sales_revenue
            )
            SET
                created_at_mtn = @created_at_mtn,
                created_at_utc = @created_at_utc;
        ;

    SELECT * FROM usat_sales_db.sales_model_2027_post_race_data;
    SELECT FORMAT(COUNT(*), 0) FROM usat_sales_db.sales_model_2027_post_race_data;

-- #3 2026 SALES MODELS
    USE usat_sales_db;

    SELECT "1_sales_model_2026" AS query_label, s.* FROM sales_model_2026 AS s;
    SELECT "2_sales_model_2026_post_race_data" AS query_label, s.* FROM sales_model_2026_post_race_data AS s;
    SELECT "2A_sales_model_2026_post_race_data" AS query_label, s.month, FORMAT(SUM(sales_revenue), 0) FROM sales_model_2026_post_race_data AS s GROUP BY 1,2 WITH ROLLUP ORDER BY 1,2;

    SELECT "3_sales_model_2026_v1_100125" AS query_label, s.* FROM sales_model_2026_v1_100125 AS s;
    SELECT "4_sales_model_2026_v2_111025" AS query_label, s.* FROM sales_model_2026_v2_111025 AS s;
    SELECT "5_sales_model_rec_rev_1_sales_estimate" AS query_label, s.* FROM sales_model_rec_rev_1_sales_estimate AS s;
    SELECT "6_sales_model_rec_rev_2_allocation_estimate" AS query_label, s.* FROM sales_model_rec_rev_2_allocation_estimate AS s;

-- #4 2027 SALES MODELS
    USE usat_sales_db;

    SELECT "1_sales_model_2027" AS query_label, s.* FROM sales_model_2027 AS s;
    SELECT "2_sales_model_2027_post_race_data" AS query_label, s.* FROM sales_model_2026_post_race_data AS s;
    SELECT "2A_sales_model_2027_post_race_data" AS query_label, s.month, FORMAT(SUM(sales_revenue), 0) FROM sales_model_2027_post_race_data AS s GROUP BY 1,2 WITH ROLLUP ORDER BY 1,2;

    SELECT * FROM sales_model_2027_versions;
    SELECT * FROM sales_model_runs;

    # SELECT "3_sales_model_2026_v1_100125" AS query_label, s.* FROM sales_model_2026_v1_100125 AS s;
    # SELECT "4_sales_model_2026_v2_111025" AS query_label, s.* FROM sales_model_2026_v2_111025 AS s;
    # SELECT "5_sales_model_rec_rev_1_sales_estimate" AS query_label, s.* FROM sales_model_rec_rev_1_sales_estimate AS s;
    # SELECT "6_sales_model_rec_rev_2_allocation_estimate" AS query_label, s.* FROM sales_model_rec_rev_2_allocation_estimate AS s;

-- #5 CREATE 2027 SALES MODEL
    -- C:\Users\calla\development\usat\sql_code\6j_2027_model\step_0_discovery_actual_vs_goal_model_v1_with_post_race.sql
    -- SALES MODEL WITH POST RACE
    USE usat_sales_db;

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

    -- 2026 ACTUAL PRICE LEVELS
        SET @One_Day_15_2026 = 14.99;
        SET @Bronze_Relay_2026 = 9;
        SET @Bronze_Sprint_2026 = 14.99;
        SET @Bronze_Intermediate_2026 = 24.99;
        SET @Bronze_Ultra_2026 = 34.99;
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
        SET @Platinum_Foundation_2026 = 429.99;
        SET @Platinum_USA_2026 = 429.99;
        SET @Young_Adult_36_2026 = 40;
        SET @Young_Adult_40_2026 = 40;
        SET @Youth_Premier_25_2026 = 25;
        SET @Youth_Premier_30_2026 = 30;
        SET @Youth_Annual_2026 = 10;
        SET @Elite_2026 = 79.99;

        -- Bronze - Bike
        -- Bronze - Run
        -- Bronze - Swim
        -- Bronze Community Membership
        -- Elite 2-Year membership

    -- 2027 ACTUAL PRICE LEVELS
        SET @One_Day_15_2027 = 14.99; -- todo:
        SET @Bronze_Relay_2027 = 9;
        SET @Bronze_Sprint_2027 = 14.99; -- todo:
        SET @Bronze_Intermediate_2027 = 24.99; -- todo:
        SET @Bronze_Ultra_2027 = 34.99; -- todo:
        SET @Bronze_$0_2027 = 0;
        SET @Bronze_AO_2027 = 0;
        SET @Bronze_Upgrade_2027 = 7;
        SET @Club_2027 = 0;
        SET @Unknown_2027 = 4;
        SET @1_Year_50_2027 = 69.99;
        SET @Silver_2027 = 69.99;
        SET @Gold_2027 = 99.99;
        SET @3_Year_2027 = 178.49;
        SET @Lifetime_2027 = 0;
        SET @Platinum_Foundation_2027 = 429.99; -- todo:
        SET @Platinum_USA_2027 = 429.99; -- todo:
        SET @Young_Adult_36_2027 = 40;
        SET @Young_Adult_40_2027 = 40;
        SET @Youth_Premier_25_2027 = 25;
        SET @Youth_Premier_30_2027 = 30;
        SET @Youth_Annual_2027 = 10;
        SET @Elite_2027 = 79.99;

    -- TODO: Find calc for effective rate assumptions in "assumptions" sheet in the 2027 sales model
    -- 2027 EFFECTIVE PRICE LEVELS
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
                    SUM(revenue_current) AS sales_rev_2026_actual,
                    SUM(revenue_prior) AS sales_rev_2025_actual,
                    SUM(units_current_year) AS sales_units_2026_actual,
                    SUM(units_prior_year) AS sales_units_2025_actual,
                    IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year)) AS rev_per_unit_2026_actual,
                    IF(SUM(units_prior_year) = 0, 0, SUM(revenue_prior) / SUM(units_prior_year)) AS rev_per_unit_2025_actual,

                    -- Splits - Bulk & NonBulk
                    SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current     ELSE 0 END) AS sales_rev_2026_actual_bulk,
                    SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year  ELSE 0 END) AS sales_units_2026_actual_bulk,

                    SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN revenue_current     ELSE 0 END) AS sales_rev_2026_actual_nonbulk,
                    SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN units_current_year  ELSE 0 END) AS sales_units_2026_actual_nonbulk,

                    MAX(origin_flag_ma = 'ADMIN_BULK_UPLOADER') AS has_bulk_upload,
                            
                    -- Bulk unit economics to reuse for 2027 bulk pricing
                    IFNULL(
                    SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current ELSE 0 END)
                    / NULLIF(SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year ELSE 0 END), 0),
                    IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year))
                    ) AS rev_per_unit_2026_actual_bulk
                    
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
                    "2026" AS year_goal,

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
                    SUM(sales_revenue) AS sales_rev_2026_goal,
                    SUM(sales_units) AS sales_units_2026_goal,
                    IF(SUM(sales_units) = 0, 0, SUM(sales_revenue) / SUM(sales_units)) AS rev_per_unit_2026_goal

                FROM sales_goal_data AS sg
                WHERE purchased_on_year_adjusted_mp = 2026
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
                    "2026" AS year_goal,

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

                    "" AS category_sort_order_goal,

                    0 AS sales_rev_2026_goal,
                    0 AS sales_units_2026_goal,
                    0 AS rev_per_unit_2026_goal

                FROM sales_goal_data
                WHERE purchased_on_year_adjusted_mp = 2026
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
                    "2026" AS year_goal,

                    CASE WHEN sa.month_actual = 8  THEN 1 ELSE 0 END AS is_current_month,
                    CASE WHEN sa.month_actual <= 8 THEN 1 ELSE 0 END AS is_year_to_date,
                    CASE WHEN sa.month_actual < 9  THEN 1 ELSE 0 END AS is_ytd_before_current_month,

                    sa.type_actual AS type_goal,
                    sa.category_actual AS category_goal,

                    999 AS category_sort_order_goal,

                    0 AS sales_rev_2026_goal,
                    0 AS sales_units_2026_goal,
                    0 AS rev_per_unit_2026_goal

                FROM sales_actuals AS sa
                    LEFT JOIN sales_goal_data AS sg ON sa.month_actual = sg.purchased_on_month_adjusted_mp
                        AND sa.type_actual = sg.real_membership_types_sa
                        AND sa.category_actual = sg.new_member_category_6_sa    
                        AND sg.purchased_on_year_adjusted_mp = 2026 -- TODO:

                WHERE sg.purchased_on_month_adjusted_mp IS NULL
            ),

            post_race AS (
                SELECT
                    pr.month  AS month_post_race,
                    pr.type   AS type_post_race,
                    pr.category AS category_post_race,

                    SUM(COALESCE(pr.sales_units, 0))   AS sales_units_2027_goal_post_race,
                    SUM(COALESCE(pr.sales_revenue, 0)) AS sales_rev_2027_goal_post_race -- overstated b/c it's not effective price
                
                FROM sales_model_2027_post_race_data pr
                GROUP BY 1, 2, 3
            ),

            sales_base AS (
                SELECT
                    -- Goals
                    sg.month_goal,
                    sg.type_goal,
                    sg.category_goal,
                    sg.is_ytd_before_current_month,

                    -- Actual splits
                    sa.sales_rev_2026_actual,
                    sa.sales_rev_2026_actual_bulk,
                    sa.sales_rev_2026_actual_nonbulk,

                    sa.sales_units_2026_actual,
                    sa.sales_units_2026_actual_bulk,
                    sa.sales_units_2026_actual_nonbulk,

                    sa.rev_per_unit_2026_actual,
                    sa.rev_per_unit_2026_actual_bulk,

                    -- sg.sales_rev_2026_goal,
                    -- pr.sales_rev_2027_goal_post_race,
                    -- pr.sales_units_2027_goal_post_race,

                    -- 2026 estimate TOTAL
                    CASE 
                        WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_rev_2026_actual
                        WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_rev_2026_goal
                        ELSE 0
                    END AS sales_rev_2026_estimate,

                    CASE 
                        WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_2026_actual
                        WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_2026_goal
                        ELSE 0
                    END AS sales_units_2026_estimate,

                    -- 2026 estimate BULK
                    sa.sales_rev_2026_actual_bulk   AS sales_rev_2026_estimate_bulk,
                    sa.sales_units_2026_actual_bulk AS sales_units_2026_estimate_bulk,

                    -- 2026 estimate NON-BULK (NOTE [5]: keep denominator consistent for period=0)
                    -- did not add in post race revenue b/c post race typically is zero
                    CASE 
                        WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_rev_2026_actual_nonbulk
                        WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_rev_2026_goal  -- total revenue available only at goal level
                        ELSE 0
                    END AS sales_rev_2026_estimate_nonbulk,

                    -- adjust to include 2026 post race
                    -- CASE 
                    --     WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_2026_actual_nonbulk
                    --     WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_2026_goal
                    --     ELSE 0
                    -- END AS sales_units_2026_estimate_nonbulk

                    CASE
                        WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_2026_actual_nonbulk + COALESCE(pr.sales_units_2027_goal_post_race, 0)
                        WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_2026_goal + COALESCE(pr.sales_units_2027_goal_post_race, 0)
                        ELSE 0
                    END AS sales_units_2026_estimate_nonbulk

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
                --     AND IFNULL(sa.sales_rev_2026_actual, 0) = 0
                --     AND IFNULL(sa.sales_units_2026_actual, 0) = 0
                -- )

                    ORDER BY month_goal, category_sort_order_actual
            ),

            -- ======================
            -- NOTE [1] & [2]: compute price once; derive units once; bulk units = difference
            -- ======================
            priced AS (
                SELECT
                    b.*,

                    -- NOTE [1]: single source of truth for the 2027 price (DECIMAL avoids float drift)
                    -- 2027 EFFECTIVE PRICE LEVELS
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
                    AS DECIMAL(10,2)) AS price_2027_nonbulk,
                    
                    -- Price for BULK: use actual bulk unit economics from 2026 / use fallback of 0 if null
                    CAST(
                        COALESCE(
                            b.rev_per_unit_2026_actual_bulk,
                            0
                        )
                    AS DECIMAL(10,2)) AS price_2027_bulk,

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

                    -- 2027 ACTUAL PRICE LEVELS
                    CAST(
                        CASE
                            WHEN b.category_goal = 'One Day - $15'              THEN @One_Day_15_2027
                            WHEN b.category_goal = 'Bronze - Relay'             THEN @Bronze_Relay_2027
                            WHEN b.category_goal = 'Bronze - Sprint'            THEN @Bronze_Sprint_2027
                            WHEN b.category_goal = 'Bronze - Intermediate'      THEN @Bronze_Intermediate_2027
                            WHEN b.category_goal = 'Bronze - Ultra'             THEN @Bronze_Ultra_2027
                            WHEN b.category_goal = 'Bronze - $0'                THEN @Bronze_$0_2027
                            WHEN b.category_goal = 'Bronze - AO'                THEN @Bronze_AO_2027
                            WHEN b.category_goal = 'Bronze - Distance Upgrade'  THEN @Bronze_Upgrade_2027
                            WHEN b.category_goal = 'Club'                       THEN @Club_2027
                            WHEN b.category_goal = 'Unknown'                    THEN @Unknown_2027
                            WHEN b.category_goal = '1-Year $50'                 THEN @1_Year_50_2027
                            WHEN b.category_goal = 'Silver'                     THEN @Silver_2027
                            WHEN b.category_goal = 'Gold'                       THEN @Gold_2027
                            WHEN b.category_goal = '3-Year'                     THEN @3_Year_2027
                            WHEN b.category_goal = 'Lifetime'                   THEN @Lifetime_2027
                            WHEN b.category_goal = 'Platinum - Foundation'      THEN @Platinum_Foundation_2027
                            WHEN b.category_goal = 'Platinum - Team USA'        THEN @Platinum_USA_2027
                            WHEN b.category_goal = 'Young Adult - $36'          THEN @Young_Adult_36_2027
                            WHEN b.category_goal = 'Young Adult - $40'          THEN @Young_Adult_40_2027
                            WHEN b.category_goal = 'Youth Annual'               THEN @Youth_Annual_2027
                            WHEN b.category_goal = 'Youth Premier - $25'        THEN @Youth_Premier_25_2027
                            WHEN b.category_goal = 'Youth Premier - $30'        THEN @Youth_Premier_30_2027
                            WHEN b.category_goal = 'Elite'                      THEN @Elite_2027
                            ELSE NULL
                        END
                    AS DECIMAL(10,2)) AS price_2027_actual,

                    -- 2027 UNIT PCT CHANGE
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
                    AS DECIMAL(10,2)) AS unit_2027_pct_change,

                    -- >>> UNIT GROWTH (ADDED): apply category growth pct to derived units >>>
                    -- Derived 2027 units for total/nonbulk; bulk = total - nonbulk
                    CAST(
                        -- CASE 
                        --     WHEN b.is_ytd_before_current_month = 1 THEN b.sales_units_2026_actual
                        --     ELSE b.sales_units_2026_estimate
                        -- END * 
                        b.sales_units_2026_estimate * 
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
                    AS DECIMAL(10,2)) units_total_2027,

                    CAST(
                        -- CASE    
                        --     WHEN b.is_ytd_before_current_month = 1 THEN b.sales_units_2026_actual_nonbulk
                        --     ELSE b.sales_units_2026_estimate_nonbulk
                        -- END * 
                        
                        -- already calc in "sales_base" CTE
                        b.sales_units_2026_estimate_nonbulk *
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
                    AS  DECIMAL(10,2)) units_nonbulk_2027
                    -- <<< UNIT GROWTH (ADDED) <<<

                FROM sales_base b
            ),

            -- ======================
            -- NOTE [3]: price all three consistently => exact reconciliation
            -- ======================
            sales_estimate_2027 AS (
                SELECT
                    p.*,

                    -- POST RACE UNITS & REVENUE
                    COALESCE(pr.sales_units_2027_goal_post_race, 0) AS sales_units_2027_goal_post_race,
                    COALESCE(pr.sales_units_2027_goal_post_race, 0) * COALESCE(p.price_2027_nonbulk, 0) AS sales_rev_2027_goal_post_race, -- did not include b/c sales rev doesn't include post race revenue

                    -- bulk units = total - nonbulk (never mix splits from different bases)
                    -- (p.units_total_2027 - p.units_nonbulk_2027) AS units_bulk_2027,

                    -- Revenues: units × price_2027 (consistent for total/nonbulk/bulk)
                    -- Bulk Units + Non-bulk Units
                    CAST(
                        ROUND((
                            (p.units_total_2027 - p.units_nonbulk_2027) * p.price_2027_bulk) + 
                            (p.units_nonbulk_2027 * p.price_2027_nonbulk)
                        , 2) 
                    AS DECIMAL(10,2)) sales_rev_2027_goal,

                    -- FORMULA ABOVE WAS NOT DISPLAYING VALUES FOR Q4 2027 REV GOAL; FIXED BUT KEEIPNG FORMULA IF NECESSARY
                    -- ROUND(
                    --     GREATEST(COALESCE(p.units_total_2027,0) - COALESCE(p.units_nonbulk_2027,0), 0) * COALESCE(p.price_2027_bulk,0)
                    --         + COALESCE(p.units_nonbulk_2027,0) * COALESCE(p.price_2027_nonbulk,0)
                    --         , 2) AS sales_rev_2027_goal,

                    -- REVENUE CALCULATIONS (price each split with its own price)
                    -- CAST((p.units_nonbulk_2027 * p.price_2027_nonbulk) AS DECIMAL(10,2)) sales_rev_2027_goal_nonbulk,
                    CAST(
                        (
                            COALESCE(p.units_nonbulk_2027, 0)
                            - COALESCE(pr.sales_units_2027_goal_post_race, 0) -- did not include b/c sales rev doesn't include post race revenue
                        ) 
                            * COALESCE(p.price_2027_nonbulk, 0)
                    AS DECIMAL(10,2)) AS sales_rev_2027_goal_nonbulk,

                    CAST(
                        ((p.units_total_2027 - p.units_nonbulk_2027) * p.price_2027_bulk)
                    AS DECIMAL(10,2)) sales_rev_2027_goal_bulk,

                    -- UNITS (for parity with your original names)
                    CAST(p.units_total_2027 AS DECIMAL(10,2)) sales_units_2027_goal,
                    CAST((p.units_total_2027 - p.units_nonbulk_2027) AS DECIMAL(10,2)) sales_units_2027_goal_bulk,
                    CAST(p.units_nonbulk_2027 AS DECIMAL(10,2)) sales_units_2027_goal_nonbulk -- includes post race; added in the sales base cte above

                FROM priced p
                    LEFT JOIN post_race AS pr ON pr.month_post_race = p.month_goal
                        AND p.type_goal = pr.type_post_race
                        AND p.category_goal = pr.category_post_race
            )

            SELECT 
                e.*,

                -- Diff vs 2026 estimate (non-bulk basis, kept)
                IFNULL(e.sales_rev_2027_goal_nonbulk - e.sales_rev_2026_estimate_nonbulk, 0) AS goal_v_actual_rev_diff_abs,
                IFNULL(e.sales_units_2027_goal_nonbulk - e.sales_units_2026_estimate_nonbulk, 0) AS goal_v_actual_units_diff_abs,

                -- PRICE VS UNIT CHANGE IMPACT: NON BULK ONLY
                ROUND(
                    (IFNULL(e.price_2027_nonbulk, IFNULL(IF(e.sales_units_2026_estimate_nonbulk = 0, 0, e.sales_rev_2026_estimate_nonbulk / NULLIF(e.sales_units_2026_estimate_nonbulk, 0)), 0))
                    - IFNULL(IF(e.sales_units_2026_estimate_nonbulk = 0, 0, e.sales_rev_2026_estimate_nonbulk / NULLIF(e.sales_units_2026_estimate_nonbulk, 0)), 0))
                    * ((IFNULL(e.sales_units_2026_estimate_nonbulk, 0) + IFNULL(e.sales_units_2027_goal_nonbulk, 0)) / 2)
                , 2) AS price_impact_abs,

                ROUND(
                    (IFNULL(e.sales_units_2027_goal_nonbulk, 0) - IFNULL(e.sales_units_2026_estimate_nonbulk, 0))
                    * ((
                        IFNULL(IF(e.sales_units_2026_estimate_nonbulk = 0, 0, e.sales_rev_2026_estimate_nonbulk / NULLIF(e.sales_units_2026_estimate_nonbulk, 0)), 0)
                        + IFNULL(e.price_2027_nonbulk, IFNULL(IF(e.sales_units_2026_estimate_nonbulk = 0, 0, e.sales_rev_2026_estimate_nonbulk / NULLIF(e.sales_units_2026_estimate_nonbulk, 0)), 0))
                    ) / 2)
                , 2) AS unit_impact_abs,
                
                -- PRICE VS UNIT CHANGE IMPACT (BULK)
                ROUND(
                    (COALESCE(e.price_2027_bulk, 0)
                    - COALESCE(NULLIF(e.sales_rev_2026_estimate_bulk,0)/NULLIF(e.sales_units_2026_estimate_bulk,0), 0))
                    * ((COALESCE(e.sales_units_2026_estimate_bulk,0)
                        + COALESCE(e.units_total_2027 - e.units_nonbulk_2027,0)) / 2)
                , 2) AS price_impact_abs_bulk,

                ROUND(
                    (COALESCE(e.units_total_2027 - e.units_nonbulk_2027,0) - COALESCE(e.sales_units_2026_estimate_bulk,0))
                    * ((COALESCE(NULLIF(e.sales_rev_2026_estimate_bulk,0)/NULLIF(e.sales_units_2026_estimate_bulk,0), 0)
                        + COALESCE(e.price_2027_bulk,0)) / 2)
                , 2) AS unit_impact_abs_bulk,

                -- PRICE VS UNIT CHANGE IMPACT (TOTAL)
                ROUND(
                    (COALESCE(NULLIF(e.sales_rev_2027_goal,0)/NULLIF(e.sales_units_2027_goal,0), 0)
                    - COALESCE(NULLIF(e.sales_rev_2026_estimate,0)/NULLIF(e.sales_units_2026_estimate,0), 0))
                    * ((COALESCE(e.sales_units_2026_estimate,0) + COALESCE(e.sales_units_2027_goal,0)) / 2)
                , 2) AS price_impact_abs_total,

                ROUND(
                    (COALESCE(e.sales_units_2027_goal,0) - COALESCE(e.sales_units_2026_estimate,0))
                    * ((COALESCE(NULLIF(e.sales_rev_2026_estimate,0)/NULLIF(e.sales_units_2026_estimate,0), 0)
                        + COALESCE(NULLIF(e.sales_rev_2027_goal,0)/NULLIF(e.sales_units_2027_goal,0), 0)) / 2)
                , 2) AS unit_impact_abs_total,

                -- NOTE [6]: optional reconciliation check (0.00 means perfect tie-out). Comment out if not needed.
                ROUND(ABS((e.sales_rev_2027_goal_nonbulk + e.sales_rev_2027_goal_bulk) - e.sales_rev_2027_goal), 6) AS recon_delta,

                -- Created at timestamps:
                @created_at_mtn AS created_at_mtn,
                @created_at_utc AS created_at_utc

            FROM sales_estimate_2027 AS e
            -- WHERE e.price_2027_bulk IS NULL
    ;

        /* -----------------------------------------------------------------------------
        2) View results
        ----------------------------------------------------------------------------- */
        SELECT * FROM sales_model_2027 LIMIT 300;

        SELECT
        "sales_model_2027" AS query_label,
        month_goal,
        COUNT(*) AS row_count,
        FORMAT(SUM(sales_units_2026_estimate), 0) AS sales_units_2026_estimate,
        FORMAT(SUM(sales_rev_2026_estimate), 0) AS sales_rev_2026_estimate,
        
        FORMAT(SUM(sales_units_2026_estimate_nonbulk), 0) AS sales_units_2026_estimate_nonbulk,
        FORMAT(SUM(sales_rev_2026_estimate_nonbulk), 0) AS sales_rev_2026_estimate_nonbulk,
        
        FORMAT(SUM(sales_units_2027_goal_nonbulk), 0) AS sales_units_2027_goal_nonbulk, 
        FORMAT(SUM(sales_rev_2027_goal_nonbulk), 0) AS sales_rev_2027_goal_nonbulk, 
        
        FORMAT(SUM(sales_units_2027_goal_post_race), 0) AS sales_units_2027_goal_post_race, 
        FORMAT(SUM(sales_rev_2027_goal_post_race), 0) AS sales_rev_2027_goal_post_race, 
        MIN(month_goal) AS min_month,
        MAX(month_goal) AS max_month
        FROM sales_model_2027
        GROUP BY month_goal WITH ROLLUP
        ORDER BY month_goal
        ;

-- #6 GET 2026 SALES ACTUALS THRU AUGUST
    USE usat_sales_db;       
            
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
                    CASE WHEN MONTH(common_purchased_on_date_adjusted) <  8 THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                    
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
                    SUM(revenue_current) AS sales_rev_2026_actual,
                    SUM(revenue_prior) AS sales_rev_2025_actual,
                    SUM(units_current_year) AS sales_units_2026_actual,
                    SUM(units_prior_year) AS sales_units_2025_actual,
                    IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year)) AS rev_per_unit_2026_actual,
                    IF(SUM(units_prior_year) = 0, 0, SUM(revenue_prior) / SUM(units_prior_year)) AS rev_per_unit_2025_actual,

                    -- Splits - Bulk & NonBulk
                    SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current     ELSE 0 END) AS sales_rev_2026_actual_bulk,
                    SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year  ELSE 0 END) AS sales_units_2026_actual_bulk,

                    SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN revenue_current     ELSE 0 END) AS sales_rev_2026_actual_nonbulk,
                    SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN units_current_year  ELSE 0 END) AS sales_units_2026_actual_nonbulk,

                    MAX(origin_flag_ma = 'ADMIN_BULK_UPLOADER') AS has_bulk_upload,
                            
                    -- Bulk unit economics to reuse for 2027 bulk pricing
                    IFNULL(
                    SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current ELSE 0 END)
                    / NULLIF(SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year ELSE 0 END), 0),
                    IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year))
                    ) AS rev_per_unit_2026_actual_bulk
                    
                FROM sales_data_year_over_year_2026 AS sa
                GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
            )
        SELECT * FROM sales_actuals;
        SELECT month_actual, FORMAT(SUM(sales_rev_2026_actual), 0) FROM sales_actuals GROUP BY 1 WITH ROLLUP ORDER BY 1;
        SELECT month_actual, SUM(sales_rev_2026_actual) FROM sales_actuals WHERE is_ytd_before_current_month = 1 GROUP BY 1 ORDER BY 1;

-- #7 GET 2026 SALES GOALS
    USE usat_sales_db;       
        
        WITH sales_goals AS (
            SELECT
                purchased_on_month_adjusted_mp AS month_goal,
                CASE 
                    WHEN purchased_on_month_adjusted_mp IN (1,2,3) THEN 1
                    WHEN purchased_on_month_adjusted_mp IN (4,5,6) THEN 2
                    WHEN purchased_on_month_adjusted_mp IN (7,8,9) THEN 3
                    ELSE 4
                END as quarter_goal,
                "2026" AS year_goal,

                -- CASE WHEN purchased_on_month_adjusted_mp =  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_current_month,
                -- CASE WHEN purchased_on_month_adjusted_mp <= MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_year_to_date,
                -- CASE WHEN purchased_on_month_adjusted_mp <  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                
                -- TODO: HARD CODE TO AUGUST GIVEN THAT'S WHEN THE ORIGINAL MODEL WAS GENERATED
                CASE WHEN purchased_on_month_adjusted_mp =  8 THEN 1 ELSE 0 END AS is_current_month,
                CASE WHEN purchased_on_month_adjusted_mp <= 8 THEN 1 ELSE 0 END AS is_year_to_date,
                CASE WHEN purchased_on_month_adjusted_mp <  8 THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                
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
                SUM(sales_revenue) AS sales_rev_2026_goal,
                SUM(sales_units) AS sales_units_2026_goal,
                IF(SUM(sales_units) = 0, 0, SUM(sales_revenue) / SUM(sales_units)) AS rev_per_unit_2026_goal

            FROM sales_goal_data AS sg
            WHERE purchased_on_year_adjusted_mp = 2026
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
                "2026" AS year_goal,

                -- CASE WHEN purchased_on_month_adjusted_mp =  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_current_month,
                -- CASE WHEN purchased_on_month_adjusted_mp <= MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_year_to_date,
                -- CASE WHEN purchased_on_month_adjusted_mp <  MONTH(CURRENT_DATE) THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                
                -- TODO: HARD CODE TO AUGUST GIVEN THAT'S WHEN THE ORIGINAL MODEL WAS GENERATED
                CASE WHEN purchased_on_month_adjusted_mp =  8 THEN 1 ELSE 0 END AS is_current_month,
                CASE WHEN purchased_on_month_adjusted_mp <= 8 THEN 1 ELSE 0 END AS is_year_to_date,
                CASE WHEN purchased_on_month_adjusted_mp <  8 THEN 1 ELSE 0 END AS is_ytd_before_current_month,
                
                -- TODO: HARD CODE TO FULL YEAR TO UNDERSTAND WHAT THAT MIGHT LOOK LIKE
                -- CASE WHEN purchased_on_month_adjusted_mp =  12 THEN 1 ELSE 0 END AS is_current_month,
                -- CASE WHEN purchased_on_month_adjusted_mp <= 12 THEN 1 ELSE 0 END AS is_year_to_date,
                -- CASE WHEN purchased_on_month_adjusted_mp <  13 THEN 1 ELSE 0 END AS is_ytd_before_current_month,

                real_membership_types_sa AS type_goal,
                'Unknown' AS category_goal,

                "" AS category_sort_order_goal,

                0 AS sales_rev_2026_goal,
                0 AS sales_units_2026_goal,
                0 AS rev_per_unit_2026_goal

            FROM sales_goal_data
            WHERE purchased_on_year_adjusted_mp = 2026
            GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
		)
	-- SELECT * FROM sales_goals;
	SELECT month_goal, FORMAT(SUM(sales_rev_2026_goal), 0) FROM sales_goals GROUP BY 1 WITH ROLLUP ORDER BY 1;

-- #8 GET 2026 POST RACE
    USE usat_sales_db;             
        
        WITH post_race AS (
            SELECT
                pr.month  AS month_post_race,
                pr.type   AS type_post_race,
                pr.category AS category_post_race,

				SUM(COALESCE(pr.sales_units, 0))   AS sales_units_2027_goal_post_race,
				SUM(COALESCE(pr.sales_revenue, 0)) AS sales_rev_2027_goal_post_race -- overstated b/c it's not effective price
            
            FROM sales_model_2027_post_race_data pr
            GROUP BY 1, 2, 3
        )
	-- SELECT * FROM post_race;
	SELECT month_post_race, FORMAT(SUM(sales_rev_2027_goal_post_race), 0), FORMAT(SUM(sales_units_2027_goal_post_race), 0) FROM post_race GROUP BY 1 WITH ROLLUP ORDER BY 1;

-- #9 GET 2026 SALES BASE
    USE usat_sales_db;        

    -- 2026 ACTUAL PRICE LEVELS
        SET @One_Day_15_2027 = 14.99;
        SET @Bronze_Relay_2027 = 9;
        SET @Bronze_Sprint_2027 = 14.99;
        SET @Bronze_Intermediate_2027 = 24.99;
        SET @Bronze_Ultra_2027 = 34.99;
        SET @Bronze_$0_2027 = 0;
        SET @Bronze_AO_2027 = 0;
        SET @Bronze_Upgrade_2027 = 7;
        SET @Club_2027 = 0;
        SET @Unknown_2027 = 4;
        SET @1_Year_50_2027 = 69.99;
        SET @Silver_2027 = 69.99;
        SET @Gold_2027 = 99.99;
        SET @3_Year_2027 = 178.49;
        SET @Lifetime_2027 = 0;
        SET @Platinum_Foundation_2027 = 429.99;
        SET @Platinum_USA_2027 = 429.99;
        SET @Young_Adult_36_2027 = 40;
        SET @Young_Adult_40_2027 = 40;
        SET @Youth_Premier_25_2027 = 25;
        SET @Youth_Premier_30_2027 = 30;
        SET @Youth_Annual_2027 = 10;
        SET @Elite_2027 = 79.99;

    -- 2027 ACTUAL PRICE LEVELS
        SET @One_Day_15_2027 = 14.99; -- todo:
        SET @Bronze_Relay_2027 = 9;
        SET @Bronze_Sprint_2027 = 14.99; -- todo:
        SET @Bronze_Intermediate_2027 = 24.99; -- todo:
        SET @Bronze_Ultra_2027 = 34.99; -- todo:
        SET @Bronze_$0_2027 = 0;
        SET @Bronze_AO_2027 = 0;
        SET @Bronze_Upgrade_2027 = 7;
        SET @Club_2027 = 0;
        SET @Unknown_2027 = 4;
        SET @1_Year_50_2027 = 69.99;
        SET @Silver_2027 = 69.99;
        SET @Gold_2027 = 99.99;
        SET @3_Year_2027 = 178.49;
        SET @Lifetime_2027 = 0;
        SET @Platinum_Foundation_2027 = 429.99; -- todo:
        SET @Platinum_USA_2027 = 429.99; -- todo:
        SET @Young_Adult_36_2027 = 40;
        SET @Young_Adult_40_2027 = 40;
        SET @Youth_Premier_25_2027 = 25;
        SET @Youth_Premier_30_2027 = 30;
        SET @Youth_Annual_2027 = 10;
        SET @Elite_2027 = 79.99;

    -- TODO: Find calc for effective rate assumptions in "assumptions" sheet in the 2027 sales model
    -- 2027 EFFECTIVE PRICE LEVELS
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
                    SUM(revenue_current) AS sales_rev_2026_actual,
                    SUM(revenue_prior) AS sales_rev_2025_actual,
                    SUM(units_current_year) AS sales_units_2026_actual,
                    SUM(units_prior_year) AS sales_units_2025_actual,
                    IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year)) AS rev_per_unit_2026_actual,
                    IF(SUM(units_prior_year) = 0, 0, SUM(revenue_prior) / SUM(units_prior_year)) AS rev_per_unit_2025_actual,

                    -- Splits - Bulk & NonBulk
                    SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current     ELSE 0 END) AS sales_rev_2026_actual_bulk,
                    SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year  ELSE 0 END) AS sales_units_2026_actual_bulk,

                    SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN revenue_current     ELSE 0 END) AS sales_rev_2026_actual_nonbulk,
                    SUM(CASE WHEN origin_flag_ma <> 'ADMIN_BULK_UPLOADER' OR origin_flag_ma IS NULL THEN units_current_year  ELSE 0 END) AS sales_units_2026_actual_nonbulk,

                    MAX(origin_flag_ma = 'ADMIN_BULK_UPLOADER') AS has_bulk_upload,
                            
                    -- Bulk unit economics to reuse for 2027 bulk pricing
                    IFNULL(
                    SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN revenue_current ELSE 0 END)
                    / NULLIF(SUM(CASE WHEN origin_flag_ma = 'ADMIN_BULK_UPLOADER' THEN units_current_year ELSE 0 END), 0),
                    IF(SUM(units_current_year) = 0, 0, SUM(revenue_current) / SUM(units_current_year))
                    ) AS rev_per_unit_2026_actual_bulk
                    
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
                    "2026" AS year_goal,

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
                    SUM(sales_revenue) AS sales_rev_2026_goal,
                    SUM(sales_units) AS sales_units_2026_goal,
                    IF(SUM(sales_units) = 0, 0, SUM(sales_revenue) / SUM(sales_units)) AS rev_per_unit_2026_goal

                FROM sales_goal_data AS sg
                WHERE purchased_on_year_adjusted_mp = 2026
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
                    "2026" AS year_goal,

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

                    "" AS category_sort_order_goal,

                    0 AS sales_rev_2026_goal,
                    0 AS sales_units_2026_goal,
                    0 AS rev_per_unit_2026_goal

                FROM sales_goal_data
                WHERE purchased_on_year_adjusted_mp = 2026
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

        "2026" AS year_goal,

        CASE WHEN sa.month_actual = 8 THEN 1 ELSE 0 END AS is_current_month,
        CASE WHEN sa.month_actual <= 8 THEN 1 ELSE 0 END AS is_year_to_date,
        CASE WHEN sa.month_actual < 9 THEN 1 ELSE 0 END AS is_ytd_before_current_month,

        sa.type_actual AS type_goal,
        sa.category_actual AS category_goal,

        999 AS category_sort_order_goal,

        0 AS sales_rev_2026_goal,
        0 AS sales_units_2026_goal,
        0 AS rev_per_unit_2026_goal

    FROM sales_actuals AS sa

    LEFT JOIN sales_goal_data AS sg
        ON sa.month_actual = sg.purchased_on_month_adjusted_mp
        AND sa.type_actual = sg.real_membership_types_sa
        AND sa.category_actual = sg.new_member_category_6_sa
        AND sg.purchased_on_year_adjusted_mp = 2026

    WHERE sg.purchased_on_month_adjusted_mp IS NULL
            ),

            post_race AS (
                SELECT
                    pr.month  AS month_post_race,
                    pr.type   AS type_post_race,
                    pr.category AS category_post_race,

                    SUM(COALESCE(pr.sales_units, 0))   AS sales_units_2027_goal_post_race,
                    SUM(COALESCE(pr.sales_revenue, 0)) AS sales_rev_2027_goal_post_race -- overstated b/c it's not effective price
                
                FROM sales_model_2027_post_race_data pr
                GROUP BY 1, 2, 3
            ),

            sales_base AS (
                SELECT
                    -- Goals
                    sg.month_goal,
                    sg.type_goal,
                    sg.category_goal,
                    sg.is_ytd_before_current_month,

                    -- Actual splits
                    sa.sales_rev_2026_actual,
                    sa.sales_rev_2026_actual_bulk,
                    sa.sales_rev_2026_actual_nonbulk,

                    sa.sales_units_2026_actual,
                    sa.sales_units_2026_actual_bulk,
                    sa.sales_units_2026_actual_nonbulk,

                    sa.rev_per_unit_2026_actual,
                    sa.rev_per_unit_2026_actual_bulk,

                    sg.sales_rev_2026_goal,
                    sg.sales_units_2026_goal,
                    pr.sales_rev_2027_goal_post_race,
                    pr.sales_units_2027_goal_post_race,

                    -- 2026 estimate TOTAL
                    CASE 
                        WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_rev_2026_actual
                        WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_rev_2026_goal
                        ELSE 0
                    END AS sales_rev_2026_estimate,

                    CASE 
                        WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_2026_actual
                        WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_2026_goal
                        ELSE 0
                    END AS sales_units_2026_estimate,

                    -- 2026 estimate BULK
                    sa.sales_rev_2026_actual_bulk   AS sales_rev_2026_estimate_bulk,
                    sa.sales_units_2026_actual_bulk AS sales_units_2026_estimate_bulk,

                    -- 2026 estimate NON-BULK (NOTE [5]: keep denominator consistent for period=0)
                    -- did not add in post race revenue b/c post race typically is zero
                    CASE 
                        WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_rev_2026_actual_nonbulk
                        WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_rev_2026_goal  -- total revenue available only at goal level
                        ELSE 0
                    END AS sales_rev_2026_estimate_nonbulk,

                    -- adjust to include 2026 post race
                    -- CASE 
                    --     WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_2026_actual_nonbulk
                    --     WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_2026_goal
                    --     ELSE 0
                    -- END AS sales_units_2026_estimate_nonbulk

                    CASE
                        WHEN sg.is_ytd_before_current_month = 1 THEN sa.sales_units_2026_actual_nonbulk + COALESCE(pr.sales_units_2027_goal_post_race, 0)
                        WHEN sg.is_ytd_before_current_month = 0 THEN sg.sales_units_2026_goal + COALESCE(pr.sales_units_2027_goal_post_race, 0)
                        ELSE 0
                    END AS sales_units_2026_estimate_nonbulk

                FROM sales_goals AS sg
                    LEFT JOIN sales_actuals AS sa ON sg.month_goal = sa.month_actual
                        AND sg.type_goal      = sa.type_actual
                        AND sg.category_goal  = sa.category_actual
                
                    LEFT JOIN post_race AS pr ON pr.month_post_race = sg.month_goal
                        AND sg.type_goal = pr.type_post_race
                        AND sg.category_goal = pr.category_post_race

                -- This clause preserves everything except when: (a) The goal is "Unknown", and (b) The actual data shows no meaningful performance (0 revenue and 0 units).
    --             WHERE NOT (
    --                 sg.category_goal = 'Unknown'
    --                 AND IFNULL(sa.sales_rev_2026_actual, 0) = 0
    --                 AND IFNULL(sa.sales_units_2026_actual, 0) = 0
    --             )

                    ORDER BY month_goal, category_sort_order_actual
            )
    -- SELECT * FROM sales_base;
    SELECT month_goal, 
        FORMAT(SUM(sales_rev_2026_actual), 0) AS sales_rev_2026_actual, 
        FORMAT(SUM(sales_rev_2026_goal), 0) AS sales_rev_2026_goal, 
        FORMAT(SUM(sales_rev_2026_estimate), 0) AS sales_rev_2026_estimate, 
        
        FORMAT(SUM(sales_units_2026_actual), 0) AS sales_units_2026_actual, 
        FORMAT(SUM(sales_units_2026_goal), 0) AS sales_units_2026_goal, 
        FORMAT(SUM(sales_units_2026_estimate), 0) AS sales_units_2026_estimate, 
        
        FORMAT(SUM(sales_rev_2026_estimate_nonbulk), 0) AS sales_rev_2026_estimate_nonbulk, 
        FORMAT(SUM(sales_units_2026_estimate_nonbulk), 0) AS sales_units_2026_estimate_nonbulk, 
        FORMAT(SUM(sales_units_2027_goal_post_race), 0) AS sales_units_2027_goal_post_race, 
        FORMAT(SUM(sales_rev_2027_goal_post_race), 0) AS sales_rev_2027_goal_post_race
    FROM sales_base 
    GROUP BY 1 WITH ROLLUP 
    ORDER BY 1
    ;