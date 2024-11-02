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

    -- , member_age_at_sale_date AS (
    --     SELECT
	-- 		am.member_number_members_sa,
    --         am.id_membership_periods_sa,
            
    --         -- am.purchased_on_year_adjusted_mp - YEAR(am.date_of_birth_profiles) - (DATE_FORMAT(am.purchased_on_adjusted_mp, '%m%d') < DATE_FORMAT(am.date_of_birth_profiles, '%m%d')) AS age_as_of_sale_date -- create age of of sale date

    --         GREATEST(0, am.purchased_on_year_adjusted_mp - YEAR(am.date_of_birth_profiles) - (DATE_FORMAT(am.purchased_on_adjusted_mp, '%m%d') < DATE_FORMAT(am.date_of_birth_profiles, '%m%d'))) AS age_as_of_sale_date -- ensure no negative age

    --     FROM all_membership_sales_data_2015_left as am
    --     -- WHERE member_number_members_sa IN ('10000106', '10000108', '100063152')
    --     GROUP BY 1, 2, 3
    --     )
    
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
        
        -- date of birth dimensions
        ad.date_of_birth_profiles,
        ad.age_now,
        -- age_now_bin
        CASE  
            WHEN ad.age_now < 0 THEN 'bad_age'
            WHEN ad.age_now >= 0 AND ad.age_now < 10 THEN '0-9'
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
        -- age_as_sale_bin
        -- sd.age_as_of_sale_date,
        -- CASE 
        --     WHEN sd.age_as_of_sale_date < 0 THEN 'bad_age'
        --     WHEN sd.age_as_of_sale_date >= 0 AND sd.age_as_of_sale_date < 10 THEN '0-9'
        --     WHEN sd.age_as_of_sale_date < 20 THEN '10-19'
        --     WHEN sd.age_as_of_sale_date < 30 THEN '20-29'
        --     WHEN sd.age_as_of_sale_date < 40 THEN '30-39'
        --     WHEN sd.age_as_of_sale_date < 50 THEN '40-49'
        --     WHEN sd.age_as_of_sale_date < 60 THEN '50-59'
        --     WHEN sd.age_as_of_sale_date < 70 THEN '60-69'
        --     WHEN sd.age_as_of_sale_date < 80 THEN '70-79'
        --     WHEN sd.age_as_of_sale_date < 90 THEN '80-89'
        --     WHEN sd.age_as_of_sale_date < 100 THEN '90-99'
        --     WHEN sd.age_as_of_sale_date >= 100 THEN 'bad_age'
        --     ELSE 'bad_age'
        -- END AS age_as_sale_bin, -- create bin for date of birth as of sale date
       
        -- membership periods, types, category
        am.id_membership_periods_sa, 
        am.real_membership_types_sa, 
        am.new_member_category_6_sa,   
        
        -- purchase on dates
        am.purchased_on_mp,
        am.purchased_on_year_mp,       
        am.purchased_on_month_mp,       
        am.purchased_on_quarter_mp,  

        -- adjust purchase on dates
        am.purchased_on_adjusted_mp,
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
            ELSE 'error_member_created_at_category'
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

        -- event detais
        id_events,
        event_type_id_events,
        name_events,
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
        LEFT JOIN member_minimum_first_created_at_dates AS fd
        ON am.member_number_members_sa = fd.member_number_members_sa
        
        LEFT JOIN member_min_created_at_date AS mc
        ON am.member_number_members_sa = mc.member_number_members_sa
        
        LEFT JOIN member_age_dimensions AS ad
        ON am.member_number_members_sa = ad.member_number_members_sa
        
        -- LEFT JOIN member_age_at_sale_date AS sd
        -- ON am.id_membership_periods_sa = sd.id_membership_periods_sa

        LEFT JOIN member_total_life_time_purchases AS lp
        ON am.member_number_members_sa = lp.member_number_members_sa
        
        LEFT JOIN membership_period_stats AS st
        ON am.id_membership_periods_sa = st.id_membership_periods_sa
    
    WHERE am.member_number_members_sa IN ('10000106', '10000108', '100063152')
    ;