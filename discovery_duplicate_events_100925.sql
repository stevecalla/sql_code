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

-- ===========================
-- REVIEW EVET UPDATED AT STATUS
-- ===========================
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
		AND r.deleted_at IS NULL
WHERE 1 = 1
	AND e.updated_at IS NOT NULL
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
		AND r.deleted_at IS NULL
WHERE 1 = 1
	AND e.created_at IS NOT NULL 
    AND e.starts >= '2025-01-01' AND e.starts < '2026-01-01'    -- sargable year filter
	-- AND LOWER(status) NOT IN ('cancelled', 'declined', 'deleted')
ORDER BY e.created_at DESC, e.sanctioning_event_id DESC
-- LIMIT 30
;

-- ===========================
-- IDENTIFY POSSIBLE EVENT DUPLICATES BASE ON EVENT NAME
-- USE RULES TO FILTER OUT NON DUPLICATES
-- ===========================
SELECT * FROM events AS e LIMIT 10;
SELECT * FROM event_types AS e LIMIT 10;
SELECT
	e.name AS name_e,
    GROUP_CONCAT(e.deleted_at, " | ") AS deleted_at_e,
    GROUP_CONCAT(DISTINCT e.sanctioning_event_id, " | ") AS sanctioning_event_id_e,	
    GROUP_CONCAT(DISTINCT e.starts, " | ") AS starts_e,
    GROUP_CONCAT(DISTINCT e.event_type_id, " | ") AS event_type_id_e,
    GROUP_CONCAT(DISTINCT et.name, " | ") AS name_et,
    GROUP_CONCAT(DISTINCT r.designation, " | ") AS designation_r,
    -- COUNTS
    COUNT(DISTINCT e.name),
    COUNT(DISTINCT e.sanctioning_event_id),
    COUNT(e.deleted_at),
    
    COUNT(et.name),
    COUNT(DISTINCT et.name),
    COUNT(e.starts),
    COUNT(DISTINCT et.name),
    COUNT(DISTINCT r.designation),
    COUNT(*),
    
    CASE
		WHEN COUNT(DISTINCT e.name) = COUNT(DISTINCT e.sanctioning_event_id) = 1 THEN "1) FALSE: ONE NAME"
        -- DELETED
		WHEN COUNT(e.deleted_at) = COUNT(DISTINCT e.sanctioning_event_id) THEN "2) FALSE: ALL DELETED"
		WHEN COUNT(DISTINCT e.sanctioning_event_id) - COUNT(e.deleted_at) = 1 THEN "2a) FALSE: ALL BUT ONE DELETED"
		WHEN COUNT(e.deleted_at) + COUNT(DISTINCT et.name) = COUNT(DISTINCT e.sanctioning_event_id) THEN "2b) FALSE: DELETED + TYPE = TOTAL COUNT"
        -- CLINIC
		WHEN SUM(CASE WHEN LOWER(et.name) LIKE '%clinic%' THEN 1 ELSE 0 END) > 0 THEN '3) FALSE: CLINIC'
		WHEN SUM(CASE WHEN LOWER(r.designation) LIKE '%clinic%' THEN 1 ELSE 0 END) > 0 THEN '3a) FALSE: CLINIC'
		-- STARTS NOT IN SAME MONTH/YEAR (RULE 4)
        WHEN COUNT(DISTINCT DATE_FORMAT(e.starts, '%Y-%m')) > 1 THEN '4) FALSE: STARTS NOT IN SAME MONTH'

        -- POSSIBLE DUPLICATE
		WHEN COUNT(DISTINCT e.sanctioning_event_id) - COUNT(e.deleted_at) >= 1 THEN '10) TRUE: POSSIBLE DUPLICATE'
        ELSE "OTHER"
	END AS is_likely_duplicate,
    FORMAT(COUNT(DISTINCT e.sanctioning_event_id), 0) AS count_rows
FROM events AS e
	LEFT JOIN event_types AS et ON et.id = e.event_type_id
	LEFT JOIN races AS r ON e.id = r.event_id 
		AND r.deleted_at IS NULL
WHERE 1 = 1
	AND YEAR(starts) = 2025
GROUP BY 1
-- HAVING 1 = 1
	-- AND count_rows > 1 
ORDER BY is_likely_duplicate, count_rows DESC, name_e ASC
;