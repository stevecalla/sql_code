USE usat_sales_db;

WITH participant_race_count AS (
    SELECT 
		id_profile_rr AS profile_id_rr
		, COUNT(DISTINCT id_race_rr) AS count_races_distinct
		-- RACE YEARS
		, COUNT(DISTINCT start_date_year_races) AS count_of_start_years_distinct											-- Count of distinct start years
		, GROUP_CONCAT(DISTINCT start_date_year_races ORDER BY start_date_year_races ASC) AS start_years_distinct  		-- Concatenate distinct year
		, MIN(start_date_year_races) AS start_year_least_recent  															-- Get the most recent start year
		, MAX(start_date_year_races) AS start_year_most_recent  															-- Get the most recent start year
        -- EVENT / RACE REGION
		, COUNT(DISTINCT region_name) AS count_of_race_regions_distinct	
        , GROUP_CONCAT(DISTINCT region_name ORDER BY start_date_year_races ASC) AS race_regions_distinct
        -- RACE TYPES, DISTANCES, NAMES
        , GROUP_CONCAT(DISTINCT name_race_type ORDER BY start_date_year_races ASC) AS name_race_type_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT name_race_type ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_name_race_type
        -- EVENT DISTANCE
        , GROUP_CONCAT(DISTINCT name_distance_types ORDER BY start_date_year_races ASC) AS name_distance_types_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT name_distance_types ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_name_distance_types
        -- EVENT TYPE
        , GROUP_CONCAT(DISTINCT name_event_type ORDER BY start_date_year_races ASC) AS name_event_type_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT name_event_type ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_name_event_type
        -- EVENT NAME
        , GROUP_CONCAT(DISTINCT name_events ORDER BY start_date_year_races ASC) AS name_events_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT name_events ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_name_events
        -- EVENT ZIP CODE
        , GROUP_CONCAT(DISTINCT zip_events ORDER BY start_date_year_races ASC) AS zip_events_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT zip_events ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_zip_events
        -- IS IRONMAN
        , GROUP_CONCAT(DISTINCT is_ironman ORDER BY start_date_year_races ASC) AS is_ironman_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT is_ironman ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_is_ironman
        , CASE WHEN MAX(is_ironman) = 1 THEN 'yes' ELSE 'no' END AS is_ironman_flag
        -- GENDER CODE
        , GROUP_CONCAT(DISTINCT gender_code ORDER BY start_date_year_races ASC) AS gender_code_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT gender_code ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_gender_code
        -- AGE
        , GROUP_CONCAT(DISTINCT age ORDER BY start_date_year_races ASC) AS age_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT age ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_age
        
        -- MEMBERSHIP TYPES & PURCHASE INFO
        -- MEMBER CREATED AT
        -- , GROUP_CONCAT(DISTINCT member_min_created_at_year ORDER BY start_date_year_races ASC) AS member_min_created_at_year_distinct
        -- MEMBERSHIP PERIODS
        , GROUP_CONCAT(DISTINCT id_membership_periods_sa ORDER BY start_date_year_races ASC) AS id_membership_period_sa_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT id_membership_periods_sa ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_id_membership_period_sa
        -- MEMBERSHIP TYPES
        , GROUP_CONCAT(DISTINCT real_membership_types_sa ORDER BY purchased_on_date_adjusted_mp ASC) AS memberships_type_purchased_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT real_membership_types_sa ORDER BY purchased_on_date_adjusted_mp ASC),',', 1) AS least_recent_membership_type
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT real_membership_types_sa ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_membership_type
        -- MEMBERSHIP CATEGORIES
        , GROUP_CONCAT(DISTINCT new_member_category_6_sa ORDER BY purchased_on_date_adjusted_mp ASC) AS memberships_category_purchased_distinct
        , GROUP_CONCAT(new_member_category_6_sa ORDER BY purchased_on_date_adjusted_mp ASC) AS memberships_category_purchased_all
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT new_member_category_6_sa ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_new_member_category_6_sa
        -- MEMBERSHIP NEW VS REPEAT
        , GROUP_CONCAT(DISTINCT member_created_at_category ORDER BY purchased_on_date_adjusted_mp ASC) AS member_created_at_category_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT member_created_at_category ORDER BY purchased_on_date_adjusted_mp ASC),',', 1) AS least_recent_member_created_at_category
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT member_created_at_category ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_member_created_at_category
        -- starts_mp
        , GROUP_CONCAT(DISTINCT starts_mp ORDER BY start_date_year_races ASC) AS starts_mp_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT starts_mp ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_starts_mp
        -- ends_mp
        , GROUP_CONCAT(DISTINCT ends_mp ORDER BY start_date_year_races ASC) AS ends_mp_distinct
        , SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT ends_mp ORDER BY purchased_on_date_adjusted_mp DESC),',', 1) AS most_recent_ends_mp
        -- IS ACTIVE MEMBERSHIP PERIODS
        , GROUP_CONCAT(DISTINCT is_active_membership ORDER BY purchased_on_date_adjusted_mp ASC) AS is_active_membership_distinct

        -- METRICS
		, COUNT(purchased_on_year_adjusted_mp) AS count_of_purchased_years_all
        , SUM(sales_units) AS sales_units_total
        , SUM(sales_revenue) AS sales_revenue_total

    FROM all_participation_data_with_membership_match
    WHERE 1 = 1
        -- AND start_date_year_races = 2022
        -- ADD IN RACE STATUS... FINISH ET AL
    GROUP BY id_profile_rr
    -- ORDER BY CAST(id_profile_rr AS UNSIGNED)
    -- HAVING count_rr > 1
    -- LIMIT 100   
),

participant_race_count_average AS (
	SELECT 
		profile_id_rr,
		count_races_distinct,

        -- REPEAT RACER
        CASE WHEN count_of_start_years_distinct > 1 THEN 1 ELSE 0 END AS is_repeat_racer,

		-- RACE DATA
		count_of_start_years_distinct,
		start_years_distinct,
		start_year_least_recent,
		start_year_most_recent,
		CASE 
			WHEN count_of_start_years_distinct > 0 THEN count_races_distinct / count_of_start_years_distinct
			ELSE 0 
		END AS avg_races_per_year  -- Calculate average races per year
        
        -- RACE REGION DATA
        , count_of_race_regions_distinct	
        , race_regions_distinct
        
        -- RACE TYPES, DISTANCES, NAMES
        , name_race_type_distinct
        , most_recent_name_race_type
        
        , name_distance_types_distinct
        , most_recent_name_distance_types
        
        , name_event_type_distinct
        , most_recent_name_event_type
        
        , name_events_distinct
        , most_recent_name_events
        
        , zip_events_distinct
        , most_recent_zip_events
        
        , is_ironman_distinct
        , most_recent_is_ironman
        
        , gender_code_distinct
        , most_recent_gender_code
        
        , age_distinct
        , most_recent_age
        
        -- MEMBERSHIP DATA
        -- MEMBER CREATED AT
        -- , member_min_created_at_year_distinct
        -- MEMBERSHIP PERIODS
        , id_membership_period_sa_distinct
        , most_recent_id_membership_period_sa
        -- MEMBERSHIP TYPES
        , memberships_type_purchased_distinct
        , least_recent_membership_type
        , most_recent_membership_type
        -- MEMBERSHIP CATEGORIES
        , memberships_category_purchased_distinct
        , memberships_category_purchased_all
        , most_recent_new_member_category_6_sa
        -- MEMBERSHIP NEW VS REPEAT
        , member_created_at_category_distinct
        , least_recent_member_created_at_category
        , most_recent_member_created_at_category
        -- starts_mp
        , starts_mp_distinct
        , most_recent_starts_mp
        -- ends_mp
        , ends_mp_distinct
        , most_recent_ends_mp
        -- IS ACTIVE MEMBERSHIP PERIODS
        , is_active_membership_distinct

        -- METRICS
        , count_of_purchased_years_all
		, sales_units_total
		, sales_revenue_total
        
    FROM participant_race_count
    WHERE 1 = 1
    GROUP BY profile_id_rr, count_races_distinct, count_of_start_years_distinct, start_years_distinct, start_year_least_recent, start_year_most_recent
    ORDER BY CAST(profile_id_rr AS UNSIGNED)
    -- LIMIT 100
),
 
summarize_by_count AS (
    SELECT
        count_races_distinct AS number_of_races
        , most_recent_member_created_at_category
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

    FROM participant_race_count_average
    WHERE 1 = 1
        AND most_recent_member_created_at_category IN ('created_year')
        -- AND most_recent_member_created_at_category IN ('after_created_year')
    GROUP BY count_races_distinct, most_recent_member_created_at_category
    ORDER BY CAST(count_races_distinct AS UNSIGNED)
)

-- SELECT * FROM participant_race_count_average; 
SELECT * FROM summarize_by_count
;