USE usat_sales_db;

-- ***********************************************************************
-- CTE: overall_summary
-- Aggregates overall metrics for each race year and event type for "Adult Event"
-- records from 2010 onward. Metrics include counts of NULL/non-NULL IDs,
-- total record count, distinct counts for events, races, profiles, and total
-- race entries.
-- ***********************************************************************
WITH overall_summary AS (
    SELECT 
        start_date_year_races AS race_year,
        name_event_type,
        SUM(CASE WHEN id_race_rr IS NULL THEN 1 ELSE 0 END) AS count_null_race_id,
        SUM(CASE WHEN id_profile_rr IS NULL THEN 1 ELSE 0 END) AS count_null_profile_id,
        SUM(CASE WHEN id_profile_rr IS NOT NULL THEN 1 ELSE 0 END) AS count_not_null_profile_id,
        COUNT(*) AS total_count,
        COUNT(DISTINCT id_sanctioning_events) AS distinct_event_count,
        COUNT(DISTINCT id_race_rr) AS distinct_race_count,
        COUNT(DISTINCT id_profile_rr) AS distinct_profile_count,
        COUNT(id_profile_rr) AS total_race_entries
    FROM all_participation_data_with_membership_match
    WHERE 1 = 1
        -- AND start_date_year_races >= 2010
        -- AND id_profile_rr = 42
        AND id_profile_rr = 1000906
        -- AND name_event_type = 'Adult Event'
    GROUP BY start_date_year_races, name_event_type
),

-- ***********************************************************************
-- CTE: profile_race_counts
-- For each profile (id_profile_rr) in each race year and event type, count the
-- number of distinct races (id_race_rr) they participated in.
-- ***********************************************************************
profile_race_counts AS (
    SELECT 
        start_date_year_races AS race_year,
        name_event_type,
        id_profile_rr,
        COUNT(DISTINCT id_race_rr) AS race_count
    FROM all_participation_data_with_membership_match
    WHERE 
        start_date_year_races >= 2010
        -- AND name_event_type = 'Adult Event'
    GROUP BY start_date_year_races, name_event_type, id_profile_rr
),

-- ***********************************************************************
-- CTE: profile_buckets
-- Aggregates the profile_race_counts into buckets:
--   - profiles_with_1_race: profiles with exactly 1 race,
--   - profiles_with_2_races: profiles with exactly 2 races,
--   - profiles_with_3_races: profiles with exactly 3 races,
--   - profiles_with_4_or_more_races: profiles with 4 or more races.
-- The aggregation is done per race year and event type.
-- ***********************************************************************
profile_buckets AS (
    SELECT 
        race_year,
        name_event_type,
        SUM(CASE WHEN race_count = 1 THEN 1 ELSE 0 END) AS profiles_with_1_race,
        SUM(CASE WHEN race_count = 2 THEN 1 ELSE 0 END) AS profiles_with_2_races,
        SUM(CASE WHEN race_count = 3 THEN 1 ELSE 0 END) AS profiles_with_3_races,
        SUM(CASE WHEN race_count >= 4 THEN 1 ELSE 0 END) AS profiles_with_4_or_more_races
    FROM profile_race_counts
    GROUP BY race_year, name_event_type
)

-- ***********************************************************************
-- Final SELECT: Join Overall Summary with Profile Bucket Counts
-- Joins the overall aggregated metrics with the bucket counts on race_year and
-- name_event_type. The final output displays overall metrics, calculated ratios,
-- and the count of profiles in each race bucket.
-- ***********************************************************************
SELECT 
    o.race_year,
    o.name_event_type,
    
    -- Overall counts and distinct counts, formatted:
    FORMAT(o.count_null_race_id, 0) AS count_null_race_id,
    FORMAT(o.count_null_profile_id, 0) AS count_null_profile_id,
    FORMAT(o.count_not_null_profile_id, 0) AS count_not_null_profile_id,
    FORMAT(o.total_count, 0) AS total_count,
    FORMAT(o.distinct_event_count, 0) AS distinct_event_count,
    FORMAT(o.distinct_race_count, 0) AS distinct_race_count,
    FORMAT(o.distinct_profile_count, 0) AS distinct_profile_count,
    FORMAT(o.total_race_entries, 0) AS total_race_entries,
    
    -- Ratios computed using NULLIF to avoid division by zero:
    FORMAT(o.distinct_profile_count / NULLIF(o.distinct_event_count, 0), 0) AS participants_per_event_distinct,
    FORMAT(o.total_count / NULLIF(o.distinct_event_count, 0), 0) AS participants_per_event_total,
    FORMAT(o.distinct_profile_count / NULLIF(o.distinct_race_count, 0), 0) AS participants_per_race_distinct,
    FORMAT(o.total_count / NULLIF(o.distinct_race_count, 0), 0) AS participants_per_race_total,
    
    -- Average races per distinct participant:
    FORMAT(o.total_race_entries / NULLIF(o.distinct_profile_count, 0), 2) AS avg_races_per_distinct_profile,
    FORMAT(o.total_count / NULLIF(o.distinct_profile_count, 0), 2) AS avg_races_per_all_results,
    
    -- Profile bucket counts, formatted:
    FORMAT(pb.profiles_with_1_race, 0) AS profiles_with_1_race,
    FORMAT(pb.profiles_with_2_races, 0) AS profiles_with_2_races,
    FORMAT(pb.profiles_with_3_races, 0) AS profiles_with_3_races,
    FORMAT(pb.profiles_with_4_or_more_races, 0) AS profiles_with_4_or_more_races
FROM overall_summary o
LEFT JOIN profile_buckets pb
  ON o.race_year = pb.race_year
  AND o.name_event_type = pb.name_event_type
ORDER BY o.name_event_type, o.race_year;
