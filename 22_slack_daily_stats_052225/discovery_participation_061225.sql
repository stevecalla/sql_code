use usat_sales_db;

-- SELECT * FROM participation_race_profiles LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM participation_race_profiles;

-- SELECT start_date_year_races, FORMAT(COUNT(DISTINCT(id_sanctioning_events)), 0), FORMAT(SUM(count_all_participants), 0) FROM participation_race_profiles GROUP BY 1 ORDER BY 1;

-- SELECT created_at_mtn FROM participation_race_profiles GROUP BY 1;

-- year over year data by month for participation # of events & participants
WITH monthly_counts AS (
    SELECT
        "year_over_year_counts" AS label,
        DATE_FORMAT(created_at_mtn, '%Y-%m-%d') AS created_at_mtn,
        start_date_month_races,

        YEAR(CURDATE()) - 1 AS last_year,
        YEAR(CURDATE()) AS this_year,

        COUNT(DISTINCT CASE WHEN start_date_year_races = YEAR(CURDATE()) - 1 THEN id_sanctioning_events END) AS participant_event_count_last_year,
        COUNT(DISTINCT CASE WHEN start_date_year_races = YEAR(CURDATE()) THEN id_sanctioning_events END) AS participant_event_count_this_year,

        SUM(CASE WHEN start_date_year_races = YEAR(CURDATE()) - 1 THEN count_all_participants END) AS participants_count_last_year,
        SUM(CASE WHEN start_date_year_races = YEAR(CURDATE()) THEN count_all_participants END) AS participants_count_this_year

    FROM participation_race_profiles
    WHERE start_date_year_races IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
    GROUP BY DATE_FORMAT(created_at_mtn, '%Y-%m-%d'), start_date_month_races
    HAVING participant_event_count_this_year > 0
)

SELECT
    label,
    created_at_mtn,
    start_date_month_races,
    last_year,
    this_year,
    participant_event_count_last_year,
    participant_event_count_this_year,
    participant_event_count_this_year - participant_event_count_last_year AS participant_event_difference_last_vs_this_year,
    participants_count_last_year,
    participants_count_this_year,
    participants_count_this_year - participants_count_last_year AS _participants_difference_last_vs_this_year
FROM monthly_counts

UNION ALL

-- Totals row based on filtered data
SELECT
    'TOTAL',
    'TOTAL',
    'TOTAL',
    MIN(last_year),
    MIN(this_year),
    SUM(participant_event_count_last_year),
    SUM(participant_event_count_this_year),
    SUM(participant_event_count_this_year) - SUM(participant_event_count_last_year),
    SUM(participants_count_last_year),
    SUM(participants_count_this_year),
    SUM(participants_count_this_year) - SUM(participants_count_last_year)
FROM monthly_counts

ORDER BY 
    label = 'TOTAL',
    start_date_month_races
;

-- compare sanctioned events vs race reporting
WITH participant_events AS (
    SELECT
        DATE_FORMAT(created_at_mtn, '%Y-%m-%d') AS created_at_mtn,
        start_date_month_races AS month_label,
        COUNT(DISTINCT CASE WHEN start_date_year_races = YEAR(CURDATE()) - 1 THEN id_sanctioning_events END) AS participant_event_count_last_year,
        COUNT(DISTINCT CASE WHEN start_date_year_races = YEAR(CURDATE()) THEN id_sanctioning_events END) AS participant_event_count_this_year
    FROM participation_race_profiles
    WHERE start_date_year_races IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
        AND LOWER(name_event_type) IN ('adult event', 'youth event')
    GROUP BY 
        DATE_FORMAT(created_at_mtn, '%Y-%m-%d'), start_date_month_races
),

sanctioned_events AS (
    SELECT
        DATE_FORMAT(created_at_mtn, '%Y-%m-%d') AS created_at_mtn,
        starts_month_events AS month_label,
        COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) - 1 THEN id_sanctioning_events END) AS sanction_count_last_year,
        COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) THEN id_sanctioning_events END) AS sanction_count_this_year
    FROM event_data_metrics
    WHERE starts_year_events IN (YEAR(CURDATE()) - 1, YEAR(CURDATE()))
        AND status_events NOT IN ('cancelled', 'declined', 'deleted')
        AND LOWER(name_event_type) IN ('adult race', 'youth race')
    GROUP BY 
        DATE_FORMAT(created_at_mtn, '%Y-%m-%d'), starts_month_events
),

combined AS (
    SELECT
        -- r.created_at_mtn,
        GREATEST(r.created_at_mtn, s.created_at_mtn) AS max_created_at,
        r.month_label,
        s.sanction_count_last_year,
        r.participant_event_count_last_year,
        r.participant_event_count_last_year - s.sanction_count_last_year AS diff_last_year,
        s.sanction_count_this_year,
        r.participant_event_count_this_year,
        r.participant_event_count_this_year - s.sanction_count_this_year AS diff_this_year
    FROM participant_events r
        LEFT JOIN sanctioned_events s ON r.month_label = s.month_label
    WHERE 
        r.participant_event_count_this_year > 0

    UNION

    SELECT
        -- r.created_at_mtn,
        GREATEST(r.created_at_mtn, s.created_at_mtn) AS max_created_at,
        s.month_label,
        s.sanction_count_last_year,
        r.participant_event_count_last_year,
        r.participant_event_count_last_year - s.sanction_count_last_year,
        s.sanction_count_this_year,
        r.participant_event_count_this_year,
        r.participant_event_count_this_year - s.sanction_count_this_year
    FROM sanctioned_events s
        LEFT JOIN participant_events r ON r.month_label = s.month_label
    WHERE 
        r.participant_event_count_this_year > 0
)

SELECT * FROM combined

UNION ALL

-- Total row
SELECT
    'TOTAL',
    'TOTAL' AS month_label,
    SUM(sanction_count_last_year),
    SUM(participant_event_count_last_year),
    SUM(diff_last_year),
    SUM(sanction_count_this_year),
    SUM(participant_event_count_this_year),
    SUM(diff_this_year)
FROM combined

ORDER BY
    CASE WHEN month_label = 'TOTAL' THEN 1 ELSE 0 END,  -- TOTAL last
    MONTH(STR_TO_DATE(month_label, '%M')) ASC
;

