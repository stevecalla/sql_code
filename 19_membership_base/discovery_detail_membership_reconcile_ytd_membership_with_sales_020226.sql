USE usat_sales_db;

SET @year_start = '2026-01-01';
SET @cutoff     = '2026-02-02';
SET @year       = 2026;

-- Step 1 — Lock the YTD purchaser universe (your 21,459)
WITH purchasers_ytd AS (
  SELECT DISTINCT
    s.id_profiles
  FROM sales_key_stats_2015 s
  WHERE s.purchased_on_date_adjusted_mp >= @year_start
    AND s.purchased_on_date_adjusted_mp <= @cutoff
)
SELECT "Step 1 — Lock the YTD purchaser universe (your 21,459)" AS query_label, COUNT(*) AS purchasers_ytd
FROM purchasers_ytd;

-- Step 2 — Among those purchasers, who has a membership overlapping 2026?
WITH purchasers_ytd AS (
  SELECT DISTINCT s.id_profiles
  FROM sales_key_stats_2015 s
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= '2026-02-02'
),

active_2026 AS (
  SELECT DISTINCT s.id_profiles
  FROM sales_key_stats_2015 s
  WHERE s.starts_year_mp <= 2026
    AND s.ends_year_mp   >= 2026
)

SELECT
  "Step 2 — Among those purchasers, who has a membership overlapping 2026?" AS query_label,
  COUNT(DISTINCT p.id_profiles)                                   AS purchasers_ytd,
  COUNT(DISTINCT a.id_profiles)                                   AS purchasers_ytd_with_2026_membership,
  COUNT(DISTINCT p.id_profiles)
- COUNT(DISTINCT a.id_profiles)                                   AS purchasers_ytd_without_2026_membership
FROM purchasers_ytd p
LEFT JOIN active_2026 a
  ON a.id_profiles = p.id_profiles;
  
-- Step 3 — Prove why those missing profiles fail the definition
WITH purchasers_ytd AS (
  SELECT DISTINCT s.id_profiles
  FROM sales_key_stats_2015 s
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= '2026-02-02'
),

memberships AS (
  SELECT
    s.id_profiles,
    s.starts_year_mp,
    s.ends_year_mp
  FROM sales_key_stats_2015 s
),

excluded AS (
  SELECT p.id_profiles
  FROM purchasers_ytd p
  LEFT JOIN memberships m
    ON m.id_profiles = p.id_profiles
   AND m.starts_year_mp <= 2026
   AND m.ends_year_mp   >= 2026
  WHERE m.id_profiles IS NULL
)

SELECT
  "Step 3 — Prove why those missing profiles fail the definition" AS query_label,
  CASE
    WHEN MAX(m.ends_year_mp) < 2026 THEN 'Ended before 2026'
    WHEN MIN(m.starts_year_mp) > 2026 THEN 'Starts after 2026'
    ELSE 'No valid 2026 membership (data issue)'
  END AS exclusion_reason,
  COUNT(DISTINCT e.id_profiles) AS profiles
FROM excluded e
LEFT JOIN memberships m
  ON m.id_profiles = e.id_profiles
GROUP BY 1
ORDER BY profiles DESC;

-- Step 4 — Reproduce the Membership Base counted population for 2026 YTD
SET @cutoff = '2026-02-02';

WITH ytd_params AS (
  SELECT DAYOFYEAR(@cutoff) AS doy
),
-- Universe: profiles who purchased YTD (your 21,459)
purchasers_ytd AS (
  SELECT DISTINCT s.id_profiles
  FROM sales_key_stats_2015 s
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= @cutoff
),
-- Only memberships that overlap 2026 (matches your “active in year” rule)
eligible_2026 AS (
  SELECT s.*
  FROM sales_key_stats_2015 s
  WHERE s.starts_year_mp <= 2026
    AND s.ends_year_mp   >= 2026
),
-- Pick best membership row for 2026 per profile (your exact ranking)
best_2026 AS (
  SELECT *
  FROM (
    SELECT
      e.*,
      ROW_NUMBER() OVER (
        PARTITION BY e.id_profiles
        ORDER BY
          CASE
            WHEN e.real_membership_types_sa = 'adult_annual' THEN 1
            WHEN e.real_membership_types_sa = 'youth_annual' THEN 2
            WHEN e.real_membership_types_sa = 'one_day' THEN 3
            WHEN e.real_membership_types_sa = 'elite' THEN 4
            ELSE 5
          END,
          e.ends_mp ASC,
          e.purchased_on_adjusted_mp ASC
      ) AS rn
    FROM eligible_2026 e
  ) x
  WHERE rn = 1
),
-- Counted by base: best row purchased in 2026 YTD window
base_counted_best_purchase_ytd AS (
  SELECT DISTINCT b.id_profiles
  FROM best_2026 b
  CROSS JOIN ytd_params p
  WHERE b.purchased_on_adjusted_mp >= MAKEDATE(2026, 1)
    AND b.purchased_on_adjusted_mp <  DATE_ADD(MAKEDATE(2026, 1), INTERVAL p.doy DAY)
)
SELECT
   "Step 4 — Reproduce the Membership Base counted population for 2026 YTD" AS query_label,
  (SELECT COUNT(*) FROM purchasers_ytd) AS purchasers_ytd,
  COUNT(DISTINCT p.id_profiles) AS purchasers_ytd_overlap_2026,
  COUNT(DISTINCT bc.id_profiles) AS counted_by_best_purchase_ytd,
  COUNT(DISTINCT p.id_profiles) - COUNT(DISTINCT bc.id_profiles) AS missing_due_to_best_logic
FROM purchasers_ytd p
JOIN eligible_2026 e
  ON e.id_profiles = p.id_profiles
LEFT JOIN base_counted_best_purchase_ytd bc
  ON bc.id_profiles = p.id_profiles;
  
-- Step 5 — Decompose the “missing_due_to_best_logic” into real reasons
SET @cutoff = '2026-02-02';

WITH ytd_params AS (SELECT DAYOFYEAR(@cutoff) AS doy),
purchasers_ytd AS (
  SELECT DISTINCT s.id_profiles
  FROM sales_key_stats_2015 s
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= @cutoff
),
eligible_2026 AS (
  SELECT s.*
  FROM sales_key_stats_2015 s
  WHERE s.starts_year_mp <= 2026
    AND s.ends_year_mp   >= 2026
),
best_2026 AS (
  SELECT *
  FROM (
    SELECT
      e.*,
      ROW_NUMBER() OVER (
        PARTITION BY e.id_profiles
        ORDER BY
          CASE
            WHEN e.real_membership_types_sa = 'adult_annual' THEN 1
            WHEN e.real_membership_types_sa = 'youth_annual' THEN 2
            WHEN e.real_membership_types_sa = 'one_day' THEN 3
            WHEN e.real_membership_types_sa = 'elite' THEN 4
            ELSE 5
          END,
          e.ends_mp ASC,
          e.purchased_on_adjusted_mp ASC
      ) AS rn
    FROM eligible_2026 e
  ) x
  WHERE rn = 1
),
best_is_ytd AS (
  SELECT DISTINCT b.id_profiles
  FROM best_2026 b
  CROSS JOIN ytd_params p
  WHERE b.purchased_on_adjusted_mp >= MAKEDATE(2026, 1)
    AND b.purchased_on_adjusted_mp <  DATE_ADD(MAKEDATE(2026, 1), INTERVAL p.doy DAY)
),
missing AS (
  SELECT p.id_profiles
  FROM purchasers_ytd p
  LEFT JOIN best_is_ytd biy ON biy.id_profiles = p.id_profiles
  WHERE biy.id_profiles IS NULL
),
ytd_purchase_types AS (
  SELECT
    s.id_profiles,
    GROUP_CONCAT(DISTINCT s.real_membership_types_sa ORDER BY s.real_membership_types_sa SEPARATOR ', ') AS ytd_types
  FROM sales_key_stats_2015 s
  JOIN missing m ON m.id_profiles = s.id_profiles
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= @cutoff
  GROUP BY s.id_profiles
)
SELECT
  "Step 5 — Decompose the “missing_due_to_best_logic” into real reasons" AS query_label,
  b.real_membership_types_sa AS best_type,
  COUNT(*) AS profiles_missing,
  COUNT(*) - SUM(CASE WHEN b.purchased_on_adjusted_mp < DATE_ADD(MAKEDATE(2026,1), INTERVAL (SELECT doy FROM ytd_params) DAY) THEN 1 ELSE 0 END) AS best_purchase_after_cutoff
FROM missing m
JOIN best_2026 b ON b.id_profiles = m.id_profiles
GROUP BY 1,2
ORDER BY profiles_missing DESC;

-- step 6: "Run this for the missing 3,738 and look at the purchase year of the best row
SET @cutoff = '2026-02-02';

WITH ytd_params AS (SELECT DAYOFYEAR(@cutoff) AS doy),
purchasers_ytd AS (
  SELECT DISTINCT s.id_profiles
  FROM sales_key_stats_2015 s
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= @cutoff
),

eligible_2026 AS (
  SELECT s.*
  FROM sales_key_stats_2015 s
  WHERE s.starts_year_mp <= 2026
    AND s.ends_year_mp   >= 2026
),

best_2026 AS (
  SELECT *
  FROM (
    SELECT
      e.*,
      ROW_NUMBER() OVER (
        PARTITION BY e.id_profiles
        ORDER BY
          CASE
            WHEN e.real_membership_types_sa = 'adult_annual' THEN 1
            WHEN e.real_membership_types_sa = 'youth_annual' THEN 2
            WHEN e.real_membership_types_sa = 'one_day' THEN 3
            WHEN e.real_membership_types_sa = 'elite' THEN 4
            ELSE 5
          END,
          e.ends_mp ASC,
          e.purchased_on_adjusted_mp ASC
      ) AS rn
    FROM eligible_2026 e
  ) x
  WHERE rn = 1
),

counted_best_ytd AS (
  SELECT DISTINCT b.id_profiles
  FROM best_2026 b
  CROSS JOIN ytd_params p
  WHERE b.purchased_on_adjusted_mp >= MAKEDATE(2026, 1)
    AND b.purchased_on_adjusted_mp <  DATE_ADD(MAKEDATE(2026, 1), INTERVAL p.doy DAY)
),
missing AS (
  SELECT p.id_profiles
  FROM purchasers_ytd p
  LEFT JOIN counted_best_ytd c ON c.id_profiles = p.id_profiles
  WHERE c.id_profiles IS NULL
)
SELECT 
  "step 6: Run this for the missing 3,738 and look at the purchase year of the best row:" AS query_label,
  YEAR(b.purchased_on_adjusted_mp) AS best_purchase_year,
  b.real_membership_types_sa       AS best_type,
  COUNT(DISTINCT b.id_profiles)    AS profiles
FROM missing m
JOIN best_2026 b ON b.id_profiles = m.id_profiles
GROUP BY 1,2,3 WITH ROLLUP
ORDER BY profiles DESC;

-- STEP 7: This tells you what the missing 3.7K people bought in 2026 YTD (the purchase that put them in the 21,459):
SET @cutoff = '2026-02-02';

WITH ytd_params AS (
  SELECT DAYOFYEAR(@cutoff) AS doy
),

/* 1) Any profile with a 2026 YTD purchase */
purchasers_ytd AS (
  SELECT DISTINCT s.id_profiles
  FROM sales_key_stats_2015 s
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= @cutoff
),

/* 2) Memberships that overlap 2026 */
eligible_2026 AS (
  SELECT s.*
  FROM sales_key_stats_2015 s
  WHERE s.starts_year_mp <= 2026
    AND s.ends_year_mp   >= 2026
),

/* 3) Best membership for 2026 per profile */
best_2026 AS (
  SELECT *
  FROM (
    SELECT
      e.*,
      ROW_NUMBER() OVER (
        PARTITION BY e.id_profiles
        ORDER BY
          CASE
            WHEN e.real_membership_types_sa = 'adult_annual' THEN 1
            WHEN e.real_membership_types_sa = 'youth_annual' THEN 2
            WHEN e.real_membership_types_sa = 'one_day' THEN 3
            WHEN e.real_membership_types_sa = 'elite' THEN 4
            ELSE 5
          END,
          e.ends_mp ASC,
          e.purchased_on_adjusted_mp ASC
      ) AS rn
    FROM eligible_2026 e
  ) x
  WHERE rn = 1
),

/* 4) Profiles counted by base logic (best membership purchased in 2026 YTD) */
counted AS (
  SELECT DISTINCT b.id_profiles
  FROM best_2026 b
  CROSS JOIN ytd_params p
  WHERE b.purchased_on_adjusted_mp >= MAKEDATE(2026, 1)
    AND b.purchased_on_adjusted_mp <  DATE_ADD(MAKEDATE(2026, 1), INTERVAL p.doy DAY)
),

/* 5) Missing profiles = purchasers YTD but not counted */
missing AS (
  SELECT p.id_profiles
  FROM purchasers_ytd p
  LEFT JOIN counted c ON c.id_profiles = p.id_profiles
  WHERE c.id_profiles IS NULL
)

/* 6) What those missing profiles actually bought in 2026 YTD */
SELECT
  "-- STEP 7: This tells you what the missing 3.7K people bought in 2026 YTD (the purchase that put them in the 21,459" AS query_label,
  s.real_membership_types_sa,
  s.new_member_category_6_sa,
  COUNT(DISTINCT s.id_profiles) AS profiles,
  COUNT(*) AS units
FROM sales_key_stats_2015 s
JOIN missing m ON m.id_profiles = s.id_profiles
WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
  AND s.purchased_on_date_adjusted_mp <= @cutoff
GROUP BY 1,2,3 WITH ROLLUP
ORDER BY profiles DESC;

-- Option A (recommended): One row per profile, with both sides summarized
SET @cutoff = '2026-02-02';

WITH ytd_params AS (SELECT DAYOFYEAR(@cutoff) AS doy),

/* Any profile with a 2026 YTD purchase */
purchasers_ytd AS (
  SELECT DISTINCT s.id_profiles
  FROM sales_key_stats_2015 s
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= @cutoff
),

/* Memberships overlapping 2026 */
eligible_2026 AS (
  SELECT s.*
  FROM sales_key_stats_2015 s
  WHERE s.starts_year_mp <= 2026
    AND s.ends_year_mp   >= 2026
),

/* Best membership for 2026 per profile */
best_2026 AS (
  SELECT *
  FROM (
    SELECT
      e.*,
      ROW_NUMBER() OVER (
        PARTITION BY e.id_profiles
        ORDER BY
          CASE
            WHEN e.real_membership_types_sa = 'adult_annual' THEN 1
            WHEN e.real_membership_types_sa = 'youth_annual' THEN 2
            WHEN e.real_membership_types_sa = 'one_day' THEN 3
            WHEN e.real_membership_types_sa = 'elite' THEN 4
            ELSE 5
          END,
          e.ends_mp ASC,
          e.purchased_on_adjusted_mp ASC
      ) AS rn
    FROM eligible_2026 e
  ) x
  WHERE rn = 1
),

/* Profiles counted by current base logic */
counted AS (
  SELECT DISTINCT b.id_profiles
  FROM best_2026 b
  CROSS JOIN ytd_params p
  WHERE b.purchased_on_adjusted_mp >= MAKEDATE(2026, 1)
    AND b.purchased_on_adjusted_mp <  DATE_ADD(MAKEDATE(2026, 1), INTERVAL p.doy DAY)
),

/* Missing cohort */
missing AS (
  SELECT p.id_profiles
  FROM purchasers_ytd p
  LEFT JOIN counted c ON c.id_profiles = p.id_profiles
  WHERE c.id_profiles IS NULL
),

/* Prior-to-2026: best membership driving exclusion */
prior_best_purchase AS (
  SELECT
    b.id_profiles,
    YEAR(b.purchased_on_adjusted_mp) AS prior_best_purchase_year,
    b.real_membership_types_sa       AS prior_best_type,
    b.new_member_category_6_sa       AS prior_best_category,
    DATE(b.purchased_on_adjusted_mp) AS prior_best_purchased_on,
    DATE(b.starts_mp)                AS prior_best_starts_on,
    DATE(b.ends_mp)                  AS prior_best_ends_on
  FROM best_2026 b
  JOIN missing m ON m.id_profiles = b.id_profiles
  WHERE YEAR(b.purchased_on_adjusted_mp) < 2026
),

/* 2026 YTD purchases with start/end visibility */
purchases_2026_ytd AS (
  SELECT
    s.id_profiles,

    COUNT(*) AS purchases_2026_ytd_units,

    MIN(DATE(s.starts_mp)) AS first_2026_start_mp,
    MAX(DATE(s.ends_mp))   AS last_2026_end_mp,

    GROUP_CONCAT(
      DISTINCT CONCAT(
        s.real_membership_types_sa,
        IFNULL(CONCAT(' [', s.new_member_category_6_sa, ']'), ''),
        ' | ',
        DATE(s.starts_mp), ' → ', DATE(s.ends_mp)
      )
      ORDER BY s.starts_mp
      SEPARATOR '; '
    ) AS purchases_2026_ytd_detail

  FROM sales_key_stats_2015 s
  JOIN missing m ON m.id_profiles = s.id_profiles
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= @cutoff
  GROUP BY s.id_profiles
)

SELECT
  m.id_profiles,

  /* Prior-year best membership */
  pb.prior_best_purchase_year,
  pb.prior_best_type,
  pb.prior_best_category,
  pb.prior_best_purchased_on,
  pb.prior_best_starts_on,
  pb.prior_best_ends_on,

  /* 2026 YTD purchases */
  p26.purchases_2026_ytd_units,
  p26.first_2026_start_mp,
  p26.last_2026_end_mp,
  p26.purchases_2026_ytd_detail

FROM missing m
LEFT JOIN prior_best_purchase pb ON pb.id_profiles = m.id_profiles
LEFT JOIN purchases_2026_ytd p26 ON p26.id_profiles = m.id_profiles
ORDER BY
  pb.prior_best_purchase_year DESC,
  pb.prior_best_type,
  m.id_profiles;

-- Option B: Aggregated summary table (counts by prior-year type × 2026 YTD type)
SET @cutoff = '2026-02-02';

WITH ytd_params AS (SELECT DAYOFYEAR(@cutoff) AS doy),

purchasers_ytd AS (
  SELECT DISTINCT s.id_profiles
  FROM sales_key_stats_2015 s
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= @cutoff
),

eligible_2026 AS (
  SELECT s.*
  FROM sales_key_stats_2015 s
  WHERE s.starts_year_mp <= 2026
    AND s.ends_year_mp   >= 2026
),

best_2026 AS (
  SELECT *
  FROM (
    SELECT
      e.*,
      ROW_NUMBER() OVER (
        PARTITION BY e.id_profiles
        ORDER BY
          CASE
            WHEN e.real_membership_types_sa = 'adult_annual' THEN 1
            WHEN e.real_membership_types_sa = 'youth_annual' THEN 2
            WHEN e.real_membership_types_sa = 'one_day' THEN 3
            WHEN e.real_membership_types_sa = 'elite' THEN 4
            ELSE 5
          END,
          e.ends_mp ASC,
          e.purchased_on_adjusted_mp ASC
      ) AS rn
    FROM eligible_2026 e
  ) x
  WHERE rn = 1
),

counted AS (
  SELECT DISTINCT b.id_profiles
  FROM best_2026 b
  CROSS JOIN ytd_params p
  WHERE b.purchased_on_adjusted_mp >= MAKEDATE(2026, 1)
    AND b.purchased_on_adjusted_mp <  DATE_ADD(MAKEDATE(2026, 1), INTERVAL p.doy DAY)
),

missing AS (
  SELECT p.id_profiles
  FROM purchasers_ytd p
  LEFT JOIN counted c ON c.id_profiles = p.id_profiles
  WHERE c.id_profiles IS NULL
),

prior AS (
  SELECT
    b.id_profiles,
    YEAR(b.purchased_on_adjusted_mp) AS prior_year,
    b.real_membership_types_sa AS prior_best_type,
    IFNULL(b.new_member_category_6_sa,'(null)') AS prior_best_category
  FROM best_2026 b
  JOIN missing m ON m.id_profiles = b.id_profiles
  WHERE YEAR(b.purchased_on_adjusted_mp) < 2026
),

p26 AS (
  SELECT
    s.id_profiles,
    s.real_membership_types_sa AS type_2026,
    IFNULL(s.new_member_category_6_sa,'(null)') AS cat_2026
  FROM sales_key_stats_2015 s
  JOIN missing m ON m.id_profiles = s.id_profiles
  WHERE s.purchased_on_date_adjusted_mp >= '2026-01-01'
    AND s.purchased_on_date_adjusted_mp <= @cutoff
)

SELECT
  prior.prior_year,
  prior.prior_best_type,
  prior.prior_best_category,
  p26.type_2026,
  p26.cat_2026,
  COUNT(DISTINCT prior.id_profiles) AS profiles
FROM prior
JOIN p26 ON p26.id_profiles = prior.id_profiles
GROUP BY 1,2,3,4,5
ORDER BY profiles DESC;

SELECT * FROM membership_detail_data WHERE id_profiles = 412 ORDER BY year DESC, id_profiles;


