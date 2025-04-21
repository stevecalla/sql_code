USE usat_sales_db; 
-- *************************************
-- EXCEL SHEET COUNT BY RACE YEAR WITH PARTICIPANT RACE COUNTS
-- *************************************
SELECT 
    a.start_date_year_races AS race_year,
    a.name_event_type,
    a.real_membership_types_sa,
    FORMAT(COUNT(CASE WHEN a.id_race_rr IS NULL THEN 1 END), 0) AS count_null_race_id,
    FORMAT(COUNT(CASE WHEN a.id_profile_rr IS NULL THEN 1 END), 0) AS count_null_profile_id,
    FORMAT(COUNT(CASE WHEN a.id_profile_rr IS NOT NULL THEN 1 END), 0) AS count_not_null_profile_id,
    
    -- TOTAL COUNT
    FORMAT(COUNT(*), 0) AS total_count,
    
    -- DISTINCT COUNTS = EVENTS, RACES, PROFILES
    FORMAT(COUNT(DISTINCT a.id_sanctioning_events), 0) AS distinct_event_count,
    FORMAT(COUNT(DISTINCT a.id_race_rr), 0) AS distinct_race_count,
    FORMAT(COUNT(DISTINCT a.id_profile_rr), 0) AS distinct_profile_count,
    
    -- PER EVENT COUNTS 
    FORMAT(COUNT(DISTINCT a.id_profile_rr) / COUNT(DISTINCT a.id_sanctioning_events), 0) AS participants_per_event_distinct,
    FORMAT(COUNT(*) / COUNT(DISTINCT a.id_sanctioning_events), 0) AS participants_per_event_total,
    
    -- PER RACE COUNTS
    FORMAT(COUNT(DISTINCT a.id_profile_rr) / COUNT(DISTINCT a.id_race_rr), 0) AS participants_per_race_distinct,
    FORMAT(COUNT(*) / COUNT(DISTINCT a.id_race_rr), 0) AS participants_per_race_total,
    
    -- AVERAGE RACES PER PARTICIPANT (using all results vs. distinct participants)
    FORMAT(COUNT(a.id_profile_rr) / COUNT(DISTINCT a.id_profile_rr), 2) AS avg_races_per_distinct_profile,
    COUNT(a.id_profile_rr) / COUNT(DISTINCT a.id_profile_rr) AS avg_races_per_all_results,
    
    -- COUNT OF PARTICIPANTS BY NUMBER OF RACES IN THE RACE YEAR:
    (
      SELECT 
        SUM(CASE WHEN x.race_count = 1 THEN 1 ELSE 0 END)
      FROM (
          SELECT id_profile_rr, COUNT(DISTINCT id_race_rr) AS race_count
          FROM all_participation_data_with_membership_match
          WHERE start_date_year_races = a.start_date_year_races
            AND name_event_type = a.name_event_type
            AND real_membership_types_sa = a.real_membership_types_sa
          GROUP BY id_profile_rr
      ) AS x
    ) AS count_1_race,
    
    (
      SELECT 
        SUM(CASE WHEN x.race_count = 2 THEN 1 ELSE 0 END)
      FROM (
          SELECT id_profile_rr, COUNT(DISTINCT id_race_rr) AS race_count
          FROM all_participation_data_with_membership_match
          WHERE start_date_year_races = a.start_date_year_races
            AND name_event_type = a.name_event_type
            AND real_membership_types_sa = a.real_membership_types_sa
          GROUP BY id_profile_rr
      ) AS x
    ) AS count_2_races,
    
    (
      SELECT 
        SUM(CASE WHEN x.race_count = 3 THEN 1 ELSE 0 END)
      FROM (
          SELECT id_profile_rr, COUNT(DISTINCT id_race_rr) AS race_count
          FROM all_participation_data_with_membership_match
          WHERE start_date_year_races = a.start_date_year_races
            AND name_event_type = a.name_event_type
            AND real_membership_types_sa = a.real_membership_types_sa
          GROUP BY id_profile_rr
      ) AS x
    ) AS count_3_races,
    
    (
      SELECT 
        SUM(CASE WHEN x.race_count >= 4 THEN 1 ELSE 0 END)
      FROM (
          SELECT id_profile_rr, COUNT(DISTINCT id_race_rr) AS race_count
          FROM all_participation_data_with_membership_match
          WHERE start_date_year_races = a.start_date_year_races
            AND name_event_type = a.name_event_type
            AND real_membership_types_sa = a.real_membership_types_sa
          GROUP BY id_profile_rr
      ) AS x
    ) AS count_4_or_more_races
    
FROM all_participation_data_with_membership_match a
WHERE a.name_event_type = 'Adult Event'
GROUP BY a.start_date_year_races, a.name_event_type, a.real_membership_types_sa
ORDER BY a.start_date_year_races ASC, a.name_event_type, a.real_membership_types_sa;
