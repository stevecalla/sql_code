-- ======================================================
-- 1. Raw Participation Data
--    Extract raw columns from the source table with meaningful aliases.
-- ======================================================

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

WITH raw_participation_data AS (
    SELECT
        id_sanctioning_events,
        id_events_rr,
        id_race_rr,

        name_race_type,
        name_distance_types,
        name_event_type,
        name_events_rr,
        is_ironman,
        gender_code,
        category,

        region_name,
        zip_events,
        city_events,
        state_code_events,

        start_date_races,
        MONTH(start_date_races) AS starts_month_events,
        QUARTER(start_date_races) AS starts_quarter_events,
        start_date_year_races,

        SUM(sales_units),
        SUM(sales_revenue),

        -- count of new / repeat
        SUM(CASE WHEN member_created_at_category IN ('after_created_year') THEN 1 ELSE 0 END) AS count_is_repeat,
        SUM(CASE WHEN member_created_at_category IN ('created_year') THEN 1 ELSE 0 END) AS count_is_new,

        -- count for membership type = adult annual, one day, elite, youth
        SUM(CASE WHEN real_membership_types_sa IN ('adult_annual') THEN 1 ELSE 0 END) AS count_is_adult_annual,
        SUM(CASE WHEN real_membership_types_sa IN ('one_day') THEN 1 ELSE 0 END) AS count_is_one_day,
        SUM(CASE WHEN real_membership_types_sa IN ('elite') THEN 1 ELSE 0 END) AS count_is_elite,
        SUM(CASE WHEN real_membership_types_sa IN ('youth_annual') THEN 1 ELSE 0 END) AS count_is_youth_annual,

        -- count of active memberships / membership matches
        SUM(CASE WHEN is_active_membership = 1 THEN 1 ELSE 0 END) AS count_is_membership_match,
        SUM(CASE WHEN is_active_membership = 0 THEN 1 ELSE 0 END) AS count_is_not_membership_match,
    
        (SELECT COUNT(DISTINCT id_profile_rr)
        FROM all_participation_data_with_membership_match
        WHERE start_date_year_races = 2024 GROUP BY start_date_year_races) AS total_id_profile_distinct,
            
        COUNT(DISTINCT id_profile_rr) AS count_id_profile_distinct,
        COUNT(id_race_rr) AS count_all_participants,
        
        -- CREATED AT DATES
        @created_at_mtn AS created_at_mtn,
        @created_at_utc AS created_at_utc

    FROM all_participation_data_with_membership_match
    
    WHERE 1 = 1
        AND start_date_year_races = 2024
        -- AND id_events = 30129
        -- AND id_race_rr = '4246724'
        -- AND id_sanctioning_events = '308416'

    GROUP BY
        id_sanctioning_events,
        id_events_rr,
        id_race_rr,

        name_race_type,
        name_distance_types,
        name_event_type,
        name_events_rr,
        is_ironman,
        gender_code,
        category,

        region_name,
        zip_events,
        city_events,
        state_code_events,

        start_date_races,
        start_date_year_races

    -- LIMIT 100
)

SELECT * FROM raw_participation_data; -- LIMIT 10;
