USE usat_sales_db;

-- #1 Build skinny participation table first.
DROP TABLE IF EXISTS tmp_01_ordered_races_safe;

CREATE TABLE tmp_01_ordered_races_safe AS
SELECT
    '#1 tmp_01_ordered_races_safe' AS query_label,
    id_profile_rr,
    id_profiles,
    id_rr,
    start_date_races,
    start_date_year_races,
    is_ironman
FROM all_participation_data_with_membership_match
WHERE id_profile_rr IS NOT NULL
  AND id_profile_rr <> '';

SELECT '#1 Count tmp_01_ordered_races_safe' AS query_label, COUNT(*) AS row_count FROM tmp_01_ordered_races_safe;

ALTER TABLE tmp_01_ordered_races_safe ADD INDEX idx_profile (id_profile_rr);

SELECT
    '#1 Summary tmp_01_ordered_races_safe' AS query_label,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT id_profile_rr) AS distinct_profiles,
    SUM(CASE WHEN is_ironman = 1 THEN 1 ELSE 0 END) AS ironman_rows
FROM tmp_01_ordered_races_safe;


-- #2 Roll up by profile/year first.
DROP TABLE IF EXISTS tmp_02_profile_rollup_by_year_safe;

CREATE TABLE tmp_02_profile_rollup_by_year_safe AS
SELECT
    '#2 tmp_02_profile_rollup_by_year_safe' AS query_label,
    id_profile_rr,
    start_date_year_races,
    COUNT(*) AS total_races_year,
    MIN(start_date_races) AS first_race_date_year,
    MAX(start_date_races) AS last_race_date_year,
    SUM(CASE WHEN is_ironman = 1 THEN 1 ELSE 0 END) AS total_ironman_races_year,
    SUM(CASE WHEN is_ironman = 0 OR is_ironman IS NULL THEN 1 ELSE 0 END) AS total_non_ironman_races_year,
    COUNT(DISTINCT id_profiles) AS distinct_membership_profiles_matched_year,
    SUM(CASE WHEN id_profiles IS NOT NULL THEN 1 ELSE 0 END) AS membership_matched_race_rows_year,
    SUM(CASE WHEN id_profiles IS NULL THEN 1 ELSE 0 END) AS no_membership_matched_race_rows_year
FROM tmp_01_ordered_races_safe
GROUP BY
    id_profile_rr,
    start_date_year_races;

ALTER TABLE tmp_02_profile_rollup_by_year_safe ADD INDEX idx_profile_year (id_profile_rr, start_date_year_races);

SELECT '#2 Count tmp_02_profile_rollup_by_year_safe' AS query_label, COUNT(*) AS row_count FROM tmp_02_profile_rollup_by_year_safe;


-- #3 Roll up to one row per race-result profile.
DROP TABLE IF EXISTS tmp_03_profile_rollup_safe;

CREATE TABLE tmp_03_profile_rollup_safe AS
SELECT
    '#3 tmp_03_profile_rollup_safe' AS query_label,
    id_profile_rr,
    SUM(total_races_year) AS total_races,
    MIN(first_race_date_year) AS first_race_date,
    MAX(last_race_date_year) AS last_race_date,
    MIN(start_date_year_races) AS first_race_year,
    MAX(start_date_year_races) AS last_race_year,
    COUNT(*) AS active_year_count,
    SUM(total_ironman_races_year) AS total_ironman_races,
    SUM(total_non_ironman_races_year) AS total_non_ironman_races,
    SUM(distinct_membership_profiles_matched_year) AS distinct_membership_profiles_matched_approx,
    SUM(membership_matched_race_rows_year) AS membership_matched_race_rows,
    SUM(no_membership_matched_race_rows_year) AS no_membership_matched_race_rows
FROM tmp_02_profile_rollup_by_year_safe
GROUP BY id_profile_rr;

ALTER TABLE tmp_03_profile_rollup_safe ADD INDEX idx_profile (id_profile_rr);

SELECT '#3 Count tmp_03_profile_rollup_safe' AS query_label, COUNT(*) AS row_count FROM tmp_03_profile_rollup_safe;


-- #4 Roll up Ironman rows by profile/year first.
DROP TABLE IF EXISTS tmp_04_ironman_by_year_safe;

CREATE TABLE tmp_04_ironman_by_year_safe AS
SELECT
    '#4 tmp_04_ironman_by_year_safe' AS query_label,
    id_profile_rr,
    start_date_year_races,
    MIN(start_date_races) AS first_ironman_date_year,
    MAX(start_date_races) AS last_ironman_date_year,
    COUNT(*) AS total_ironman_races_year
FROM tmp_01_ordered_races_safe
WHERE is_ironman = 1
GROUP BY
    id_profile_rr,
    start_date_year_races;

ALTER TABLE tmp_04_ironman_by_year_safe ADD INDEX idx_profile_year (id_profile_rr, start_date_year_races);

SELECT '#4 Count tmp_04_ironman_by_year_safe' AS query_label, COUNT(*) AS row_count FROM tmp_04_ironman_by_year_safe;

-- #5 Roll up to one row per Ironman profile, including first/last Ironman behavior.

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE tmp_01_ordered_races_safe ADD INDEX idx_profile_date (id_profile_rr, start_date_races);

DROP TABLE IF EXISTS tmp_05_ironman_positions_safe;

CREATE TABLE tmp_05_ironman_positions_safe AS
SELECT
    '#5 tmp_05_ironman_positions_safe' AS query_label,

    i.id_profile_rr,

    MIN(i.first_ironman_date_year) AS first_ironman_date,
    MAX(i.last_ironman_date_year) AS last_ironman_date,

    MIN(i.start_date_year_races) AS first_ironman_year,
    MAX(i.start_date_year_races) AS last_ironman_year,

    SUM(i.total_ironman_races_year) AS total_ironman_races,
    COUNT(*) AS distinct_ironman_year_count,

    CAST(NULL AS SIGNED) AS first_ironman_order,
    CAST(NULL AS SIGNED) AS last_ironman_order,
    CAST(NULL AS SIGNED) AS races_before_first_ironman,
    CAST(NULL AS SIGNED) AS races_after_first_ironman,
    CAST(NULL AS SIGNED) AS races_before_last_ironman,
    CAST(NULL AS SIGNED) AS races_after_last_ironman

FROM tmp_04_ironman_by_year_safe i
GROUP BY i.id_profile_rr;

ALTER TABLE tmp_05_ironman_positions_safe ADD INDEX idx_profile (id_profile_rr);


-- #5A Add first Ironman order.
UPDATE tmp_05_ironman_positions_safe i
SET
    i.races_before_first_ironman = (
        SELECT COUNT(*)
        FROM tmp_01_ordered_races_safe r
        WHERE r.id_profile_rr = i.id_profile_rr
          AND r.start_date_races < i.first_ironman_date
    ),
    i.first_ironman_order = (
        SELECT COUNT(*)
        FROM tmp_01_ordered_races_safe r
        WHERE r.id_profile_rr = i.id_profile_rr
          AND r.start_date_races < i.first_ironman_date
    ) + 1;


-- #5B Add last Ironman order.
UPDATE tmp_05_ironman_positions_safe i
SET
    i.races_before_last_ironman = (
        SELECT COUNT(*)
        FROM tmp_01_ordered_races_safe r
        WHERE r.id_profile_rr = i.id_profile_rr
          AND r.start_date_races < i.last_ironman_date
    ),
    i.last_ironman_order = (
        SELECT COUNT(*)
        FROM tmp_01_ordered_races_safe r
        WHERE r.id_profile_rr = i.id_profile_rr
          AND r.start_date_races <= i.last_ironman_date
    );


-- #5C Add races after first/last Ironman.
UPDATE tmp_05_ironman_positions_safe i
INNER JOIN tmp_03_profile_rollup_safe p
    ON i.id_profile_rr = p.id_profile_rr
SET
    i.races_after_first_ironman = p.total_races - i.first_ironman_order,
    i.races_after_last_ironman = p.total_races - i.last_ironman_order;


-- #5D Check result.
SELECT '#5 Count tmp_05_ironman_positions_safe' AS query_label, COUNT(*) AS row_count FROM tmp_05_ironman_positions_safe;

SELECT '#5 Preview tmp_05_ironman_positions_safe' AS query_label, s.*
FROM tmp_05_ironman_positions_safe AS s
ORDER BY total_ironman_races DESC, first_ironman_date
LIMIT 1000;

SET SQL_SAFE_UPDATES = 1;

-- #6 Create empty profile/year dimension table first.
DROP TABLE IF EXISTS tmp_06_profile_dimensions_by_year_safe;

CREATE TABLE tmp_06_profile_dimensions_by_year_safe (
    query_label VARCHAR(100),
    id_profile_rr VARCHAR(255),
    start_date_year_races INT,
    gender_code_year VARCHAR(50),
    age_year INT,
    age_as_race_results_bin_year VARCHAR(100),
    distinct_event_type_count_year INT,
    distinct_distance_type_count_year INT,
    distinct_race_type_count_year INT,
    distinct_event_state_count_year INT,
    distinct_event_region_count_year INT
);

-- #6 Insert dimensions year-by-year to avoid one huge GROUP BY.
INSERT INTO tmp_06_profile_dimensions_by_year_safe
SELECT
    '#6 tmp_06_profile_dimensions_by_year_safe' AS query_label,
    id_profile_rr,
    start_date_year_races,
    MAX(gender_code) AS gender_code_year,
    MAX(age) AS age_year,
    MAX(age_as_race_results_bin) AS age_as_race_results_bin_year,
    COUNT(DISTINCT name_event_type) AS distinct_event_type_count_year,
    COUNT(DISTINCT name_distance_types) AS distinct_distance_type_count_year,
    COUNT(DISTINCT name_race_type) AS distinct_race_type_count_year,
    COUNT(DISTINCT state_code_events) AS distinct_event_state_count_year,
    COUNT(DISTINCT region_name) AS distinct_event_region_count_year
FROM all_participation_data_with_membership_match
WHERE id_profile_rr IS NOT NULL
  AND id_profile_rr <> ''
  AND start_date_year_races = 2026
GROUP BY id_profile_rr, start_date_year_races;

-- Repeat this INSERT for each year you need by changing 2026 to 2025, 2024, etc.

ALTER TABLE tmp_06_profile_dimensions_by_year_safe ADD INDEX idx_profile_year (id_profile_rr, start_date_year_races);

SELECT '#6 Count tmp_06_profile_dimensions_by_year_safe' AS query_label, COUNT(*) AS row_count FROM tmp_06_profile_dimensions_by_year_safe;

-- #7 Roll dimensions to one row per profile.
DROP TABLE IF EXISTS tmp_07_profile_dimensions_safe;

CREATE TABLE tmp_07_profile_dimensions_safe AS
SELECT
    '#7 tmp_07_profile_dimensions_safe' AS query_label,
    id_profile_rr,
    MAX(gender_code_year) AS gender_code,
    MAX(age_year) AS age,
    MAX(age_as_race_results_bin_year) AS age_as_race_results_bin,
    SUM(distinct_event_type_count_year) AS distinct_event_type_count_approx,
    SUM(distinct_distance_type_count_year) AS distinct_distance_type_count_approx,
    SUM(distinct_race_type_count_year) AS distinct_race_type_count_approx,
    SUM(distinct_event_state_count_year) AS distinct_event_state_count_approx,
    SUM(distinct_event_region_count_year) AS distinct_event_region_count_approx
FROM tmp_06_profile_dimensions_by_year_safe
GROUP BY id_profile_rr;

ALTER TABLE tmp_07_profile_dimensions_safe ADD INDEX idx_profile (id_profile_rr);

SELECT '#7 Count tmp_07_profile_dimensions_safe' AS query_label, COUNT(*) AS row_count FROM tmp_07_profile_dimensions_safe;


-- #8A Create Ironman profile output table with dimensions.
DROP TABLE IF EXISTS tmp_08a_ironman_profiles_safe;

CREATE TABLE tmp_08a_ironman_profiles_safe AS
SELECT
    '#8A tmp_08a_ironman_profiles_safe' AS query_label,
    p.id_profile_rr,
    1 AS has_ironman,
    'Ironman Profile' AS ironman_profile_type,
    d.gender_code,
    d.age,
    d.age_as_race_results_bin,
    p.total_races,
    i.total_ironman_races,
    p.total_non_ironman_races,
    p.first_race_date,
    p.last_race_date,
    p.first_race_year,
    p.last_race_year,
    p.active_year_count,
    i.first_ironman_date,
    i.last_ironman_date,
    i.first_ironman_year,
    i.last_ironman_year,
    i.distinct_ironman_year_count,
    d.distinct_event_type_count_approx,
    d.distinct_distance_type_count_approx,
    d.distinct_race_type_count_approx,
    d.distinct_event_state_count_approx,
    d.distinct_event_region_count_approx,
    p.distinct_membership_profiles_matched_approx,
    p.membership_matched_race_rows,
    p.no_membership_matched_race_rows,
    CASE WHEN p.membership_matched_race_rows > 0 THEN 1 ELSE 0 END AS ever_had_membership_match
FROM tmp_03_profile_rollup_safe p
INNER JOIN tmp_05_ironman_positions_safe i
    ON p.id_profile_rr = i.id_profile_rr
LEFT JOIN tmp_07_profile_dimensions_safe d
    ON p.id_profile_rr = d.id_profile_rr;

ALTER TABLE tmp_08a_ironman_profiles_safe ADD INDEX idx_profile (id_profile_rr);

SELECT '#8A Preview tmp_08a_ironman_profiles_safe' AS query_label, s.* FROM tmp_08a_ironman_profiles_safe AS s ORDER BY total_races DESC LIMIT 1000;


-- #8B Create Non-Ironman profile output table with dimensions.
DROP TABLE IF EXISTS tmp_08b_non_ironman_profiles_safe;

CREATE TABLE tmp_08b_non_ironman_profiles_safe AS
SELECT
    '#8B tmp_08b_non_ironman_profiles_safe' AS query_label,
    p.id_profile_rr,
    0 AS has_ironman,
    'Non-Ironman Profile' AS ironman_profile_type,
    d.gender_code,
    d.age,
    d.age_as_race_results_bin,
    p.total_races,
    0 AS total_ironman_races,
    p.total_non_ironman_races,
    p.first_race_date,
    p.last_race_date,
    p.first_race_year,
    p.last_race_year,
    p.active_year_count,
    d.distinct_event_type_count_approx,
    d.distinct_distance_type_count_approx,
    d.distinct_race_type_count_approx,
    d.distinct_event_state_count_approx,
    d.distinct_event_region_count_approx,
    p.distinct_membership_profiles_matched_approx,
    p.membership_matched_race_rows,
    p.no_membership_matched_race_rows,
    CASE WHEN p.membership_matched_race_rows > 0 THEN 1 ELSE 0 END AS ever_had_membership_match
FROM tmp_03_profile_rollup_safe p
LEFT JOIN tmp_05_ironman_positions_safe i
    ON p.id_profile_rr = i.id_profile_rr
LEFT JOIN tmp_07_profile_dimensions_safe d
    ON p.id_profile_rr = d.id_profile_rr
WHERE i.id_profile_rr IS NULL;

ALTER TABLE tmp_08b_non_ironman_profiles_safe ADD INDEX idx_profile (id_profile_rr);

SELECT '#8B Preview tmp_08b_non_ironman_profiles_safe' AS query_label, s.* FROM tmp_08b_non_ironman_profiles_safe AS s ORDER BY total_races DESC, active_year_count DESC LIMIT 1000;


-- #9 Create Ironman counts output table.
DROP TABLE IF EXISTS tmp_09_ironman_counts_safe;

CREATE TABLE tmp_09_ironman_counts_safe AS
SELECT
    '#9 tmp_09_ironman_counts_safe' AS query_label,
    i.first_ironman_year,
    p.total_races,
    p.total_races - i.total_ironman_races AS non_ironman_races_for_profile,
    i.total_ironman_races,
    CASE WHEN p.membership_matched_race_rows > 0 THEN 1 ELSE 0 END AS ever_had_membership_match,
    CASE
        WHEN p.membership_matched_race_rows = p.total_races THEN 'All Race Rows Matched Membership'
        WHEN p.membership_matched_race_rows > 0 THEN 'Some Race Rows Matched Membership'
        ELSE 'No Race Rows Matched Membership'
    END AS membership_match_profile_type,
    COUNT(*) AS profile_count
FROM tmp_05_ironman_positions_safe i
INNER JOIN tmp_03_profile_rollup_safe p
    ON i.id_profile_rr = p.id_profile_rr
GROUP BY
    i.first_ironman_year,
    p.total_races,
    p.total_races - i.total_ironman_races,
    i.total_ironman_races,
    ever_had_membership_match,
    membership_match_profile_type;

SELECT '#9 Preview tmp_09_ironman_counts_safe' AS query_label, s.* FROM tmp_09_ironman_counts_safe AS s ORDER BY first_ironman_year, total_races DESC LIMIT 1000;