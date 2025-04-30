USE usat_sales_db; 
-- *************************************
-- EXCEL SHEET COUNT BY RACE YEAR
-- *************************************
SELECT 
    start_date_year_races AS race_year,
    name_event_type,
    real_membership_types_sa,
    FORMAT(COUNT(CASE WHEN id_race_rr IS NULL THEN 1 END), 0) AS count_null_race_id,
    FORMAT(COUNT(CASE WHEN id_profile_rr IS NULL THEN 1 END), 0) AS count_null_profile_id,
    FORMAT(COUNT(CASE WHEN id_profile_rr IS NOT NULL THEN 1 END), 0) AS count_not_null_profile_id,
    
    -- TOTAL COUNT
    FORMAT(COUNT(*), 0) AS total_count,
    
    -- DISTINCT COUNTS = EVENTS, RACES, PROFILES
    FORMAT(COUNT(DISTINCT id_sanctioning_events), 0) AS distinct_event_count,
    FORMAT(COUNT(DISTINCT id_race_rr), 0) AS distinct_race_count,
    FORMAT(COUNT(DISTINCT id_profile_rr), 0) AS distinct_profile_count,
    
    -- PER EVENT COUNTS = 
    FORMAT(COUNT(DISTINCT id_profile_rr) / COUNT(DISTINCT id_sanctioning_events), 0) AS participants_per_event_distinct,
    FORMAT(COUNT(*) / COUNT(DISTINCT id_sanctioning_events), 0) AS participants_per_event_total,
    
    -- PER RACE COUNTS
    FORMAT(COUNT(DISTINCT id_profile_rr) / COUNT(DISTINCT id_race_rr), 0) AS participants_per_race_distinct,
    FORMAT(COUNT(*) / COUNT(DISTINCT id_race_rr), 0) AS participants_per_race_total,
    
    -- AVERAGE RACES PER PARTICIPANT
    FORMAT(COUNT(id_profile_rr) /  COUNT(DISTINCT id_profile_rr), 2) AS avg_races_per_distinct_profile, -- avg races per distinct participant
    FORMAT(COUNT(*) /  COUNT(DISTINCT id_profile_rr), 2) AS avg_races_per_all_results -- avg races per distinct participant
    
FROM all_participation_data_with_membership_match
-- WHERE start_date_year_races = 2010 
WHERE 1 = 1
	AND name_event_type = 'Adult Event'
    -- AND real_membership_types_sa = 'adult_annual' -- elite, one_day, other, youth_annual
GROUP BY start_date_year_races, name_event_type, real_membership_types_sa
ORDER BY start_date_year_races ASC, name_event_type, real_membership_types_sa
-- LIMIT 10
;