USE usat_sales_db;

-- 0) Support tables
SELECT * FROM all_participation_min_start_date_races LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM all_participation_min_start_date_races LIMIT 10;
SELECT * FROM all_participation_prev_race_date LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM all_participation_prev_race_date LIMIT 10;

-- 1) Peek latest rows by id_profiles
SELECT * FROM all_participation_data_with_membership_match LIMIT 100;
-- 2) Total row count (formatted) in 2015 table
SELECT FORMAT(COUNT(*), 0) FROM all_participation_data_with_membership_match LIMIT 10;
-- 3) Purchased on year x gender breakdown with member_created_at_category = new (created_year), distinct profiles, and total rows (formatted)
SELECT
    purchased_on_year_adjusted_mp,
    gender_code,
    
    -- Distinct profiles flagged as "new" / repeat
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category_purchased_on IS NULL OR member_created_at_category_purchased_on = 'created_year' THEN id_profiles END), 0) AS count_distinct_member_created_at_new,
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category_purchased_on IS NULL OR member_created_at_category_purchased_on = 'after_created_year' THEN id_profiles END), 0) AS count_distinct_member_created_at_repeat,
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category_purchased_on IS NULL OR member_created_at_category_purchased_on = 'after_created_year' OR member_created_at_category_purchased_on = 'created_year' THEN id_profiles END), 0) AS count_distinct_member_created_at_total,
    FORMAT(COUNT(DISTINCT id_profiles), 0) AS distinct_id_profiles,
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category_purchased_on IS NULL OR member_created_at_category_purchased_on = 'after_created_year' OR member_created_at_category_purchased_on = 'created_year' THEN id_profiles END) - COUNT(DISTINCT id_profiles), 0) AS var_v1,
    
    -- Count of rows
    FORMAT(SUM(CASE WHEN member_created_at_category_purchased_on = 'created_year' THEN 1 ELSE 0 END), 0) AS count_total_member_created_at_new,
    FORMAT(SUM(CASE WHEN member_created_at_category_purchased_on IS NULL OR member_created_at_category_purchased_on = 'after_created_year' THEN 1 ELSE 0 END), 0) AS count_total_member_created_at_repeat,
    FORMAT(SUM(CASE WHEN member_created_at_category_purchased_on IS NULL OR member_created_at_category_purchased_on = 'after_created_year' OR member_created_at_category_purchased_on = 'created_year' THEN 1 ELSE 0 END), 0) AS count_total_member_created_at_total,
    FORMAT(COUNT(*), 0) AS total_rows,
    FORMAT(SUM(CASE WHEN member_created_at_category_purchased_on IS NULL OR member_created_at_category_purchased_on = 'after_created_year' OR member_created_at_category_purchased_on = 'created_year' THEN 1 ELSE 0 END) - COUNT(*), 0) AS var_v2
    
FROM all_participation_data_with_membership_match
WHERE 1 = 1
  AND age_as_race_results_bin IN ('20-29')
  AND gender_code = 'f'
  -- AND purchased_on_year_adjusted_mp <> '2025'
GROUP BY
  purchased_on_year_adjusted_mp,
  gender_code
ORDER BY purchased_on_year_adjusted_mp DESC
;

-- 4) Race starts year x gender breakdown with member_created_at_category = new (created_year), distinct profiles, and total rows (formatted)
SELECT
    start_date_year_races,
    gender_code,
    
    -- Distinct profiles flagged as "new" / repeat; Removed members = null
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category_starts_mp = 'created_year' THEN id_profiles END), 0) AS count_distinct_member_created_at_new,
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category_starts_mp = 'after_created_year' THEN id_profiles END), 0) AS count_distinct_member_created_at_repeat,
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category_starts_mp IS NULL THEN id_profiles END), 0) AS count_distinct_member_created_at_null,
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category_starts_mp = 'after_created_year' OR member_created_at_category_starts_mp = 'created_year' THEN id_profiles END), 0) AS count_distinct_member_created_at_total,
    FORMAT(COUNT(DISTINCT id_profiles), 0) AS distinct_id_profiles,
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category_starts_mp = 'after_created_year' OR member_created_at_category_starts_mp = 'created_year' THEN id_profiles END) - COUNT(DISTINCT id_profiles), 0) AS var_v1,
    
    -- Count of rows
    FORMAT(SUM(CASE WHEN member_created_at_category_starts_mp = 'created_year' THEN 1 ELSE 0 END), 0) AS count_total_member_created_at_new,
    FORMAT(SUM(CASE WHEN member_created_at_category_starts_mp = 'after_created_year' THEN 1 ELSE 0 END), 0) AS count_total_member_created_at_repeat,
    FORMAT(SUM(CASE WHEN member_created_at_category_starts_mp IS NULL THEN 1 ELSE 0 END), 0) AS count_total_member_created_at_repeat,
    FORMAT(SUM(CASE WHEN member_created_at_category_starts_mp = 'after_created_year' OR member_created_at_category_starts_mp = 'created_year' THEN 1 ELSE 0 END), 0) AS count_total_member_created_at_total,
    FORMAT(COUNT(*), 0) AS total_rows,
    FORMAT(SUM(CASE WHEN member_created_at_category_starts_mp IS NULL OR member_created_at_category_starts_mp = 'after_created_year' OR member_created_at_category_starts_mp = 'created_year' THEN 1 ELSE 0 END) - COUNT(*), 0) AS var_v2
    
FROM all_participation_data_with_membership_match
WHERE 1 = 1
  AND age_as_race_results_bin IN ('20-29')
  AND gender_code = 'f'
  -- AND purchased_on_year_adjusted_mp <> '2025'
GROUP BY
  start_date_year_races,
  gender_code	
ORDER BY start_date_year_races DESC
;

-- 4) Find profiles with member created at category both new & repeat in 2024
SELECT
    purchased_on_year_adjusted_mp,
    gender_code
    id_profiles,
    GROUP_CONCAT(member_created_at_category_purchased_on)
FROM all_participation_data_with_membership_match
WHERE 1 = 1
  AND age_as_race_results_bin IN ('20-29')
  AND gender_code = 'F'
  AND member_created_at_category_purchased_on IN ('created_year', 'after_created_year')
  AND purchased_on_year_adjusted_mp = '2024'
  -- AND id_profiles = '235475'
GROUP BY
    purchased_on_year_adjusted_mp,
    gender_code,
    id_profiles
HAVING
    SUM(member_created_at_category_purchased_on = 'created_year') > 0
    AND SUM(member_created_at_category_purchased_on = 'after_created_year') > 0
ORDER BY purchased_on_year_adjusted_mp DESC, id_profiles
LIMIT 10
;

-- 4a) Find profiles with member created at category both new & repeat in 2024
SELECT
	start_date_year_races,
    gender_code,
    id_profiles,
    GROUP_CONCAT(member_created_at_category_starts_mp)
FROM all_participation_data_with_membership_match
WHERE 1 = 1
	AND age_as_race_results_bin IN ('20-29')
	AND gender_code = 'F'
	AND member_created_at_category_starts_mp IN ('created_year', 'after_created_year')
	AND start_date_year_races = '2024'
	-- AND start_date_year_races = '2023'
	-- AND id_profiles = '235475'
	AND id_profiles = '2264133'
GROUP BY
    start_date_year_races,
    gender_code,
    id_profiles
HAVING
    SUM(member_created_at_category_starts_mp = 'created_year') > 0
    AND SUM(member_created_at_category_starts_mp = 'after_created_year') > 0
ORDER BY id_profiles ASC, start_date_year_races ASC
-- LIMIT 100
;

-- 4b) Detail of profile with multiple member created at category
WITH min_start_date_races AS (
	SELECT
		id_profile_rr,
        MIN(start_date_year_races) AS min_start_date_year_races
	FROM all_participation_data_raw
    WHERE id_profile_rr = '2264133'
    GROUP BY 1
    ORDER BY 1 DESC
    LIMIT 10
)
-- SELECT * FROM min_start_date_races;
SELECT
	id_profiles,
    id_rr,
    new_member_category_6_sa,
    member_created_at_category_purchased_on,
    member_created_at_category_starts_mp,
    purchased_on_date_adjusted_mp,
    purchased_on_year_adjusted_mp,
    start_date_races,
    start_date_year_races,
    first_starts_mp,
    starts_mp,
    age,
    age_as_race_results_bin,
    mr.min_start_date_year_races,
    CASE
		WHEN start_date_year_races = mr.min_start_date_year_races THEN 'created_year'
		WHEN start_date_year_races <> mr.min_start_date_year_races THEN 'after_created_year'
		ELSE 'error_first_purchase_year_category'
	END AS member_created_at_category_starts_mp
FROM all_participation_data_with_membership_match p
	LEFT JOIN min_start_date_races AS mr ON mr.id_profile_rr = p.id_profiles
WHERE 1 = 1
	-- AND age_as_race_results_bin IN ('20-29')
	AND gender_code = 'F'
	AND member_created_at_category_starts_mp IN ('created_year', 'after_created_year')
	-- AND start_date_year_races = '2024'
	-- AND start_date_year_races = '2023'
	-- AND id_profiles = '924274'
	AND id_profiles = '2264133'
ORDER BY start_date_races ASC, id_profiles
;





