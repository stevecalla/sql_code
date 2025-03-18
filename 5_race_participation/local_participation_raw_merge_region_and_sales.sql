USE usat_sales_db;
-- *************************************
-- ALL PARTICIPATION DATA
-- *************************************
SELECT * FROM all_participation_data_raw LIMIT 10;
SELECT "participation data", FORMAT(COUNT(*), 0), SUM(count_all_participation) FROM all_participation_data_raw;
SELECT "participation data", start_date_year_races, COUNT(*), SUM(count_all_participation) FROM all_participation_data_raw GROUP BY 2;
-- *************************************
-- REGION DATA
-- *************************************
SELECT * FROM region_data LIMIT 10; -- '5,880,334'
-- *************************************
-- MERGE WITH REGIONS
-- *************************************
SELECT "participation & region merge", FORMAT(COUNT(*), 0) FROM all_participation_data_raw AS p LEFT JOIN region_data AS r ON p.state_code_events = r.state_code LIMIT 10; -- 5,880,334
SELECT 
    DISTINCT(p.state_code_events),
    r.state_code,
    r.region_name,
    r.region_abbr,
    FORMAT(COUNT(*), 0)
FROM all_participation_data_raw AS p
	LEFT JOIN region_data AS r ON p.state_code_events = r.state_code
GROUP BY 1, 2, 3, 4
ORDER BY 1
LIMIT 100
;

DROP TABLE IF EXISTS all_participation_data_with_regions;

CREATE TABLE IF NOT EXISTS all_participation_data_with_regions AS
SELECT
    p.*,
    r.*
FROM all_participation_data_raw AS p
	LEFT JOIN region_data AS r ON p.state_code_events = r.state_code
-- LIMIT 100
;

ALTER TABLE all_participation_data_with_regions
    ADD INDEX idx_id_events (id_events),
    ADD INDEX idx_name_event_type (name_event_type),
    ADD INDEX idx_name_events (name_events),
    ADD INDEX idx_starts_events (starts_events),
    ADD INDEX idx_id_profile_rr (id_profile_rr),
    ADD INDEX idx_member_number_rr (member_number_rr),
    ADD INDEX idx_gender_code_rr (gender_code),
    ADD INDEX idx_start_date_races (start_date_races),
    ADD INDEX idx_start_date_year_races (start_date_year_races),
    ADD INDEX idx_name_distance_types (name_distance_types),
    ADD INDEX idx_name_race_type (name_race_type),
    ADD INDEX idx_state_code_events (state_code_events),
    ADD INDEX idx_region_abbr (region_abbr),
    ADD INDEX idx_region_name (region_name)

-- *************************************
-- *************************************
-- SALES DATA
-- *************************************
SELECT * FROM sales_key_stats_2015 LIMIT 10; -- ''
SELECT FORMAT(COUNT(*), 0) FROM sales_key_stats_2015 LIMIT 10; -- '3,476,277'
-- *************************************
-- MERGE WITH SALES
-- *************************************
SHOW INDEX FROM all_participation_data_raw;
DROP INDEX idx_id_profile_rr ON all_participation_data_raw;
CREATE INDEX idx_id_profile_rr
ON all_participation_data_raw (id_profile_rr);

SELECT "participation & sales merge", FORMAT(COUNT(*), 0) FROM all_participation_data_raw AS p LEFT JOIN sales_key_stats_2015 AS s ON p.id_profile_rr = s.id_profiles LIMIT 10; -- '27,918,936'
SELECT 
    p.id_profile_rr
	, s.id_profiles
	, FORMAT(COUNT(*), 0)
FROM all_participation_data_raw AS p
	LEFT JOIN sales_key_stats_2015 AS s ON p.id_profile_rr = s.id_profiles
WHERE id_profile_rr IS NOT NULL
GROUP BY 1, 2
ORDER BY 1
LIMIT 100
;
-- *************************************