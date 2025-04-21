-- Materialize participation data into a temporary table selecting only necessary columns

-- STEP #1 = CREATE LIMITED VIEW OF PARTICIPATION DATA
DROP TEMPORARY TABLE tmp_participation;
CREATE TEMPORARY TABLE tmp_participation AS
SELECT 
    id_profile_rr,
    id_rr,
    id_race_rr,
    id_events,
    id_sanctioning_events,
    name_events,
    start_date_races,
    start_date_year_races
FROM all_participation_data_raw
WHERE 1 = 1
	-- AND id_profile_rr = 1086344
;
SELECT FORMAT(COUNT(*), 0) FROM tmp_participation LIMIT 10; -- '5880334'
-- Add indexes to improve join and range queries
-- CREATE INDEX idx_tmp_participation_profile ON tmp_participation(id_profile_rr);
-- CREATE INDEX idx_tmp_participation_start_date ON tmp_participation(start_date_races);

-- STEP #2 = CREATE LIMITED VIEW OF THE MEMBER SALES DATA
-- Materialize membership sales data into another temporary table
DROP TEMPORARY TABLE tmp_membership_sales_data;
CREATE TEMPORARY TABLE tmp_membership_sales_data AS
SELECT
    id_profiles,
    id_membership_periods_sa,
    real_membership_types_sa,
    new_member_category_6_sa,
    purchased_on_adjusted_mp,
    starts_mp,
    ends_mp,
    id_events AS id_events_m,
    name_events AS name_events_m
FROM sales_key_stats_2015
WHERE 1 = 1
	-- AND YEAR(starts_mp) IN (2024)
	-- AND YEAR(ends_mp) IN (2024) -- missing three year that overlaps?
	-- AND purchased_on_year_adjusted_mp = 2024
    -- AND start_date_year_races = 2024
	-- AND id_profiles = 1086344
ORDER BY starts_mp ASC
;
SELECT FORMAT(COUNT(DISTINCT id_profiles), 0), FORMAT(COUNT(DISTINCT id_membership_periods_sa), 0) FROM tmp_membership_sales_data LIMIT 10; -- 1,518,575, 3,476,277 -- 243K distinct profiles had 281K membership that ended in 2024, the var could be multiple one-days and/or duplicates
SELECT real_membership_types_sa, FORMAT(COUNT(DISTINCT id_profiles), 0), FORMAT(COUNT(DISTINCT id_membership_periods_sa), 0) FROM tmp_membership_sales_data GROUP BY 1 WITH ROLLUP LIMIT 10; -- 243,203, 280,668; most of the variance is one_day memberships

-- Add indexes to help with join and date filtering
-- CREATE INDEX idx_tmp_sales_data_profile ON tmp_membership_sales_data(id_profiles);
-- CREATE INDEX idx_tmp_sales_data_starts ON tmp_membership_sales_data(starts_mp);
-- CREATE INDEX idx_tmp_sales_data_ends ON tmp_membership_sales_data(ends_mp);

-- STEP #3 = Categorize if a membership has a race result or not
-- Perform the join using the temporary tables
DROP TEMPORARY TABLE tmp_merge_member_sales_with_race_result_match;
CREATE TEMPORARY TABLE tmp_merge_member_sales_with_race_result_match AS
SELECT 
    s.*,
    YEAR(s.purchased_on_adjusted_mp),
    p.id_profile_rr,
    p.id_rr,
    p.id_race_rr,
    p.id_events AS id_events_p,
    p.id_sanctioning_events,
    p.name_events AS name_events_p,
    p.start_date_races,
    p.start_date_year_races, 
    CASE WHEN p.id_rr IS NOT NULL THEN 1 ELSE 0 END AS has_matching_race_record
-- FROM tmp_membership_sales_data AS s
-- 	LEFT JOIN tmp_participation AS p ON s.id_profiles = p.id_profile_rr
FROM sales_key_stats_2015 AS s
	LEFT JOIN all_participation_data_raw AS p ON s.id_profiles = p.id_profile_rr
		AND s.starts_mp <= p.start_date_races
		AND s.ends_mp >= p.start_date_races
WHERE 1 = 1
	-- AND YEAR(s.ends_mp) IN (2025) -- missing 3-year that ends in 2025, 2026 but has race results in 2024, 2 but includes with end date in 2024
	AND s.purchased_on_date_adjusted_mp >= '2025-01-01'
	AND s.purchased_on_date_adjusted_mp <= '2025-03-31'
ORDER BY s.id_profiles, p.start_date_races
;

SELECT FORMAT(COUNT(DISTINCT id_profiles), 0), FORMAT(COUNT(DISTINCT id_profile_rr), 0) AS count_profile_id_distinct, FORMAT(COUNT(*), 0) AS count_all_records FROM tmp_merge_member_sales_with_race_result_match; -- 243,203, 173,381, 369,588

SELECT * FROM tmp_merge_member_sales_with_race_result_match WHERE id_profiles = 125; -- LIMIT 10;
SELECT has_matching_race_record, FORMAT(COUNT(*), 0) FROM tmp_merge_member_sales_with_race_result_match WHERE id_profiles = 125 GROUP BY 1;

SET @ends_year = '2025';
SELECT * FROM tmp_merge_member_sales_with_race_result_match WHERE YEAR(ends_mp) IN (@ends_year) ORDER BY id_profiles, start_date_races ASC; -- LIMIT 10;
SELECT has_matching_race_record, FORMAT(COUNT(DISTINCT id_profiles), 0), FORMAT(COUNT(DISTINCT id_membership_periods_sa), 0), FORMAT(COUNT(DISTINCT id_profile_rr), 0) AS count_profile_id_distinct, FORMAT(COUNT(id_profiles), 0) FROM tmp_merge_member_sales_with_race_result_match WHERE YEAR(ends_mp) IN (@ends_year) GROUP BY 1 WITH ROLLUP;
SELECT has_matching_race_record, real_membership_types_sa, FORMAT(COUNT(DISTINCT id_profiles), 0), FORMAT(COUNT(DISTINCT id_membership_periods_sa), 0), FORMAT(COUNT(DISTINCT id_profile_rr), 0) AS count_profile_id_distinct, FORMAT(COUNT(id_profiles), 0) FROM tmp_merge_member_sales_with_race_result_match WHERE YEAR(ends_mp) IN (@ends_year) GROUP BY 1, 2 WITH ROLLUP;

SELECT 
    has_matching_race_record, 
    real_membership_types_sa,
    -- TOTAL RACE RESULTS
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) = 2025 THEN 1 ELSE 0 END), 0) AS ends_mp_2025,
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) = 2024 THEN 1 ELSE 0 END), 0) AS ends_mp_2024,
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) = 2023 THEN 1 ELSE 0 END), 0) AS ends_mp_2023,
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) = 2022 THEN 1 ELSE 0 END), 0) AS ends_mp_2022,
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) = 2021 THEN 1 ELSE 0 END), 0) AS ends_mp_2021,
	-- FORMAT(SUM(CASE WHEN YEAR(ends_mp) <= 2020 THEN 1 ELSE 0 END), 0) AS ends_mp_less_than_2020,
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) = 2020 THEN 1 ELSE 0 END), 0) AS ends_mp_2020,
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) = 2019 THEN 1 ELSE 0 END), 0) AS ends_mp_2019,
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) = 2018 THEN 1 ELSE 0 END), 0) AS ends_mp_2018,
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) = 2017 THEN 1 ELSE 0 END), 0) AS ends_mp_2017,
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) = 2016 THEN 1 ELSE 0 END), 0) AS ends_mp_2016,
    FORMAT(SUM(CASE WHEN YEAR(ends_mp) <= 2015 THEN 1 ELSE 0 END), 0) AS ends_mp_less_than_2015,
    
    -- UNIQUE PROFILE / MEMBER RESULTS
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) = 2025 THEN id_profiles END), 0) AS ends_mp_2025,
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) = 2024 THEN id_profiles END), 0) AS ends_mp_2024,
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) = 2023 THEN id_profiles END), 0) AS ends_mp_2023,
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) = 2022 THEN id_profiles END), 0) AS ends_mp_2022,
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) = 2021 THEN id_profiles END), 0) AS ends_mp_2021,
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) = 2020 THEN id_profiles END), 0) AS ends_mp_2020,
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) = 2019 THEN id_profiles END), 0) AS ends_mp_2019,
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) = 2018 THEN id_profiles END), 0) AS ends_mp_2018,
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) = 2017 THEN id_profiles END), 0) AS ends_mp_2017,
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) = 2016 THEN id_profiles END), 0) AS ends_mp_2016,
    FORMAT(COUNT(DISTINCT CASE WHEN YEAR(ends_mp) <= 2015 THEN id_profiles END), 0) AS ends_mp_less_than_2015,

	FORMAT(COUNT(DISTINCT id_profiles), 0)
    
FROM tmp_merge_member_sales_with_race_result_match
WHERE 1 = 1
GROUP BY has_matching_race_record WITH ROLLUP
;

-- ******************
-- OTHER QA
-- STEP #4 = QA: FOR ONE-DAY, FIND MEMBERSHIP SALES WITH EVENT NAMES THAT DON'T MATCH THE RACE RESULTS EVENT NAME
-- Perform the join using the temporary tables
-- ******************
SELECT 
    s.*,
    p.id_profile_rr,
    p.id_rr,
    p.id_race_rr,
    p.id_events,
    p.id_sanctioning_events,
    p.name_events AS name_events_p,
    p.start_date_races,
    p.start_date_year_races
FROM tmp_membership_sales_data AS s
	LEFT JOIN tmp_participation AS p ON s.id_profiles = p.id_profile_rr
		AND s.starts_mp <= p.start_date_races
		AND s.ends_mp >= p.start_date_races
WHERE 1 = 1
	AND NOT (s.name_events_m <=> p.name_events)
    AND p.id_profile_rr IS NOT NULL
    AND real_membership_types_sa NOT IN ('adult_annual', 'elite', 'youth_annual')
    AND YEAR(starts_mp) = 2024
ORDER BY s.id_profiles, p.start_date_races
;

