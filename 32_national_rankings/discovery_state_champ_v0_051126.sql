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

        -- FORMATTED TIME
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

        AND e.starts > "2025-12_31" 
        AND e.starts < "2027-01-01"
        -- AND e.starts BETWEEN '2025-12-31' AND '2027-01-01'

        AND st.name IN ('Florida', 'Massachusetts')
        AND e.state_name IN ('Florida', 'Massachusetts')
        AND e.state_name = st.name

        -- and race count >= 3 
        -- and gender?
        -- AND p.id = 181259
)

-- CHECK UNIQUE COUNTS
-- SELECT FORMAT(COUNT(id_profiles), 0) FROM filtered_results;
-- SELECT FORMAT(COUNT(DISTINCT(id_profiles)), 0) FROM filtered_results;
-- SELECT id_profiles, full_name_profiles, FORMAT(COUNT(id_profiles), 0) AS count FROM filtered_results GROUP BY 1, 2 HAVING count > 0;

-- CHECK STATE SPELLING
-- SELECT state_profile_states, FORMAT(COUNT(id_profiles), 0) FROM filtered_results GROUP BY 1 ORDER BY 1;
-- SELECT state_name_events, FORMAT(COUNT(id_profiles), 0) FROM filtered_results GROUP BY 1 ORDER BY 1;

-- REVIEW RACE DETAILS
-- SELECT DISTINCT
--     id_profiles, full_name_profiles, first_name_profiles, last_name_profiles,
--     date_of_birth_profiles, deleted_at_profiles,
--     email_users, deleted_at_users,
--     flag_genders, label_genders,
--     state_profile_states,

--     id_events, starts_events, name_events, state_name_events, event_type_id_events,
--     sanctioning_event_id_events, deleted_at_events,
--     designation_races, deleted_at_races,
--     name_race_types, name_distance_types,

--     id_race_results, created_at_race_results, finish_status_race_results,
--     category_race_results, first_name_race_results, last_name_race_results,
--     age_race_results, gender_code_race_results,

--     milliseconds_race_results,
--     formatted_time_race_results
-- FROM filtered_results
-- ORDER BY id_profiles ASC
-- -- LIMIT 100
-- ;

SELECT 
    fr.id_profiles,
    fr.full_name_profiles,
    fr.last_name_profiles,
    fr.first_name_profiles,
    fr.date_of_birth_profiles,
    fr.email_users,

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
WHERE 1 = 1
    AND fr.id_profiles = 2997

GROUP BY 1
-- LIMIT 10
;
