-- ========================
-- basic discovery
-- ========================
SELECT
	DISTINCT s.new_member_category_6_sa,
	"distinct category" AS query_label
FROM all_membership_sales_data_2015_left AS s
LIMIT 1000
;

SELECT
	member_number_members_sa,
    real_membership_types_sa,
    new_member_category_6_sa,
    purchased_on_adjusted_mp,
    ends_mp
FROM all_membership_sales_data_2015_left AS s
WHERE 1 = 1
	AND new_member_category_6_sa = "3-Year"
LIMIT 1000
;

SELECT 
	"expire in 2026" AS query_label,
	COUNT(*)
FROM all_membership_sales_data_2015_left 
WHERE 1 = 1
	AND new_member_category_6_sa = "3-Year"
	AND ends_mp > '2025-12-31'
	AND ends_mp <= '2026-12-31'
LIMIT 10
;

SELECT 
	"purchase in 2025" AS query_label,
	COUNT(*)
FROM all_membership_sales_data_2015_left 
WHERE 1 = 1
	AND new_member_category_6_sa = "3-Year"
	AND purchased_on_year_adjusted_mp = 2025
LIMIT 10
;

SELECT 
    'count purchased year' AS query_label,
    purchased_on_year_adjusted_mp,
    COUNT(*) AS rows_count,
    COUNT(*) AS distinct_members
FROM all_membership_sales_data_2015_left 
WHERE 1 = 1
	AND new_member_category_6_sa = "3-Year"
GROUP BY 1, 2
ORDER BY 1, 2
-- LIMIT 10
;

SELECT 
    'ends / expiration year' AS query_label,
    YEAR(ends_mp),
    COUNT(*) AS rows_count,
    COUNT(*) AS distinct_members
FROM all_membership_sales_data_2015_left 
WHERE 1 = 1
	AND new_member_category_6_sa = "3-Year"
GROUP BY 1, 2
ORDER BY 1, 2
-- LIMIT 10
;

-- ========================
-- breakdown 3-year sales figures
-- ========================
WITH base AS (
  SELECT
    id_profiles,
    new_member_category_6_sa,
    purchased_on_date_adjusted_mp,
    starts_mp,
    ends_mp
  FROM all_membership_sales_data_2015_left
),

purchases_2025_any AS (
  SELECT DISTINCT id_profiles
  FROM base
  WHERE purchased_on_date_adjusted_mp >= '2025-01-01'
    AND purchased_on_date_adjusted_mp <  '2026-01-01'
),

purchases_2025_3yr AS (
  SELECT DISTINCT id_profiles
  FROM base
  WHERE 1 = 1
    AND new_member_category_6_sa = '3-Year'
    AND purchased_on_date_adjusted_mp >= '2025-01-01'
    AND purchased_on_date_adjusted_mp <  '2026-01-01'
),

purchases_pre_2025_any AS (
  SELECT DISTINCT id_profiles
  FROM base
  WHERE purchased_on_date_adjusted_mp < '2025-01-01'
),

purchases_pre_2025_3yr AS (
  SELECT DISTINCT id_profiles
  FROM base
  WHERE 1 = 1
    AND new_member_category_6_sa = '3-Year'
    AND purchased_on_date_adjusted_mp < '2025-01-01'
),

/* --- Cohorts / helper sets --- */
expiring_2025_3yr AS (
  SELECT DISTINCT id_profiles
  FROM base
  WHERE 1 = 1
    AND new_member_category_6_sa = '3-Year'
    AND ends_mp >= '2025-01-01' AND ends_mp < '2026-01-01'
),

renewed_any AS (
  SELECT DISTINCT e.id_profiles
  FROM expiring_2025_3yr e
  JOIN purchases_2025_any p USING (id_profiles)
),

renewed_3yr AS (
  SELECT DISTINCT e.id_profiles
  FROM expiring_2025_3yr e
  JOIN purchases_2025_3yr p USING (id_profiles)
)

SELECT ord, driver, rows_count, distinct_members, flow_role, sub_role, logic_sql, logic_explained
FROM (

  /* ===== Stage 1: 2025 purchases (NEW SALES) ===== */
  SELECT
    1 AS ord,
    '1) 2025 purchases (3-Year)' AS driver,
    COUNT(*) AS rows_count,
    COUNT(*) AS distinct_members,
    'new_sales'  AS flow_role,
    'new_sales_all_3yr' AS sub_role,
    'FROM purchases_2025_3yr' AS logic_sql,
    'Members who bought a 3-Year product during calendar year 2025.' AS logic_explained
  FROM purchases_2025_3yr

  UNION ALL
  SELECT
    2,
    '2) 2025 3-Year purchase — NO prior ANY purchase',
    COUNT(*), COUNT(*),
    'new_sales' AS flow_role,
    'new_sales_net_new' AS sub_role,
    'purchases_2025_3yr LEFT JOIN purchases_pre_2025_any IS NULL' AS logic_sql,
    '2025 3-Year buyers with no purchase history of any product before 2025 (net-new).' AS logic_explained
  FROM (
    SELECT p25.id_profiles
    FROM purchases_2025_3yr p25
    LEFT JOIN purchases_pre_2025_any pre USING (id_profiles)
    WHERE pre.id_profiles IS NULL
  ) y

  UNION ALL
  SELECT
    3,
    '3) 2025 3-Year purchase — prior ANY purchase',
    COUNT(*), COUNT(*),
    'new_sales' AS flow_role,
    'new_sales_prior_any' AS sub_role,
    'purchases_2025_3yr JOIN purchases_pre_2025_any' AS logic_sql,
    '2025 3-Year buyers who did buy something before 2025 (any category).' AS logic_explained
  FROM (
    SELECT DISTINCT p25.id_profiles
    FROM purchases_2025_3yr p25
    JOIN purchases_pre_2025_any pre USING (id_profiles)
  ) y

  UNION ALL
  SELECT
    4,
    '4) 2025 3-Year purchase — prior 3-Year',
    COUNT(*), COUNT(*),
    'new_sales' AS flow_role,
    'new_sales_prior_3yr' AS sub_role,
    'purchases_2025_3yr JOIN purchases_pre_2025_3yr' AS logic_sql,
    '2025 3-Year buyers who specifically had a prior 3-Year before 2025 (regardless of when it expired).' AS logic_explained
  FROM (
    SELECT DISTINCT p25.id_profiles
    FROM purchases_2025_3yr p25
    JOIN purchases_pre_2025_3yr pre3 USING (id_profiles)
  ) y

  /* ===== Stage 2: Expirations & Renewals ===== */
  UNION ALL
  SELECT
    5,
    '5) Expire in 2025 (3-Year)',
    COUNT(*), COUNT(DISTINCT id_profiles),
    'expiring' AS flow_role,
    'expiring_2025' AS sub_role,
    'new_member_category_6_sa = ''3-Year'' AND ends_mp >= ''2025-01-01'' AND ends_mp < ''2026-01-01''' AS logic_sql,
    '3-Year contracts whose end date falls during 2025 (renewal pool for 2025).' AS logic_explained
  FROM base
  WHERE new_member_category_6_sa = '3-Year'
    AND ends_mp >= '2025-01-01' AND ends_mp < '2026-01-01'

  UNION ALL
  SELECT
    6,
    '6) Expiring 2025 who made ANY 2025 purchase',
    COUNT(*), COUNT(*),
    'renewals' AS flow_role,
    'renewal_any' AS sub_role,
    'expiring_2025_3yr JOIN purchases_2025_any' AS logic_sql,
    'Of those expiring in 2025, members who bought anything (any category) during 2025.' AS logic_explained
  FROM (SELECT DISTINCT id_profiles FROM renewed_any) x

  UNION ALL
  SELECT
    7,
    '7) Expiring 2025 who repurchased 3-Year',
    COUNT(*), COUNT(*),
    'renewals' AS flow_role,
    'renewal_3yr' AS sub_role,
    'expiring_2025_3yr JOIN purchases_2025_3yr' AS logic_sql,
    'Of those expiring in 2025, members who bought a 3-Year again during 2025.' AS logic_explained
  FROM (SELECT DISTINCT id_profiles FROM renewed_3yr) x

  /* ===== Forward-looking expirations (context) ===== */
  UNION ALL
  SELECT
    8,
    '8) Expire in 2026 (3-Year)',
    COUNT(*), COUNT(DISTINCT id_profiles),
    'expiring' AS flow_role,
    'expiring_2026' AS sub_role,
    'new_member_category_6_sa = ''3-Year'' AND ends_mp >= ''2026-01-01'' AND ends_mp < ''2027-01-01''' AS logic_sql,
    '3-Year contracts that will expire in 2026 (forward-looking renewal pool).' AS logic_explained
  FROM base
  WHERE new_member_category_6_sa = '3-Year'
    AND ends_mp >= '2026-01-01' AND ends_mp < '2027-01-01'

  UNION ALL
  SELECT
    9,
    '9) Expire in 2027 (3-Year)',
    COUNT(*), COUNT(DISTINCT id_profiles),
    'expiring' AS flow_role,
    'expiring_2027' AS sub_role,
    'new_member_category_6_sa = ''3-Year'' AND ends_mp >= ''2027-01-01'' AND ends_mp < ''2028-01-01''' AS logic_sql,
    '3-Year contracts that will expire in 2027 (forward-looking renewal pool).' AS logic_explained
  FROM base
  WHERE new_member_category_6_sa = '3-Year'
    AND ends_mp >= '2027-01-01' AND ends_mp < '2028-01-01'

  /* ===== Starting coverage snapshots ===== */
  UNION ALL
  SELECT
    10,
    '10) Covered through 2025 (no need to buy)',
    COUNT(*), COUNT(DISTINCT id_profiles),
    'starting_coverage' AS flow_role,
    'covered_2025' AS sub_role,
    'new_member_category_6_sa = ''3-Year'' AND starts_mp <= ''2025-01-01'' AND ends_mp > ''2025-12-31''' AS logic_sql,
    '3-Year contracts spanning all of 2025; these members are covered and not in-market in 2025.' AS logic_explained
  FROM base
  WHERE new_member_category_6_sa = '3-Year'
    AND starts_mp <= '2025-01-01' AND ends_mp > '2025-12-31'

  UNION ALL
  SELECT
    11,
    '11) Covered through 2026 (no need to buy)',
    COUNT(*), COUNT(DISTINCT id_profiles),
    'starting_coverage' AS flow_role,
    'covered_2026' AS sub_role,
    'new_member_category_6_sa = ''3-Year'' AND starts_mp <= ''2026-01-01'' AND ends_mp > ''2026-12-31''' AS logic_sql,
    '3-Year contracts spanning all of 2026; these members are covered and not in-market in 2026.' AS logic_explained
  FROM base
  WHERE new_member_category_6_sa = '3-Year'
    AND starts_mp <= '2026-01-01' AND ends_mp > '2026-12-31'

  UNION ALL
  SELECT
    12,
    '12) Covered through 2027 (no need to buy)',
    COUNT(*), COUNT(DISTINCT id_profiles),
    'starting_coverage' AS flow_role,
    'covered_2027' AS sub_role,
    'new_member_category_6_sa = ''3-Year'' AND starts_mp <= ''2027-01-01'' AND ends_mp > ''2027-12-31''' AS logic_sql,
    '3-Year contracts spanning all of 2027; these members are covered and not in-market in 2027.' AS logic_explained
  FROM base
  WHERE new_member_category_6_sa = '3-Year'
    AND starts_mp <= '2027-01-01' AND ends_mp > '2027-12-31'

) z
ORDER BY ord;
