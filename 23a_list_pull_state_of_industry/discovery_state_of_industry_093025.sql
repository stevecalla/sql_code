-- SURVEY SAMPLE

-- Members
	-- membership period starts >= 2021-01-01
    -- exclude clubs, exclude youth, must be >= 18
    -- a) active annual = has membership that overlaps with today (Silver, Gold, Platinum, Lifetime, Elite, Young Adult etc)
    -- b) active one-day = had membership that was active in 2025 (Bronze relay, sprint, intermediate, Ultra et al)
    -- c) lapsed annual = had membership in 2021, 2022, 2023, 2024 but not active (a or b)
    -- d) lapsed one-day = had membership in 2021, 2022, 2023, 2024 but not active (a or b)

-- Race Director

-- Coach

-- Club = Board Member / Administrator of a Club

-- =========================
-- Members = Active annual, one-day; Lapsed annual, one-day
-- =========================
WITH members AS (
	SELECT
		profiles.id AS id_profiles,
		profiles.first_name AS first_name_profiles,
		profiles.last_name AS last_name_profiles,
		LOWER(users.email) AS email_users,
		profiles.date_of_birth AS dob_profiles,
		-- Age in whole years as of today
		CASE
			WHEN profiles.date_of_birth IS NULL THEN NULL
			WHEN profiles.date_of_birth > CURDATE() THEN NULL  -- guard against bad future DOBs
			ELSE
				TIMESTAMPDIFF(YEAR, profiles.date_of_birth, CURDATE())
				- (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(profiles.date_of_birth, '%m%d'))
		END AS age_years,
		profiles.gender_id AS gender_profiles,
		mp.id AS id_membership_period,
		mp.purchased_on,
		membership_types.id AS id_membership_types,
		membership_types.name AS name_memership_types,
		CASE
			WHEN mp.membership_type_id IN (1, 2, 3, 52, 55, 60, 62, 64, 65, 66, 67, 68, 70, 71, 73, 74, 75, 85, 89, 91, 93, 96, 98, 99, 101, 103, 104, 112, 113, 114, 117, 119) THEN 'adult_annual'
			WHEN mp.membership_type_id IN (4, 51, 54, 61, 94, 107) THEN 'youth_annual'
			WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100, 115, 118) THEN 'one_day'
			WHEN mp.membership_type_id IN (56, 58, 81, 105) THEN 'club'
			WHEN mp.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) THEN 'elite'
			ELSE 'other'
		END AS real_membership_types,
		mp.starts,
		mp.ends,
		CURDATE() AS date_today,
		CASE
			WHEN CURDATE() between mp.starts AND mp.ends THEN true
			ElSE false
		END AS is_active_today,
		CASE
			WHEN mp.starts IS NOT NULL AND mp.ends IS NOT NULL
				AND YEAR(mp.starts) = YEAR(CURDATE())
				AND YEAR(mp.ends)   = YEAR(CURDATE())
				THEN TRUE ELSE FALSE
		END AS is_active_this_year,
		now() AS created_at_mtn
	FROM membership_periods AS mp
		-- who the period belongs to
			-- inner join ensures membership period has member else drops membership period
			INNER JOIN members    ON members.id = mp.member_id 
				AND members.memberable_type = 'profiles'
				AND members.deleted_at IS NULL

			-- inner join ensures membership period has profile else drops membership period
			INNER JOIN profiles   ON profiles.id = members.memberable_id 
				AND profiles.deleted_at IS NULL

			LEFT JOIN users       ON users.id = profiles.user_id

			-- applications tied to the period
			LEFT JOIN membership_applications ON membership_applications.membership_period_id = mp.id
		
			-- app metadata
			LEFT JOIN membership_types ON membership_types.id = membership_applications.membership_type_id
		WHERE 1 = 1
			AND users.email IS NOT NULL
			AND mp.starts > '2021-01-01'
	-- LIMIT 10000
	)
	, active_annual AS (
		SELECT 
			"active_annual" AS query_label,
			am.id_profiles,
			am.first_name_profiles,
			am.last_name_profiles,
			am.email_users,
			age_years,
			GROUP_CONCAT(DISTINCT dob_profiles) AS dob_profiles,
			GROUP_CONCAT(DISTINCT real_membership_types) AS real_membership_types,
			COUNT(*) AS count_active_memberships
		FROM members AS am
		WHERE 1 = 1 	
			AND is_active_today = 1 
            AND real_membership_types IN ("adult_annual", "elite") -- ACTIVE ANNUAL; adult_annual (inclusive of youth_annual), elite
			AND real_membership_types NOT IN ("one_day", "youth_annual", "club", "other")
			AND age_years >= 18
		GROUP BY 1, 2, 3, 4
	)
    
    , active_one_day AS (
		SELECT 
			"active one_day" AS query_label,
			am.id_profiles,
			am.first_name_profiles,
			am.last_name_profiles,
			am.email_users,
			age_years,
			GROUP_CONCAT(DISTINCT dob_profiles) AS dob_profiles,
			GROUP_CONCAT(DISTINCT real_membership_types) AS real_membership_types,
			COUNT(*) AS count_active_memberships
		FROM members AS am
		WHERE 1 = 1 	
			AND is_active_this_year = 1 
            AND real_membership_types IN ("one_day") -- ACTIVE ONE-DAY
			AND real_membership_types NOT IN ("adult_annual", "elite", "club", "other")
			AND age_years >= 18
		GROUP BY 1, 2, 3, 4
	)

   -- union of currently returned (active) profiles ----
	, active_ids AS (
		SELECT id_profiles FROM active_annual
			UNION
		SELECT id_profiles FROM active_one_day
	),

	-- helper: did a membership overlap any part of 2021-01-01..2024-12-31? ----
	history_2021_2024 AS (
	SELECT
		m.id_profiles,
		m.real_membership_types,
		COUNT(DISTINCT m.id_membership_period) AS periods_2021_2024
	FROM members m
	WHERE 1 = 1
		AND m.starts <= DATE('2024-12-31')
		AND m.ends   >= DATE('2021-01-01')  -- overlap with the 2022–2024 window
	GROUP BY m.id_profiles, m.real_membership_types
	),

	-- Lapsed adult annual (had adult_annual/elite in 2022–2024, not in current active sets) ----
	lapsed_adult_annual AS (
		SELECT 
			'lapsed_adult_annual' AS segment,
			p.id_profiles,
			MAX(p.first_name_profiles) AS first_name_profiles,
			MAX(p.last_name_profiles)  AS last_name_profiles,
			MAX(p.email_users)         AS email_users,
			MAX(p.age_years)           AS age_years,
			GROUP_CONCAT(DISTINCT p.dob_profiles) AS dob_profiles,
			'adult_annual' AS real_membership_types,
			SUM(h.periods_2021_2024)  AS count_memberships_2021_2024
		FROM members p
		JOIN history_2021_2024 h ON h.id_profiles = p.id_profiles
			AND h.real_membership_types IN ('adult_annual','elite')
		WHERE 1 = 1
			AND p.age_years >= 18
			AND p.id_profiles NOT IN (SELECT id_profiles FROM active_ids)
		GROUP BY p.id_profiles
	),

	-- ---- Lapsed one-day (had one_day in 2022–2024, not in current active sets) ----
	lapsed_one_day AS (
		SELECT 
			'lapsed_one_day' AS segment,
			p.id_profiles,
			MAX(p.first_name_profiles) AS first_name_profiles,
			MAX(p.last_name_profiles)  AS last_name_profiles,
			MAX(p.email_users)         AS email_users,
			MAX(p.age_years)           AS age_years,
			GROUP_CONCAT(DISTINCT p.dob_profiles) AS dob_profiles,
			'one_day' AS real_membership_types,
			SUM(h.periods_2021_2024)  AS count_memberships_2021_2024
		FROM members p
			JOIN history_2021_2024 h ON h.id_profiles = p.id_profiles
				AND h.real_membership_types = 'one_day'
		WHERE 1 = 1 
			AND p.age_years >= 18
			AND p.id_profiles NOT IN (SELECT id_profiles FROM active_ids)
		GROUP BY p.id_profiles
	)

	SELECT * FROM active_annual -- 79,739 total; 79,691 mp.starts > '2021-01-01'; 78,823 without null email 
	 UNION ALL
	SELECT * FROM active_one_day -- 147,705 total; 147,705 mp.starts > '2021-01-01'; 145,638 without null email
	 UNION ALL
	SELECT * FROM lapsed_adult_annual -- 110,172 mp.starts > '2021-01-01' & without null email
	 UNION ALL
	SELECT * FROM lapsed_one_day; -- '355,118' mp.starts > '2021-01-01' & without null email

	-- ===== outputs =====
	-- Example counts:
	-- SELECT 'active_annual' seg, FORMAT(COUNT(*), 0) FROM active_annual -- 79,739 total; 79,691 mp.starts > '2021-01-01'; 78,823 without null email 
	--  UNION ALL
	-- SELECT 'active_one_day', FORMAT(COUNT(*), 0) FROM active_one_day -- 147,705 total; 147,705 mp.starts > '2021-01-01'; 145,642 without null email
	--  UNION ALL
	-- SELECT 'lapsed_adult_annual', FORMAT(COUNT(*), 0) FROM lapsed_adult_annual -- 110,172 mp.starts > '2021-01-01' & without null email
	--  UNION ALL
	-- SELECT 'lapsed_one_day', FORMAT(COUNT(*), 0) FROM lapsed_one_day; -- '355,118' mp.starts > '2021-01-01' & without null email
    
	-- Randomized pulls by segment (seeded):
	-- SELECT * FROM active_annual       ORDER BY RAND(1234) LIMIT 1000;
	-- SELECT * FROM active_one_day      ORDER BY RAND(1234) LIMIT 1000;
	-- SELECT * FROM lapsed_adult_annual ORDER BY RAND(1234) LIMIT 1000;
	-- SELECT * FROM lapsed_one_day ORDER BY RAND(1234) LIMIT 1000; 
    
	-- LIST PULL CRITERIA
	-- blackout list / opt out list?
	-- age >= 18?
	-- mix of one-day vs adult vs more micro segments (lifetime, elite et al)?
	-- one-day active 	= starts / ends date in 2025
	-- annual active / young adult / elite 	= current active membership starts before / ends after today
	-- random mix of gender, date of birth, geography

	-- no current membership either in active annual or one_day but active in 2022, 2023, 2025
