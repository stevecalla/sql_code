USE vapor;
-- =========================================================
-- 🔍 DISCOVERY (quick table samples + basic distributions)
-- =========================================================
-- SELECT "profiles_table", p.* FROM profiles AS p LIMIT 10;
-- SELECT "profiles_table", para, COUNT(*) FROM profiles AS p GROUP BY 2,1 LIMIT 10;
-- SELECT "membership_periods_table", mp.* FROM membership_periods AS mp LIMIT 10;
-- SELECT "membership_types_table", mt.* FROM membership_types AS mt LIMIT 10;
-- SELECT "militaries_table", m.* FROM militaries AS m LIMIT 10;
-- SELECT "profiles_table", m.label, COUNT(*) FROM profiles AS p LEFT JOIN militaries AS m ON m.id = p.military_id GROUP BY 2,1 LIMIT 10;
-- SELECT "ethnicity_table", e.* FROM ethnicities AS e LIMIT 10;
-- SELECT "gender_table", g.* FROM genders AS g LIMIT 10;

-- -- per Sam, imported from prior membership in 2021 but haven't updated or collected data since
-- SELECT "income_levels_table", g.* FROM income_levels AS g LIMIT 10;
-- SELECT "education_levels_table", g.* FROM education_levels AS g LIMIT 10;
-- SELECT "occupations_table", g.* FROM occupations AS g LIMIT 10;

-- =========================================================
-- 📊 ANALYTICS (active members in 2025 | income distribution)
-- =========================================================
-- filters: active in 2025, exclude specific membership types
-- note: income data is legacy (not actively collected)
SELECT
	"1_membership_income_levels_counts_query" AS source,
    i.min_level AS min_income_level,
    i.max_level,
	COUNT(DISTINCT p.id) AS count
FROM profiles AS p
	LEFT JOIN ethnicities 			AS e ON e.id = p.ethnicity_id
	LEFT JOIN militaries  			AS m ON m.id = p.military_id
	LEFT JOIN genders     			AS g ON g.id = p.gender_id
	LEFT JOIN income_levels 		AS i ON i.id = p.income_id
	LEFT JOIN education_levels  	AS ed ON ed.id = p.education_id
	LEFT JOIN occupations     		AS o ON o.id = p.occupation_id
	LEFT JOIN members     			AS mb ON mb.memberable_id = p.id
	LEFT JOIN membership_periods 	AS mp ON mp.member_id = mb.id
	LEFT JOIN membership_types 		AS mt ON mt.id = mp.membership_type_id
WHERE 1 = 1
  AND mp.starts < '2026-01-01'
  AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)  
  AND mp.deleted_at IS NULL
  AND mp.terminated_on IS NULL
  AND mp.membership_type_id NOT IN (56, 58, 81, 105) 
GROUP BY 2, 3 WITH ROLLUP
ORDER BY count DESC
LIMIT 10
;

-- =========================================================
-- 📊 ANALYTICS (active members in 2025 | education distribution)
-- =========================================================
SELECT
	"2_membership_education_counts_query" AS source,
	ed.name AS status_education,
	COUNT(DISTINCT p.id) AS count
FROM profiles AS p
	LEFT JOIN ethnicities 			AS e ON e.id = p.ethnicity_id
	LEFT JOIN militaries  			AS m ON m.id = p.military_id
	LEFT JOIN genders     			AS g ON g.id = p.gender_id
	LEFT JOIN income_levels 		AS i ON i.id = p.income_id
	LEFT JOIN education_levels  	AS ed ON ed.id = p.education_id
	LEFT JOIN occupations     		AS o ON o.id = p.occupation_id
	LEFT JOIN members     			AS mb ON mb.memberable_id = p.id
	LEFT JOIN membership_periods 	AS mp ON mp.member_id = mb.id
	LEFT JOIN membership_types 		AS mt ON mt.id = mp.membership_type_id
WHERE 1 = 1
  AND mp.starts < '2026-01-01'
  AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)  
  AND mp.deleted_at IS NULL
  AND mp.terminated_on IS NULL
  AND mp.membership_type_id NOT IN (56, 58, 81, 105) 
GROUP BY 2 WITH ROLLUP
ORDER BY count DESC
LIMIT 10
;

-- =========================================================
-- 📊 ANALYTICS (active members in 2025 | occupation distribution)
-- =========================================================
SELECT
	"3_membership_occupation_counts_query" AS source,
	o.name AS status_occupation,
	COUNT(DISTINCT p.id) AS count
FROM profiles AS p
	LEFT JOIN ethnicities 			AS e ON e.id = p.ethnicity_id
	LEFT JOIN militaries  			AS m ON m.id = p.military_id
	LEFT JOIN genders     			AS g ON g.id = p.gender_id
	LEFT JOIN income_levels 		AS i ON i.id = p.income_id
	LEFT JOIN education_levels  	AS ed ON ed.id = p.education_id
	LEFT JOIN occupations     		AS o ON o.id = p.occupation_id
	LEFT JOIN members     			AS mb ON mb.memberable_id = p.id
	LEFT JOIN membership_periods 	AS mp ON mp.member_id = mb.id
	LEFT JOIN membership_types 		AS mt ON mt.id = mp.membership_type_id
WHERE 1 = 1
  AND mp.starts < '2026-01-01'
  AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)  
  AND mp.deleted_at IS NULL
  AND mp.terminated_on IS NULL
  AND mp.membership_type_id NOT IN (56, 58, 81, 105) 
GROUP BY 2 WITH ROLLUP
ORDER BY count DESC
LIMIT 10
;

-- =========================================================
-- 📊 ANALYTICS (active members in 2025 | age bucket distribution + %)
-- =========================================================
SELECT
	"4_membership_age_bucket_counts_query" AS query_label,
	age_bucket_at_year_end,
	count,
	ROUND(100.0 * count / SUM(count) OVER (), 2) AS pct_of_total
FROM (
	SELECT
		CASE
			WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 0 AND 18 THEN '0_18'
			WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 19 AND 29 THEN '19_29'
			WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 30 AND 39 THEN '30_39'
			WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 40 AND 49 THEN '40_49'
			WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 50 AND 59 THEN '50_59'
			WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 60 AND 69 THEN '60_69'
			WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') >= 70 THEN '70_plus'
			ELSE 'unknown'
		END AS age_bucket_at_year_end,
		COUNT(DISTINCT p.id) AS count
	FROM profiles AS p
		LEFT JOIN members     			AS mb ON mb.memberable_id = p.id
		LEFT JOIN membership_periods 	AS mp ON mp.member_id = mb.id
		LEFT JOIN membership_types 		AS mt ON mt.id = mp.membership_type_id
	WHERE 1 = 1
	  AND p.date_of_birth IS NOT NULL
	  AND mp.starts < '2026-01-01'
	  AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)
	  AND mp.deleted_at IS NULL
	  AND mp.terminated_on IS NULL
	  AND mp.membership_type_id NOT IN (56, 58, 81, 105)
	GROUP BY 1
) t
ORDER BY
	CASE age_bucket_at_year_end
		WHEN '0_18' THEN 1
		WHEN '19_29' THEN 2
		WHEN '30_39' THEN 3
		WHEN '40_49' THEN 4
		WHEN '50_59' THEN 5
		WHEN '60_69' THEN 6
		WHEN '70_plus' THEN 7
		WHEN 'unknown' THEN 8
		ELSE 9
	END
;

-- ========================================================= 
-- 📊 ANALYTICS (active members in 2025 | age bucket distribution + %)
-- =========================================================
SELECT
    "5_membership_age_bucket_counts_query" AS query_label,
    age_bucket_at_year_end,
    count,
    ROUND(100.0 * count / SUM(count) OVER (), 2) AS pct_of_total
FROM (
    SELECT
        CASE
            WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') < 18 THEN 'under_18'
            WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 18 AND 24 THEN '18_24'
            WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 25 AND 34 THEN '25_34'
            WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 35 AND 44 THEN '35_44'
            WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 45 AND 54 THEN '45_54'
            WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') BETWEEN 55 AND 64 THEN '55_64'
            WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') >= 65 THEN '65_plus'
            ELSE 'unknown'
        END AS age_bucket_at_year_end,
        COUNT(DISTINCT p.id) AS count
    FROM profiles AS p
        LEFT JOIN members              AS mb ON mb.memberable_id = p.id
        LEFT JOIN membership_periods   AS mp ON mp.member_id = mb.id
        LEFT JOIN membership_types     AS mt ON mt.id = mp.membership_type_id
    WHERE 1 = 1
      AND p.date_of_birth IS NOT NULL
      AND mp.starts < '2026-01-01'
      AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)
      AND mp.deleted_at IS NULL
      AND mp.terminated_on IS NULL
      AND mp.membership_type_id NOT IN (56, 58, 81, 105)
    GROUP BY 1
) t
ORDER BY
    CASE age_bucket_at_year_end
        WHEN 'under_18' THEN 1
        WHEN '18_24' THEN 2
        WHEN '25_34' THEN 3
        WHEN '35_44' THEN 4
        WHEN '45_54' THEN 5
        WHEN '55_64' THEN 6
        WHEN '65_plus' THEN 7
        WHEN 'unknown' THEN 8
        ELSE 9
    END
;