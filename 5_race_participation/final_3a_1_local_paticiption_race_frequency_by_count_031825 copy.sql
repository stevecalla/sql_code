USE vapor; 

WITH participation_by_race AS (
    SELECT 
        -- RACE / EVENT INFO
        rr.race_id AS id_race_results,
        r.id AS id_races,
        e.id AS id_events,
        e.sanctioning_event_id AS id_sanctioning_events,
        e.event_type_id AS event_type_id_events,
        et.name AS name_event_type,

        -- EVENTS / EVENT TYPES TABLE
        CONCAT('"', REPLACE(REPLACE(REPLACE(SUBSTRING(e.name, 1, 255), '''', ''), '"', ''), ',', ''), '"') AS name_events,
        CONCAT('"', REPLACE(REPLACE(REPLACE(SUBSTRING(e.address, 1, 255), '''', ''), '"', ''), ',', ''), '"') AS address_events,
        CONCAT('"', REPLACE(REPLACE(REPLACE(SUBSTRING(e.city, 1, 255), '''', ''), '"', ''), ',', ''), '"') AS city_events,

        e.zip AS zip_events,
        e.state_code AS state_code_events,
        e.country_code AS country_code_events,

        DATE_FORMAT(r.created_at, '%Y-%m-%d %H:%i:%s') AS created_at_events,
        MONTH(e.created_at) AS created_at_month_events,
        QUARTER(e.created_at) AS created_at_quarter_events,
        YEAR(e.created_at) AS created_at_year_events,

        DATE_FORMAT(e.starts, '%Y-%m-%d') AS starts_events,
        MONTH(e.starts) AS starts_month_events,
        QUARTER(e.starts) AS starts_quarter_events,
        YEAR(e.starts) AS starts_year_events,

        DATE_FORMAT(e.ends, '%Y-%m-%d') AS ends_events,
        MONTH(e.ends) AS ends_month_events,
        QUARTER(e.ends) AS ends_quarter_events,
        YEAR(e.ends) AS ends_year_events,

        e.status AS status_events,

        e.race_director_id AS race_director_id_events,
        e.last_season_event_id AS last_season_event_id,

        -- MEMBER DETAIL
        rr.gender_code,
        rr.gender_id,

        -- RACE DETAILS
        dt.name AS name_distance_types,
        rr.category,
        
        -- RACE TYPES
        rt.id AS id_race_types,
        rt.name AS name_race_type,
        
        -- MEMBER INFO (REMOVE TO GET HIGHER LEVEL SUMMARY)
		-- , rr.profile_id AS profile_id_rr
		-- , rr.member_number as member_number_rr
        -- rr.score,
        -- rr.finish_status,
        -- rr.age,
        -- rr.readable_time,
        -- rr.milliseconds,
        
        -- IRONMAN
		CASE 
			WHEN e.name LIKE '%IRONMAN%' OR e.name LIKE '%Ironman%' 
				OR e.name LIKE '%70.3%' OR e.name LIKE '%140.6%' THEN 1 
			ELSE 0
			END AS is_ironman, -- 1 = is_ironman / 0 = is_not_ironman

        -- METRICS
        COUNT(DISTINCT rr.profile_id) AS count_profile_id_distinct, -- Excludes those without a profile ID
        COUNT(*) AS count_all_participation -- Includes all race participants because this query includes granular data

    FROM race_results AS rr
		LEFT JOIN races AS r ON rr.race_id = r.id 
        LEFT JOIN race_types AS rt ON r.race_type_id = rt.id
		LEFT JOIN events AS e ON r.event_id = e.id
		LEFT JOIN event_types AS et ON e.event_type_id = et.id
		LEFT JOIN distance_types AS dt ON r.distance_type_id = dt.id

	-- WHERE
	-- 	YEAR(e.starts) = 2024
        
    GROUP BY 
        rr.race_id, r.id, e.id, e.sanctioning_event_id, e.event_type_id, et.name,
        e.name, e.address, e.city, e.zip, e.state_code, e.country_code,
        r.created_at, e.created_at, e.starts, e.ends, e.status, e.race_director_id,
        e.last_season_event_id, rr.gender_code, rr.gender_id,
        dt.name, rr.category, rt.id, rt.name

    ORDER BY e.sanctioning_event_id, e.id, rr.race_id ASC
)

SELECT * FROM participation_by_race;