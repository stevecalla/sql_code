USE usat_sales_db;

-- SELECT * FROM all_membership_sales_data_2015_left LIMIT 10;
-- SELECT * FROM all_membership_sales_data_2015_left WHERE id_profiles = 0 LIMIT 10;
-- SELECT DISTINCT(origin_flag_ma) FROM all_membership_sales_data_2015_left LIMIT 100;
-- SELECT DISTINCT(real_membership_types_sa) FROM all_membership_sales_data_2015_left LIMIT 100;
-- SELECT DISTINCT(new_member_category_6_sa) FROM all_membership_sales_data_2015_left LIMIT 100;

-- CREATE INDEX idx_profiles_membership_starts ON all_membership_sales_data_2015_left (id_profiles, id_membership_periods_sa, starts_mp);

-- Define variables for pagination
SET @profile_limit = 100;
SET @profile_offset = 0;  -- Change this to 100, 200, etc., for next batches
SET @id_profile_1 = 54;
SET @id_profile_2 = 57;
SET @id_profile_3 = 60;

-- GET PROFILES IDS TO USE IN THE NEXT QUERY; THIS ENSURES THE QUERY RETRIEVES ALL PROFILE ID HISTORY
WITH get_n_profiles_ids AS (
    SELECT DISTINCT 
        id_profiles, id_membership_periods_sa, starts_mp, ends_mp
    FROM all_membership_sales_data_2015_left
    WHERE 1 = 1
        AND id_profiles NOT IN (0) -- 0 is a bad / invalid profile id based on dates et al
        -- AND ends_mp >= DATE_FORMAT(NOW(), '%Y-01-01') -- current year dynamically without needing to manually change the date each year
        -- AND id_profiles IN (@id_profile_1, @id_profile_2, @id_profile_3)
        
        -- NODE JS
		-- AND ends_mp = ${ends_mp} -- todo:
        -- AND id_profiles IN (54, 57, 60) -- basic test examples
        -- AND id_profiles IN (2599832, 2737677) -- upgraded from / to examples
        -- AND id_profiles IN (2701138) -- multiple upgrades
        -- AND id_profiles IN (2738933) -- multiple upgrades
        AND id_profiles IN (2390634) -- multiple upgrades
        -- AND ends_mp >= '2025-01-01'
        
    ORDER BY id_profiles, starts_mp
    -- LIMIT 100 OFFSET 0  -- Paginating on distinct profile IDs, not raw rows.
)
, membership_upgrades AS (
    SELECT 
        upgraded_from_id_mp, 
        id_membership_periods_sa AS upgraded_to_id_mp
    FROM all_membership_sales_data_2015_left
		WHERE 1 = 1
			AND upgraded_from_id_mp IS NOT NULL
            -- NOTE: Needed to exclude these combinations b/c the upgrade_from_id was included incorrectly for these records (a ticket was submitted to DS 5/15/25 to correct)
			AND (id_profiles, id_membership_periods_sa) NOT IN (
				(2701138, 4767827),
				(2738933, 4631539),
                (2390634, 4882173) -- 5019736
			)
)
SELECT
    a.id_profiles,
    a.id_membership_periods_sa,
    
    a.real_membership_types_sa,
    a.new_member_category_6_sa,
    a.origin_flag_ma,
    
    a.created_at_mp AS created_at_mp,
    DATE_FORMAT(a.created_at_mp, '%Y-%m-%d') AS created_at_date_mp,
    MONTH(a.created_at_mp) AS created_at_mp_month,
    QUARTER(a.created_at_mp) AS created_at_mp_quarter,
    YEAR(a.created_at_mp) AS created_at_mp_year,

    a.updated_at_mp AS updated_at_mp,
    DATE_FORMAT(a.updated_at_mp, '%Y-%m-%d') AS updated_at_date_mp,
    MONTH(a.updated_at_mp) AS updated_at_mp_month,
    QUARTER(a.updated_at_mp) AS updated_at_mp_quarter,
    YEAR(a.updated_at_mp) AS updated_at_mp_year,

    a.purchased_on_date_mp,
    MONTH(a.purchased_on_date_mp) AS purchased_on_date_mp_month,
    QUARTER(a.purchased_on_date_mp) AS purchased_on_date_mp_quarter,
    YEAR(a.purchased_on_date_mp) AS purchased_on_date_mp_year,

    a.purchased_on_date_adjusted_mp,
    MONTH(a.purchased_on_date_adjusted_mp) AS purchased_on_date_adjusted_mp_month,
    QUARTER(a.purchased_on_date_adjusted_mp) AS purchased_on_date_adjusted_mp_quarter,
    YEAR(a.purchased_on_date_adjusted_mp) AS purchased_on_date_adjusted_mp_year,

    a.starts_mp,
    MONTH(a.starts_mp) AS starts_mp_month,
    QUARTER(a.starts_mp) AS starts_mp_quarter,
    YEAR(a.starts_mp) AS starts_mp_year,

    a.ends_mp,
    MONTH(a.ends_mp) AS ends_mp_month,
    QUARTER(a.ends_mp) AS ends_mp_quarter,
    YEAR(a.ends_mp) AS ends_mp_year,

    -- Standard difference (excludes the first partial month)
    TIMESTAMPDIFF(MONTH, a.starts_mp, a.ends_mp) AS months_mp_difference,

    -- Recursive months to allocate revenue -- todo: revise rules
    TIMESTAMPDIFF(MONTH, a.starts_mp, a.ends_mp) + 1 AS months_mp_allocated_custom,
    -- CASE 
    --     WHEN a.real_membership_types_sa = 'Adult Annual' THEN 12
    --     WHEN a.real_membership_types_sa = '1 Day' THEN 1
    --     ELSE TIMESTAMPDIFF(MONTH, a.starts_mp, a.ends_mp) + 1
    -- END AS total_months_recursive,

    -- Definition: This flag indicates that the current membership period (based on start and end dates) is exactly the same as the previous or next period for the same profile.
    CASE
        WHEN a.starts_mp = LAG(a.starts_mp) OVER (PARTITION BY a.id_profiles ORDER BY a.starts_mp) 
            AND a.ends_mp = LAG(a.ends_mp) OVER (PARTITION BY a.id_profiles ORDER BY a.starts_mp) 
        THEN 1 
        ELSE 0 
    END AS is_duplicate_previous_period,

    -- Definition: This flag indicates that the start date of the current membership period is on or before the end date of the previous or the next period for the same profile.
    CASE
        WHEN a.starts_mp <= LAG(a.ends_mp) OVER (PARTITION BY a.id_profiles ORDER BY a.starts_mp)
            OR a.starts_mp <= LEAD(a.ends_mp) OVER (PARTITION BY a.id_profiles ORDER BY a.starts_mp)
        THEN 1 ELSE 0
    END AS is_overlaps_previous_mp,

    -- Definition: Stacked membership is one where the start date of the current membership is within 30 days before or after the end date of the previous or the next membership.
    CASE
        WHEN ABS(DATEDIFF(a.starts_mp, LAG(a.ends_mp) OVER (PARTITION BY a.id_profiles ORDER BY a.starts_mp))) <= 30
            OR ABS(DATEDIFF(a.starts_mp, LEAD(a.ends_mp) OVER (PARTITION BY a.id_profiles ORDER BY a.starts_mp))) <= 30
        THEN 1 ELSE 0
    END AS is_stacked_previous_mp,

    DATEDIFF(
        a.starts_mp,
        LAG(a.ends_mp) OVER (PARTITION BY a.id_profiles ORDER BY a.starts_mp)
    ) AS days_between_previous_end_and_start,
    
    CASE WHEN a.actual_membership_fee_6_sa <= 0 THEN 1 ELSE 0 END AS is_sales_revenue_zero,
    CASE WHEN a.origin_flag_ma = "ADMIN_BULK_UPLOADER" THEN 1 ELSE 0 END AS is_bulk,

    CASE WHEN a.new_member_category_6_sa LIKE "%Youth Premier%" THEN 1 ELSE 0 END AS is_youth_premier,
    CASE WHEN a.new_member_category_6_sa = 'Lifetime' THEN 1 ELSE 0 END AS is_lifetime,

    a.upgraded_from_id_mp,
--     u.upgraded_to_id_mp,  -- Joined from CTE
--     CASE 
--         WHEN a.upgraded_from_id_mp IS NOT NULL THEN 1 
--         WHEN u.upgraded_to_id_mp IS NOT NULL THEN 1 
--         ELSE 0 
--     END AS has_upgrade_from_or_to_path,

    CASE 
        WHEN YEAR(a.created_at_mp) > YEAR(a.purchased_on_date_mp)
            OR (
                YEAR(a.created_at_mp) = YEAR(a.purchased_on_date_mp)
                AND MONTH(a.created_at_mp) > MONTH(a.purchased_on_date_mp)
            )
        THEN 1
        ELSE 0
    END AS has_created_at_gt_purchased_on,

    a.actual_membership_fee_6_rule_sa,
    a.actual_membership_fee_6_sa AS sales_revenue,
    1 AS sales_units,

    -- CREATED AT DATES
    DATE_FORMAT(CONVERT_TZ(UTC_TIMESTAMP(), 'UTC', 'America/Denver'), '%Y-%m-%d %H:%i:%s') AS created_at_mtn,
    DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d %H:%i:%s') AS created_at_utc

    -- for node/js
    -- '${created_at_mtn}' AS created_at_mtn,
    -- '${created_at_utc}' AS created_at_utc
    
FROM all_membership_sales_data_2015_left AS a
	-- LEFT JOIN membership_upgrades AS u ON u.upgraded_from_id_mp = a.id_membership_periods_sa
    
WHERE 1 = 1
    AND a.id_profiles IN (SELECT id_profiles FROM get_n_profiles_ids)
ORDER BY a.id_profiles, a.starts_mp
;