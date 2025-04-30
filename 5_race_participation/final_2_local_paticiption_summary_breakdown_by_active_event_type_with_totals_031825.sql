USE usat_sales_db;

-- ***********************************************************************
-- CTE: participant_counts
-- For each participant (id_profile_rr) in each group (race year, active 
-- membership, event type, membership type), count the distinct races.
-- ***********************************************************************
WITH participant_counts AS (
    SELECT 
        start_date_year_races,
        is_active_membership,
        name_event_type,
        real_membership_types_sa,
        id_profile_rr,
        COUNT(DISTINCT id_race_rr) AS race_count
    FROM all_participation_data_with_membership_match
    GROUP BY start_date_year_races, is_active_membership, name_event_type, real_membership_types_sa, id_profile_rr
),

-- ***********************************************************************
-- CTE: participant_race_summary
-- Aggregates per-participant race counts into buckets for each group:
--   - count_1_race: participants who ran exactly 1 race,
--   - count_2_races: participants who ran exactly 2 races,
--   - count_3_races: participants who ran exactly 3 races,
--   - count_4_or_more_races: participants who ran 4 or more races.
-- ***********************************************************************
participant_race_summary AS (
    SELECT 
        start_date_year_races,
        is_active_membership,
        name_event_type,
        real_membership_types_sa,
        SUM(CASE WHEN race_count = 1 THEN 1 ELSE 0 END) AS count_1_race,
        SUM(CASE WHEN race_count = 2 THEN 1 ELSE 0 END) AS count_2_races,
        SUM(CASE WHEN race_count = 3 THEN 1 ELSE 0 END) AS count_3_races,
        SUM(CASE WHEN race_count >= 4 THEN 1 ELSE 0 END) AS count_4_or_more_races
    FROM participant_counts
    GROUP BY start_date_year_races, is_active_membership, name_event_type, real_membership_types_sa
),

-- ***********************************************************************
-- CTE: race_year_summary
-- Aggregates various statistics from the base table (for 2010+ and 'Adult Event')
-- for each group (race year, active membership, event type, membership type).
-- ***********************************************************************
race_year_summary AS (
    SELECT 
        start_date_year_races AS race_year,
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
		start_date_year_races >= 2010
		-- AND name_event_type = 'Adult Event'
    GROUP BY start_date_year_races, is_active_membership, name_event_type, real_membership_types_sa
),

-- ***********************************************************************
-- CTE: yearly_totals
-- Aggregates overall totals (ignoring group breakdown) for each race year.
-- ***********************************************************************
yearly_totals AS (
    SELECT 
        start_date_year_races AS race_year,
        SUM(CASE WHEN id_race_rr IS NULL THEN 1 ELSE 0 END) AS overall_count_null_race,
        SUM(CASE WHEN id_profile_rr IS NULL THEN 1 ELSE 0 END) AS overall_count_null_profile,
        SUM(CASE WHEN id_profile_rr IS NOT NULL THEN 1 ELSE 0 END) AS overall_count_not_null_profile,
        COUNT(*) AS total_count,              
        COUNT(DISTINCT id_sanctioning_events) AS overall_distinct_event_count,
        COUNT(DISTINCT id_race_rr) AS overall_distinct_race_count,
        COUNT(DISTINCT id_profile_rr) AS overall_distinct_profile_count,
        COUNT(id_profile_rr) AS overall_race_entries  -- Total race entries (may include duplicates)
    FROM all_participation_data_with_membership_match
    WHERE start_date_year_races >= 2010
      -- AND name_event_type = 'Adult Event'
    GROUP BY start_date_year_races
),

-- ***********************************************************************
-- CTE: overall_participant_race_summary
-- Aggregates overall participant race bucket counts per race year.
-- ***********************************************************************
overall_participant_race_summary AS (
    SELECT 
        start_date_year_races,
        SUM(CASE WHEN race_count = 1 THEN 1 ELSE 0 END) AS overall_count_1_race,
        SUM(CASE WHEN race_count = 2 THEN 1 ELSE 0 END) AS overall_count_2_races,
        SUM(CASE WHEN race_count = 3 THEN 1 ELSE 0 END) AS overall_count_3_races,
        SUM(CASE WHEN race_count >= 4 THEN 1 ELSE 0 END) AS overall_count_4_or_more_races
    FROM participant_counts
    GROUP BY start_date_year_races
)

-- ***********************************************************************
-- Final Query: UNION ALL Detailed Group Rows with an Overall Totals Row per Year
-- Detailed rows come from race_year_summary joined with participant_race_summary.
-- The overall row aggregates totals for each race year and is labeled "Overall".
-- ***********************************************************************
SELECT 
    r.race_year,
    r.is_active_membership,
    r.name_event_type,
    r.real_membership_types_sa,
    
    -- Group-level aggregated counts (without overall totals)
    FORMAT(r.count_null_race_id, 0) AS count_null_race_id,
    FORMAT(r.count_null_profile_id, 0) AS count_null_profile_id,
    FORMAT(r.count_not_null_profile_id, 0) AS count_not_null_profile_id,
    FORMAT(r.total_count, 0) AS total_count,
    FORMAT(r.distinct_event_count, 0) AS distinct_event_count,
    FORMAT(r.distinct_race_count, 0) AS distinct_race_count,
    FORMAT(r.distinct_profile_count, 0) AS distinct_profile_count,
    
    -- Ratios based on distinct counts (avoiding division by zero)
    FORMAT(r.distinct_profile_count / NULLIF(r.distinct_event_count, 0), 0) AS participants_per_event_distinct,
    FORMAT(r.distinct_profile_count / NULLIF(r.distinct_race_count, 0), 0) AS participants_per_race_distinct,
    
    -- Average races per participant (formatted to two decimal places)
    FORMAT(r.total_race_entries / NULLIF(r.distinct_profile_count, 0), 2) AS avg_races_per_distinct_profile,
    FORMAT(r.total_count / NULLIF(r.distinct_profile_count, 0), 2) AS avg_races_per_all_results,
    
    -- Participant bucket counts: number of participants with 1, 2, 3, or 4+ races
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

UNION ALL

-- Overall Totals Row per Year (labeled "Overall")
SELECT 
    y.race_year,
    'Overall' AS is_active_membership,
    'Overall' AS name_event_type,
    'Overall' AS real_membership_types_sa,
    
    -- Overall aggregated counts from yearly_totals (without "total" columns)
    FORMAT(y.overall_count_null_race, 0) AS count_null_race_id,
    FORMAT(y.overall_count_null_profile, 0) AS count_null_profile_id,
    FORMAT(y.overall_count_not_null_profile, 0) AS count_not_null_profile_id,
    FORMAT(y.total_count, 0) AS total_count,
    FORMAT(y.overall_distinct_event_count, 0) AS distinct_event_count,
    FORMAT(y.overall_distinct_race_count, 0) AS distinct_race_count,
    FORMAT(y.overall_distinct_profile_count, 0) AS distinct_profile_count,
    
    -- Overall ratios computed from yearly_totals
    FORMAT(y.overall_distinct_profile_count / NULLIF(y.overall_distinct_event_count, 0), 0) AS participants_per_event_distinct,
    FORMAT(y.overall_distinct_profile_count / NULLIF(y.overall_distinct_race_count, 0), 0) AS participants_per_race_distinct,
    
    -- Average races per participant (formatted to two decimal places)
    FORMAT(y.overall_race_entries / NULLIF(y.overall_distinct_profile_count, 0), 2) AS avg_races_per_distinct_profile,
    FORMAT(y.total_count / NULLIF(y.overall_distinct_profile_count, 0), 2) AS avg_races_per_all_results,
    
    -- Overall participant bucket counts from overall_participant_race_summary
    FORMAT(ops.overall_count_1_race, 0) AS count_1_races,
    FORMAT(ops.overall_count_2_races, 0) AS count_2_races,
    FORMAT(ops.overall_count_3_races, 0) AS count_3_races,
    FORMAT(ops.overall_count_4_or_more_races, 0) AS count_4_or_more_races
    
FROM yearly_totals y
LEFT JOIN overall_participant_race_summary ops
  ON y.race_year = ops.start_date_year_races

ORDER BY race_year, 
         CASE is_active_membership WHEN 'Overall' THEN 1 ELSE 0 END,
         name_event_type,
         real_membership_types_sa;
