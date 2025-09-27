SELECT * FROM events LIMIT 10;	
	
SELECT name, created_at, updated_at FROM events LIMIT 10;	
	
SELECT 	
	"query_deleted_at", name, created_at, starts, YEAR(starts), ends, updated_at, deleted_at, status
FROM events 	
WHERE 1 = 1	
	AND deleted_at IS NOT NULL
    AND starts >= '2025-01-01' AND starts < '2026-01-01'    -- sargable year filter	
	-- AND LOWER(status) IN ('cancelled', 'declined', 'deleted')
ORDER BY deleted_at DESC, sanctioning_event_id DESC	
LIMIT 10;	
	
SELECT 	
	"query_updated_at",	
    e.name, 	
    e.sanctioning_event_id, 	
    e.created_at, 	
    e.starts, 	
    e.ends, 	
    e.updated_at, 	
    e.deleted_at, 	
    e.status,	
    -- EVENT TYPES	
    e.event_type_id AS event_type_id_events,	
    -- et.name AS name_event_type, 	
    r.designation as designation_races,	
    -- ALSO CHANGE CODE FOR BELOW AT...	
    -- ... src\queries\participation_data\step_1_get_participation_data.js	
            CASE	
                WHEN r.designation IS NOT NULL THEN r.designation	
                WHEN r.designation IS NULL AND e.event_type_id = 1 THEN 'Adult Race'	
                WHEN r.designation IS NULL AND e.event_type_id = 2 THEN 'Adult Clinic'	
                WHEN r.designation IS NULL AND e.event_type_id = 3 THEN 'Youth Race'	
                WHEN r.designation IS NULL AND e.event_type_id = 4 THEN 'Youth Clinic'	
                ELSE "missing_event_type_race_designation"	
            END AS name_event_type	
FROM events AS e	
	LEFT JOIN races AS r ON e.id = r.event_id 
WHERE 1 = 1	
	AND e.updated_at IS NOT NULL
    -- AND e.sanctioning_event_id IN (352322, 352331)
    AND e.starts >= '2025-01-01' AND e.starts < '2026-01-01'    -- sargable year filter	
	-- AND LOWER(status) NOT IN ('cancelled', 'declined', 'deleted')
GROUP BY 1,2,3,4,5,6,7	
ORDER BY updated_at DESC, sanctioning_event_id DESC	
-- LIMIT 30	
;	
	
SELECT 	
	"query_created_at", e.name, e.sanctioning_event_id, e.created_at, e.starts, e.ends, e.updated_at, e.deleted_at, e.status 
FROM events AS e	
	LEFT JOIN races AS r ON e.id = r.event_id 
	
WHERE 1 = 1	
	AND e.created_at IS NOT NULL 
    AND e.starts >= '2025-01-01' AND e.starts < '2026-01-01'    -- sargable year filter	
	-- AND LOWER(status) NOT IN ('cancelled', 'declined', 'deleted')
ORDER BY e.created_at DESC, e.sanctioning_event_id DESC	
-- LIMIT 30	
;	
