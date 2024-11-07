USE usat_sales_db;   

WITH 
    member_minimum_first_created_at_dates AS (
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
        -- WHERE member_number_members_sa IN ('10000106', '10000108', '100063152')
        GROUP BY member_number_members_sa
    )

    -- SELECT * FROM member_minimum_first_created_at_dates;

    , member_min_created_at_date AS (
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

        FROM member_minimum_first_created_at_dates
        )

    -- SELECT * FROM member_min_created_at_date;
    
    , member_total_life_time_purchases AS (
        SELECT
            member_number_members_sa,
            COUNT(*) AS member_lifetime_purchases -- total lifetime purchases due to group by

        FROM all_membership_sales_data_2015_left
        -- WHERE member_number_members_sa IN ('10000106', '10000108', '100063152')
        GROUP BY member_number_members_sa
        )

    -- SELECT * FROM member_total_life_time_purchases;

    , member_age_dimensions AS (
        SELECT
            member_number_members_sa,
            YEAR(CURDATE()) - YEAR(date_of_birth_profiles) - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(date_of_birth_profiles, '%m%d')) AS age_now, -- create age as of now,
            MIN(date_of_birth_profiles) AS date_of_birth_profiles

        FROM all_membership_sales_data_2015_left
        -- WHERE member_number_members_sa IN ('10000106', '10000108', '100063152')
        GROUP BY member_number_members_sa, 2
        )
    
    -- SELECT * FROM member_age_dimensions;

    , member_age_at_sale_date AS (
        SELECT
			am.member_number_members_sa,
            am.id_membership_periods_sa,
            
            -- am.purchased_on_year_adjusted_mp - YEAR(am.date_of_birth_profiles) - (DATE_FORMAT(am.purchased_on_adjusted_mp, '%m%d') < DATE_FORMAT(am.date_of_birth_profiles, '%m%d')) AS age_as_of_sale_date -- create age of of sale date

            -- GREATEST(0, am.purchased_on_year_adjusted_mp - YEAR(am.date_of_birth_profiles) - (DATE_FORMAT(am.purchased_on_adjusted_mp, '%m%d') < DATE_FORMAT(am.date_of_birth_profiles, '%m%d'))) AS age_as_of_sale_date -- ensure no negative age
            
            (YEAR(purchased_on_adjusted_mp) - YEAR(am.date_of_birth_profiles)) - (DATE_FORMAT(am.purchased_on_adjusted_mp, '%m%d') < DATE_FORMAT(am.date_of_birth_profiles, '%m%d')) AS age_as_of_sale_date -- create age of of sale date

        FROM all_membership_sales_data_2015_left as am
        -- WHERE member_number_members_sa IN ('10000106', '10000108', '100063152')
        GROUP BY 1, 2, 3
        )
    
    -- SELECT * FROM member_age_at_sale_date;

    , membership_period_stats AS (
        SELECT
            id_membership_periods_sa,
                
            COUNT(id_membership_periods_sa) AS sales_units,
            SUM(actual_membership_fee_6_sa) AS sales_revenue

        FROM all_membership_sales_data_2015_left
        -- WHERE member_number_members_sa IN ('10000106', '10000108', '100063152')
        GROUP BY id_membership_periods_sa
        )

    -- SELECT * FROM membership_period_stats;

    SELECT 
        am.member_number_members_sa, 
        am.id_profiles, 

        -- sale origin
        am.origin_flag_ma,        
        CASE
            -- categorize NULL as sourced from usat direct
            WHEN am.purchased_on_year_adjusted_mp IN ('2023', '2024') AND am.origin_flag_ma IS NULL THEN 'source_usat_direct'
            WHEN am.purchased_on_year_adjusted_mp IN ('2023', '2024') AND am.origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 'source_race_registration'
            -- categorize 'ADMIN_BULK_UPLOADER', 'AUDIT_API', 'RTAV_CLASSIC' as sourced from race registration
            WHEN am.purchased_on_year_adjusted_mp IN ('2023', '2024') THEN 'source_race_registration'
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

        am.purchased_on_year_adjusted_mp - YEAR(mc.min_created_at) AS member_created_at_years_out,
        CASE
            WHEN am.purchased_on_year_adjusted_mp = YEAR(mc.min_created_at) THEN 'created_year'
            WHEN am.purchased_on_year_adjusted_mp > YEAR(mc.min_created_at) THEN 'after_created_year'
            ELSE 'error_first_purchase_year_category'
        END AS member_created_at_category,

        -- member lifetime frequency
        lp.member_lifetime_purchases, -- total lifetime purchases  
        CASE 
            WHEN member_lifetime_purchases = 1 THEN 'one_purchase'
            ELSE 'more_than_one_purchase'
        END AS member_lifetime_frequency,
        -- ********************************************

        -- member first purchase year segmentation
        fd.first_purchased_on_year_adjusted_mp AS member_first_purchase_year,
        am.purchased_on_year_adjusted_mp - first_purchased_on_year_adjusted_mp AS member_first_purchase_years_out,
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
            WHEN ad.age_now >= 4 AND ad.age_now < 10 THEN '0-9'
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
            WHEN sd.age_as_of_sale_date >= 4 AND sd.age_as_of_sale_date < 10 THEN '0-9'
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
            WHEN ye.age_at_end_of_year >= 4 AND ye.age_at_end_of_year < 10 THEN '0-9'
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
        id_events,
        event_type_id_events,
        name_events,
        -- cleaned event name for comparison
        REGEXP_REPLACE(
            LOWER(REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                name_events, 
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
        LOWER(name_events) AS name_events_lower, -- used to index & search efficiently

        created_at_events,
        created_at_month_events,
        created_at_quarter_events,
        created_at_year_events,

        starts_events,
        starts_month_events,
        starts_quarter_events,
        starts_year_events,

        ends_events,
        ends_month_events,
        ends_quarter_events,
        ends_year_events,

        status_events,

        race_director_id_events,
        last_season_event_id,

        city_events,
        state_events,
        country_name_events,
        country_events,

        -- key stats
        st.sales_units,
        st.sales_revenue,    

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
    -- LIMIT 10    
    
    -- WHERE am.member_number_members_sa IN ('10000106', '10000108', '100063152')
    WHERE am.member_number_members_sa IN ('10000106')
    ;