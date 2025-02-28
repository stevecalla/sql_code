USE usat_match;

-- ****************************
-- BASLINE QUERIES
-- ****************************
-- EMAIL & EVENT DATA
SELECT * FROM usat_match.email_021525 ORDER BY created_at_date_profiles ASC LIMIT 10;
SELECT COUNT(*) FROM usat_match.email_021525 ORDER BY created_at_date_profiles ASC LIMIT 10;

SELECT * FROM usat_match.events_021525 ORDER BY created_at_events ASC LIMIT 10;
SELECT COUNT(*) FROM usat_match.events_021525 ORDER BY created_at_events ASC LIMIT 10;

-- MEMBERSHIPS SOLD > 6/1/2024
SELECT * FROM usat_match.membership_periods_021525 ORDER BY created_at_mp ASC LIMIT 10;
SELECT COUNT(*) FROM usat_match.membership_periods_021525 ORDER BY created_at_mp ASC LIMIT 10;

-- TICKET SOCKET RAW DATA
SELECT * FROM usat_match.ticket_socket_021525 LIMIT 10;
SELECT COUNT(*) FROM usat_match.ticket_socket_021525 LIMIT 10;
SELECT COUNT(*) FROM usat_match.ticket_socket_021525 WHERE amount IS NOT NULL;
SELECT * FROM usat_match.ticket_socket_021525 WHERE email_address IN ('12tms34@gmail.com', 'amjett82@gmail.com') LIMIT 10;

-- ****************************
-- APPEND EVENT, EMAIL, FIRST NAME TO MP DATA
-- ****************************
WITH EventData AS ( -- 194,850
    SELECT 
        id_events, 
        id_sanctioning_events,
        COUNT(id_sanctioning_events) AS count_santioning_id
    FROM events_021525
    GROUP BY id_events
)
-- SELECT * FROM EventData LIMIT 10;
, EmailData AS (
    SELECT 
		id_profiles,
        GROUP_CONCAT(DISTINCT email_users) AS distinct_email_users, 
        GROUP_CONCAT(DISTINCT first_name_profiles) AS distinct_first_name_profiles,
        COUNT(email_users) AS count_email_address
    FROM email_021525
    GROUP BY email_users, id_profiles
)
SELECT 
    mp.*,
    ev.id_sanctioning_events,
    ev.count_santioning_id,
    emd.distinct_email_users,
    emd.distinct_first_name_profiles,
    emd.count_email_address
FROM membership_periods_021525 AS mp
	LEFT JOIN EventData AS ev ON CAST(mp.id_events AS UNSIGNED) = CAST(ev.id_events AS UNSIGNED)
	LEFT JOIN EmailData AS emd ON mp.id_profiles = emd.id_profiles
GROUP BY created_at_mp, id_events, starts_mp, ends_mp, id_membership_periods_sa, id_profiles, id_membership_count, created_at, ev.id_sanctioning_events, ev.count_santioning_id, emd.id_profiles, emd.distinct_email_users, emd.distinct_first_name_profiles, emd.count_email_address
LIMIT 10
;

-- ****************************
-- TICKET SOCKET DATA
-- ****************************
SELECT * FROM usat_match.ticket_socket_021525 LIMIT 10;
SELECT COUNT(*) FROM usat_match.ticket_socket_021525 LIMIT 10; -- 53,421

SELECT COUNT(*) FROM usat_match.ticket_socket_021525 WHERE amount IS NOT NULL LIMIT 10; -- 33,641 filter out amount = null as these are validated memberships

-- TICKET SOCKET GROUP DUPLICATE EMAIL ADDRESSES & AMOUNT IS NOT NULL (ELIMINATE MEMBERSHIP VALIDATION)
SELECT -- ~33k
    usat_event_id,
    first_name,
    
    -- DUPLICATE EMAIL ADDRESSES
    email_address,
    COUNT(email_address) AS count_email_address,
    
    GROUP_CONCAT(DISTINCT group_id ORDER BY group_id SEPARATOR '|') AS distinct_group_id,
	(LENGTH(GROUP_CONCAT(DISTINCT group_id)) - LENGTH(REPLACE(GROUP_CONCAT(DISTINCT group_id), ',', '')) + 1) AS count_distinct_group_id,
        
	GROUP_CONCAT(DISTINCT ticket_id ORDER BY ticket_id SEPARATOR '|') AS distinct_ticket_id,
	(LENGTH(GROUP_CONCAT(DISTINCT ticket_id)) - LENGTH(REPLACE(GROUP_CONCAT(DISTINCT ticket_id), ',', '')) + 1) AS count_distinct_ticket_id,
    
    -- DUPLICATE DOB
    -- GROUP_CONCAT(dob),
    GROUP_CONCAT(DISTINCT dob) AS distinct_dobs,
    -- (LENGTH(GROUP_CONCAT(dob)) - LENGTH(REPLACE(GROUP_CONCAT(dob), ',', '')) + 1) AS count_dob,
    (LENGTH(GROUP_CONCAT(DISTINCT dob)) - LENGTH(REPLACE(GROUP_CONCAT(DISTINCT dob), ',', '')) + 1) AS count_distinct_dob,
    
    -- DUPLICATE ZIP
    -- GROUP_CONCAT(zip) AS all_zips,
    -- GROUP_CONCAT(DISTINCT zip) AS distinct_zips,
    -- GROUP_CONCAT(DISTINCT LOWER(REPLACE(zip, ' ', ''))) AS normalized_zips,
    GROUP_CONCAT(DISTINCT LPAD(LEFT(LOWER(REPLACE(zip, ' ', '')), 5), 5, '0')) AS distinct_zip_5chars,
    -- (LENGTH(GROUP_CONCAT(zip)) - LENGTH(REPLACE(GROUP_CONCAT(zip), ',', '')) + 1) AS count_zip,
    (LENGTH(GROUP_CONCAT(DISTINCT LPAD(LEFT(LOWER(REPLACE(zip, ' ', '')), 5), 5, '0'))) - 
     LENGTH(REPLACE(GROUP_CONCAT(DISTINCT LPAD(LEFT(LOWER(REPLACE(zip, ' ', '')), 5), 5, '0')), ',', '')) + 1) AS count_distinct_zip_5chars,
     
     -- DUPLICATE EVENTS
    -- GROUP_CONCAT(usat_event_id),
    GROUP_CONCAT(DISTINCT usat_event_id) AS distinct_event_id,
    -- (LENGTH(GROUP_CONCAT(usat_event_id)) - LENGTH(REPLACE(GROUP_CONCAT(usat_event_id), ',', '')) + 1) AS count_usat_event_id,
    (LENGTH(GROUP_CONCAT(DISTINCT usat_event_id)) - LENGTH(REPLACE(GROUP_CONCAT(DISTINCT usat_event_id), ',', '')) + 1) AS count_distinct_usat_event_id
     
FROM ticket_socket_021525
WHERE amount IS NOT NULL
GROUP BY 1, 2, 3
-- HAVING count_email_address > 1
ORDER BY count_email_address DESC, email_address, count_distinct_dob DESC, count_distinct_zip_5chars DESC
;

-- ****************************
-- CREATE TABLE = MEMBERSHIP PERIODS SOLD GROUP DUPLICATES -- 194,850
-- ****************************
SET SESSION group_concat_max_len = 1000000;  -- Ensures longer GROUP_CONCAT results

DROP TABLE IF EXISTS membership_periods_summary_021525;

CREATE TABLE IF NOT EXISTS membership_periods_summary_021525 AS -- 194,850
WITH EventData AS ( -- 194,850
    SELECT 
        id_events, 
        id_sanctioning_events,
        COUNT(id_sanctioning_events) AS count_santioning_id
    FROM events_021525
    GROUP BY id_events
)
, EmailData AS (
    SELECT 
		id_profiles,
        GROUP_CONCAT(DISTINCT email_users) AS distinct_email_users, 
        GROUP_CONCAT(DISTINCT first_name_profiles) AS distinct_first_name_profiles,
        COUNT(email_users) AS count_email_address
    FROM email_021525
    GROUP BY email_users, id_profiles
)
SELECT 
    mp.*,
    ev.id_sanctioning_events,
    ev.count_santioning_id,
    emd.distinct_email_users,
    emd.distinct_first_name_profiles,
    emd.count_email_address
FROM membership_periods_021525 AS mp
	LEFT JOIN EventData AS ev ON CAST(mp.id_events AS UNSIGNED) = CAST(ev.id_events AS UNSIGNED)
	LEFT JOIN EmailData AS emd ON mp.id_profiles = emd.id_profiles
GROUP BY created_at_mp, id_events, starts_mp, ends_mp, id_membership_periods_sa, id_profiles, id_membership_count, created_at, ev.id_sanctioning_events, ev.count_santioning_id, emd.id_profiles, emd.distinct_email_users, emd.distinct_first_name_profiles, emd.count_email_address
-- LIMIT 10
;

ALTER TABLE membership_periods_summary_021525
ADD COLUMN created_at_summary_table TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

SELECT * FROM membership_periods_summary_021525 LIMIT 10;
SELECT COUNT(*) FROM membership_periods_summary_021525 LIMIT 10;

-- ****************************
-- CREATE TABLE = TICKET SOCKET SUMMARY GROUPS DUPLICATES & AMOUNT IS NOT NULL (ELIMINATES VALIDATIONS)
-- ****************************
DROP TABLE IF EXISTS ticket_socket_summary_021525;

CREATE TABLE IF NOT EXISTS ticket_socket_summary_021525 AS 
WITH TicketSocketData AS (
    SELECT 
        usat_event_id,
        first_name,
        
        -- DUPLICATE EMAIL ADDRESSES
        email_address,
        COUNT(email_address) AS count_email_address,
    
		GROUP_CONCAT(DISTINCT group_id ORDER BY group_id SEPARATOR '|') AS distinct_group_id,
		(LENGTH(GROUP_CONCAT(DISTINCT group_id)) - LENGTH(REPLACE(GROUP_CONCAT(DISTINCT group_id), ',', '')) + 1) AS count_distinct_group_id,
        
		GROUP_CONCAT(DISTINCT ticket_id ORDER BY ticket_id SEPARATOR '|') AS distinct_ticket_id,
		(LENGTH(GROUP_CONCAT(DISTINCT ticket_id)) - LENGTH(REPLACE(GROUP_CONCAT(DISTINCT ticket_id), ',', '')) + 1) AS count_distinct_ticket_id,
        
        -- DISTINCT DOBs
        GROUP_CONCAT(DISTINCT dob ORDER BY dob SEPARATOR '|') AS distinct_dobs,
        (LENGTH(GROUP_CONCAT(DISTINCT dob)) - LENGTH(REPLACE(GROUP_CONCAT(DISTINCT dob), ',', '')) + 1) AS count_distinct_dob,
        
        -- DISTINCT ZIPs (Normalized to 5 Digits)
        GROUP_CONCAT(
            DISTINCT LPAD(LEFT(LOWER(REPLACE(zip, ' ', '')), 5), 5, '0') 
            ORDER BY LPAD(LEFT(LOWER(REPLACE(zip, ' ', '')), 5), 5, '0') 
            SEPARATOR '|'
        ) AS distinct_zip_5chars,
        (LENGTH(GROUP_CONCAT(DISTINCT LPAD(LEFT(LOWER(REPLACE(zip, ' ', '')), 5), 5, '0')) ) - 
         LENGTH(REPLACE(GROUP_CONCAT(DISTINCT LPAD(LEFT(LOWER(REPLACE(zip, ' ', '')), 5), 5, '0')) , ',', '')) + 1) AS count_distinct_zip_5chars,
         
        -- DISTINCT Events
        GROUP_CONCAT(DISTINCT usat_event_id ORDER BY usat_event_id SEPARATOR '|') AS distinct_event_id,
        (LENGTH(GROUP_CONCAT(DISTINCT usat_event_id)) - LENGTH(REPLACE(GROUP_CONCAT(DISTINCT usat_event_id), ',', '')) + 1) AS count_distinct_usat_event_id
     
    FROM ticket_socket_021525
	WHERE amount IS NOT NULL
    GROUP BY usat_event_id, first_name, email_address
    -- HAVING count_email_address > 1  -- Uncomment if you only want duplicate emails
    ORDER BY count_email_address DESC, email_address, count_distinct_dob DESC, count_distinct_zip_5chars DESC
)
SELECT * FROM TicketSocketData;

ALTER TABLE ticket_socket_summary_021525
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

SELECT * FROM ticket_socket_summary_021525 LIMIT 10;
SELECT COUNT(*) FROM ticket_socket_summary_021525 LIMIT 10;

-- ****************************
-- GET MATCH RESULTS = MATCH TICKET SOCKET DATA AGAINST MEMBERSHIP PERIOD SALES DATA TO FIND MATCHES
-- ****************************
-- FINAL MATCH
SELECT distinct_email_users, COUNT(*) 
FROM membership_periods_summary_021525
GROUP BY distinct_email_users
HAVING COUNT(*) > 1
LIMIT 10;

SELECT distinct_email_users, id_sanctioning_events, COUNT(*) 
FROM membership_periods_summary_021525
WHERE distinct_email_users IN ('12tms34@gmail.com', 'amjett82@gmail.com')
GROUP BY distinct_email_users, id_sanctioning_events
LIMIT 10;

WITH MatchResults AS (
    SELECT 
		tsd.distinct_group_id,
        tsd.count_distinct_group_id,
		tsd.distinct_ticket_id,
        tsd.count_distinct_ticket_id,
        
        tsd.email_address,
        md.distinct_email_users,
        
        -- Email Match Flag
        CASE 
            WHEN LOWER(tsd.email_address) = LOWER(md.distinct_email_users) THEN 1 
            ELSE 0 
        END AS is_email_match,

        tsd.first_name,
        md.distinct_first_name_profiles,
        
        -- First Name Match Flag (Fuzzy Match)
        CASE 
            WHEN LOWER(tsd.first_name) LIKE LOWER(CONCAT('%', md.distinct_first_name_profiles, '%')) THEN 1 
            ELSE 0 
        END AS is_first_name_match,

        tsd.usat_event_id,
        md.id_sanctioning_events,

        -- Concatenated Sanctioning Event IDs
        GROUP_CONCAT(DISTINCT md.id_sanctioning_events ORDER BY md.id_sanctioning_events SEPARATOR '|') AS all_sanctioning_event_ids,

        -- Sanctioning Event Match Flag
        CASE 
            WHEN tsd.usat_event_id = md.id_sanctioning_events THEN 1 
            ELSE 0 
        END AS is_sanctioning_event_id_match,

        -- Full Match Flag (1 if all fields match, 0 otherwise)
        CASE 
            WHEN LOWER(tsd.email_address) = LOWER(md.distinct_email_users) 
            AND LOWER(tsd.first_name) LIKE LOWER(CONCAT('%', md.distinct_first_name_profiles, '%')) 
            AND tsd.usat_event_id = md.id_sanctioning_events 
            THEN 1 
            ELSE 0 
        END AS full_match

    FROM ticket_socket_summary_021525 AS tsd
		LEFT JOIN membership_periods_summary_021525 AS md 
			ON LOWER(tsd.email_address) = LOWER(md.distinct_email_users)
			AND LOWER(tsd.first_name) LIKE LOWER(CONCAT('%', md.distinct_first_name_profiles, '%')) -- Fuzzy Match on First Name
			AND tsd.usat_event_id = md.id_sanctioning_events

	GROUP BY 
		tsd.distinct_group_id,
        tsd.count_distinct_group_id,
		tsd.distinct_ticket_id,
        tsd.count_distinct_ticket_id,
        tsd.email_address, md.distinct_email_users, tsd.first_name, md.distinct_first_name_profiles, tsd.usat_event_id, md.id_sanctioning_events
)
-- **Final Output**
SELECT * FROM MatchResults
-- WHERE email_address IN ('12tms34@gmail.com', 'amjett82@gmail.com')
ORDER BY email_address, usat_event_id;

-- Final Summary Output
SELECT 
    COUNT(*) AS total_records,
    SUM(is_email_match) AS total_email_matches,
    SUM(is_first_name_match) AS total_first_name_matches,
    SUM(is_sanctioning_event_id_match) AS total_event_matches,
    SUM(full_match) AS total_full_matches,  -- Count of records where all three match
    COUNT(*) - SUM(full_match) AS total_not_full_matches,
    ROUND(SUM(is_email_match) / COUNT(*) * 100, 2) AS email_match_percentage,
    ROUND(SUM(is_first_name_match) / COUNT(*) * 100, 2) AS first_name_match_percentage,
    ROUND(SUM(is_sanctioning_event_id_match) / COUNT(*) * 100, 2) AS event_match_percentage,
    ROUND(SUM(full_match) / COUNT(*) * 100, 2) AS full_match_percentage -- Percentage of full matches
FROM MatchResults;
