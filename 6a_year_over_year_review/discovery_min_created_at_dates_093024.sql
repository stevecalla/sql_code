USE usat_sales_db;

SELECT
    member_number_members_sa,
    id_membership_periods_sa,
    total_purchases,
    new_member_category_6_sa,
    
    -- Key dates
    created_at_members,
	created_at_mp,
	created_at_profiles,
	created_at_users,
    
    -- Key dates
    first_created_at_members,
    first_created_at_mp,
    first_created_at_profiles,
    first_created_at_users,
    first_purchased_on_mp,
    first_purchased_on_adjusted_mp,
    first_starts_mp,
    starts_mp,
    
	CASE   
        WHEN starts_mp < DATE_FORMAT(purchased_on_mp, '%Y-%m-%d') THEN starts_mp
        ELSE purchased_on_mp
    END AS test,

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
    END AS min_created_at_source

FROM sales_key_stats_2015
LIMIT 100;
