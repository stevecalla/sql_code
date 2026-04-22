USE vapor;

SELECT "profiles_table", p.* FROM profiles AS p LIMIT 10;
	SELECT "profiles_table", para, COUNT(*) FROM profiles AS p GROUP BY 2,1 LIMIT 10;
SELECT "membership_periods_table", mp.* FROM membership_periods AS mp LIMIT 10;
SELECT "membership_types_table", mt.* FROM membership_types AS mt LIMIT 10;
SELECT "militaries_table", m.* FROM militaries AS m LIMIT 10;
	SELECT "profiles_table", m.label, COUNT(*) FROM profiles AS p LEFT JOIN militaries  AS m ON m.id = p.military_id GROUP BY 2,1 LIMIT 10;
SELECT "ethnicity_table", e.* FROM ethnicities AS e LIMIT 10;
SELECT "gender_table", g.* FROM genders AS g LIMIT 10;

SELECT
	"profiles_table" AS source,
    m.label AS status_military,
	COUNT(DISTINCT p.id)
FROM profiles AS p
	LEFT JOIN ethnicities AS e ON e.id = p.ethnicity_id
	LEFT JOIN militaries  AS m ON m.id = p.military_id
	LEFT JOIN genders     AS g ON g.id = p.gender_id
	LEFT JOIN members     AS mb ON mb.memberable_id = p.id
	LEFT JOIN membership_periods AS mp ON mp.member_id = mb.id
	LEFT JOIN membership_types AS mt ON mt.id = mp.membership_type_id
WHERE 1 = 1
  AND mp.starts < '2026-01-01'
  AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)  
  AND mp.deleted_at IS NULL
  AND mp.terminated_on IS NULL
  AND mp.membership_type_id NOT IN (56, 58, 81, 105) 
GROUP BY 2 WITH ROLLUP
ORDER BY p.user_id DESC
LIMIT 10
;

SELECT
  "profiles_table" AS source,
  p.id,
  p.name,
  p.date_of_birth,

  -- Dec 31, 2025 (fixed target year)
  '2025-12-31' AS year_end_date,

  TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') AS age_at_year_end,

  CASE
    WHEN p.date_of_birth <= DATE_SUB('2025-12-31', INTERVAL 18 YEAR)
    THEN '18_or_older'
    ELSE 'under_18'
  END AS age_category_at_year_end,

  e.label AS status_ethnicity,
  m.label AS status_military,
  g.short AS status_gender,
  p.para AS status_disability,

  GROUP_CONCAT(DISTINCT mt.name ORDER BY mp.starts) AS membership_type_name,
  GROUP_CONCAT(DISTINCT mp.starts ORDER BY mp.starts) AS membership_start_dates,
  GROUP_CONCAT(DISTINCT mp.ends ORDER BY mp.ends) AS membership_end_dates

FROM profiles AS p
	LEFT JOIN ethnicities AS e ON e.id = p.ethnicity_id
	LEFT JOIN militaries  AS m ON m.id = p.military_id
	LEFT JOIN genders     AS g ON g.id = p.gender_id
	LEFT JOIN members     AS mb ON mb.memberable_id = p.id
	LEFT JOIN membership_periods AS mp ON mp.member_id = mb.id
	LEFT JOIN membership_types AS mt ON mt.id = mp.membership_type_id

WHERE 1 = 1
  AND mp.starts < '2026-01-01'
  AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)
  AND mp.deleted_at IS NULL
  AND mp.terminated_on IS NULL
  AND mp.membership_type_id NOT IN (56, 58, 81, 105) 

GROUP BY
  p.id, p.name, p.date_of_birth,
  e.label, m.label, g.short

ORDER BY p.user_id DESC
LIMIT 10
;

-- Q81 — Race × Gender Breakdown
WITH membership_2025 AS (
    SELECT DISTINCT p.id
    FROM profiles p
    JOIN members mb            ON mb.memberable_id = p.id
    JOIN membership_periods mp ON mp.member_id = mb.id
    WHERE 1 = 1
	  AND mp.starts < '2026-01-01'
      AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)
	  AND mp.deleted_at IS NULL
	  AND mp.terminated_on IS NULL
      AND mp.membership_type_id NOT IN (56, 58, 81, 105) 
)
SELECT
	"Q81 — Race × Gender Breakdown" AS report,
    COALESCE(e.label, 'Unknown Race or Ethnicity') AS ethnicity,
    COALESCE(g.short, 'Unknown') AS gender,
    -- COALESCE(m.label, 'Unknown Veteran Status') AS military_status,
    -- COALESCE(p.para, 'Unknown Disability Status') AS disability_status,
    COUNT(*) AS member_count
FROM membership_2025 m25
JOIN profiles p        ON p.id = m25.id
LEFT JOIN ethnicities e ON e.id = p.ethnicity_id
LEFT JOIN genders g     ON g.id = p.gender_id
LEFT JOIN militaries m  ON m.id = p.military_id
GROUP BY report, ethnicity, gender
ORDER BY ethnicity, gender;

-- Q81 — Race × Gender Breakdown
-- USOPC Grouping / Order
WITH membership_2025 AS (
    SELECT DISTINCT p.id
    FROM profiles p
    JOIN members mb            ON mb.memberable_id = p.id
    JOIN membership_periods mp ON mp.member_id = mb.id
    WHERE mp.starts < '2026-01-01'
      AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)
      AND mp.deleted_at IS NULL
      AND mp.terminated_on IS NULL
      AND mp.membership_type_id NOT IN (56, 58, 81, 105)
),

base AS (
    SELECT
        p.id,

        -- Survey race mapping (match sheet text)
        CASE
            WHEN e.label = 'White Non Hispanic'
                THEN 'White (Not of Hispanic Origin)'
            WHEN e.label = 'Black/African American'
                THEN 'Black/African American (Not of Hispanic Origin)'
            WHEN e.label = 'Native Hawaiian or Other Pacific Islander'
                THEN 'Native Hawaiian or Pacific Islander'
            WHEN e.label = 'Two or more ethnic races'
                THEN 'Two or More Races'
            WHEN e.label IS NULL OR e.label = 'Prefer not to Answer'
                THEN 'Unknown Race or Ethnicity'
            ELSE e.label
        END AS ethnicity_group,

        -- Gender mapping (show Unknown as 4th row)
        CASE
            WHEN g.short = 'M'  THEN 'Men'
            WHEN g.short = 'F'  THEN 'Women'
            WHEN g.short = 'NB' THEN 'Nonbinary'
            ELSE 'Unknown'
        END AS gender_group
    FROM membership_2025 m25
    JOIN profiles p          ON p.id = m25.id
    LEFT JOIN ethnicities e  ON e.id = p.ethnicity_id
    LEFT JOIN genders g      ON g.id = p.gender_id
),

counts_all_genders AS (
    -- includes Unknown gender
    SELECT
        ethnicity_group,
        gender_group,
        COUNT(*) AS member_count
    FROM base
    GROUP BY ethnicity_group, gender_group
),

counts_display AS (
    -- display Men/Women/Nonbinary/Unknown
    SELECT *
    FROM counts_all_genders
    WHERE gender_group IN ('Men', 'Women', 'Nonbinary', 'Unknown')
)

SELECT *
FROM (
    -- Detail rows (Unknown shown)
    SELECT
		"Q81 — Race × Gender Breakdown: USOPC Grouping / Order" AS report,
        CONCAT(c.ethnicity_group, ' - ', c.gender_group) AS row_label,
        c.member_count,
        1 AS sort_group,
        FIELD(
            c.ethnicity_group,
            'American Indian or Alaska Native',
            'Asian',
            'Black/African American (Not of Hispanic Origin)',
            'Hispanic or Latino',
            'Native Hawaiian or Pacific Islander',
            'White (Not of Hispanic Origin)',
            'Two or More Races',
            'Unknown Race or Ethnicity'
        ) AS sort_eth,
        FIELD(c.gender_group, 'Men', 'Women', 'Nonbinary', 'Unknown') AS sort_gender
    FROM counts_display c

    UNION ALL

    -- Total includes Unknown gender
    SELECT
		"Q81 — Race × Gender Breakdown: USOPC Grouping / Order" AS report,
        'Total' AS row_label,
        SUM(member_count) AS member_count,
        2 AS sort_group,
        999 AS sort_eth,
        999 AS sort_gender
    FROM counts_all_genders
) final
ORDER BY sort_group, sort_eth, sort_gender;


-- Q82–Q105 — Add Veteran Category Breakdown
WITH membership_2025 AS (
    SELECT DISTINCT p.id
    FROM profiles p
    JOIN members mb            ON mb.memberable_id = p.id
    JOIN membership_periods mp ON mp.member_id = mb.id
    WHERE mp.starts < '2026-01-01'
      AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)
      AND mp.deleted_at IS NULL
      AND mp.terminated_on IS NULL
      AND mp.membership_type_id NOT IN (56, 58, 81, 105)
)
SELECT
    'Q82–Q105 — Add Veteran Category Breakdown' AS report,
    COALESCE(e.label, 'Unknown Race or Ethnicity') AS ethnicity,
    COALESCE(g.short, 'Unknown') AS gender,
    COALESCE(m.label, 'Unknown Veteran Status') AS military_status,
    COALESCE(p.para, 'Unknown Disability Status') AS disability_status,
    COUNT(*) AS member_count
FROM membership_2025 m25
JOIN profiles p          ON p.id = m25.id
LEFT JOIN ethnicities e  ON e.id = p.ethnicity_id
LEFT JOIN genders g      ON g.id = p.gender_id
LEFT JOIN militaries m   ON m.id = p.military_id
GROUP BY
    report, ethnicity, gender, military_status, disability_status
ORDER BY
    ethnicity, gender, military_status, disability_status;

-- Q82–Q105 — Add Veteran Category Breakdown
-- USOPC Categories
WITH membership_2025 AS (
    SELECT DISTINCT p.id
    FROM profiles p
    JOIN members mb            ON mb.memberable_id = p.id
    JOIN membership_periods mp ON mp.member_id = mb.id
    WHERE mp.starts < '2026-01-01'
      AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)
      AND mp.deleted_at IS NULL
      AND mp.terminated_on IS NULL
      AND mp.membership_type_id NOT IN (56, 58, 81, 105)
),

base AS (
    SELECT
        p.id,

        CASE
            WHEN e.label = 'White Non Hispanic'
                THEN 'White (Not of Hispanic Origin)'
            WHEN e.label = 'Black/African American'
                THEN 'Black/African American (Not of Hispanic Origin)'
            WHEN e.label IS NULL OR e.label = 'Prefer not to Answer'
                THEN 'Unknown Race or Ethnicity'
            ELSE e.label
        END AS ethnicity_group,

        CASE
            WHEN g.short = 'M'  THEN 'Men'
            WHEN g.short = 'F'  THEN 'Women'
            WHEN g.short = 'NB' THEN 'Nonbinary'
            ELSE 'Unknown'
        END AS gender_group,

        CASE
            WHEN m.label = 'Veteran' THEN 'Veterans'
            WHEN m.label IN ('Non-Military', 'Active Duty') THEN 'Non-Veteran'
            ELSE 'Unknown Veteran Status'
        END AS veteran_group,

        CASE
            WHEN p.para = 1 THEN 'Persons with Disability'
            WHEN p.para = 0 THEN 'Persons without Disability'
            ELSE 'Persons with Unknown Disability Status'
        END AS disability_group
    FROM membership_2025 m25
    JOIN profiles p         ON p.id = m25.id
    LEFT JOIN ethnicities e ON e.id = p.ethnicity_id
    LEFT JOIN genders g     ON g.id = p.gender_id
    LEFT JOIN militaries m  ON m.id = p.military_id
),

-- what categories exist in your data (race x gender)
eth_gender AS (
    SELECT DISTINCT
        ethnicity_group,
        gender_group
    FROM base
),

veteran_dim AS (
    SELECT 'Veterans' AS veteran_group
    UNION ALL SELECT 'Non-Veteran'
    UNION ALL SELECT 'Unknown Veteran Status'
),

disability_dim AS (
    SELECT 'Persons with Disability' AS disability_group
    UNION ALL SELECT 'Persons without Disability'
    UNION ALL SELECT 'Persons with Unknown Disability Status'
),

-- all combos we want to force
grid AS (
    SELECT
        eg.ethnicity_group,
        eg.gender_group,
        v.veteran_group,
        d.disability_group
    FROM eth_gender eg
    CROSS JOIN veteran_dim v
    CROSS JOIN disability_dim d
),

counts AS (
    SELECT
        ethnicity_group,
        gender_group,
        veteran_group,
        disability_group,
        COUNT(*) AS member_count
    FROM base
    GROUP BY
        ethnicity_group,
        gender_group,
        veteran_group,
        disability_group
)

SELECT
	"Q82–Q105 — Add Veteran Category Breakdown: USOPC Grouping / Order",
    g.ethnicity_group,
    g.gender_group,
    CONCAT(g.veteran_group, ' - ', g.disability_group) AS category,
    COALESCE(c.member_count, 0) AS member_count
FROM grid g
LEFT JOIN counts c
    ON  c.ethnicity_group  = g.ethnicity_group
    AND c.gender_group     = g.gender_group
    AND c.veteran_group    = g.veteran_group
    AND c.disability_group = g.disability_group
ORDER BY
    g.ethnicity_group,
    FIELD(g.gender_group, 'Men', 'Women', 'Nonbinary'),
    FIELD(g.veteran_group, 'Veterans', 'Non-Veteran', 'Unknown Veteran Status'),
    FIELD(
        g.disability_group,
        'Persons with Disability',
        'Persons without Disability',
        'Persons with Unknown Disability Status'
    );
    
-- Q107 - Youth Percentage
WITH membership_2025 AS (
    SELECT DISTINCT p.id
    FROM profiles p
    JOIN members mb            ON mb.memberable_id = p.id
    JOIN membership_periods mp ON mp.member_id = mb.id
    WHERE mp.starts < '2026-01-01'
      AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)
	  AND mp.deleted_at IS NULL
	  AND mp.terminated_on IS NULL
      AND mp.membership_type_id NOT IN (56, 58, 81, 105) 
)

SELECT
	"Q107 - Youth Percentage",
    ROUND(
        SUM(
            CASE
                WHEN TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') < 18
                THEN 1 ELSE 0
            END
        ) / COUNT(*) * 100
    ) AS youth_percentage
FROM membership_2025 m25
JOIN profiles p ON p.id = m25.id;

-- Q107 - Youth Percentage - breakout by ethnicity / gender
WITH membership_2025 AS (
    SELECT DISTINCT p.id
    FROM profiles p
    JOIN members mb            ON mb.memberable_id = p.id
    JOIN membership_periods mp ON mp.member_id = mb.id
    WHERE mp.starts < '2026-01-01'
      AND (mp.ends >= '2025-01-01' OR mp.ends IS NULL)
      AND mp.deleted_at IS NULL
      AND mp.terminated_on IS NULL
      AND mp.membership_type_id NOT IN (56, 58, 81, 105)
),

base AS (
    SELECT
        p.id,

        -- Survey race mapping (match sheet text)
        CASE
            WHEN e.label = 'White Non Hispanic'
                THEN 'White (Not of Hispanic Origin)'
            WHEN e.label = 'Black/African American'
                THEN 'Black/African American (Not of Hispanic Origin)'
            WHEN e.label = 'Native Hawaiian or Other Pacific Islander'
                THEN 'Native Hawaiian or Pacific Islander'
            WHEN e.label = 'Two or more ethnic races'
                THEN 'Two or More Races'
            WHEN e.label IS NULL OR e.label = 'Prefer not to Answer'
                THEN 'Unknown Race or Ethnicity'
            ELSE e.label
        END AS ethnicity_group,

        -- Gender mapping (show Unknown as 4th row)
        CASE
            WHEN g.short = 'M'  THEN 'Men'
            WHEN g.short = 'F'  THEN 'Women'
            WHEN g.short = 'NB' THEN 'Nonbinary'
            ELSE 'Unknown'
        END AS gender_group
    FROM membership_2025 m25
    JOIN profiles p          ON p.id = m25.id
    LEFT JOIN ethnicities e  ON e.id = p.ethnicity_id
    LEFT JOIN genders g      ON g.id = p.gender_id
    WHERE TIMESTAMPDIFF(YEAR, p.date_of_birth, '2025-12-31') < 18
),

counts_all_genders AS (
    -- includes Unknown gender
    SELECT
        ethnicity_group,
        gender_group,
        COUNT(*) AS member_count
    FROM base
    GROUP BY ethnicity_group, gender_group
),

counts_display AS (
    -- display Men/Women/Nonbinary/Unknown
    SELECT *
    FROM counts_all_genders
    WHERE gender_group IN ('Men', 'Women', 'Nonbinary', 'Unknown')
)

SELECT *
FROM (
    -- Detail rows (Unknown shown)
    SELECT
        "Q81 — Race × Gender Breakdown (Youth < 18 as of 2025-12-31): USOPC Grouping / Order" AS report,
        CONCAT(c.ethnicity_group, ' - ', c.gender_group) AS row_label,
        c.member_count,
        1 AS sort_group,
        FIELD(
            c.ethnicity_group,
            'American Indian or Alaska Native',
            'Asian',
            'Black/African American (Not of Hispanic Origin)',
            'Hispanic or Latino',
            'Native Hawaiian or Pacific Islander',
            'White (Not of Hispanic Origin)',
            'Two or More Races',
            'Unknown Race or Ethnicity'
        ) AS sort_eth,
        FIELD(c.gender_group, 'Men', 'Women', 'Nonbinary', 'Unknown') AS sort_gender
    FROM counts_display c

    UNION ALL

    -- Total includes Unknown gender
    SELECT
        "Q81 — Race × Gender Breakdown (Youth < 18 as of 2025-12-31): USOPC Grouping / Order" AS report,
        'Total' AS row_label,
        SUM(member_count) AS member_count,
        2 AS sort_group,
        999 AS sort_eth,
        999 AS sort_gender
    FROM counts_all_genders
) final
ORDER BY sort_group, sort_eth, sort_gender;