-- (1) Ironman participants only — one pass, then index.
DROP TABLE IF EXISTS tmp_im_profiles;
CREATE TABLE tmp_im_profiles (
    profile_id VARCHAR(255) NOT NULL,
    PRIMARY KEY (profile_id)
) AS
SELECT DISTINCT id_profile_rr AS profile_id
FROM all_participation_data_with_membership_match
WHERE id_profile_rr IS NOT NULL AND id_profile_rr <> ''
  AND LOWER(name_events_rr) LIKE '%ironman%';

-- (2) Full race history for just those profiles, with derived flags — then index by profile+date.
DROP TABLE IF EXISTS tmp_im_history;
CREATE TABLE tmp_im_history AS
SELECT
    m.id_profile_rr AS profile_id,
    m.id_rr, m.id_race_rr,
    m.name_events_rr, m.name_distance_types, m.name_race_type, m.category,
    m.age, m.age_as_race_results_bin, m.gender_code, m.region_name,
    m.start_date_races, m.start_date_year_races,
    CASE WHEN LOWER(m.name_events_rr) LIKE '%ironman%' THEN 1 ELSE 0 END AS is_ironman_event,
    CASE
        WHEN LOWER(m.name_events_rr) LIKE '%ironman%'
             AND (m.name_events_rr LIKE '%70.3%'  OR LOWER(m.name_distance_types) LIKE '%70.3%'
                  OR LOWER(m.name_distance_types) LIKE '%half%')  THEN '70.3'
        WHEN LOWER(m.name_events_rr) LIKE '%ironman%'
             AND (m.name_events_rr LIKE '%140.6%' OR LOWER(m.name_distance_types) LIKE '%140.6%'
                  OR LOWER(m.name_distance_types) LIKE '%full%')  THEN 'full'
        WHEN LOWER(m.name_events_rr) LIKE '%ironman%'             THEN 'ironman_other'
        ELSE 'non_ironman'
    END AS im_distance_bucket
FROM all_participation_data_with_membership_match m
    JOIN tmp_im_profiles p ON m.id_profile_rr = p.profile_id;

ALTER TABLE tmp_im_history
    ADD INDEX idx_profile_date (profile_id, start_date_races),
    ADD INDEX idx_profile_im   (profile_id, is_ironman_event);

-- (3) Now run Appendix A, but replace `all_participation_data_with_membership_match`
--     in `base` with `tmp_im_history`. You can also drop the im_participants/base_im CTEs
--     (tmp_im_history is already the participant history) and SELECT FROM tmp_im_history
--     directly. Every CTE then scans the small staged table with index support.

WITH base AS (
    SELECT
        id_profile_rr            AS profile_id,
        id_rr, id_race_rr,
        name_events_rr, name_distance_types, name_race_type, category,
        age, age_as_race_results_bin, gender_code, region_name,
        start_date_races, start_date_year_races,
        CASE WHEN LOWER(name_events_rr) LIKE '%ironman%' THEN 1 ELSE 0 END AS is_ironman_event,
        CASE
            WHEN LOWER(name_events_rr) LIKE '%ironman%'
                 AND (name_events_rr LIKE '%70.3%'  OR LOWER(name_distance_types) LIKE '%70.3%'
                      OR LOWER(name_distance_types) LIKE '%half%')                 THEN '70.3'
            WHEN LOWER(name_events_rr) LIKE '%ironman%'
                 AND (name_events_rr LIKE '%140.6%' OR LOWER(name_distance_types) LIKE '%140.6%'
                      OR LOWER(name_distance_types) LIKE '%full%')                 THEN 'full'
            WHEN LOWER(name_events_rr) LIKE '%ironman%'                            THEN 'ironman_other'
            ELSE 'non_ironman'
        END AS im_distance_bucket
    FROM all_participation_data_with_membership_match
    WHERE id_profile_rr IS NOT NULL AND id_profile_rr <> ''
),
im_participants AS (                       -- Ironman participants only
    SELECT DISTINCT profile_id FROM base WHERE is_ironman_event = 1
),
base_im AS (                               -- full race history of those participants
    SELECT b.* FROM base b JOIN im_participants p ON b.profile_id = p.profile_id
),
first_im AS (
    SELECT * FROM (
        SELECT profile_id,
               start_date_races AS first_im_date, start_date_year_races AS first_im_year,
               age AS first_im_age, age_as_race_results_bin AS first_im_age_bucket,
               gender_code AS first_im_gender, im_distance_bucket AS first_im_distance_bucket,
               name_distance_types AS first_im_distance_type, name_race_type AS first_im_race_type,
               category AS first_im_category, region_name AS first_im_region,
               ROW_NUMBER() OVER (PARTITION BY profile_id ORDER BY start_date_races ASC, id_rr ASC) AS rn
        FROM base_im WHERE is_ironman_event = 1
    ) t WHERE rn = 1
),
last_im AS (
    SELECT * FROM (
        SELECT profile_id,
               start_date_races AS last_im_date, start_date_year_races AS last_im_year,
               age AS last_im_age, im_distance_bucket AS last_im_distance_bucket,
               ROW_NUMBER() OVER (PARTITION BY profile_id ORDER BY start_date_races DESC, id_rr DESC) AS rn
        FROM base_im WHERE is_ironman_event = 1
    ) t WHERE rn = 1
),
agg AS (
    SELECT profile_id,
        COUNT(DISTINCT id_race_rr)                                              AS count_races_total,
        COUNT(DISTINCT CASE WHEN is_ironman_event = 1     THEN id_race_rr END)  AS count_ironman_races,
        COUNT(DISTINCT CASE WHEN im_distance_bucket='full' THEN id_race_rr END) AS count_im_full,
        COUNT(DISTINCT CASE WHEN im_distance_bucket='70.3' THEN id_race_rr END) AS count_im_703,
        COUNT(DISTINCT CASE WHEN is_ironman_event = 0     THEN id_race_rr END)  AS count_non_ironman_races,
        COUNT(DISTINCT start_date_year_races)                                   AS count_start_years,
        MIN(start_date_year_races) AS first_race_year,
        MAX(start_date_year_races) AS last_race_year
    FROM base_im GROUP BY profile_id
),
post AS (                                  -- behavior relative to first/last Ironman
    SELECT bi.profile_id,
        COUNT(DISTINCT CASE WHEN bi.start_date_races > f.first_im_date THEN bi.id_race_rr END)                              AS races_after_first_im,
        COUNT(DISTINCT CASE WHEN bi.start_date_races > l.last_im_date  THEN bi.id_race_rr END)                              AS races_after_last_im,
        COUNT(DISTINCT CASE WHEN bi.start_date_races > f.first_im_date AND bi.is_ironman_event=0 THEN bi.id_race_rr END)    AS non_im_races_after_first_im,
        COUNT(DISTINCT CASE WHEN bi.start_date_races > f.first_im_date AND bi.is_ironman_event=1 THEN bi.id_race_rr END)    AS im_races_after_first_im,
        COUNT(DISTINCT CASE WHEN bi.start_date_races > f.first_im_date THEN bi.start_date_year_races END)                   AS years_after_first_im,
        COUNT(DISTINCT CASE WHEN bi.start_date_races > l.last_im_date  THEN bi.start_date_year_races END)                   AS years_after_last_im,
        MAX(CASE WHEN bi.start_date_races > l.last_im_date AND bi.start_date_races <= l.last_im_date + INTERVAL 12 MONTH THEN 1 ELSE 0 END) AS raced_within_12m_after_last_im,
        MAX(CASE WHEN bi.start_date_races > l.last_im_date AND bi.start_date_races <= l.last_im_date + INTERVAL 24 MONTH THEN 1 ELSE 0 END) AS raced_within_24m_after_last_im,
        MAX(CASE WHEN bi.start_date_races > l.last_im_date AND bi.start_date_races <= l.last_im_date + INTERVAL 36 MONTH THEN 1 ELSE 0 END) AS raced_within_36m_after_last_im
    FROM base_im bi
        JOIN first_im f ON bi.profile_id = f.profile_id
        JOIN last_im  l ON bi.profile_id = l.profile_id
    GROUP BY bi.profile_id
)
SELECT
    f.profile_id,
    f.first_im_year, f.first_im_age, f.first_im_age_bucket, f.first_im_gender,
    f.first_im_distance_bucket, f.first_im_distance_type, f.first_im_race_type,
    f.first_im_category, f.first_im_region,
    l.last_im_year, l.last_im_age, l.last_im_distance_bucket,
    a.count_races_total, a.count_ironman_races, a.count_im_full, a.count_im_703,
    a.count_non_ironman_races, a.count_start_years, a.first_race_year, a.last_race_year,
    p.races_after_first_im, p.races_after_last_im, p.non_im_races_after_first_im,
    p.im_races_after_first_im, p.years_after_first_im, p.years_after_last_im,
    CASE WHEN p.races_after_last_im  > 0 THEN 1 ELSE 0 END AS continued_after_last_im,
    CASE WHEN p.races_after_first_im > 0 THEN 1 ELSE 0 END AS continued_after_first_im,
    p.raced_within_12m_after_last_im, p.raced_within_24m_after_last_im, p.raced_within_36m_after_last_im,
    CASE
        WHEN p.races_after_last_im = 0 AND a.count_ironman_races = 1 THEN 'one_and_done'
        WHEN p.im_races_after_first_im > 0                          THEN 'repeat_ironman'
        WHEN p.races_after_last_im  > 0                             THEN 'continued_non_ironman'
        ELSE 'lapsed_after_ironman'
    END AS behavior_segment
FROM first_im f
    JOIN last_im l ON f.profile_id = l.profile_id
    JOIN agg     a ON f.profile_id = a.profile_id
    JOIN post    p ON f.profile_id = p.profile_id;

    