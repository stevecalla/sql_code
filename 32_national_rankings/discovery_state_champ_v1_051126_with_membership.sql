USE vapor;

WITH filtered_results AS (
    SELECT
        -- PROFILE / USER
        p.id AS id_profiles,
        p.date_of_birth AS date_of_birth_profiles,
        p.deleted_at AS deleted_at_profiles,
        p.name AS full_name_profiles,
        p.first_name AS first_name_profiles,
        p.last_name AS last_name_profiles,
        u.email AS email_users,
        u.deleted_at AS deleted_at_users,

        -- GENDER
        g.short AS flag_genders,
        g.label AS label_genders,

        -- LOCATION
        st.name AS state_profile_states,

        -- EVENT / RACE
        e.id AS id_events,
        e.starts AS starts_events,
        e.name AS name_events,
        e.state_name AS state_name_events,
        e.event_type_id AS event_type_id_events,
        e.sanctioning_event_id AS sanctioning_event_id_events,
        e.deleted_at AS deleted_at_events,
        r.designation AS designation_races,
        r.deleted_at AS deleted_at_races,
        rt.name AS name_race_types,
        dt.name AS name_distance_types,

        -- RACE RESULT
        rr.id AS id_race_results,
        rr.created_at AS created_at_race_results,
        rr.finish_status AS finish_status_race_results,
        rr.category AS category_race_results,
        rr.first_name AS first_name_race_results,
        rr.last_name AS last_name_race_results,
        rr.age AS age_race_results,
        rr.gender_code AS gender_code_race_results,
        rr.milliseconds AS milliseconds_race_results,
        SEC_TO_TIME(FLOOR(rr.milliseconds / 1000)) AS formatted_time_race_results

    FROM race_results AS rr
        LEFT JOIN profiles AS p ON rr.profile_id = p.id
        INNER JOIN races AS r ON rr.race_id = r.id
        INNER JOIN events AS e ON r.event_id = e.id
        INNER JOIN race_types AS rt ON r.race_type_id = rt.id
        INNER JOIN distance_types AS dt ON r.distance_type_id = dt.id
        LEFT JOIN users AS u ON p.user_id = u.id
        LEFT JOIN genders AS g ON p.gender_id = g.id
        INNER JOIN addresses AS ad ON p.primary_address_id = ad.id
        INNER JOIN states AS st ON ad.state_id = st.id

    WHERE 1 = 1
        AND r.designation = 'Adult Race'
        AND rr.created_at >= '2023-07-25 00:00:00'
        AND rr.finish_status NOT IN ('DNF', 'DNS', 'DQ')
        AND e.deleted_at IS NULL
        AND r.deleted_at IS NULL
        AND u.deleted_at IS NULL
        AND p.deleted_at IS NULL
        AND rt.name IN ('Triathlon', 'Triathlon Off-Road')
        AND rr.category <> 'ELITE'
        AND p.date_of_birth >= '1900-01-01'
        AND rr.id <> 5454368
        AND e.starts > '2025-12-31'
        AND e.starts < '2027-01-01'
        AND st.name IN ('Florida', 'Massachusetts')
        AND e.state_name IN ('Florida', 'Massachusetts')
        AND e.state_name = st.name
),

membership_period_results AS (
    SELECT
	    ma.profile_id AS id_profiles_ma,

        GROUP_CONCAT(mp.id ORDER BY mp.starts SEPARATOR ' | ') AS ids_membership_periods,
        GROUP_CONCAT(mp.membership_type_id ORDER BY mp.starts SEPARATOR ' | ') AS ids_membership_type_membership_periods,
        GROUP_CONCAT(mt.name ORDER BY mp.starts SEPARATOR ' | ') AS names_membership_types,
        GROUP_CONCAT(mp.starts ORDER BY mp.starts SEPARATOR ' | ') AS starts_membership_periods,
        GROUP_CONCAT(mp.ends ORDER BY mp.starts SEPARATOR ' | ') AS ends_membership_periods,
        GROUP_CONCAT(mt.group ORDER BY mp.starts SEPARATOR ' | ') AS groups_membership_types,

        COUNT(mp.id) AS count_membership_periods

    FROM membership_periods AS mp
        LEFT JOIN membership_types AS mt ON mp.membership_type_id = mt.id
        LEFT JOIN membership_applications AS ma ON ma.membership_period_id = mp.id

    WHERE 1 = 1
        AND mp.deleted_at IS NULL
        AND (
            -- active at any point during current year
            (
                mp.starts < DATE_ADD(MAKEDATE(YEAR(CURDATE()), 1), INTERVAL 1 YEAR)
                AND mp.ends >= MAKEDATE(YEAR(CURDATE()), 1)
            )

            -- or starts and ends after current year
            OR (
                mp.starts >= DATE_ADD(MAKEDATE(YEAR(CURDATE()), 1), INTERVAL 1 YEAR)
                AND mp.ends >= DATE_ADD(MAKEDATE(YEAR(CURDATE()), 1), INTERVAL 1 YEAR)
            )
        )

    GROUP BY ma.profile_id
)

SELECT 
    fr.id_profiles,
    fr.full_name_profiles,
    fr.last_name_profiles,
    fr.first_name_profiles,
    fr.date_of_birth_profiles,
    fr.email_users,

    -- membership periods
    mpr.ids_membership_periods,
    mpr.ids_membership_type_membership_periods,
    mpr.names_membership_types,
    mpr.starts_membership_periods,
    mpr.ends_membership_periods,
    mpr.groups_membership_types,
    mpr.count_membership_periods,

    -- events
    GROUP_CONCAT(fr.id_events ORDER BY fr.starts_events SEPARATOR ' | ') AS ids_events,
    GROUP_CONCAT(fr.starts_events ORDER BY fr.starts_events SEPARATOR ' | ') AS starts_events,
    GROUP_CONCAT(fr.name_events ORDER BY fr.starts_events SEPARATOR ' | ') AS names_events,

    -- race results
    GROUP_CONCAT(fr.designation_races ORDER BY fr.starts_events SEPARATOR ' | ') AS designations_races,
    GROUP_CONCAT(fr.name_distance_types ORDER BY fr.starts_events SEPARATOR ' | ') AS names_distance_types,
    GROUP_CONCAT(fr.name_race_types ORDER BY fr.starts_events SEPARATOR ' | ') AS names_race_types,
    GROUP_CONCAT(fr.id_race_results ORDER BY fr.starts_events SEPARATOR ' | ') AS ids_race_results,

    COUNT(DISTINCT fr.id_profiles) AS count_distinct_profiles,
    COUNT(fr.id_race_results) AS count_total_race_results

FROM filtered_results AS fr
    LEFT JOIN membership_period_results AS mpr ON fr.id_profiles = mpr.id_profiles_ma

GROUP BY fr.id_profiles
-- LIMIT 10
;