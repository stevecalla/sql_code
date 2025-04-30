SELECT FORMAT(COUNT(*), 0) FROM all_participation_data_raw; -- 5,880,334
SELECT * FROM all_participation_data_raw p WHERE p.id_profile_rr = 42;
SELECT * FROM sales_key_stats_2015 s WHERE s.id_profiles = 42;

WITH participation AS (
    SELECT 
        *
    FROM all_participation_data_raw
	WHERE 1 = 1
		AND start_date_year_races >= 2024
        AND id_sanctioning_events = '309562'
		-- AND id_profile_rr = 42 -- AND id_rr = 4527556 -- this member is missing memberships to match race history; total number of races = 6; total memberships = 4 with missing for 2014, 2017, 2021 races
		-- AND id_profile_rr = 999977 -- AND id_rr = 1197359 -- this member has multiple memberships for the same race (a one day & an annual)
)

, merge_participation_with_active_membership AS (
    SELECT 
        p.id_profile_rr
        , p.id_rr
        , p.id_race_rr
        , ROW_NUMBER() OVER (
            PARTITION BY p.id_rr 
            ORDER BY ABS(TIMESTAMPDIFF(SECOND, p.start_date_races, s.purchased_on_date_adjusted_mp)) ASC
        ) AS rn -- RANKS DUPLICATES BASED ON THE NEAREST MP PURCHASE DATE TO THE RACE START DATE; USED TO FILTER OUT DUPLICATES
        , p.name_events
        , p.state_code_events
    --     , p.region_abbr
    --     , p.region_name
        , p.start_date_races
        , p.start_date_year_races
        , p.name_distance_types
        , p.name_race_type
        , s.id_profiles
        , s.purchased_on_date_adjusted_mp
        , s.id_membership_periods_sa
        , s.starts_mp
        , s.ends_mp
        , s.real_membership_types_sa
        , s.new_member_category_6_sa
        , s.sales_revenue
        , s.sales_units
        , CASE WHEN s.starts_mp IS NOT NULL THEN 1 ELSE 0 END AS is_active_membership
    FROM participation p
        LEFT JOIN sales_key_stats_2015 s ON s.id_profiles = p.id_profile_rr
        AND s.starts_mp <= p.start_date_races
        AND s.ends_mp >= p.start_date_races
    ORDER BY p.id_profile_rr, p.start_date_races, p.id_race_rr, s.id_membership_periods_sa
)

-- SELECT * FROM merge_participation_with_active_membership WHERE rn = 1;  -- only returns the first match if there are duplicates

-- SELECT FORMAT(COUNT(*), 0) FROM merge_participation_with_active_membership WHERE rn = 1  -- ONLY RETURNS THE FIRST MATCH IF THERE ARE DUPLICATES; -- 5,880,334 ROWS RETURNED

-- RETURN ALL RECORDS
-- SELECT * FROM merge_participation_with_active_membership WHERE rn = 1  -- only returns the first match if there are duplicates

-- RETURN COUNTS
-- SELECT FORMAT(COUNT(*), 0) FROM merge_participation_with_active_membership  -- DOES NOT ELIMINATE DUPLICATES; -- 5,943,108 ROWS RETURNED

-- RETURNS COUNTS BY RACE START YEAR TO IDENTIFY RACE RESULTS WITH AN ACTIVE OR NOT ACTIVE MEMBERSHIP FOR THAT SPECIFIC RACE
SELECT 
    is_active_membership,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2025 THEN 1 ELSE 0 END), 0) AS race_year_2025,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2024 THEN 1 ELSE 0 END), 0) AS race_year_2024,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2023 THEN 1 ELSE 0 END), 0) AS race_year_2023,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2022 THEN 1 ELSE 0 END), 0) AS race_year_2022,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2021 THEN 1 ELSE 0 END), 0) AS race_year_2021,
	FORMAT(SUM(CASE WHEN start_date_year_races <= 2020 THEN 1 ELSE 0 END), 0) AS race_year_less_than_2020,
--     FORMAT(SUM(CASE WHEN start_date_year_races = 2020 THEN 1 ELSE 0 END), 0) AS race_year_2020,
--     FORMAT(SUM(CASE WHEN start_date_year_races = 2019 THEN 1 ELSE 0 END), 0) AS race_year_2019,
--     FORMAT(SUM(CASE WHEN start_date_year_races = 2018 THEN 1 ELSE 0 END), 0) AS race_year_2018,
--     FORMAT(SUM(CASE WHEN start_date_year_races = 2017 THEN 1 ELSE 0 END), 0) AS race_year_2017,
--     FORMAT(SUM(CASE WHEN start_date_year_races = 2016 THEN 1 ELSE 0 END), 0) AS race_year_2016,
--     FORMAT(SUM(CASE WHEN start_date_year_races <= 2015 THEN 1 ELSE 0 END), 0) AS race_year_less_than_2015,
    FORMAT(COUNT(*), 0) AS total_count
FROM merge_participation_with_active_membership 
WHERE 1 = 1
	AND rn = 1 -- ONLY RETURNS THE FIRST MATCH IF THERE ARE DUPLICATES
GROUP BY is_active_membership WITH ROLLUP
;

    

