USE vapor;

-- RACE RESULTS DISCOVERY
SELECT * FROM race_results LIMIT 10;
SELECT "race_results", FORMAT(COUNT(*), 0) FROM race_results; -- 5.9M records
SELECT "race_results", MIN(created_at) FROM race_results; -- 12/20/22
SELECT "race_results", YEAR(created_at), FORMAT(COUNT(*), 0) FROM race_results GROUP BY YEAR(created_at) ORDER BY YEAR(created_at); -- most records created in 2023 = 5.3M
SELECT "race_results", YEAR(updated_at), FORMAT(COUNT(*), 0) FROM race_results GROUP BY YEAR(updated_at) ORDER BY YEAR(updated_at); -- most records updated in 2023 = 5.3M with 68.9K in 2025

-- RACES TABLE DISCOVERY
SELECT * FROM races LIMIT 10;
SELECT "races", FORMAT(COUNT(*), 0) FROM races; -- 611,903
SELECT "race",  MIN(created_at) FROM races; -- 2/23/11
SELECT "races", YEAR(created_at), FORMAT(COUNT(*), 0) FROM races GROUP BY YEAR(created_at) ORDER BY YEAR(created_at); -- most created in 2021
SELECT "races", YEAR(updated_at), FORMAT(COUNT(*), 0) FROM races GROUP BY YEAR(updated_at) ORDER BY YEAR(updated_at); -- all updated 2021 forward

-- EVENTS TABLE DISCOVERY
SELECT * FROM events LIMIT 10;
SELECT "events", FORMAT(COUNT(*), 0) FROM events; -- 33,291
SELECT "events", MIN(created_at) FROM events; -- 10/29/2011
SELECT "events", YEAR(created_at), FORMAT(COUNT(*), 0) FROM events GROUP BY YEAR(created_at) ORDER BY YEAR(created_at); -- most created in 2018
SELECT "events", YEAR(updated_at), FORMAT(COUNT(*), 0) FROM events GROUP BY YEAR(updated_at) ORDER BY YEAR(updated_at); -- most updated 2021 forward

-- find null profile id / member number id
SELECT 
	* 
FROM race_results AS rr
	LEFT JOIN races AS r ON rr.race_id = r.id  
WHERE 	YEAR(r.start_date) IN (2022) 
		AND profile_id IS NULL 
        AND original_member_number IN ('Unknown') 
        AND member_number IS NULL 
-- LIMIT 
;

-- *************************************
-- EXCEL SHEET COUNT BY RACE YEAR
-- *************************************
SELECT 
    YEAR(r.start_date) AS race_year,
    FORMAT(COUNT(CASE WHEN rr.race_id IS NULL THEN 1 END), 0) AS count_null_race_id,
    FORMAT(COUNT(CASE WHEN rr.profile_id IS NULL THEN 1 END), 0) AS count_null_profile_id,
    FORMAT(COUNT(CASE WHEN rr.profile_id IS NOT NULL THEN 1 END), 0) AS count_not_null_profile_id,
    FORMAT(COUNT(CASE WHEN rr. member_number IS NULL THEN 1 END), 0) AS count_null_member_number,
    FORMAT(COUNT(CASE WHEN rr. member_number IS NOT NULL THEN 1 END), 0) AS count_not_null_member_number,
    FORMAT(COUNT(*), 0) AS total_count
FROM race_results AS rr
        LEFT JOIN races AS r ON rr.race_id = r.id  
-- WHERE YEAR(r.start_date) > 2010 
GROUP BY YEAR(r.start_date) WITH ROLLUP
;
-- *************************************

-- DNF, DNS, DQ, FINISHED, UNKNOWN
SELECT DISTINCT(finish_status), FORMAT(COUNT(*), 0) FROM race_results GROUP BY finish_status ORDER BY finish_status;
-- agegroup, elite, open, para
SELECT DISTINCT(category), FORMAT(COUNT(*), 0) FROM race_results GROUP BY category ORDER BY category;
SELECT member_number, first_name, last_name, COUNT(*) FROM race_results WHERE LOWER(first_name) IN ('cindy') AND last_name IN ('zhang') GROUP BY 1, 2;
-- look for duplicates
SELECT 
        rr.first_name AS first_name_rr
        , rr.last_name AS last_name_rr
        , rr.profile_id as profile_id_rr
        , rr.original_member_number AS member_number_original_rr
        , rr.member_number as member_number_rr
        , rr.city AS city_rr
        , rr.race_id AS id_rr
        , YEAR(r.start_date) AS year_races
        , FORMAT(COUNT(rr.race_id), 0) AS count_rr
FROM 
        race_results AS rr
	LEFT JOIN races AS r ON rr.race_id = r.id  
WHERE 
	YEAR(r.start_date) IN (2022) 
    -- AND MONTH(r.start_date) IN (8)
GROUP BY 
    rr.first_name, 
    rr.last_name, 
    rr.profile_id,
    rr.original_member_number,
    rr.member_number,
    rr.city, 
    rr.race_id, 
    YEAR(r.start_date)
HAVING count_rr > 1
-- LIMIT 100
;
-- blank profiles / member number?

SELECT * FROM test;

SELECT * FROM races LIMIT 50;
SELECT FORMAT(COUNT(*), 0) FROM races;
-- adult clinic, adult race, blank, youth clinic, youth race
SELECT DISTINCT(designation), FORMAT(COUNT(*), 0) FROM races GROUP BY designation ORDER BY designation;

-- super spring, short, intermediate, long, ultra, youth, clinic, relay
SELECT * FROM distance_types LIMIT 50;
SELECT FORMAT(COUNT(*), 0) FROM distance_types;

SELECT 
        rr.member_number AS member_number_rr
        , r.name as races_name
        , YEAR(r.start_date) AS year_races
        , MONTH(r.start_date) AS month_races
        , dt.name AS distance_dt
        , FORMAT(COUNT(DISTINCT rr.id), 0) AS count_race_results

FROM race_results AS rr 
        LEFT JOIN races AS r ON rr.race_id = r.id
        LEFT JOIN events AS e ON r.event_id = e.id
        LEFT JOIN distance_types AS dt ON r.distance_type_id = dt.id

WHERE year(r.start_date) IN (2023)
--     AND rr.member_number IN (24)

GROUP BY 1,2,3,4
LIMIT 10
;