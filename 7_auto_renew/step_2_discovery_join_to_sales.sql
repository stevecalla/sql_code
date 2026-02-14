/* ============================================================================
   QUERY 0 — BASE TABLE SANITY CHECK
   Purpose:
   - Quick smoke test to confirm table shape, columns, and data presence
   - Useful when opening a new session or validating schema changes
============================================================================ */

SELECT
    'QUERY 0 — sales_key_stats_2015 sample rows' AS query_label,
    s.*
FROM sales_key_stats_2015 s
LIMIT 10;

/* ============================================================================
   QUERY 1 — SINGLE PROFILE MEMBERSHIPS ENDING IN 2025
   Purpose:
   - Inspect all membership periods for ONE profile
   - Restricted to memberships that ended during calendar year 2025
   - Useful for validating lifecycle + member_lapsed_renew_category
============================================================================ */

SELECT
    'QUERY 1 — profile 54 memberships ending in 2025' AS query_label,
    id_profiles,
    member_number_members_sa,
    starts_mp,
    ends_mp,
    member_lapsed_renew_category
FROM sales_key_stats_2015
WHERE 1 = 1
  AND id_profiles = 54
  AND ends_mp BETWEEN '2025-01-01' AND '2025-12-31'
LIMIT 10;
/* ============================================================================
   QUERY 2 — SINGLE PROFILE RENEWAL CHECK (SELF-JOIN)
   Purpose:
   - For one profile, determine whether a membership ending in 2025
     was followed by another membership purchase
   - Renewal window = within 365 days of the end date
   - Shows original membership + next membership (if any)
============================================================================ */

SELECT
    'QUERY 2 — profile 54 renewal detection' AS query_label,
    m1.id_profiles,
    m1.member_number_members_sa,
    m1.starts_mp AS original_start,
    m1.ends_mp   AS original_end,

    CASE 
        WHEN m2.id_profiles IS NOT NULL THEN 1
        ELSE 0
    END AS renewed_flag,

    m2.starts_mp AS next_start,
    m2.ends_mp   AS next_end

FROM sales_key_stats_2015 m1

LEFT JOIN sales_key_stats_2015 m2
    ON m1.id_profiles = m2.id_profiles
   AND m2.starts_mp > m1.ends_mp
   AND m2.starts_mp <= DATE_ADD(m1.ends_mp, INTERVAL 365 DAY) -- renewal window

WHERE m1.id_profiles = 54
  AND m1.ends_mp BETWEEN '2025-01-01' AND '2025-12-31';

/* ============================================================================
   QUERY 3 — ALL PROFILES WITH MEMBERSHIPS ENDING IN 2025
   Purpose:
   - Expand renewal logic to ALL profiles
   - One row per membership period that ended in 2025
   - Flags whether another membership was purchased after expiration
   - Foundation for renewal rate analysis
============================================================================ */
SELECT
    'QUERY 3 — all profiles renewal detection (2025 ends)' AS query_label,
    m1.id_profiles,
    m1.member_number_members_sa,
    m1.starts_mp AS original_start,
    m1.ends_mp   AS original_end,

    CASE 
        WHEN m2.id_profiles IS NOT NULL THEN 1
        ELSE 0
    END AS renewed_flag,

    m2.starts_mp AS next_start,
    m2.ends_mp   AS next_end

FROM sales_key_stats_2015 m1

LEFT JOIN sales_key_stats_2015 m2
    ON m1.id_profiles = m2.id_profiles
   AND m2.starts_mp > m1.ends_mp
   AND m2.starts_mp <= DATE_ADD(m1.ends_mp, INTERVAL 365 DAY) -- renewal window

WHERE m1.ends_mp BETWEEN '2025-01-01' AND '2025-12-31';
