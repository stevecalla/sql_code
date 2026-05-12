USE vapor;

WITH filtered_results AS (
    SELECT
        -- PROFILE / USER
        p.id AS id_profiles,
        p.date_of_birth AS date_of_birth_profiles,
        p.is_us_citizen AS is_us_citizen_profiles,
        p.deleted_at AS deleted_at_profiles,

        u.email AS email_users,
        u.deleted_at AS deleted_at_users,

        -- MEMBER
        m.memberable_type AS memberable_type_members,
        m.deleted_at AS deleted_at_members,

        -- GENDER
        g.label AS label_genders,

        -- ADDRESS / MEMBER LOCATION
        ad.address AS address_member_addresses,
        ad.city AS city_member_addresses,
        ad.postal_code AS postal_code_member_addresses,

        st.name AS name_member_states,
        st.code AS code_member_states,
        st.country_code AS country_code_member_states,

        -- RANKING PERIOD / LIST
        rlp.ranked_at AS ranked_at_ranking_list_periods,
        rl.id AS id_ranking_lists,

        -- RANKING CONFIG
        ag.min AS min_age_groups,
        ag.max AS max_age_groups,
        CONCAT(ag.min, '-', ag.max) AS ranked_age_bin,

        rt.name AS name_race_types,
        rs.name AS name_ranking_series,

        -- RANKING ENTRY
        rlpe.id AS id_ranking_list_period_entries,
        rlpe.member_number AS member_number_ranking_list_period_entries,
        rlpe.first_name AS first_name_ranking_list_period_entries,
        rlpe.last_name AS last_name_ranking_list_period_entries,
        rlpe.rank AS rank_ranking_list_period_entries,
        rlpe.score AS score_ranking_list_period_entries,
        rlpe.multiplier_score AS multiplier_score_ranking_list_period_entries,
        rlpe.all_american AS all_american_ranking_list_period_entries,

        -- RANKING SCORE STATE
        -- GROUP_CONCAT(e.state) AS state_ranking_result_events
        GROUP_CONCAT(DISTINCT e.state ORDER BY e.state SEPARATOR ' | ') AS state_ranking_result_events

    FROM ranking_list_period_entries AS rlpe
        INNER JOIN ranking_list_periods AS rlp ON rlpe.ranking_list_period_id = rlp.id
        INNER JOIN profiles AS p ON rlpe.profile_id = p.id
        INNER JOIN genders AS g ON p.gender_id = g.id
        INNER JOIN users AS u ON p.user_id = u.id
        LEFT JOIN addresses AS ad ON p.primary_address_id = ad.id
        INNER JOIN members AS m ON p.id = m.memberable_id
        LEFT JOIN states AS st ON ad.state_id = st.id
        INNER JOIN ranking_lists AS rl ON rlp.ranking_list_id = rl.id
        INNER JOIN ranking_configs AS rc ON rl.ranking_config_id = rc.id
        INNER JOIN age_groups AS ag ON rc.age_group_id = ag.id
        INNER JOIN race_types AS rt ON rc.race_type_id = rt.id
        INNER JOIN ranking_series AS rs ON rc.ranking_series_id = rs.id

        -- states used for the ranking score
        INNER JOIN ranking_list_period_entry_race_result AS rlperr ON rlperr.ranking_list_period_entry_id = rlpe.id
        INNER JOIN race_results AS rr ON rr.id = rlperr.race_result_id
        INNER JOIN races as r ON r.id = rr.race_id
        INNER JOIN events AS e ON e.id = r.event_id

    WHERE 1 = 1
        AND m.deleted_at IS NULL
        AND u.deleted_at IS NULL
        AND p.deleted_at IS NULL
        AND m.memberable_type = 'profiles'
        AND rs.name = 'National Rankings'
        AND rlp.ranked_at = '2026-12-31'
        AND st.code IN ('FL', 'MA')
        AND rt.name IN ('Triathlon', 'Triathlon Off-Road')
        -- AND rlpe.rank >= 1
    
    GROUP BY p.id, rt.name, ranked_age_bin, label_genders
)

SELECT DISTINCT
    id_profiles,
    date_of_birth_profiles,
    is_us_citizen_profiles,
    deleted_at_profiles,

    email_users,
    deleted_at_users,

    memberable_type_members,
    deleted_at_members,

    label_genders,

    address_member_addresses,
    city_member_addresses,
    postal_code_member_addresses,

    name_member_states,
    code_member_states,
    country_code_member_states,

    ranked_at_ranking_list_periods,
    id_ranking_lists,

    min_age_groups,
    max_age_groups,
    ranked_age_bin,
    name_race_types,
    name_ranking_series,

    id_ranking_list_period_entries,
    member_number_ranking_list_period_entries,
    first_name_ranking_list_period_entries,
    last_name_ranking_list_period_entries,
    rank_ranking_list_period_entries,
    score_ranking_list_period_entries,
    multiplier_score_ranking_list_period_entries,
    all_american_ranking_list_period_entries
    

FROM filtered_results    
GROUP BY id_profiles, name_race_types, ranked_age_bin, label_genders -- in filtered_results cte
ORDER BY id_profiles ASC

-- LIMIT 1
;