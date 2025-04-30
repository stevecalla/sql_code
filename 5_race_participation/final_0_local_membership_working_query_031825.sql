WITH membership_sales AS (
    SELECT 
		id_profiles,
		id_membership_periods_sa,
		real_membership_types_sa,
		new_member_category_6_sa,
        purchased_on_date_adjusted_mp,
		starts_mp,
		ends_mp,
		id_events AS id_events_m,
		name_events AS name_events_m
    FROM sales_key_stats_2015

    WHERE 1 = 1 
        -- AND purchased_on_date_adjusted_year_mp = 2025
        -- AND start_date_races >= @start_date
        -- AND start_date_races <= @end_date
        -- AND purchased_on_date_adjusted_mp = '2025-01-01'
        -- AND ends_year_mp IN (2019) AND id_profiles IN (2771799,2771802,2772162) -- testing 2019 results
        AND id_profiles IN ('1000119', '1000906') -- 1000906 has a duplicate for Dino Gravel Tri; using rn field and filter to remove
        -- AND purchased_on_date_adjusted_mp >= '2025-03-01'
--         AND purchased_on_date_adjusted_mp <= '2025-03-01'
)

-- SELECT 
--     COUNT(DISTINCT id_membership_periods_sa),
-- 	COUNT(*) 
-- FROM membership_sales; -- 47149, 47149

, merge_membership_sales_with_participation AS (
    SELECT 
		s.*
		, p.id_profile_rr,
		p.id_rr,
		p.id_race_rr,
		p.id_events,
		p.id_sanctioning_events,
		p.name_events AS name_events_p,
		p.start_date_races,
		p.start_date_year_races, 
        
		-- IDENTIFY DUPLICATES
		ROW_NUMBER() OVER (
			PARTITION BY CASE WHEN p.id_rr IS NULL THEN s.id_membership_periods_sa ELSE p.id_rr END -- ensures null values are not counted in the same grouping/ null should have unique membership period id
			ORDER BY ABS(TIMESTAMPDIFF(SECOND, p.start_date_races, s.purchased_on_date_adjusted_mp)) ASC
		) AS rn, -- Ranks duplicates based on the nearest MP purchase date to the race start date,
        
		CASE WHEN p.id_rr IS NOT NULL THEN 1 ELSE 0 END AS has_overlapping_race_record

    FROM membership_sales AS s
		LEFT JOIN all_participation_data_raw p ON p.id_profile_rr = s.id_profiles
             AND s.starts_mp <= p.start_date_races
             AND s.ends_mp >= p.start_date_races
		LEFT JOIN region_data AS r ON p.state_code_events = r.state_code
)
SELECT * FROM merge_membership_sales_with_participation WHERE 1 = 1 AND rn = 1 ORDER BY id_profiles, ends_mp, start_date_races; -- LIMIT 100
SELECT
    COUNT(DISTINCT id_membership_periods_sa),
	COUNT(*)
FROM merge_membership_sales_with_participation
WHERE 1 = 1
	AND rn = 1
ORDER BY id_profiles, starts_mp
;