USE usat_sales_db;

WITH 
    -- Get 50 random member numbers
    -- random_members AS (
    --     SELECT DISTINCT member_number_members_sa
    --     FROM all_membership_sales_data_2015_left
    --     ORDER BY RAND()  -- Use RAND() for MySQL
    --     LIMIT 50
    -- ),

    -- get the minimum date for each created at field
    min_created_at_date_options AS (
        SELECT
            DISTINCT
            member_number_members_sa,

            MIN(created_at_members) AS min_created_at_members,
            MIN(created_at_mp) AS min_created_at_mp,
            MIN(created_at_profiles) AS min_created_at_profiles,
            MIN(created_at_users) AS min_created_at_users,
            MIN(purchased_on_adjusted_mp) AS min_purchased_on_adjusted_mp,
            MIN(starts_mp) AS min_starts_mp

            -- YEAR(MIN(purchased_on_adjusted_mp)) AS first_purchased_on_year_adjusted_mp,
            
        FROM all_membership_sales_data_2015_left
        -- WHERE member_number_members_sa IN (SELECT member_number_members_sa FROM random_members)
        GROUP BY member_number_members_sa
        -- LIMIT 10
    )

    -- SELECT * FROM min_created_at_date_options;

    -- determine the minimum date among the fields in the prior query
    , min_created_at_date AS (
        SELECT
            member_number_members_sa,

            -- Calculate the minimum date from the first created at fields, considering nulls
            LEAST(
                COALESCE(min_created_at_members, '9999-12-31'),
                COALESCE(min_created_at_mp, '9999-12-31'),
                COALESCE(min_created_at_profiles, '9999-12-31'),
                COALESCE(min_created_at_users, '9999-12-31'),
                COALESCE(min_purchased_on_adjusted_mp, '9999-12-31'),
                COALESCE(min_starts_mp, '9999-12-31')
            ) AS min_created_at

        FROM min_created_at_date_options
        GROUP BY member_number_members_sa
        -- LIMIT 10
    )

    -- SELECT * FROM min_created_at_date;

    -- determine the minimum date field source 
    , min_created_at_date_source AS (
        SELECT
            md.member_number_members_sa,

            mo.min_created_at_members,
            mo.min_created_at_mp,
            mo.min_created_at_profiles,
            mo.min_created_at_users,
            mo.min_purchased_on_adjusted_mp,
            mo.min_starts_mp,

            md.min_created_at,

        CASE           
            WHEN mo.min_created_at_members          = md.min_created_at THEN '1 - created_at_members'
            WHEN mo.min_created_at_mp               = md.min_created_at THEN '2 - created_at_mp'
            WHEN mo.min_created_at_profiles         = md.min_created_at THEN '3 - created_at_profiles'
            WHEN mo.min_created_at_users            = md.min_created_at THEN '4 - created_at_users'
            WHEN mo.min_purchased_on_adjusted_mp    = md.min_created_at THEN '5 - purchased_on_adjusted_mp'
            WHEN mo.min_starts_mp                   = md.min_created_at THEN '6 - starts_mp'
            ELSE '7 - error / unknown'
        END AS min_created_at_date_source_field

        FROM min_created_at_date as md
            LEFT JOIN min_created_at_date_options AS mo ON md.member_number_members_sa = mo.member_number_members_sa
        GROUP BY member_number_members_sa
        -- LIMIT 10
    )

    -- review final results
    -- SELECT * FROM min_created_at_date_source IMIT 50;

    -- why is starts_mp populated if purchase on adjusted is the lesser of purchase on or starts mp?
    -- answer... because starts on is a date field and purchase on is a datetime field
    -- in the example / sample reviewed starts on and purchase on adjusted were the same date
    -- SELECT 
    --     * 
    -- FROM min_created_at_date_source 
    -- WHERE min_created_at_date_source_field IN ('6 - starts_mp') 
    -- LIMIT 50;

    SELECT
        min_created_at_date_source_field,
        FORMAT(COUNT(*), 0) AS total_count

    FROM min_created_at_date_source
    GROUP BY min_created_at_date_source_field WITH ROLLUP
    ORDER BY 
        CASE 
            WHEN min_created_at_date_source_field IS NULL THEN 1  -- Push the rollup row to the end
            ELSE 0
        END,
        min_created_at_date_source_field
    -- LIMIT 10
    ;