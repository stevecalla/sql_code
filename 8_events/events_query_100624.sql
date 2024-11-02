USE vapor;

-- SELECT * FROM events;

WITH events_summary AS (
    SELECT 
        -- EVENTS TABLE
        events.id AS id_events,
        events.event_type_id AS event_type_id_events,
        events.name AS name_events,
        
        events.created_at AS created_at_events,
        MONTH(events.created_at) AS created_at_month_events,
        QUARTER(events.created_at) AS created_at_quarter_events,
        YEAR(events.created_at) AS created_at_year_events,
	
        events.deleted_at AS deleted_at_events,
        YEAR(events.deleted_at) AS deleted_at_year_events,
        MONTH(events.deleted_at) AS deleted_at_month_events,

        events.starts AS starts_events,
        MONTH(events.starts) AS starts_month_events,
        QUARTER(events.starts) AS starts_quarter_events,
        YEAR(events.starts) AS starts_year_events,

        events.ends AS ends_events,
        MONTH(events.ends) AS ends_month_events,
        QUARTER(events.ends) AS ends_quarter_events,
        YEAR(events.ends) AS ends_year_events,
        
		events.status AS status_events,

        events.race_director_id AS race_director_id_events,
        events.last_season_event_id AS last_season_event_id,

        events.city AS city_events,
        events.state AS state_events,
        events.country_name AS country_name_events,
        events.country AS country_events

    FROM events
)

-- SELECT * FROM events
-- SELECT deleted_at_year_events, COUNT(*) FROM events GROUP BY deleted_at_year_events

-- SELECT 
--     starts_month_events,
--     -- status_events, -- doesn't seem to be consistent with deleted_at date
--     CASE 
--         WHEN deleted_at_events IS NULL THEN 'not_deleted'
--         WHEN deleted_at_events IS NOT NULL THEN 'is_deleted'
--         ELSE 'other'
--     END AS is_deleted,

--     SUM(CASE WHEN YEAR(starts_events) < 2023 THEN 1 ELSE 0 END) AS 'events_<2023',
--     SUM(CASE WHEN YEAR(starts_events) = 2023 THEN 1 ELSE 0 END) AS 'events_2023',
--     SUM(CASE WHEN YEAR(starts_events) = 2024 THEN 1 ELSE 0 END) AS 'events_2024',
--     SUM(CASE WHEN YEAR(starts_events) = 2025 THEN 1 ELSE 0 END) AS 'events_2025',
--     SUM(CASE WHEN YEAR(starts_events) = 2026 THEN 1 ELSE 0 END) AS 'events_2026',
--     SUM(CASE WHEN YEAR(starts_events) > 2026 THEN 1 ELSE 0 END) AS 'events_2026+'

-- FROM events_summary
-- -- WHERE deleted_at_events IS NULL
-- GROUP BY starts_month_events, is_deleted WITH ROLLUP
-- ORDER BY starts_month_events, is_deleted DESC

SELECT 
    starts_month_events,
    CASE 
        WHEN deleted_at_events IS NULL THEN 'not_deleted'
        WHEN deleted_at_events IS NOT NULL THEN 'is_deleted'
        ELSE 'other'
    END AS is_deleted,

    SUM(CASE WHEN YEAR(starts_events) < 2023 THEN 1 ELSE 0 END) AS 'events_<2023',
    SUM(CASE WHEN YEAR(starts_events) = 2023 THEN 1 ELSE 0 END) AS 'events_2023',
    SUM(CASE WHEN YEAR(starts_events) = 2024 THEN 1 ELSE 0 END) AS 'events_2024',
    SUM(CASE WHEN YEAR(starts_events) = 2025 THEN 1 ELSE 0 END) AS 'events_2025',
    SUM(CASE WHEN YEAR(starts_events) = 2026 THEN 1 ELSE 0 END) AS 'events_2026',
    SUM(CASE WHEN YEAR(starts_events) > 2026 THEN 1 ELSE 0 END) AS 'events_2026+'

FROM events_summary
WHERE deleted_at_events IS NULL
GROUP BY starts_month_events, is_deleted
ORDER BY starts_month_events, is_deleted DESC

-- SELECT 
--     starts_month_events,
--     name_events,

--     SUM(CASE WHEN YEAR(starts_events) < 2023 THEN 1 ELSE 0 END) AS 'events_<2023',
--     SUM(CASE WHEN YEAR(starts_events) = 2023 THEN 1 ELSE 0 END) AS 'events_2023',
--     SUM(CASE WHEN YEAR(starts_events) = 2024 THEN 1 ELSE 0 END) AS 'events_2024',
--     SUM(CASE WHEN YEAR(starts_events) = 2025 THEN 1 ELSE 0 END) AS 'events_2025',
--     SUM(CASE WHEN YEAR(starts_events) = 2026 THEN 1 ELSE 0 END) AS 'events_2026',
--     SUM(CASE WHEN YEAR(starts_events) > 2026 THEN 1 ELSE 0 END) AS 'events_2026+'

-- FROM events_summary
-- WHERE 
-- 	deleted_at_events IS NULL
-- 	AND starts_month_events IN (8)
--     AND starts_year_events IN (2023, 2024)
--     AND LOWER(name_events) LIKE '%chicago%'  -- Case-insensitive search for 'Chicago'

-- GROUP BY starts_month_events, name_events WITH ROLLUP
-- ORDER BY starts_month_events, name_events ASC
;



