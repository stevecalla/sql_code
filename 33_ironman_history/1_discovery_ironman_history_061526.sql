USE usat_sales_db;

SELECT "#1 All data" AS query_label, p.* FROM all_participation_data_with_membership_match AS p ORDER BY id_profile_rr ASC LIMIT 10;
SELECT "#2 Data for id profile rr = 40" AS query_label, p.* FROM all_participation_data_with_membership_match AS p WHERE id_profile_rr = 40 ORDER BY id_profile_rr ASC LIMIT 50;
SELECT "#3 Data for id profiles = 40" AS query_label, p.* FROM all_participation_data_with_membership_match AS p WHERE id_profiles = 40 ORDER BY id_profiles ASC LIMIT 50;

SELECT "#4 Total Count" AS query_label, FORMAT(COUNT(*), 0) AS total_rows FROM all_participation_data_with_membership_match;
SELECT 
    "#5 Count Detail" AS query_label, 
    FORMAT(COUNT(DISTINCT id_profiles), 0) AS distinct_id_profiles,
    FORMAT(COUNT(DISTINCT id_profile_rr), 0) AS distinct_id_profile_rr, 
    FORMAT(COUNT(*), 0) AS total_rows
FROM all_participation_data_with_membership_match 
LIMIT 10
;

SELECT 
	"#6 Ironman Count" AS query_label, 
    FORMAT(SUM(CASE WHEN is_ironman = 1 THEN 1 ELSE 0 END), 0) AS count_im_race_rows,
    FORMAT(SUM(CASE WHEN is_ironman = 0 OR is_ironman IS NULL THEN 1 ELSE 0 END), 0) AS count_non_im_race_rows,

    FORMAT(COUNT(DISTINCT id_profiles), 0) AS distinct_id_profiles,
    FORMAT(COUNT(id_profile_rr), 0) AS count_profile_rows,
    FORMAT(COUNT(DISTINCT id_profile_rr), 0) AS distinct_id_profile_rr, 
    FORMAT(COUNT(*), 0) AS total_rows
FROM all_participation_data_with_membership_match
LIMIT 10
;

WITH ordered_races AS (
    SELECT
        id_profile_rr AS id_profile_rr,
        id_profiles,

        id_rr,
        id_race_rr,
        id_events_rr,
        id_sanctioning_events,

        name_events_rr,
        start_date_races,
        start_date_year_races,
        start_date_month_races,
        start_date_quarter_races,

        name_race_type,
        name_distance_types,
        name_event_type,

        region_name,
        region_abbr,
        state_code_events,
        city_events,
        zip_events,

        gender_code,
        age,
        age_as_race_results_bin,

        CASE
            WHEN age IS NULL THEN 'Unknown'
            WHEN age < 20 THEN 'Under 20'
            WHEN age BETWEEN 20 AND 29 THEN '20-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            WHEN age BETWEEN 60 AND 69 THEN '60-69'
            ELSE '70+'
        END AS age_band,

        is_ironman,

        region_name_member,
        region_abbr_member,
        member_city_addresses,
        member_state_code_addresses,
        member_postal_code_addresses,

        purchased_on_date_adjusted_mp,
        purchased_on_year_adjusted_mp,
        starts_mp,
        ends_mp,
        real_membership_types_sa,
        new_member_category_6_sa,
        is_active_membership,

        member_min_created_at_year,
        member_created_at_category_purchased_on,
        member_lapsed_renew_category_purchased_on,
        member_created_at_category_starts_mp,
        member_lapsed_renew_category_starts_mp,

        member_lifetime_purchases,
        member_lifetime_frequency,
        member_upgrade_downgrade_category,
        most_recent_prior_purchase_membership_type,

        origin_flag_category,
        origin_flag_ma,

        sales_revenue,
        sales_units,

        ROW_NUMBER() OVER (
            PARTITION BY id_profile_rr
            ORDER BY start_date_races ASC, id_rr ASC
        ) AS race_order,

        COUNT(*) OVER (
            PARTITION BY id_profile_rr
        ) AS total_races

    FROM all_participation_data_with_membership_match
    WHERE id_profile_rr IS NOT NULL
      AND id_profile_rr <> ''
),

ironman_positions AS (
    SELECT
        id_profile_rr,

        MIN(race_order) AS first_ironman_order,
        MAX(race_order) AS last_ironman_order,

        MIN(start_date_races) AS first_ironman_date,
        MAX(start_date_races) AS last_ironman_date,

        MIN(start_date_year_races) AS first_ironman_year,
        MAX(start_date_year_races) AS last_ironman_year,

        COUNT(*) AS total_ironman_races,

        COUNT(DISTINCT start_date_year_races) AS distinct_ironman_year_count,

        GROUP_CONCAT(
            DISTINCT start_date_year_races
            ORDER BY start_date_year_races ASC
            SEPARATOR ' | '
        ) AS ironman_years_distinct,

        GROUP_CONCAT(
            race_order
            ORDER BY race_order ASC
            SEPARATOR ' | '
        ) AS ironman_race_positions,

        GROUP_CONCAT(
            name_events_rr
            ORDER BY race_order ASC
            SEPARATOR ' | '
        ) AS ironman_race_names

    FROM ordered_races
    WHERE is_ironman = 1
    GROUP BY id_profile_rr
),

profile_rollup AS (
    SELECT
        id_profile_rr,

        MAX(id_profiles) AS id_profiles,

        MAX(total_races) AS total_races,

        MIN(start_date_races) AS first_race_date,
        MAX(start_date_races) AS last_race_date,

        MIN(start_date_year_races) AS first_race_year,
        MAX(start_date_year_races) AS last_race_year,

        COUNT(DISTINCT start_date_year_races) AS active_year_count,

        GROUP_CONCAT(
            DISTINCT start_date_year_races
            ORDER BY start_date_year_races ASC
            SEPARATOR ' | '
        ) AS race_years_distinct,

        SUM(CASE WHEN is_ironman = 1 THEN 1 ELSE 0 END) AS total_ironman_races_calc,

        SUM(CASE WHEN is_ironman = 0 OR is_ironman IS NULL THEN 1 ELSE 0 END) AS total_non_ironman_races,

        MAX(gender_code) AS gender_code,
        MAX(age) AS age,
        MAX(age_as_race_results_bin) AS age_as_race_results_bin,
        MAX(age_band) AS age_band,

        COUNT(DISTINCT name_event_type) AS distinct_event_type_count,
        COUNT(DISTINCT name_distance_types) AS distinct_distance_type_count,
        COUNT(DISTINCT name_race_type) AS distinct_race_type_count,
        COUNT(DISTINCT state_code_events) AS distinct_event_state_count,
        COUNT(DISTINCT region_name) AS distinct_event_region_count,

        GROUP_CONCAT(
            DISTINCT name_events_rr
            ORDER BY start_date_races ASC
            SEPARATOR ' | '
        ) AS name_events_distinct,

        GROUP_CONCAT(
            DISTINCT name_event_type
            ORDER BY name_event_type ASC
            SEPARATOR ' | '
        ) AS event_types_distinct,

        GROUP_CONCAT(
            DISTINCT name_distance_types
            ORDER BY name_distance_types ASC
            SEPARATOR ' | '
        ) AS distance_types_distinct,

        GROUP_CONCAT(
            DISTINCT name_race_type
            ORDER BY name_race_type ASC
            SEPARATOR ' | '
        ) AS race_types_distinct,

        GROUP_CONCAT(
            DISTINCT state_code_events
            ORDER BY state_code_events ASC
            SEPARATOR ' | '
        ) AS event_states_distinct,

        GROUP_CONCAT(
            DISTINCT region_name
            ORDER BY region_name ASC
            SEPARATOR ' | '
        ) AS event_regions_distinct,

        MAX(region_name_member) AS region_name_member,
        MAX(region_abbr_member) AS region_abbr_member,
        MAX(member_city_addresses) AS member_city_addresses,
        MAX(member_state_code_addresses) AS member_state_code_addresses,
        MAX(member_postal_code_addresses) AS member_postal_code_addresses,

        MIN(member_min_created_at_year) AS member_min_created_at_year,

        COUNT(DISTINCT real_membership_types_sa) AS distinct_membership_type_count,

        GROUP_CONCAT(
            DISTINCT real_membership_types_sa
            ORDER BY real_membership_types_sa ASC
            SEPARATOR ' | '
        ) AS membership_types_distinct,

        GROUP_CONCAT(
            DISTINCT new_member_category_6_sa
            ORDER BY new_member_category_6_sa ASC
            SEPARATOR ' | '
        ) AS new_member_categories_distinct,

        SUM(CASE WHEN is_active_membership = 1 THEN 1 ELSE 0 END) AS active_membership_match_rows,

        SUM(CASE WHEN is_active_membership = 0 OR is_active_membership IS NULL THEN 1 ELSE 0 END) AS non_active_membership_match_rows,

        SUM(sales_units) AS sales_units_total,
        SUM(sales_revenue) AS sales_revenue_total

    FROM ordered_races
    GROUP BY id_profile_rr
)

SELECT
	"#7 Ironman vs Non-Ironman Data" AS query_label, 
    p.id_profile_rr,
    p.id_profiles,

    CASE
        WHEN i.id_profile_rr IS NOT NULL THEN 1
        ELSE 0
    END AS has_ironman,

    CASE
        WHEN i.id_profile_rr IS NOT NULL THEN 'Ironman Profile'
        ELSE 'Non-Ironman Profile'
    END AS ironman_profile_type,

    p.gender_code,
    p.age,
    p.age_as_race_results_bin,
    p.age_band,

    p.total_races,

    COALESCE(i.total_ironman_races, 0) AS total_ironman_races,
    p.total_non_ironman_races,

    p.first_race_date,
    p.last_race_date,
    p.first_race_year,
    p.last_race_year,
    p.active_year_count,
    p.race_years_distinct,

    i.first_ironman_date,
    i.last_ironman_date,
    i.first_ironman_year,
    i.last_ironman_year,
    i.distinct_ironman_year_count,
    i.ironman_years_distinct,

    i.ironman_race_positions,
    i.ironman_race_names,

    i.first_ironman_order,

    CASE
        WHEN i.first_ironman_order IS NOT NULL
        THEN i.first_ironman_order - 1
        ELSE NULL
    END AS races_before_first_ironman,

    CASE
        WHEN i.first_ironman_order IS NOT NULL
        THEN p.total_races - i.first_ironman_order
        ELSE NULL
    END AS races_after_first_ironman,

    i.last_ironman_order,

    CASE
        WHEN i.last_ironman_order IS NOT NULL
        THEN p.total_races - i.last_ironman_order
        ELSE NULL
    END AS races_after_last_ironman,

    CASE
        WHEN i.first_ironman_year IS NOT NULL
        THEN p.last_race_year - i.first_ironman_year
        ELSE NULL
    END AS years_after_first_ironman,

    CASE
        WHEN i.last_ironman_year IS NOT NULL
        THEN p.last_race_year - i.last_ironman_year
        ELSE NULL
    END AS years_after_last_ironman,

    p.distinct_event_type_count,
    p.distinct_distance_type_count,
    p.distinct_race_type_count,
    p.distinct_event_state_count,
    p.distinct_event_region_count,

    p.event_types_distinct,
    p.distance_types_distinct,
    p.race_types_distinct,
    p.event_states_distinct,
    p.event_regions_distinct,

    p.region_name_member,
    p.region_abbr_member,
    p.member_city_addresses,
    p.member_state_code_addresses,
    p.member_postal_code_addresses,

    p.member_min_created_at_year,

    p.distinct_membership_type_count,
    p.membership_types_distinct,
    p.new_member_categories_distinct,

    p.active_membership_match_rows,
    p.non_active_membership_match_rows,

    p.sales_units_total,
    p.sales_revenue_total,

    p.name_events_distinct

FROM profile_rollup p
LEFT JOIN ironman_positions i
    ON p.id_profile_rr = i.id_profile_rr

ORDER BY
    p.id_profile_rr ASC,
    has_ironman DESC,
    years_after_last_ironman DESC,
    races_after_last_ironman DESC,
    p.total_races DESC
;

## 2
WITH ordered_races AS (
    SELECT
        id_profile_rr AS id_profile_rr,
        name_events_rr,
        start_date_races,
        is_ironman,

        ROW_NUMBER() OVER (
            PARTITION BY id_profile_rr
            ORDER BY start_date_races ASC, id_rr ASC
        ) AS race_order,

        COUNT(*) OVER (
            PARTITION BY id_profile_rr
        ) AS total_races
    FROM all_participation_data_with_membership_match
    WHERE id_profile_rr IS NOT NULL
      AND id_profile_rr <> ''
),

ironman_positions AS (
    SELECT
        id_profile_rr,
        MIN(race_order) AS first_ironman_order,
        MAX(total_races) AS total_races
    FROM ordered_races
    WHERE is_ironman = 1
    GROUP BY id_profile_rr
)

SELECT
    "#8 Ironman Counts" AS query_label, 
    first_ironman_order,
    total_races - first_ironman_order AS races_after_ironman,
    COUNT(*) AS profile_count
FROM ironman_positions
GROUP BY
    first_ironman_order,
    total_races - first_ironman_order
ORDER BY
    first_ironman_order,
    races_after_ironman
;