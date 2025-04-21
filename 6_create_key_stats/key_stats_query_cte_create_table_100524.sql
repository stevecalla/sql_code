USE usat_sales_db;

-- SOURCE?
-- C:\Users\calla\development\usat\sql_code\6_create_key_stats\key_stats_query_cte_create_table_100524.sql

-- STEP #1 = CREATE MINIMUM FIRST CREATED AT DATES TABLE -- TODO: DONE 90 SECS
DROP TABLE IF EXISTS step_1_member_minimum_first_created_at_dates;

    CREATE TABLE step_1_member_minimum_first_created_at_dates AS
        SELECT 
            member_number_members_sa,

            MIN(created_at_members) AS first_created_at_members,
            MIN(created_at_mp) AS first_created_at_mp,
            MIN(created_at_profiles) AS first_created_at_profiles,
            MIN(created_at_users) AS first_created_at_users,
            MIN(purchased_on_adjusted_mp) AS first_purchased_on_adjusted_mp,
            MIN(starts_mp) AS first_starts_mp,

            YEAR(MIN(purchased_on_adjusted_mp)) AS first_purchased_on_year_adjusted_mp

        FROM all_membership_sales_data_2015_left
        GROUP BY member_number_members_sa;
        
        -- CREATE INDEX idx_member_number_members_sa ON step_1_member_minimum_first_created_at_dates (member_number_members_sa);
        -- CREATE INDEX idx_first_purchased_on_year_adjusted_mp ON step_1_member_minimum_first_created_at_dates (first_purchased_on_year_adjusted_mp);
-- *********************************************

-- STEP #2 = CREATE MIN CREATED AT DATE TABLE -- TODO: DONE 26 SECS
DROP TABLE IF EXISTS step_2_member_min_created_at_date;

    CREATE TABLE step_2_member_min_created_at_date AS
        SELECT 
            member_number_members_sa,

            -- Calculate the minimum date from the first created at fields, considering nulls
            LEAST(
                COALESCE(first_created_at_members, '9999-12-31'),
                COALESCE(first_created_at_mp, '9999-12-31'),
                COALESCE(first_created_at_profiles, '9999-12-31'),
                COALESCE(first_created_at_users, '9999-12-31'),
                COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
                COALESCE(first_starts_mp, '9999-12-31')
            ) AS min_created_at

        FROM step_1_member_minimum_first_created_at_dates;
        
        -- CREATE INDEX idx_member_number_members_sa ON step_2_member_min_created_at_date (member_number_members_sa);
        -- CREATE INDEX idx_min_created_at ON step_2_member_min_created_at_date (min_created_at);
-- *********************************************

-- STEP #3 = CREATE TOTAL LIFETIME PURCHASES TABLE -- TODO: DONE 61 secs
DROP TABLE IF EXISTS step_3_member_total_life_time_purchases;

    CREATE TABLE step_3_member_total_life_time_purchases AS
        SELECT
            member_number_members_sa,
            COUNT(*) AS member_lifetime_purchases -- total lifetime purchases due to group by

    FROM all_membership_sales_data_2015_left
    GROUP BY member_number_members_sa;

    -- CREATE INDEX idx_member_number_members_sa ON step_3_member_total_life_time_purchases (member_number_members_sa);
    -- CREATE INDEX idx_member_lifetime_purchases ON step_3_member_total_life_time_purchases (member_lifetime_purchases);
-- *********************************************

-- STEP #4 = CREATE AGE NOW TABLE -- TODO: done 92
DROP TABLE IF EXISTS step_4_member_age_dimensions;

    CREATE TABLE step_4_member_age_dimensions AS
        SELECT
            member_number_members_sa,
            (YEAR(CURDATE()) - YEAR(date_of_birth_profiles)) - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(date_of_birth_profiles, '%m%d')) AS age_now, -- create age as of now,
            MIN(date_of_birth_profiles) AS date_of_birth_profiles

        FROM all_membership_sales_data_2015_left
        GROUP BY member_number_members_sa, 2;

        -- CREATE INDEX idx_member_number_members_sa ON step_4_member_age_dimensions (member_number_members_sa);
        -- CREATE INDEX idx_date_of_birth_profiles ON step_4_member_age_dimensions (date_of_birth_profiles);
-- *********************************************

-- STEP #5 = CREATE MEMBER AGE AT SALE DATE TABLE -- TODO: done 94 secs
DROP TABLE IF EXISTS step_5_member_age_at_sale_date;

    CREATE TABLE step_5_member_age_at_sale_date AS
        SELECT
            am.member_number_members_sa,
            am.id_membership_periods_sa,
            
            (YEAR(purchased_on_adjusted_mp) - YEAR(am.date_of_birth_profiles)) - (DATE_FORMAT(am.purchased_on_adjusted_mp, '%m%d') < DATE_FORMAT(am.date_of_birth_profiles, '%m%d')) AS age_as_of_sale_date -- create age of of sale date

        FROM all_membership_sales_data_2015_left as am
        GROUP BY 1, 2;
        
    -- CREATE INDEX idx_member_number_members_sa ON step_5_member_age_at_sale_date (member_number_members_sa);
    -- CREATE INDEX idx_id_membership_periods_sa ON step_5_member_age_at_sale_date (id_membership_periods_sa);
    -- CREATE INDEX idx_age_as_of_sale_date ON step_5_member_age_at_sale_date (age_as_of_sale_date);
-- *********************************************

-- STEP #5a = CREATE AGE AT THE END OF EACH YEAR OF THE DATE OF SALE -- TODO: done 101 secs
DROP TABLE IF EXISTS step_5a_member_age_at_end_of_year_of_sale;

    CREATE TABLE step_5a_member_age_at_end_of_year_of_sale AS
        SELECT
            am.member_number_members_sa,
            am.id_membership_periods_sa,
            
            (YEAR(am.purchased_on_adjusted_mp) - YEAR(am.date_of_birth_profiles)) - 
            (DATE_FORMAT(STR_TO_DATE(CONCAT(YEAR(am.purchased_on_adjusted_mp), '-12-31'), '%Y-%m-%d'), '%m%d') < DATE_FORMAT(am.date_of_birth_profiles, '%m%d')) AS age_at_end_of_year

        FROM all_membership_sales_data_2015_left AS am
        GROUP BY 1, 2;
        
    -- CREATE INDEX idx_member_number_members_sa ON step_5a_member_age_at_end_of_year_of_sale (member_number_members_sa);
    -- CREATE INDEX idx_id_membership_periods_sa ON step_5a_member_age_at_end_of_year_of_sale (id_membership_periods_sa);
    -- CREATE INDEX idx_age_at_end_of_year ON step_5a_member_age_at_end_of_year_of_sale (age_at_end_of_year);
-- *********************************************

-- STEP #6 = CREATE MEMBERSHIP PERIOD STATS TABLE -- TODO: 
DROP TABLE IF EXISTS step_6_membership_period_stats;

    CREATE TABLE step_6_membership_period_stats AS
        SELECT
            id_membership_periods_sa,
            actual_membership_fee_6_rule_sa,
                
            COUNT(id_membership_periods_sa) AS sales_units,
            SUM(actual_membership_fee_6_sa) AS sales_revenue

        FROM all_membership_sales_data_2015_left
        GROUP BY id_membership_periods_sa, actual_membership_fee_6_rule_sa;

    -- CREATE INDEX idx_id_membership_periods_sa ON step_6_membership_period_stats (id_membership_periods_sa);
    -- CREATE INDEX idx_sales_units ON step_6_membership_period_stats (sales_units);
    -- CREATE INDEX idx_sales_revenue ON step_6_membership_period_stats (sales_revenue);
-- *********************************************

-- STEP #7 = MOST RECENT PRIOR PURCHASE TO DETERMINE NEW, LAPSED, RENEW -- TODO: done 10 min
DROP TABLE IF EXISTS step_7_prior_purchase;

    CREATE TABLE step_7_prior_purchase AS
        SELECT 
			am1.member_number_members_sa AS member_number_members_sa,
            am1.id_membership_periods_sa,
            am1.new_member_category_6_sa,
            am1.purchased_on_adjusted_mp AS most_recent_purchase_date,
            am1.ends_mp AS most_recent_mp_ends_date,
            (
                SELECT 
                    MAX(am2.purchased_on_adjusted_mp)
                FROM all_membership_sales_data_2015_left am2
                WHERE 
                    am2.member_number_members_sa = am1.member_number_members_sa
                    AND DATE(am2.purchased_on_adjusted_mp) < DATE(am1.purchased_on_adjusted_mp)
                    -- AND am2.member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
                LIMIT 1
            ) AS most_recent_prior_purchase_date,
            (
                SELECT 
                    MAX(am2.ends_mp)
                FROM all_membership_sales_data_2015_left am2
                WHERE 
                    am2.member_number_members_sa = am1.member_number_members_sa
                    AND DATE(am2.ends_mp) < DATE(am1.ends_mp)
                    -- AND am2.member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
                LIMIT 1
            ) AS most_recent_prior_mp_ends_date,
            (
                SELECT 
                    am2.real_membership_types_sa
                FROM all_membership_sales_data_2015_left am2
                WHERE 
                    am2.member_number_members_sa = am1.member_number_members_sa
                    AND DATE(am2.purchased_on_adjusted_mp) < DATE(am1.purchased_on_adjusted_mp)
                    -- AND am2.member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
				ORDER BY am2.purchased_on_adjusted_mp DESC
                LIMIT 1
            ) AS most_recent_prior_purchase_membership_type,
            (
                SELECT 
                    am2.new_member_category_6_sa
                FROM all_membership_sales_data_2015_left am2
                WHERE 
                    am2.member_number_members_sa = am1.member_number_members_sa
                    AND DATE(am2.purchased_on_adjusted_mp) < DATE(am1.purchased_on_adjusted_mp)
                    -- AND am2.member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
				ORDER BY am2.purchased_on_adjusted_mp DESC
                LIMIT 1
            ) AS most_recent_prior_purchase_membership_category

        FROM all_membership_sales_data_2015_left am1
        -- WHERE member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
        -- LIMIT 100
        ;

    -- CREATE INDEX idx_member_number_members_sa ON step_7_prior_purchase (member_number_members_sa);
    -- CREATE INDEX idx_most_recent_purchase_date ON step_7_prior_purchase (most_recent_purchase_date);
    -- CREATE INDEX idx_most_recent_prior_purchase_date ON step_7_prior_purchase (most_recent_prior_purchase_date);
    -- CREATE INDEX idx_most_recent_prior_purchase_membership_type ON step_7_prior_purchase (most_recent_prior_purchase_membership_type);
    -- CREATE INDEX idx_most_recent_prior_purchase_membership_category ON step_7_prior_purchase (most_recent_prior_purchase_membership_category);
-- *********************************************

-- STEP #8 = CREATE FINAL SALES TABLE -- TODO: done in 10 min
DROP TABLE IF EXISTS sales_key_stats_2015;

    CREATE TABLE sales_key_stats_2015 AS
        SELECT 
            am.member_number_members_sa, 
            am.id_profiles,

            -- sale origin     
            CASE
                -- categorize NULL as sourced from member_portal
                WHEN am.purchased_on_year_adjusted_mp >= 2023 AND am.origin_flag_ma IS NULL THEN 'member_portal'
                ELSE am.origin_flag_ma
            END AS origin_flag_ma,        
            CASE
                -- categorize NULL as sourced from usat direct
                WHEN am.purchased_on_year_adjusted_mp >= 2023 AND am.origin_flag_ma IS NULL THEN 'source_usat_direct'
                WHEN am.purchased_on_year_adjusted_mp >= 2023 AND am.origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 'source_usat_direct'
                -- categorize 'ADMIN_BULK_UPLOADER', 'AUDIT_API', 'RTAV_CLASSIC' as sourced from race registration
                WHEN am.purchased_on_year_adjusted_mp >= 2023 THEN 'source_race_registration'
                ELSE 'prior_to_2023'
            END AS origin_flag_category,

            -- membership periods, types, category
            am.id_membership_periods_sa, 
            am.real_membership_types_sa, 
            am.new_member_category_6_sa, 

            -- purchase on dates
            am.purchased_on_mp,
            am.purchased_on_date_mp,
            am.purchased_on_year_mp,       
            am.purchased_on_quarter_mp,  
            am.purchased_on_month_mp,       

            -- adjust purchase on dates
            am.purchased_on_adjusted_mp,
            am.purchased_on_date_adjusted_mp,
            am.purchased_on_year_adjusted_mp,
            am.purchased_on_quarter_adjusted_mp,
            am.purchased_on_month_adjusted_mp,
                    
            -- start period dates
            am.starts_mp as starts_mp,
            YEAR(am.starts_mp) as starts_year_mp,
            QUARTER(am.starts_mp) as starts__quarter_mp,
            MONTH(am.starts_mp) as starts_month_mp,

            -- end period dates
            am.ends_mp ends_mp,
            YEAR(am.ends_mp) ends_year_mp,
            QUARTER(am.ends_mp) ends_quarter_mp,
            MONTH(am.ends_mp) ends_month_mp,

            -- member created at segmentation
            mc.min_created_at AS member_min_created_at,
            YEAR(mc.min_created_at) AS member_min_created_at_year,
            QUARTER(mc.min_created_at) AS member_min_created_at_quarter,
            MONTH(mc.min_created_at) AS member_min_created_at_month,

            GREATEST(am.purchased_on_year_adjusted_mp - YEAR(mc.min_created_at), 0) AS member_created_at_years_out, -- TODO
            CASE
                WHEN am.purchased_on_year_adjusted_mp = YEAR(mc.min_created_at) THEN 'created_year'
                WHEN am.purchased_on_year_adjusted_mp > YEAR(mc.min_created_at) THEN 'after_created_year'
                ELSE 'error_first_purchase_year_category'
            END AS member_created_at_category,

            -- member lapsed, new, renew segmentation
            pp.most_recent_purchase_date,
            pp.most_recent_prior_purchase_date,

			pp.most_recent_mp_ends_date,
			pp.most_recent_prior_mp_ends_date,
            
            CASE
                WHEN am.purchased_on_year_adjusted_mp = YEAR(mc.min_created_at) THEN 'created_year' -- new 
                -- ORIGINAL DEFINITION BASED ON MOST RECENT PURCHASE DATE LOGIC; REVISED TO USE MP END & START PERIOD DATE
                -- WHEN pp.most_recent_purchase_date > DATE_ADD(most_recent_prior_purchase_date, INTERVAL 2 YEAR) THEN 'after_created_year_lapsed'
                -- WHEN pp.most_recent_purchase_date <= DATE_ADD(most_recent_prior_purchase_date, INTERVAL 2 YEAR) THEN 'after_created_year_renew'
                
                 -- current starts_mp is within 2 years of the most recent ends_mp
				WHEN am.starts_mp > DATE_ADD(pp.most_recent_prior_mp_ends_date, INTERVAL 2 YEAR) THEN 'after_created_year_lapsed'
				WHEN am.starts_mp <= DATE_ADD(pp.most_recent_prior_mp_ends_date, INTERVAL 2 YEAR) THEN 'after_created_year_renew'
                    
                ELSE 'error_lapsed_renew_segmentation'
            END AS member_lapsed_renew_category,

            -- upgrade, downgrade, same
            most_recent_prior_purchase_membership_type,
            most_recent_prior_purchase_membership_category,
            CASE
                WHEN am.purchased_on_year_adjusted_mp = YEAR(mc.min_created_at) THEN 'created_year' -- new 
                WHEN pp.most_recent_prior_purchase_membership_type = 'one_day' AND real_membership_types_sa = 'adult_annual' THEN 'upgrade_oneday_to_annual'
                WHEN pp.most_recent_prior_purchase_membership_type = 'adult_annual' AND real_membership_types_sa = 'one_day' THEN 'downgrade_annual_to_oneday'
                WHEN pp.most_recent_prior_purchase_membership_type = 'one_day' AND real_membership_types_sa = 'one_day' THEN 'same_one_day_to_one_day'
                WHEN pp.most_recent_prior_purchase_membership_type ='adult_annual' AND real_membership_types_sa = 'adult_annual' THEN 'same_annual_to_annual'
                ELSE 'other'
            END AS member_upgrade_downgrade_category,
            
            -- member lifetime frequency
            lp.member_lifetime_purchases, -- total lifetime purchases  
            CASE 
                WHEN member_lifetime_purchases = 1 THEN 'one_purchase'
                ELSE 'more_than_one_purchase'
            END AS member_lifetime_frequency,
            -- ********************************************

            -- member first purchase year segmentation
            fd.first_purchased_on_year_adjusted_mp AS member_first_purchase_year,
            GREATEST(am.purchased_on_year_adjusted_mp - first_purchased_on_year_adjusted_mp, 0) AS member_first_purchase_years_out, -- TODO
            CASE
                WHEN am.purchased_on_year_adjusted_mp = fd.first_purchased_on_year_adjusted_mp THEN 'first_year'
                WHEN am.purchased_on_year_adjusted_mp > fd.first_purchased_on_year_adjusted_mp THEN 'after_first_year'
                ELSE 'error_first_purchase_year_category'
            END AS member_first_purchase_year_category,

            -- date of birth dimensions
            ad.date_of_birth_profiles,
            YEAR(ad.date_of_birth_profiles) as date_of_birth_year_mp,
            QUARTER(ad.date_of_birth_profiles) as date_of_birth_quarter_mp,
            MONTH(ad.date_of_birth_profiles) as date_of_birth_month_mp,

            ad.age_now,
            CASE  
                WHEN ad.age_now < 4 THEN 'bad_age'
                WHEN ad.age_now >= 4 AND ad.age_now < 10 THEN '4-9'
                WHEN ad.age_now < 20 THEN '10-19'
                WHEN ad.age_now < 30 THEN '20-29'
                WHEN ad.age_now < 40 THEN '30-39'
                WHEN ad.age_now < 50 THEN '40-49'
                WHEN ad.age_now < 60 THEN '50-59'
                WHEN ad.age_now < 70 THEN '60-69'
                WHEN ad.age_now < 80 THEN '70-79'
                WHEN ad.age_now < 90 THEN '80-89'
                WHEN ad.age_now < 100 THEN '90-99'
                WHEN ad.age_now >= 100 THEN 'bad_age'
                ELSE 'bad_age'
            END AS age_now_bin, -- create bin for date of birth as of now

            sd.age_as_of_sale_date,
            CASE 
                WHEN sd.age_as_of_sale_date < 4 THEN 'bad_age'
                WHEN sd.age_as_of_sale_date >= 4 AND sd.age_as_of_sale_date < 10 THEN '4-9'
                WHEN sd.age_as_of_sale_date < 20 THEN '10-19'
                WHEN sd.age_as_of_sale_date < 30 THEN '20-29'
                WHEN sd.age_as_of_sale_date < 40 THEN '30-39'
                WHEN sd.age_as_of_sale_date < 50 THEN '40-49'
                WHEN sd.age_as_of_sale_date < 60 THEN '50-59'
                WHEN sd.age_as_of_sale_date < 70 THEN '60-69'
                WHEN sd.age_as_of_sale_date < 80 THEN '70-79'
                WHEN sd.age_as_of_sale_date < 90 THEN '80-89'
                WHEN sd.age_as_of_sale_date < 100 THEN '90-99'
                WHEN sd.age_as_of_sale_date >= 100 THEN 'bad_age'
                ELSE 'bad_age'
            END AS age_as_sale_bin, -- create bin for date of birth as of sale date
            
            ye.age_at_end_of_year,
            CASE 
                WHEN ye.age_at_end_of_year < 4 THEN 'bad_age'
                WHEN ye.age_at_end_of_year >= 4 AND ye.age_at_end_of_year < 10 THEN '4-9'
                WHEN ye.age_at_end_of_year < 20 THEN '10-19'
                WHEN ye.age_at_end_of_year < 30 THEN '20-29'
                WHEN ye.age_at_end_of_year < 40 THEN '30-39'
                WHEN ye.age_at_end_of_year < 50 THEN '40-49'
                WHEN ye.age_at_end_of_year < 60 THEN '50-59'
                WHEN ye.age_at_end_of_year < 70 THEN '60-69'
                WHEN ye.age_at_end_of_year < 80 THEN '70-79'
                WHEN ye.age_at_end_of_year < 90 THEN '80-89'
                WHEN ye.age_at_end_of_year < 100 THEN '90-99'
                WHEN ye.age_at_end_of_year >= 100 THEN 'bad_age'
                ELSE 'bad_age'
            END AS age_as_year_end_bin, -- create bin for age at the end of year of sale

            -- event detais
            am.id_events,
            am.event_type_id_events,
            am.name_events,
            -- cleaned event name for comparison
            REGEXP_REPLACE(
                LOWER(REPLACE(
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                REGEXP_REPLACE(
                                    am.name_events, 
                                    '^\\b[0-9]{4}\\s*|\\s*\\b[0-9]{4}\\b', ''  -- Remove year at start or end
                                ),  
                                'The\\s+\\b[0-9]{1,2}(st|nd|rd|th)\\s*', ''  -- Remove "The" followed by series number
                            ), 
                            '\\b[0-9]{1,2}(st|nd|rd|th)\\s*', ''  -- Remove series number
                        ), 
                        '-', '' -- Replace - with a single space
                    ), 
                    '/', ' ' -- Replace / with a single space
                )),
            '\\s+', ' ' -- Replace multiple spaces with a single space
            ) AS cleaned_name_events,
            LOWER(am.name_events) AS name_events_lower, -- used to index & search efficiently

            am.created_at_events,
            am.created_at_month_events,
            am.created_at_quarter_events,
            am.created_at_year_events,

            am.starts_events,
            am.starts_month_events,
            am.starts_quarter_events,
            am.starts_year_events,

            am.ends_events,
            am.ends_month_events,
            am.ends_quarter_events,
            am.ends_year_events,

            am.status_events,

            am.race_director_id_events,
            am.last_season_event_id,

            am.city_events,
            am.state_events,
            am.country_name_events,
            am.country_events,

            -- key stats
            st.sales_units,
            st.sales_revenue,
            st.actual_membership_fee_6_rule_sa, 

            -- data created at dates
            DATE_FORMAT(DATE_ADD(NOW(), INTERVAL -6 HOUR), '%Y-%m-%d') AS created_at_mtn,
            DATE_FORMAT(NOW(), '%Y-%m-%d') AS created_at_utc

        FROM all_membership_sales_data_2015_left am

            LEFT JOIN step_1_member_minimum_first_created_at_dates AS fd
            ON am.member_number_members_sa = fd.member_number_members_sa

            LEFT JOIN step_2_member_min_created_at_date AS mc
            ON am.member_number_members_sa = mc.member_number_members_sa
            
            LEFT JOIN step_3_member_total_life_time_purchases AS lp
            ON am.member_number_members_sa = lp.member_number_members_sa

            LEFT JOIN step_4_member_age_dimensions AS ad
            ON am.member_number_members_sa = ad.member_number_members_sa

            LEFT JOIN step_5_member_age_at_sale_date AS sd
            ON am.id_membership_periods_sa = sd.id_membership_periods_sa

            LEFT JOIN step_5a_member_age_at_end_of_year_of_sale AS ye
            ON am.id_membership_periods_sa = ye.id_membership_periods_sa

            LEFT JOIN step_6_membership_period_stats AS st
            ON am.id_membership_periods_sa = st.id_membership_periods_sa

            LEFT JOIN step_7_prior_purchase AS pp
            ON am.id_membership_periods_sa = pp.id_membership_periods_sa

        -- WHERE id_membership_periods_sa IN (421768, 1214842, 1214843, 1952878, 3272901) -- bad purchased on dates; eliminated iwth where statement below
		WHERE CAST(am.purchased_on_date_mp AS CHAR) != '0000-00-00';
        -- LIMIT 10    
        ;
-- *********************************************

-- Step #8a: Create indexes on the new table
CREATE INDEX idx_name_events ON sales_key_stats_2015 (name_events);
    CREATE INDEX idx_name_events_starts_events ON sales_key_stats_2015 (name_events, starts_events);

    CREATE INDEX idx_event_search ON sales_key_stats_2015 (
        starts_month_events,
        starts_year_events,
        purchased_on_mp,
        purchased_on_adjusted_mp,
        name_events_lower
    );

    CREATE INDEX idx_date_of_birth_profiles ON sales_key_stats_2015 (date_of_birth_profiles);

    CREATE INDEX idx_member_number ON sales_key_stats_2015 (member_number_members_sa);
    CREATE INDEX idx_id_membership_periods ON sales_key_stats_2015 (id_membership_periods_sa);

    CREATE INDEX idx_member_min_created_at ON sales_key_stats_2015 (member_min_created_at);
    CREATE INDEX idx_member_lifetime_purchases ON sales_key_stats_2015 (member_lifetime_purchases);
    CREATE INDEX idx_sales_units ON sales_key_stats_2015 (sales_units);
    CREATE INDEX idx_member_first_purchase_year ON sales_key_stats_2015 (member_first_purchase_year);
    CREATE INDEX idx_id_events ON sales_key_stats_2015 (id_events);
    
    CREATE INDEX idx_year_month ON sales_key_stats_2015 (purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp);
    CREATE INDEX idx_purchase_date ON sales_key_stats_2015 (purchased_on_adjusted_mp);

    CREATE INDEX idx_origin_flag_ma ON sales_key_stats_2015 (origin_flag_ma(255));

    CREATE INDEX idx_member_lapsed_renew_category ON sales_key_stats_2015 (member_lapsed_renew_category);
    CREATE INDEX idx_most_recent_prior_purchase_membership_type ON sales_key_stats_2015 (most_recent_prior_purchase_membership_type);
    CREATE INDEX idx_most_recent_prior_purchase_membership_category ON sales_key_stats_2015 (most_recent_prior_purchase_membership_category);
    CREATE INDEX idx_member_upgrade_downgrade_category ON sales_key_stats_2015 (member_upgrade_downgrade_category);
    CREATE INDEX idx_most_recent_purchase_date ON sales_key_stats_2015 (most_recent_purchase_date);
    CREATE INDEX idx_most_recent_prior_purchase_date ON sales_key_stats_2015 (most_recent_prior_purchase_date);
-- ********************************************

SELECT * FROM sales_key_stats_2015 LIMIT 10;

-- SELECT 
-- 	purchased_on_year_adjusted_mp
--     , AVG(age_at_end_of_year) AS mean_age_avg
    -- , (SELECT AVG(middle_ages) AS median_age
    --  FROM (
    --      SELECT age_at_end_of_year AS middle_ages
    --      FROM sales_key_stats_2015
    --      ORDER BY age_at_end_of_year
    --      LIMIT 2
    --  ) AS median_table
    --  WHERE (SELECT COUNT(*) FROM sales_key_stats_2015) % 2 = 0  -- For even count
    --  UNION ALL
    --  SELECT age_at_end_of_year AS middle_ages
    --  FROM (
    --      SELECT age_at_end_of_year
    --      FROM sales_key_stats_2015
    --      ORDER BY age_at_end_of_year
    --      LIMIT 1
    --  ) AS median_table_odd
    --  WHERE (SELECT COUNT(*) FROM sales_key_stats_2015) % 2 = 1  -- For odd count
    -- ) AS median_subquery

    -- , (SELECT age_at_end_of_year 
    --  FROM sales_key_stats_2015
    --  GROUP BY age_at_end_of_year
    --  ORDER BY COUNT(*) DESC 
    --  LIMIT 1) AS mode_age_most_frequent

-- FROM sales_key_stats_2015
-- GROUP BY purchased_on_year_adjusted_mp
-- ORDER BY purchased_on_year_adjusted_mp;

-- -- GET 0-9 MEMBER SALES
-- SELECT
--     member_number_members_sa
--     , id_membership_periods_sa
--     , real_membership_types_sa
--     , new_member_category_6_sa
--     , date_of_birth_profiles
--     , age_at_end_of_year
--     , age_now
-- FROM sales_key_stats_2015
-- WHERE purchased_on_year_adjusted_mp IN (2024)
--     AND age_at_end_of_year IN (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
-- -- LIMIT 10
;