-- ======================================================
-- 1. Raw Participation Data
--    Extract raw columns from the source table with meaningful aliases.
-- ======================================================
WITH raw_participation_data AS (
    SELECT
        id_profile_rr AS profile_id,
        id_rr,
        id_race_rr,
        id_sanctioning_events,

        start_date_races,
        start_date_year_races,

        region_name,
        zip_events,
        city_events,
        state_code_events,

        name_race_type,
        name_distance_types,
        name_event_type,
        name_events_rr,

        is_ironman,

        gender_code,
        age,

        region_name_member,
        member_city_addresses,
        member_state_code_addresses,
        member_postal_code_addresses,
        member_lat_addresses,
        member_lng_addresses,

        id_membership_periods_sa,
        real_membership_types_sa,

        member_min_created_at_year,
        new_member_category_6_sa,
        member_created_at_category,

        starts_mp,
        ends_mp,

        is_active_membership,

        purchased_on_date_adjusted_mp,
        sales_units,
        sales_revenue,
        purchased_on_year_adjusted_mp
    FROM all_participation_data_with_membership_match
    -- LIMIT 10000
),

-- ======================================================
-- 2. Aggregated Participation Stats
--    Compute aggregates per profile, grouped into logical sections.
-- ======================================================
aggregated_participation_stats AS (
    SELECT
        profile_id,
        
        -- [Race Metrics]
        COUNT(DISTINCT id_race_rr) AS count_races_distinct,
        COUNT(DISTINCT start_date_year_races) AS count_of_start_years_distinct,
        GROUP_CONCAT(DISTINCT start_date_year_races ORDER BY start_date_year_races ASC) AS start_years_distinct,
        MIN(start_date_year_races) AS start_year_least_recent,
        MAX(start_date_year_races) AS start_year_most_recent,
        
        -- [Region Metrics]
        COUNT(DISTINCT region_name) AS count_of_race_regions_distinct,
        GROUP_CONCAT(DISTINCT region_name ORDER BY start_date_year_races ASC) AS race_regions_distinct,

        -- city_events,
        GROUP_CONCAT(DISTINCT city_events ORDER BY start_date_year_races ASC) AS aggregated_city_events,
        SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT city_events ORDER BY purchased_on_date_adjusted_mp DESC), ',', 1) AS most_recent_city_events,
        
        -- state_code_events,
        GROUP_CONCAT(DISTINCT state_code_events ORDER BY start_date_year_races ASC) AS aggregated_state_code_events,
        SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT state_code_events ORDER BY purchased_on_date_adjusted_mp DESC), ',', 1) AS most_recent_state_code_events,
        
        -- [Race Type Metrics]
        GROUP_CONCAT(DISTINCT name_race_type ORDER BY start_date_year_races ASC) AS name_race_type_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT name_race_type ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_name_race_type,
        
        -- [Distance Types]
        GROUP_CONCAT(DISTINCT name_distance_types ORDER BY start_date_year_races ASC) AS name_distance_types_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT name_distance_types ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_name_distance_types,
        
        -- [Event Type Metrics]
        GROUP_CONCAT(DISTINCT name_event_type ORDER BY start_date_year_races ASC) AS name_event_type_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT name_event_type ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_name_event_type,
        
        -- [Event Name Metrics]
        GROUP_CONCAT(DISTINCT name_events_rr ORDER BY start_date_year_races ASC) AS name_events_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT name_events_rr ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_name_events,
        
        -- [Event Zip Code Metrics]
        GROUP_CONCAT(DISTINCT zip_events ORDER BY start_date_year_races ASC) AS zip_events_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT zip_events ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_zip_events,
        
        -- [Ironman Metrics]
        GROUP_CONCAT(DISTINCT is_ironman ORDER BY start_date_year_races ASC) AS is_ironman_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT is_ironman ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_is_ironman,
        CASE WHEN MAX(is_ironman) = 1 THEN 'yes' ELSE 'no' END AS is_ironman_flag,
        
        -- [Gender and Age Metrics]
        GROUP_CONCAT(DISTINCT gender_code ORDER BY start_date_year_races ASC) AS gender_code_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT gender_code ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_gender_code,

        GROUP_CONCAT(DISTINCT age ORDER BY start_date_year_races ASC) AS age_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT age ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_age,

        -- [Member Created At]
        GROUP_CONCAT(DISTINCT member_min_created_at_year ORDER BY start_date_year_races ASC) AS member_min_created_at_year_distinct,

        -- [Member Address Fields]
        -- region_name_member
        GROUP_CONCAT(DISTINCT region_name_member ORDER BY start_date_year_races ASC) AS aggregated_region_name_member,
        SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT region_name_member ORDER BY purchased_on_date_adjusted_mp DESC), ',', 1) AS most_recent_region_name_member,
        
        -- member_city_addresses
        GROUP_CONCAT(DISTINCT member_city_addresses ORDER BY start_date_year_races ASC) AS aggregated_member_city_addresses,
        SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT member_city_addresses ORDER BY purchased_on_date_adjusted_mp DESC), ',', 1) AS most_recent_member_city_addresses,
        
        -- member_state_code_addresses
        GROUP_CONCAT(DISTINCT member_state_code_addresses ORDER BY start_date_year_races ASC) AS aggregated_member_state_code_addresses,
        SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT member_state_code_addresses ORDER BY purchased_on_date_adjusted_mp DESC), ',', 1) AS most_recent_member_state_code_addresses,
        
        -- member_postal_code_addresses
        GROUP_CONCAT(DISTINCT member_postal_code_addresses ORDER BY start_date_year_races ASC) AS aggregated_member_postal_code_addresses,
        SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT member_postal_code_addresses ORDER BY purchased_on_date_adjusted_mp DESC), ',', 1) AS most_recent_member_postal_code_addresses,
        
        -- member_lat_addresses
        GROUP_CONCAT(DISTINCT member_lat_addresses ORDER BY start_date_year_races ASC) AS aggregated_member_lat_addresses,
        SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT member_lat_addresses ORDER BY purchased_on_date_adjusted_mp DESC), ',', 1) AS most_recent_member_lat_addresses,
        
        -- member_lng_addresses
        GROUP_CONCAT(DISTINCT member_lng_addresses ORDER BY start_date_year_races ASC) AS aggregated_member_lng_addresses,
        SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT member_lng_addresses ORDER BY purchased_on_date_adjusted_mp DESC), ',', 1) AS most_recent_member_lng_addresses,

        -- [Membership Period Metrics]
        GROUP_CONCAT(DISTINCT id_membership_periods_sa ORDER BY start_date_year_races ASC) AS id_membership_period_sa_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT id_membership_periods_sa ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_id_membership_period_sa,
        
        -- [Membership Type Metrics]
        GROUP_CONCAT(DISTINCT real_membership_types_sa ORDER BY purchased_on_date_adjusted_mp ASC) AS memberships_type_purchased_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT real_membership_types_sa ORDER BY purchased_on_date_adjusted_mp ASC),
            ',', 1
        ) AS least_recent_membership_type,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT real_membership_types_sa ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_membership_type,
        
        -- [Membership Category Metrics]
        GROUP_CONCAT(DISTINCT new_member_category_6_sa ORDER BY purchased_on_date_adjusted_mp ASC) AS memberships_category_purchased_distinct,
        GROUP_CONCAT(new_member_category_6_sa ORDER BY purchased_on_date_adjusted_mp ASC) AS memberships_category_purchased_all,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT new_member_category_6_sa ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_new_member_category_6_sa,
        
        -- [Membership Creation Category Metrics]
        GROUP_CONCAT(member_created_at_category ORDER BY purchased_on_date_adjusted_mp ASC) AS member_created_at_category_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(member_created_at_category ORDER BY purchased_on_date_adjusted_mp ASC),
            ',', 1
        ) AS least_recent_member_created_at_category,
        SUBSTRING_INDEX(
            GROUP_CONCAT(member_created_at_category ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_member_created_at_category,
        
        -- [Starts/Ends Metrics]
        GROUP_CONCAT(DISTINCT starts_mp ORDER BY start_date_year_races ASC) AS starts_mp_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT starts_mp ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_starts_mp,
        GROUP_CONCAT(DISTINCT ends_mp ORDER BY start_date_year_races ASC) AS ends_mp_distinct,
        SUBSTRING_INDEX(
            GROUP_CONCAT(DISTINCT ends_mp ORDER BY purchased_on_date_adjusted_mp DESC),
            ',', 1
        ) AS most_recent_ends_mp,
        
        -- [Active Membership Metrics]
        GROUP_CONCAT(DISTINCT is_active_membership ORDER BY purchased_on_date_adjusted_mp ASC) AS is_active_membership_distinct,
        
        -- [Sales and Purchase Metrics]
        COUNT(purchased_on_year_adjusted_mp) AS count_of_purchased_years_all,
        SUM(sales_units) AS sales_units_total,
        SUM(sales_revenue) AS sales_revenue_total

    FROM raw_participation_data
    GROUP BY profile_id
),

-- ======================================================
-- 3. Latest Membership Status
--    Identify the most recent membership record per profile using a window function.
-- ======================================================
-- latest_membership_status AS (
--     SELECT
--         profile_id,
--         member_created_at_category,
--         purchased_on_date_adjusted_mp,
--         ROW_NUMBER() OVER (PARTITION BY profile_id ORDER BY purchased_on_date_adjusted_mp DESC) AS rn
--     FROM raw_participation_data
-- ),

-- ======================================================
-- 4. Aggregate Participation Profile Stats
--    Combine aggregated stats with the latest membership status and apply final filters.
-- ======================================================
aggregate_participation_profile_stats AS (
    SELECT
        -- [Profile & Race Metrics]
        ap.profile_id,
        
        -- RACE DATA
        ap.count_races_distinct,
        CASE WHEN ap.count_races_distinct > 1 THEN 1 ELSE 0 END AS is_repeat_racer,
        ap.count_of_start_years_distinct,
        ap.start_years_distinct,
        ap.start_year_least_recent,
        ap.start_year_most_recent,
        CASE 
            WHEN ap.count_of_start_years_distinct > 0 THEN ap.count_races_distinct / ap.count_of_start_years_distinct
            ELSE 0
        END AS avg_races_per_year,
        
        -- [Region Metrics]
        ap.count_of_race_regions_distinct,
        ap.race_regions_distinct,

        -- city_events
        aggregated_city_events,
        most_recent_city_events,
        
        -- state_code_events
        aggregated_state_code_events,
        most_recent_state_code_events,

        -- [Race Types, Distances, and Event Metrics]
        ap.name_race_type_distinct,
        ap.most_recent_name_race_type,
        
        ap.name_distance_types_distinct,
        ap.most_recent_name_distance_types,
        
        ap.name_event_type_distinct,
        ap.most_recent_name_event_type,
        
        ap.name_events_distinct,
        ap.most_recent_name_events,
        
        ap.zip_events_distinct,
        ap.most_recent_zip_events,
        
        -- [Ironman, Gender, and Age Metrics]
        ap.is_ironman_distinct,
        ap.most_recent_is_ironman,
        ap.is_ironman_flag,
        
        ap.gender_code_distinct,
        ap.most_recent_gender_code,
        
        ap.age_distinct,
        ap.most_recent_age,

        -- [MEMBER CREATED AT]
        ap.member_min_created_at_year_distinct,

        -- region_name_member
        ap.aggregated_region_name_member,
        ap.most_recent_region_name_member,
        
        -- member_city_addresses
        ap.aggregated_member_city_addresses,
        ap.most_recent_member_city_addresses,
        
        -- member_state_code_addresses
        ap.aggregated_member_state_code_addresses,
        ap.most_recent_member_state_code_addresses,
        
        -- member_postal_code_addresses
        ap.aggregated_member_postal_code_addresses,
        ap.most_recent_member_postal_code_addresses,
        
        -- member_lat_addresses
        ap.aggregated_member_lat_addresses,
        ap.most_recent_member_lat_addresses,
        
        -- member_lng_addresses
        ap.aggregated_member_lng_addresses,
        ap.most_recent_member_lng_addresses,
        
        -- [Membership Period and Type Metrics]
        ap.id_membership_period_sa_distinct,
        ap.most_recent_id_membership_period_sa,
        
        ap.memberships_type_purchased_distinct,
        ap.least_recent_membership_type,
        ap.most_recent_membership_type,
        
        -- [Membership Category and Creation Metrics]
        ap.memberships_category_purchased_distinct,
        ap.memberships_category_purchased_all,
        ap.most_recent_new_member_category_6_sa,
        
        ap.member_created_at_category_distinct,
        ap.least_recent_member_created_at_category,
        ap.most_recent_member_created_at_category,
        
        -- [Starts/Ends Metrics]
        ap.starts_mp_distinct,
        ap.most_recent_starts_mp,
        
        ap.ends_mp_distinct,
        ap.most_recent_ends_mp,
        
        -- [Active Membership & Sales Metrics]
        ap.is_active_membership_distinct,
        
        ap.count_of_purchased_years_all,
        ap.sales_units_total,
        ap.sales_revenue_total
        
        -- [Latest Membership Status]
        -- lms.member_created_at_category AS latest_member_created_category
        
    FROM aggregated_participation_stats ap
        -- JOIN latest_membership_status lms ON ap.profile_id = lms.profile_id
    WHERE 1 = 1
        -- AND ap.most_recent_member_created_at_category  = 'created_year'
        -- AND lms.rn = 1
        -- AND ap.start_year_least_recent > 2022
        -- AND lms.member_created_at_category = 'created_year'
    GROUP BY ap.profile_id
)

, summarize_by_count AS (
    SELECT
        count_races_distinct AS number_of_races
        -- , most_recent_member_created_at_category
        , COUNT(*) AS count_of_participants
        , AVG(avg_races_per_year) -- AVERAGE RACE COUNT
        , SUM(COUNT(*)) OVER (ORDER BY count_races_distinct) AS running_total  -- Running total
        , 100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percent_of_total  -- Percentage of total
                
        -- MOST RECENT START YEAR       
        , FORMAT(SUM(CASE WHEN start_year_most_recent < 2020 THEN 1 ELSE 0 END), 0) start_year_most_recent_before_2020
        , FORMAT(SUM(CASE WHEN start_year_most_recent < 2023 THEN 1 ELSE 0 END), 0) start_year_most_recent_before_2023
        , FORMAT(SUM(CASE WHEN start_year_most_recent IN (2023) THEN 1 ELSE 0 END), 0) start_year_most_recent_2023
        , FORMAT(SUM(CASE WHEN start_year_most_recent IN (2024) THEN 1 ELSE 0 END), 0) start_year_most_recent_2024
        , FORMAT(SUM(CASE WHEN start_year_most_recent IN (2025) THEN 1 ELSE 0 END), 0) start_year_most_recent_2025

        -- NUMBER OF START YEARS
        , FORMAT(SUM(CASE WHEN count_of_start_years_distinct IN (1) THEN 1 ELSE 0 END), 0) AS start_year_count_one
        , FORMAT(SUM(CASE WHEN count_of_start_years_distinct IN (2) THEN 1 ELSE 0 END), 0) AS start_year_count_two
        , FORMAT(SUM(CASE WHEN count_of_start_years_distinct IN (3) THEN 1 ELSE 0 END), 0) AS start_year_count_three
        , FORMAT(SUM(CASE WHEN count_of_start_years_distinct IN (4) THEN 1 ELSE 0 END), 0) AS start_year_count_four
        , FORMAT(SUM(CASE WHEN count_of_start_years_distinct IN (5) THEN 1 ELSE 0 END), 0) AS start_year_count_five
        , FORMAT(SUM(CASE WHEN count_of_start_years_distinct >= (6) THEN 1 ELSE 0 END), 0) AS start_year_count_six_plus

    FROM aggregate_participation_profile_stats
    WHERE 1 = 1
        -- AND most_recent_member_created_at_category IN ('created_year')
        -- AND most_recent_member_created_at_category IN ('after_created_year')
    -- GROUP BY count_races_distinct, most_recent_member_created_at_category
    GROUP BY count_races_distinct
    ORDER BY CAST(count_races_distinct AS UNSIGNED)
)

-- ======================================================
-- 5. Final Output
-- ======================================================
-- SELECT * FROM aggregate_participation_profile_stats;
SELECT * FROM summarize_by_count LIMIT 10;
