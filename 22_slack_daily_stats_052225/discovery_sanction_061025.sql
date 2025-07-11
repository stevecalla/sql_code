use usat_sales_db;

-- GET SANCTION EVENT DATA
SELECT "sanction_data" AS "table", e.* FROM event_data_metrics AS e ORDER BY created_at_events DESC LIMIT 10;
SELECT "sanction_data" AS "table", FORMAT(COUNT(*), 0) FROM event_data_metrics AS e LIMIT 10;

-- last 10 created events by created date with event name, region, event start date
SELECT
	"last_10_created_events",
            DATE_FORMAT(created_at_mtn, '%Y-%m-%d') AS created_at_mtn,
            DATE_FORMAT(NOW(), '%Y-%m-%d') AS now_date_mtn,
            DATE_FORMAT(created_at_events, '%Y-%m-%d %H:%i:%s') AS created_at_events,
    -- id_sanctioning_events,
	SUBSTRING_INDEX(id_sanctioning_events, '-', 1) AS id_sanctioning_events, -- removed the event type used to get unique count
    TRIM(BOTH '"' FROM name_events) AS name_events,
    status_events,
    CASE WHEN name_event_type LIKE "%missing%" THEN "missing" ELSE name_event_type END name_event_type,
    id_races,
    name_distance_types,
    name_race_type,
            DATE_FORMAT(starts_events, '%Y-%m-%d') AS starts_events,
    state_code_events
FROM event_data_metrics
-- WHERE created_at_events >= NOW() - INTERVAL 3 DAY
ORDER BY created_at_events DESC
LIMIT 100
;

-- last 10 created events by created date with event name, region, event start date
SELECT
	"last_10_created_events",
	DATE_FORMAT(created_at_mtn, '%Y-%m-%d') AS created_at_mtn,
	DATE_FORMAT(NOW(), '%Y-%m-%d') AS now_date_mtn,
	DATE_FORMAT(created_at_events, '%Y-%m-%d %H:%i:%s') AS created_at_events,
	SUBSTRING_INDEX(id_sanctioning_events, '-', 1) AS id_sanctioning_events, -- removed the event type used to get unique count
    TRIM(BOTH '"' FROM name_events) AS name_events,
	DATE_FORMAT(starts_events, '%Y-%m-%d') AS starts_events,
    state_code_events,
    COUNT(DISTINCT(id_races)) AS race_count
FROM event_data_metrics
-- WHERE created_at_events >= NOW() - INTERVAL 3 DAY
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
ORDER BY created_at_events DESC
LIMIT 10
;

-- last 7 days by event type
-- Create a 7-day range using a derived table of numbers (0 to 6)
WITH RECURSIVE date_range AS (
    SELECT CURDATE() - INTERVAL 7 DAY AS generated_date

    UNION ALL

    SELECT generated_date + INTERVAL 1 DAY
    FROM date_range
    WHERE generated_date + INTERVAL 1 DAY <= CURDATE()
)

SELECT
    "last_7_days" AS label,
    DATE_FORMAT(d.generated_date, '%Y-%m-%d') AS created_at_mtn,
    DATE_FORMAT(d.generated_date, '%a') AS created_weekday_abbr,  -- 3-letter weekday
    COALESCE(
        CASE 
            WHEN LOWER(e.name_event_type) LIKE "%missing%" THEN "missing" 
            WHEN LOWER(e.name_event_type) LIKE "%adult clinic%" THEN "AC" 
            WHEN LOWER(e.name_event_type) LIKE "%adult race%" THEN "AR" 
            WHEN LOWER(e.name_event_type) LIKE "%youth clinic%" THEN "YC"
            WHEN LOWER(e.name_event_type) LIKE "%youth race%" THEN "YC"
            ELSE ""
        END, 'no_event'
    ) AS event_type,
    COUNT(e.id_sanctioning_events) AS count_total,
    COUNT(DISTINCT e.id_sanctioning_events) AS count_distinct_id_sanctioning_events

FROM date_range d
    LEFT JOIN event_data_metrics e ON DATE(e.created_at_events) = d.generated_date
    AND e.status_events NOT IN ('cancelled', 'declined', 'deleted')
GROUP BY d.generated_date, event_type
ORDER BY d.generated_date DESC, event_type
LIMIT 100
;

-- year over year data for full year or by month by event type
-- Main rows grouped by event_type and created_at_mtn
SELECT
    "year_over_year_counts" AS label,
    DATE_FORMAT(created_at_mtn, '%Y-%m-%d %H:%i:%s') AS created_at_mtn,

    CASE 
        WHEN name_event_type LIKE "%missing%" THEN "missing" 
        ELSE name_event_type 
    END AS event_type,

    YEAR(CURDATE()) - 1 AS last_year,
    YEAR(CURDATE()) AS this_year,
    YEAR(CURDATE()) + 1 AS next_year,

    COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) - 1 THEN id_sanctioning_events END) AS sanction_count_last_year,
    COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) THEN id_sanctioning_events END) AS sanction_count_this_year,
    COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) + 1 THEN id_sanctioning_events END) AS sanction_count_next_year,

    COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) THEN id_sanctioning_events END) -
    COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) - 1 THEN id_sanctioning_events END) AS difference_last_vs_this_year

FROM event_data_metrics
WHERE 1 = 1
    AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1, YEAR(CURDATE()) + 1)
    -- AND starts_month_events IN (5)
    -- ${month_where_clause}
    AND status_events NOT IN ('cancelled', 'declined', 'deleted')
GROUP BY created_at_mtn, event_type

UNION ALL

-- Total rollup row (no grouping fields)
SELECT
    "year_over_year_counts" AS label,
    NULL AS created_at_mtn,
    'TOTAL' AS event_type,

    YEAR(CURDATE()) - 1 AS last_year,
    YEAR(CURDATE()) AS this_year,
    YEAR(CURDATE()) + 1 AS next_year,

    COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) - 1 THEN id_sanctioning_events END),
    COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) THEN id_sanctioning_events END),
    COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) + 1 THEN id_sanctioning_events END),

    COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) THEN id_sanctioning_events END) -
    COUNT(DISTINCT CASE WHEN starts_year_events = YEAR(CURDATE()) - 1 THEN id_sanctioning_events END)

FROM event_data_metrics
WHERE 1 = 1
    AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1, YEAR(CURDATE()) + 1)
    -- AND starts_month_events IN (5)
    -- ${month_where_clause}
    AND status_events NOT IN ('cancelled', 'declined', 'deleted')

ORDER BY created_at_mtn IS NULL,  -- places the TOTAL row at the bottom
event_type
;
