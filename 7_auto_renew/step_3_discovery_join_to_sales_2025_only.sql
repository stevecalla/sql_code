
/* ============================================================================
   CTE VERSION — ALL PROFILES RENEWAL DETECTION (MEMBERSHIPS ENDING IN 2025)
   What it does:
   - ended_2025: isolates all membership periods that ended in calendar year 2025
   - renewal_candidates: finds any later membership starts within 365 days of that end
   - final SELECT: returns original + matched “next” membership rows and a renewed flag
   Notes:
   - This returns 1+ rows per original membership if multiple future memberships qualify.
     (If you want ONLY the earliest next membership, I can add a ROW_NUMBER filter.)
============================================================================ */
WITH ended_2025 AS (
  SELECT
    id_profiles,
    member_number_members_sa,
    id_membership_periods_sa,
    purchased_on_adjusted_mp,
    starts_mp AS original_start,
    ends_mp   AS original_end,
    real_membership_types_sa,
    new_member_category_6_sa,
    origin_flag_category,
    origin_flag_ma
  FROM sales_key_stats_2015
  WHERE ends_mp >= '2025-01-01' AND ends_mp <  '2026-01-01'
),
renewal_candidates AS (
  SELECT
    e.id_profiles,
    e.member_number_members_sa,
    e.id_membership_periods_sa AS original_id_membership_periods_sa,
    e.purchased_on_adjusted_mp AS original_purchased_on_adjusted_mp,
    e.original_start,
    e.original_end,
    e.real_membership_types_sa AS original_type,
    e.new_member_category_6_sa AS original_category,
    e.origin_flag_category AS original_origin_flag_category,
    e.origin_flag_ma AS original_origin_flag_ma,

    s.purchased_on_date_mp AS next_purchased_on_date_mp,
    s.id_membership_periods_sa AS next_id_membership_periods_sa,
    s.starts_mp AS next_start,
    s.ends_mp   AS next_end,
    s.real_membership_types_sa AS next_type,
    s.new_member_category_6_sa AS next_category,
    s.origin_flag_category AS next_origin_flag_category,
    s.origin_flag_ma AS next_origin_flag_ma,

		CASE WHEN s.starts_mp IS NOT NULL THEN 1 ELSE 0 END AS renewed_flag,
		DATEDIFF(s.purchased_on_date_mp, e.original_end) AS days_to_renew,

    CASE
      WHEN s.starts_mp IS NULL THEN 'no_renewal'
      WHEN DATEDIFF(s.purchased_on_date_mp, e.original_end) < -30 THEN 'very_early'
      WHEN DATEDIFF(s.purchased_on_date_mp, e.original_end) BETWEEN -30 AND -1 THEN 'early'
      WHEN DATEDIFF(s.purchased_on_date_mp, e.original_end) = 0 THEN 'on_time'
      WHEN DATEDIFF(s.purchased_on_date_mp, e.original_end) BETWEEN 1 AND 30 THEN 'grace_period'
      WHEN DATEDIFF(s.purchased_on_date_mp, e.original_end) > 30 THEN 'reacquired'
    END AS renewal_timing_category,

    ROW_NUMBER() OVER (
      PARTITION BY e.id_profiles
      ORDER BY e.original_end, e.original_start, e.purchased_on_adjusted_mp, e.id_membership_periods_sa
    ) AS original_seq,

    ROW_NUMBER() OVER (
      PARTITION BY e.id_profiles, e.id_membership_periods_sa, e.original_end
      ORDER BY s.starts_mp, s.purchased_on_date_mp, s.id_membership_periods_sa
    ) AS next_rank

  FROM ended_2025 e
  LEFT JOIN sales_key_stats_2015 s
    ON s.id_profiles = e.id_profiles
   AND s.starts_mp > e.original_end
   AND s.starts_mp <= DATE_ADD(e.original_end, INTERVAL 365 DAY) -- renewal window
),
final_rows AS (
  SELECT
    'CTE — all profiles renewal detection (2025 ends)' AS query_label,
    id_profiles,
    member_number_members_sa,
    original_id_membership_periods_sa,
    original_purchased_on_adjusted_mp,
    original_start,
    original_end,
    original_type,
    original_category,
    original_origin_flag_category,
    original_origin_flag_ma,

    renewed_flag,
    days_to_renew,
    renewal_timing_category,
    next_id_membership_periods_sa,
    next_purchased_on_date_mp,
    next_start,
    next_end,
    next_type,
    next_category,
    next_origin_flag_category,
    next_origin_flag_ma,

    original_seq,
    next_rank
  FROM renewal_candidates
)
-- SELECT *
-- FROM final_rows
-- WHERE 1 = 1
-- 	AND next_rank = 1  -- keeps earliest "next" membership per original membership
-- ORDER BY
--   id_profiles,
--   original_seq,
--   original_end,
--   next_start
-- ;
SELECT
  'SUMMARY — renewal counts by type/category/origin flags' AS query_label,
  original_type,
  original_category,
  original_origin_flag_category,
  original_origin_flag_ma,
--   next_type,
--   next_category,
--   next_origin_flag_category,
--   next_origin_flag_ma,
  COUNT(*) AS ended_2025_row_count,
  SUM(renewed_flag) AS did_renew_row_count,
  COUNT(*) - SUM(renewed_flag) AS did_not_renew_count,
  (COUNT(*) - SUM(renewed_flag)) / COUNT(*) AS did_not_renew_rate,
  SUM(renewed_flag) / COUNT(*) AS did_renew_rate
FROM final_rows
WHERE 1 = 1
	AND next_rank = 1  -- keeps earliest "next" membership per original membership
GROUP BY
  original_type,
  original_category,
  original_origin_flag_category,
  original_origin_flag_ma
--   next_type,
--   next_category,
--   next_origin_flag_category,
--   next_origin_flag_ma
ORDER BY
  original_type,
  original_category,
  original_origin_flag_category,
  original_origin_flag_ma
--   next_type,
--   next_category,
--   next_origin_flag_category,
--   next_origin_flag_ma
;

