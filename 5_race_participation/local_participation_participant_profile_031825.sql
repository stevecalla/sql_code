USE usat_sales_db; 
SELECT * FROM usat_sales_db.all_participation_data_with_membership_match LIMIT 10;

SELECT id_profile_rr, COUNT(id_race_rr) FROM all_participation_data_with_membership_match GROUP BY 1 LIMIT 10;
-- *************************************
-- EXCEL SHEET COUNT BY NUMBER OF EVENTS
-- *************************************
WITH participant_race_count AS (
	SELECT 
		id_profile_rr 
        , COUNT(DISTINCT id_race_rr)
        
		-- RACE YEARS
		, COUNT(DISTINCT start_date_year_races) AS count_of_start_years  										-- Count of distinct start years
 		, GROUP_CONCAT(DISTINCT start_date_year_races ORDER BY start_date_year_races ASC) AS start_years  -- Concatenate distinct year
 		, MIN(start_date_year_races) AS start_year_least_recent  												-- Get the most recent start year
		, MAX(start_date_year_races) AS start_year_most_recent  												-- Get the most recent start year
        
	FROM all_participation_data_with_membership_match
	-- WHERE 1 = 1
		-- AND start_date_year_races = 2025
        -- AND id_profile_rr = '35'
	GROUP BY id_profile_rr
	-- HAVING count_rr > 1
	-- ORDER BY CAST(id_profile_rr AS UNSIGNED)
	-- LIMIT 100
)

SELECT * FROM participant_race_count LIMIT 10;

, participant_race_count_average AS (
        SELECT 
                profile_id_rr,
                count_rr,
                count_of_start_years,
                start_years,
                start_year_least_recent,
                start_year_most_recent,
                CASE 
                        WHEN count_of_start_years > 0 THEN count_rr / count_of_start_years
                        ELSE 0 
                END AS avg_races_per_year  -- Calculate average races per year
        FROM participant_race_count
        GROUP BY profile_id_rr, count_rr, count_of_start_years, start_years, start_year_least_recent, start_year_most_recent
        -- ORDER BY CAST(profile_id_rr AS UNSIGNED)
        -- LIMIT 100
)
SELECT * FROM participant_race_count_average LIMIT 10;
 
, summarize_by_count AS (
        SELECT
                count_rr AS number_of_races
                , COUNT(*) AS count_of_participants
                , AVG(avg_races_per_year) -- AVERAGE RACE COUNT
                , SUM(COUNT(*)) OVER (ORDER BY count_rr) AS running_total  -- Running total
                , 100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percent_of_total  -- Percentage of total
                
                -- MOST RECENT START YEAR       
                , FORMAT(SUM(CASE WHEN start_year_most_recent < 2020 THEN 1 ELSE 0 END), 0) AS start_year_most_recent_before_2020
                , FORMAT(SUM(CASE WHEN start_year_most_recent < 2023 THEN 1 ELSE 0 END), 0) AS start_year_most_recent_before_2023
                , FORMAT(SUM(CASE WHEN start_year_most_recent IN (2023) THEN 1 ELSE 0 END), 0) AS start_year_most_recent_2023
                , FORMAT(SUM(CASE WHEN start_year_most_recent IN (2024) THEN 1 ELSE 0 END), 0) AS start_year_most_recent_2024

                -- NUMBER OF START YEARS
                , FORMAT(SUM(CASE WHEN count_of_start_years IN (1) THEN 1 ELSE 0 END), 0) AS start_year_count_one
                , FORMAT(SUM(CASE WHEN count_of_start_years IN (2) THEN 1 ELSE 0 END), 0) AS start_year_count_two
                , FORMAT(SUM(CASE WHEN count_of_start_years IN (3) THEN 1 ELSE 0 END), 0) AS start_year_count_three
                , FORMAT(SUM(CASE WHEN count_of_start_years IN (4) THEN 1 ELSE 0 END), 0) AS start_year_count_four
                , FORMAT(SUM(CASE WHEN count_of_start_years IN (5) THEN 1 ELSE 0 END), 0) AS start_year_count_five
                , FORMAT(SUM(CASE WHEN count_of_start_years >= (6) THEN 1 ELSE 0 END), 0) AS start_year_count_six_plus

        FROM participant_race_count_average
        GROUP BY count_rr
        ORDER BY CAST(count_rr AS UNSIGNED)
)

SELECT * FROM participant_race_count_average; 
-- SELECT * FROM summarize_by_count;

-- finish_status
-- pivot by year
-- group concat the number of race years... proxy for annual is someone with races over multiple years?

-- QA CHECKS
-- #1) SOME # OF RACES = 0? LEGIT = MEANS THE RACE ID WAS BLANK
-- SELECT
--         *
-- FROM participant_race_count AS mr
--         LEFT JOIN race_results AS rr ON mr.profile_id_rr = rr.profile_id
-- WHERE count_rr IN (0);
-- #2) SOME # OF RACES = 725806? LEGIT = MEANS NO PROFILE ID EXISTS
-- SELECT
--         *
-- FROM participant_race_count AS mr
--         LEFT JOIN race_results AS rr ON mr.profile_id_rr = rr.profile_id
-- WHERE count_rr IN (725806);