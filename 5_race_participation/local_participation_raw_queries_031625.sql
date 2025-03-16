USE usat_sales_db;

SELECT * FROM all_participation_data_raw LIMIT 10;
SELECT COUNT(*), SUM(count_all_participation) FROM all_participation_data_raw;
SELECT "participation data", start_date_year_races, COUNT(*), SUM(count_all_participation) FROM all_participation_data_raw GROUP BY 2;

-- *************************************
-- QUERY #1 
-- EXCEL SHEET COUNT BY RACE YEAR
-- missing data with no race start date; didn't load this data
-- *************************************
SELECT 
    start_date_year_races AS race_year,
    FORMAT(COUNT(CASE WHEN id_race_rr IS NULL THEN 1 END), 0) AS count_null_race_id,
    FORMAT(COUNT(CASE WHEN id_profile_rr IS NULL THEN 1 END), 0) AS count_null_profile_id,
    FORMAT(COUNT(CASE WHEN id_profile_rr IS NOT NULL THEN 1 END), 0) AS count_not_null_profile_id,
    FORMAT(COUNT(CASE WHEN member_number_rr IS NULL THEN 1 END), 0) AS count_null_member_number,
    FORMAT(COUNT(CASE WHEN member_number_rr IS NOT NULL THEN 1 END), 0) AS count_not_null_member_number,
    FORMAT(COUNT(*), 0) AS total_count
FROM all_participation_data_raw
GROUP BY start_date_year_races WITH ROLLUP
;
-- *************************************

-- *************************************
-- QUERY #2
-- EXCEL SHEET COUNT BY NUMBER OF EVENTS
-- *************************************
WITH participant_race_count AS (
        SELECT 
                id_profile_rr AS profile_id_rr
                , member_number_rr
                , COUNT(id_race_rr) AS count_rr

                -- RACE YEARS
                , COUNT(DISTINCT YEAR(start_date_races)) AS count_of_start_years  -- Count of distinct start years
                , GROUP_CONCAT(DISTINCT YEAR(start_date_races) ORDER BY YEAR(start_date_races) ASC) AS start_years  -- Concatenate distinct year
                , MIN(YEAR(start_date_races)) AS start_year_least_recent  -- Get the most recent start year
                , MAX(YEAR(start_date_races)) AS start_year_most_recent  -- Get the most recent start year

                -- RACE DISTANCES

                -- RACE DETAILS

                -- FINISH STATUS
        FROM all_participation_data_raw
        -- WHERE 
                -- YEAR(start_date_races) = 2022
                -- ADD IN RACE STATUS... FINISH ET AL
        GROUP BY id_profile_rr, member_number_rr
        ORDER BY CAST(id_profile_rr AS UNSIGNED)
        -- HAVING count_rr > 1
        -- LIMIT 100   
),

participant_race_count_average AS (
        SELECT 
                profile_id_rr,
                member_number_rr,
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
        GROUP BY profile_id_rr, member_number_rr, count_rr, count_of_start_years, start_years, start_year_least_recent, start_year_most_recent
        ORDER BY CAST(profile_id_rr AS UNSIGNED)
        -- LIMIT 100
),
 
summarize_by_count AS (
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

-- QUERY #2A
SELECT * FROM participant_race_count_average; 
-- QUERY #2B
-- SELECT * FROM summarize_by_count;