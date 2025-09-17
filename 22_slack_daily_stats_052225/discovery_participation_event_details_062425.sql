-- compare sanctioned events vs race reporting
-- SELECT * FROM participation_race_profiles WHERE month = "2025-06";
-- SELECT FORMAT(COUNT(*), 0) FROM participation_race_profiles;

-- SELECT * FROM event_data_metrics LIMIT 10;
-- SELECT status_events, FORMAT(COUNT(*), 0) FROM event_data_metrics GROUP BY status_events LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM event_data_metrics;

WITH participant_events AS (
    SELECT
        DATE_FORMAT(created_at_mtn, '%Y-%m-%d') AS created_at_mtn,
        id_sanctioning_events,
        GROUP_CONCAT(DISTINCT(start_date_month_races)) AS month_label,
        GROUP_CONCAT(DISTINCT(start_date_races)) AS start_date_races
    FROM participation_race_profiles
    WHERE 1 = 1
        AND start_date_year_races = YEAR(CURDATE())
        AND start_date_month_races <= MONTH(CURDATE())
        AND LOWER(name_event_type) IN ('adult race', 'youth race')
    GROUP BY 
        DATE_FORMAT(created_at_mtn, '%Y-%m-%d'), id_sanctioning_events
)
-- SELECT * FROM participant_events;
-- SELECT id_sanctioning_events, FORMAT(COUNT(*), 0) FROM participant_events GROUP BY 1;
-- SELECT month_label, FORMAT(COUNT(DISTINCT(id_sanctioning_events)), 0) FROM participant_events GROUP BY 1 ORDER BY 1;

, sanctioned_events AS (
        SELECT
            DATE_FORMAT(created_at_mtn, '%Y-%m-%d') AS created_at_mtn,
            starts_month_events AS month_label,
			LEFT(id_sanctioning_events, 6) AS id_sanctioning_short,
            id_sanctioning_events,
			name_events,
			starts_events,
			starts_month_events,
			state_code_events
        FROM event_data_metrics
        WHERE 1 = 1
            AND starts_year_events IN (YEAR(CURDATE()))
            AND status_events NOT IN ('cancelled', 'declined', 'deleted')
            AND LOWER(name_event_type) IN ('adult race', 'youth race')
        GROUP BY 
            DATE_FORMAT(created_at_mtn, '%Y-%m-%d'), starts_month_events, id_sanctioning_short, 
			id_sanctioning_events, name_events, starts_events, starts_month_events, 
            state_code_events
    )
-- SELECT * FROM sanctioned_events ORDER BY month_label ASC;
-- SELECT month_label, FORMAT(COUNT(DISTINCT(id_sanctioning_events)), 0) FROM sanctioned_events GROUP BY 1 ORDER BY 1;

, sanctioned_events_with_reported_flag AS ( 
	SELECT 
    s.id_sanctioning_short         AS s_id_sanctioning_short,
    s.id_sanctioning_events 	   AS s_id_sanctioning_events,
    -- GROUP_CONCAT(s.id_sanctioning_events) AS s_id_sanctioning_events,

    TRIM(BOTH '"' FROM TRIM(BOTH '''' FROM name_events)) AS s_name_events,
    
    s.starts_events                AS s_starts_events,
    s.month_label                  AS s_month_label,
    s.state_code_events            AS s_state_code_events,
    s.created_at_mtn               AS s_created_at_mtn,

    p.id_sanctioning_events        AS p_id_sanctioning_events,
    p.month_label             	   AS p_month_label,
    p.start_date_races             AS p_start_date_races,
    
    CASE
		WHEN p.id_sanctioning_events IS NOT NULL THEN '✅ Reported'
        ELSE '❌ Not Reported'
	END AS reported_flag
    
    -- COUNT(DISTINCT(s.id_sanctioning_events)) AS total_sanctioned
    
FROM sanctioned_events AS s
    LEFT JOIN participant_events AS p ON p.id_sanctioning_events = s.id_sanctioning_short
WHERE s.month_label = 6
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
) 
SELECT * FROM sanctioned_events_with_reported_flag AS s ORDER BY s.s_month_label, s.s_id_sanctioning_events;

-- SELECT s_id_sanctioning_short, FORMAT(COUNT(*), 0) FROM sanctioned_events_with_reported_flag AS s GROUP BY 1;

-- COUNTS ARE OFF SLIGHTY FROM THE discovery_partication_061225 b/c
-- participation event id is counted once / distinct in the participation events query but
-- can be applied to multiple id_sanctioning_events in the sanctioning events query
-- i think i can align the queries by group concat in the participation query
-- 310734 id sanctioning events is an issue b/c it has race start date in 2/25 & 3/25 (asked Sam to fix)
SELECT
    s.s_month_label,
    COUNT(DISTINCT s.p_id_sanctioning_events) AS total_reported,
    COUNT(DISTINCT s.s_id_sanctioning_events) - COUNT(DISTINCT s.p_id_sanctioning_events) AS count_not_reported,
    COUNT(DISTINCT(s.s_id_sanctioning_events)) AS total_sanctioned
FROM sanctioned_events_with_reported_flag s
GROUP BY s.s_month_label
HAVING total_reported > 0
ORDER BY s.s_month_label
;
