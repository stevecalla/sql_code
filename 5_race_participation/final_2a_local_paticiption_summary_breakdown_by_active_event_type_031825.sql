-- BREAKDOWN BY EVENT & TYPE
-- This query aggregates participation data from the all_participation_data_with_membership_match table.
-- It calculates, for each combination of race year, membership status, event type, and membership type:
--   1. The number of races each participant ran (participant_counts).
--   2. Bucketed counts of participants based on their race count (participant_race_summary).
--   3. Overall distinct counts and ratios for each group (race_year_summary).
-- Finally, the query joins these summaries to output detailed aggregated metrics.

USE usat_sales_db;

-- ***********************************************************************
-- CTE: participant_counts
-- For each participant (id_profile_rr) within each group defined by:
--   - Race year (start_date_year_races)
--   - Active membership status (is_active_membership)
--   - Event type (name_event_type)
--   - Membership type (real_membership_types_sa)
-- This CTE calculates the number of distinct races (id_race_rr) the participant has run.
-- ***********************************************************************
WITH participant_counts AS (
    SELECT 
        start_date_year_races,                -- Race year of the event
        is_active_membership,                 -- Active membership flag (e.g., 'Yes' or 'No')
        name_event_type,                      -- Type of event (e.g., 'Adult Event')
        real_membership_types_sa,             -- Membership type (e.g., 'annual', 'one-day')
        id_profile_rr,                        -- Participant ID
        COUNT(DISTINCT id_race_rr) AS race_count  -- Number of distinct races the participant has run
    FROM all_participation_data_with_membership_match
    WHERE 1 = 1
        -- Optional filters can be applied here:
        -- AND start_date_year_races >= 2010
        -- AND name_event_type = 'Adult Event'
        -- AND id_profile_rr = 42
    GROUP BY start_date_year_races, is_active_membership, name_event_type, real_membership_types_sa, id_profile_rr
),

-- ***********************************************************************
-- CTE: participant_race_summary
-- This CTE aggregates the participant_counts into buckets based on race_count:
--   - count_1_race: Number of participants who ran exactly 1 race.
--   - count_2_races: Number of participants who ran exactly 2 races.
--   - count_3_races: Number of participants who ran exactly 3 races.
--   - count_4_or_more_races: Number of participants who ran 4 or more races.
-- The aggregation is performed for each group.
-- ***********************************************************************
participant_race_summary AS (
    SELECT 
        start_date_year_races,                -- Race year
        is_active_membership,                 -- Active membership status
        name_event_type,                      -- Event type
        real_membership_types_sa,             -- Membership type
        SUM(CASE WHEN race_count = 1 THEN 1 ELSE 0 END) AS count_1_race,
        SUM(CASE WHEN race_count = 2 THEN 1 ELSE 0 END) AS count_2_races,
        SUM(CASE WHEN race_count = 3 THEN 1 ELSE 0 END) AS count_3_races,
        SUM(CASE WHEN race_count >= 4 THEN 1 ELSE 0 END) AS count_4_or_more_races
    FROM participant_counts
    GROUP BY start_date_year_races, is_active_membership, name_event_type, real_membership_types_sa
),

-- ***********************************************************************
-- CTE: race_year_summary
-- This CTE aggregates various overall statistics for each group:
--   - It calculates counts of records with NULL or non-NULL race and profile IDs.
--   - It computes distinct counts for events, races, and participants.
--   - It also counts the total number of race entries.
-- These aggregated metrics are grouped by race year, membership status, event type, and membership type.
-- ***********************************************************************
race_year_summary AS (
    SELECT 
        start_date_year_races AS race_year,   -- Rename for clarity
        is_active_membership,
        name_event_type,
        real_membership_types_sa,
        SUM(CASE WHEN id_race_rr IS NULL THEN 1 ELSE 0 END) AS count_null_race_id,
        SUM(CASE WHEN id_profile_rr IS NULL THEN 1 ELSE 0 END) AS count_null_profile_id,
        SUM(CASE WHEN id_profile_rr IS NOT NULL THEN 1 ELSE 0 END) AS count_not_null_profile_id,
        COUNT(*) AS total_count,               -- Total records for the group
        COUNT(DISTINCT id_sanctioning_events) AS distinct_event_count,
        COUNT(DISTINCT id_race_rr) AS distinct_race_count,
        COUNT(DISTINCT id_profile_rr) AS distinct_profile_count,
        COUNT(id_profile_rr) AS total_race_entries  -- Total race entries (may include duplicates)
    FROM all_participation_data_with_membership_match
    WHERE 
        start_date_year_races >= 2010        -- Filter: Consider races from 2010 onward
        -- Optional filter:
        -- AND name_event_type = 'Adult Event'
    GROUP BY start_date_year_races, is_active_membership, name_event_type, real_membership_types_sa
)

-- ***********************************************************************
-- Final SELECT: Detailed Aggregated Metrics by Event & Type
-- This query joins race_year_summary with participant_race_summary to provide:
--   - Aggregated counts (nulls, distinct counts)
--   - Ratios for participants per event and per race (with division-by-zero protection)
--   - Average races per participant metrics.
--   - Counts of participants based on their race count buckets.
-- The results are ordered by race year, event type, and membership type.
-- ***********************************************************************
SELECT 
    r.race_year,
    r.is_active_membership,
    r.name_event_type,
    r.real_membership_types_sa,
    
    -- Aggregated counts (formatted with thousand separators)
    FORMAT(r.count_null_race_id, 0) AS count_null_race_id,
    FORMAT(r.count_null_profile_id, 0) AS count_null_profile_id,
    FORMAT(r.count_not_null_profile_id, 0) AS count_not_null_profile_id,
    FORMAT(r.total_count, 0) AS total_count,
    FORMAT(r.distinct_event_count, 0) AS distinct_event_count,
    FORMAT(r.distinct_race_count, 0) AS distinct_race_count,
    FORMAT(r.distinct_profile_count, 0) AS distinct_profile_count,
    
    -- Ratios calculated using NULLIF to avoid division by zero:
    FORMAT(r.distinct_profile_count / NULLIF(r.distinct_event_count, 0), 0) AS participants_per_event_distinct,
    FORMAT(r.total_count / NULLIF(r.distinct_event_count, 0), 0) AS participants_per_event_total,
    FORMAT(r.distinct_profile_count / NULLIF(r.distinct_race_count, 0), 0) AS participants_per_race_distinct,
    FORMAT(r.total_count / NULLIF(r.distinct_race_count, 0), 0) AS participants_per_race_total,
    
    -- Average races per participant (formatted to two decimal places)
    FORMAT(r.total_race_entries / NULLIF(r.distinct_profile_count, 0), 2) AS avg_races_per_distinct_profile,
    FORMAT(r.total_count / NULLIF(r.distinct_profile_count, 0), 2) AS avg_races_per_all_results,
    
    -- Bucket counts: Number of participants who ran 1, 2, 3, or 4+ races
    FORMAT(pr.count_1_race, 0) AS count_1_races,
    FORMAT(pr.count_2_races, 0) AS count_2_races,
    FORMAT(pr.count_3_races, 0) AS count_3_races,
    FORMAT(pr.count_4_or_more_races, 0) AS count_4_or_more_races

FROM race_year_summary r
LEFT JOIN participant_race_summary pr
  ON r.race_year = pr.start_date_year_races
 AND r.is_active_membership = pr.is_active_membership
 AND r.name_event_type = pr.name_event_type
 AND r.real_membership_types_sa = pr.real_membership_types_sa
ORDER BY r.race_year, r.name_event_type, r.real_membership_types_sa;
