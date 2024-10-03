USE usat_sales_db;

DROP TABLE IF EXISTS sales_member_summary_2015;

CREATE TABLE sales_member_summary_2015 AS
SELECT 
        member_number_members_sa,  -- Unique member number from original data
        id_membership_periods_sa,  -- Membership period ID from original data
        real_membership_types_sa,   -- Type of membership from original data
        new_member_category_6_sa,    -- Category of new members from original data
        
        purchased_on_mp,             -- Exact date of purchase from original data
        purchased_on_adjusted_mp,
        starts_mp,
        ends_mp,
        
        purchased_on_year_mp,       -- Year of purchase from original data
        purchased_on_month_mp,       -- Month of purchase from original data
        purchased_on_quarter_mp,    -- Quarter of purchase from original data
        
        purchased_on_year_adjusted_mp,
        purchased_on_quarter_adjusted_mp,
        purchased_on_month_adjusted_mp,

        -- Key dates
        created_at_members,
        created_at_mp,
        created_at_profiles,
        created_at_users,

        -- Calculate the first purchase date for each member using a window function
        MIN(purchased_on_mp) OVER (PARTITION BY member_number_members_sa) AS first_purchased_on_mp,
        MIN(purchased_on_adjusted_mp) OVER (PARTITION BY member_number_members_sa) AS first_purchased_on_adjusted_mp,
        MIN(created_at_members) OVER (PARTITION BY member_number_members_sa) AS first_created_at_members,
        MIN(created_at_mp) OVER (PARTITION BY member_number_members_sa) AS first_created_at_mp,
        MIN(created_at_profiles) OVER (PARTITION BY member_number_members_sa) AS first_created_at_profiles,
        MIN(created_at_users) OVER (PARTITION BY member_number_members_sa) AS first_created_at_users,
        MIN(starts_mp) OVER (PARTITION BY member_number_members_sa) AS first_starts_mp,

        actual_membership_fee_6_sa,  -- Membership fee from original data
        
        -- First occurrence of any purchase for each member
        ROW_NUMBER() OVER (
            PARTITION BY member_number_members_sa 
            ORDER BY purchased_on_mp
        ) AS first_occurrence_any_purchase,
        
        -- First purchase by year for each member
        ROW_NUMBER() OVER (
            PARTITION BY member_number_members_sa, purchased_on_year_mp
            ORDER BY purchased_on_mp
        ) AS first_purchase_by_year,
        
        -- First purchase by year by month for each member
        ROW_NUMBER() OVER (
            PARTITION BY member_number_members_sa, purchased_on_year_mp, purchased_on_month_mp 
            ORDER BY purchased_on_mp
        ) AS first_purchase_by_year_month,

        COUNT(*) OVER (PARTITION BY member_number_members_sa) AS total_purchases  -- Total purchases for each member

    FROM all_membership_sales_data_2015_left -- Source table containing membership sales data
-- LIMIT 1
;

-- DROP TABLE IF EXISTS sales_key_stats_2015_v2;
DROP TABLE IF EXISTS sales_key_stats_2015;

-- CREATE TABLE sales_key_stats_2015_v2 AS
CREATE TABLE sales_key_stats_2015 AS
SELECT
    member_number_members_sa,
    id_membership_periods_sa,
    real_membership_types_sa,
    new_member_category_6_sa,
    
    purchased_on_mp,
    purchased_on_adjusted_mp,
    starts_mp,
    ends_mp,
    
    purchased_on_year_mp,
    purchased_on_quarter_mp,
    purchased_on_month_mp,
    
    purchased_on_year_adjusted_mp,
    purchased_on_quarter_adjusted_mp,
    purchased_on_month_adjusted_mp,
    
    YEAR(starts_mp) AS starts_year_mp,
    QUARTER(starts_mp) AS starts_quarter_mp,
    MONTH(starts_mp) AS starts_month_mp,
    YEAR(ends_mp) AS ends_year_mp,
    QUARTER(ends_mp) AS ends_quarter_mp,
    MONTH(ends_mp) AS ends_month_mp,

    -- Key dates
    created_at_members,
    created_at_mp,
    created_at_profiles,
    created_at_users,

    first_created_at_members,
    first_created_at_mp,
    first_created_at_profiles,
    first_created_at_users,
    first_purchased_on_mp,
    first_purchased_on_adjusted_mp,
    first_starts_mp,

    total_purchases,

    CASE   
        WHEN starts_mp < DATE_FORMAT(purchased_on_mp, '%Y-%m-%d') THEN starts_mp
        ELSE purchased_on_mp
    END AS start_mp_purchase_mp_adjusted_check,

    -- Calculate the minimum date from the first created at fields, considering nulls
    LEAST(
        COALESCE(first_created_at_members, '9999-12-31'),
        COALESCE(first_created_at_mp, '9999-12-31'),
        COALESCE(first_created_at_profiles, '9999-12-31'),
        COALESCE(first_created_at_users, '9999-12-31'),
        COALESCE(first_purchased_on_mp, '9999-12-31'),
        COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
        COALESCE(first_starts_mp, '9999-12-31')
    ) AS min_created_at,

    -- Extract month, quarter, and year from the minimum created date
    EXTRACT(MONTH FROM LEAST(
        COALESCE(first_created_at_members, '9999-12-31'),
        COALESCE(first_created_at_mp, '9999-12-31'),
        COALESCE(first_created_at_profiles, '9999-12-31'),
        COALESCE(first_created_at_users, '9999-12-31'),
        COALESCE(first_purchased_on_mp, '9999-12-31'),
        COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
        COALESCE(first_starts_mp, '9999-12-31')
    )) AS min_created_at_month,

    EXTRACT(QUARTER FROM LEAST(
        COALESCE(first_created_at_members, '9999-12-31'),
        COALESCE(first_created_at_mp, '9999-12-31'),
        COALESCE(first_created_at_profiles, '9999-12-31'),
        COALESCE(first_created_at_users, '9999-12-31'),
        COALESCE(first_purchased_on_mp, '9999-12-31'),
        COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
        COALESCE(first_starts_mp, '9999-12-31')
    )) AS min_created_at_quarter,

    EXTRACT(YEAR FROM LEAST(
        COALESCE(first_created_at_members, '9999-12-31'),
        COALESCE(first_created_at_mp, '9999-12-31'),
        COALESCE(first_created_at_profiles, '9999-12-31'),
        COALESCE(first_created_at_users, '9999-12-31'),
        COALESCE(first_purchased_on_mp, '9999-12-31'),
        COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
        COALESCE(first_starts_mp, '9999-12-31')
    )) AS min_created_at_year,

    -- Determine which date field contains the minimum date
        CASE 
            WHEN first_created_at_members = LEAST(
                COALESCE(first_created_at_members, '9999-12-31'),
                COALESCE(first_created_at_mp, '9999-12-31'),
                COALESCE(first_created_at_profiles, '9999-12-31'),
                COALESCE(first_created_at_users, '9999-12-31'),
                COALESCE(first_purchased_on_mp, '9999-12-31'),
                COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
                COALESCE(first_starts_mp, '9999-12-31')
            ) THEN 'first_created_at_members'
            WHEN first_created_at_mp = LEAST(
                COALESCE(first_created_at_members, '9999-12-31'),
                COALESCE(first_created_at_mp, '9999-12-31'),
                COALESCE(first_created_at_profiles, '9999-12-31'),
                COALESCE(first_created_at_users, '9999-12-31'),
                COALESCE(first_purchased_on_mp, '9999-12-31'),
                COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
                COALESCE(first_starts_mp, '9999-12-31')
            ) THEN 'first_created_at_mp'
            WHEN first_created_at_profiles = LEAST(
                COALESCE(first_created_at_members, '9999-12-31'),
                COALESCE(first_created_at_mp, '9999-12-31'),
                COALESCE(first_created_at_profiles, '9999-12-31'),
                COALESCE(first_created_at_users, '9999-12-31'),
                COALESCE(first_purchased_on_mp, '9999-12-31'),
                COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
                COALESCE(first_starts_mp, '9999-12-31')
            ) THEN 'first_created_at_profiles'
            WHEN first_created_at_users = LEAST(
                COALESCE(first_created_at_members, '9999-12-31'),
                COALESCE(first_created_at_mp, '9999-12-31'),
                COALESCE(first_created_at_profiles, '9999-12-31'),
                COALESCE(first_created_at_users, '9999-12-31'),
                COALESCE(first_purchased_on_mp, '9999-12-31'),
                COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
                COALESCE(first_starts_mp, '9999-12-31')
            ) THEN 'first_created_at_users'
            WHEN first_purchased_on_mp = LEAST(
                COALESCE(first_created_at_members, '9999-12-31'),
                COALESCE(first_created_at_mp, '9999-12-31'),
                COALESCE(first_created_at_profiles, '9999-12-31'),
                COALESCE(first_created_at_users, '9999-12-31'),
                COALESCE(first_purchased_on_mp, '9999-12-31'),
                COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
                COALESCE(first_starts_mp, '9999-12-31')
            ) THEN 'first_purchased_on_mp'
            WHEN first_purchased_on_adjusted_mp = LEAST(
                COALESCE(first_created_at_members, '9999-12-31'),
                COALESCE(first_created_at_mp, '9999-12-31'),
                COALESCE(first_created_at_profiles, '9999-12-31'),
                COALESCE(first_created_at_users, '9999-12-31'),
                COALESCE(first_purchased_on_mp, '9999-12-31'),
                COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
                COALESCE(first_starts_mp, '9999-12-31')
            ) THEN 'first_purchased_on_adjusted_mp'
            WHEN first_starts_mp = LEAST(
                COALESCE(first_created_at_members, '9999-12-31'),
                COALESCE(first_created_at_mp, '9999-12-31'),
                COALESCE(first_created_at_profiles, '9999-12-31'),
                COALESCE(first_created_at_users, '9999-12-31'),
                COALESCE(first_purchased_on_mp, '9999-12-31'),
                COALESCE(first_purchased_on_adjusted_mp, '9999-12-31'),
                COALESCE(first_starts_mp, '9999-12-31')
            ) THEN 'first_starts_mp'
            ELSE 'No valid date'
        END AS min_created_at_source,
    -- **************************************************

    SUM(CASE WHEN first_occurrence_any_purchase = 1 THEN 1 ELSE 0 END) AS first_occurrence_any_purchase,
    SUM(CASE WHEN first_purchase_by_year = 1 THEN 1 ELSE 0 END) AS first_purchase_by_year,
    SUM(CASE WHEN first_purchase_by_year_month = 1 THEN 1 ELSE 0 END) AS first_purchase_by_year_month,

    COUNT(id_membership_periods_sa) AS sales_units,
    SUM(actual_membership_fee_6_sa) AS sales_revenue,

    -- CREATE MEMBER FREQUENCY
    CASE 
        WHEN total_purchases = 1 THEN 'one_purchase'
        ELSE 'more_than_one_purchase'
    END AS member_frequency,
    -- ********************************************

    DATE_FORMAT(DATE_ADD(NOW(), INTERVAL -6 HOUR), '%Y-%m-%d') AS created_at_mtn,
    DATE_FORMAT(NOW(), '%Y-%m-%d') AS created_at_utc

FROM sales_member_summary_2015

GROUP BY 
    member_number_members_sa,
    id_membership_periods_sa,
    real_membership_types_sa,
    new_member_category_6_sa,
    purchased_on_mp,
    purchased_on_adjusted_mp,
    starts_mp,
    ends_mp,
    purchased_on_year_mp,
    purchased_on_quarter_mp,
    purchased_on_month_mp,
    purchased_on_year_adjusted_mp,
    purchased_on_quarter_adjusted_mp,
    purchased_on_month_adjusted_mp,
    created_at_members,
    created_at_mp,
    created_at_profiles,
    created_at_users,
    first_created_at_members,
    first_created_at_mp,
    first_created_at_profiles,
    first_created_at_users,
    first_purchased_on_mp,
    first_purchased_on_adjusted_mp,
    first_starts_mp,
    total_purchases

ORDER BY 
    member_number_members_sa,
    id_membership_periods_sa,
    real_membership_types_sa,
    new_member_category_6_sa,
    purchased_on_mp,
    purchased_on_adjusted_mp,
    starts_mp,
    ends_mp,
    purchased_on_year_mp,
    purchased_on_quarter_mp,
    purchased_on_month_mp
-- LIMIT 1
;