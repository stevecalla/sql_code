-- ============================================================================
-- RECURSIVE VERSION TO GET MORE YEARS
-- ============================================================================
SET @start_year = 2025;
SET @ends_mp = '2025-01-01';

WITH RECURSIVE
params AS (
  SELECT
    DATE_SUB(CURDATE(), INTERVAL 1 DAY) AS as_of_date,
    @start_year AS start_year
),
years AS (
  SELECT
    p.start_year AS report_year,
    p.as_of_date
  FROM params p
  UNION ALL
  SELECT
    y.report_year + 1,
    y.as_of_date
  FROM years y
  WHERE y.report_year + 1 <= YEAR(y.as_of_date)
),
period_definitions AS (
  SELECT
    report_year,
    'FULL' AS period_type,
    DATE(CONCAT(report_year, '-01-01')) AS period_start,
    DATE(CONCAT(report_year + 1, '-01-01')) AS period_end,
    as_of_date
  FROM years

  UNION ALL

  SELECT
    report_year,
    'YTD' AS period_type,
    DATE(CONCAT(report_year, '-01-01')) AS period_start,
    CASE
      WHEN report_year < YEAR(as_of_date)
        THEN DATE(CONCAT(report_year, '-', DATE_FORMAT(as_of_date, '%m-%d')))
      ELSE as_of_date
    END AS period_end,
    as_of_date
  FROM years
),
ended_periods AS (
  SELECT
    pd.report_year,
    pd.period_type,
    pd.period_start,
    pd.period_end,

    s.id_profiles,
    s.member_number_members_sa,
    s.id_membership_periods_sa,
    s.purchased_on_adjusted_mp,
    s.starts_mp AS original_start,
    s.ends_mp   AS original_end,
    s.real_membership_types_sa,
    s.new_member_category_6_sa,
    s.origin_flag_category,
    s.origin_flag_ma
  FROM period_definitions pd
  JOIN sales_key_stats_2015 s ON s.ends_mp >= pd.period_start
   AND s.ends_mp <  pd.period_end
   AND s.ends_mp >= @ends_mp
  WHERE 1 = 1
    -- cap only the YTD rows to as_of_date (and do it safely for DATETIME)
    AND (
      pd.period_type <> 'YTD'
      OR s.ends_mp < DATE_ADD((SELECT as_of_date FROM params), INTERVAL 1 DAY)
    )
),
renewal_candidates AS (
  SELECT
    e.report_year,
    e.period_type,
    e.period_start,
    e.period_end,

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
      PARTITION BY e.report_year, e.period_type, e.id_profiles
      ORDER BY e.original_end, e.original_start, e.purchased_on_adjusted_mp, e.id_membership_periods_sa
    ) AS original_seq,

    ROW_NUMBER() OVER (
      PARTITION BY e.report_year, e.period_type, e.id_profiles, e.id_membership_periods_sa, e.original_end
      ORDER BY s.starts_mp, s.purchased_on_date_mp, s.id_membership_periods_sa
    ) AS next_rank

  FROM ended_periods e
  LEFT JOIN sales_key_stats_2015 s
    ON s.id_profiles = e.id_profiles
   AND s.starts_mp > e.original_end
   AND s.starts_mp <= DATE_ADD(e.original_end, INTERVAL 365 DAY) -- renewal window
),
final_rows AS (
  SELECT
    report_year,
    period_type,
    period_start,
    period_end,

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
  WHERE next_rank = 1
),
summary_by_dims AS (
  SELECT
    'SUMMARY — renewal rates (FULL + YTD)' AS query_label,
    report_year,
    period_type,
    period_start,
    period_end,

    original_type,
    original_category,
    original_origin_flag_category,
    original_origin_flag_ma,

    COUNT(*) AS ended_row_count,
    SUM(renewed_flag) AS did_renew_row_count,
    (COUNT(*) - SUM(renewed_flag)) AS did_not_renew_count,

    (COUNT(*) - SUM(renewed_flag)) / COUNT(*) AS did_not_renew_rate,
    SUM(renewed_flag) / COUNT(*) AS did_renew_rate
  FROM final_rows
  GROUP BY
    report_year,
    period_type,
    period_start,
    period_end,
    original_type,
    original_category,
    original_origin_flag_category,
    original_origin_flag_ma
),
summary_rollup AS (
  SELECT
    'ROLLUP — overall renewal rate by year/period' AS query_label,
    report_year,
    period_type,
    period_start,
    period_end,

    COUNT(*) AS ended_row_count,
    SUM(renewed_flag) AS did_renew_count,
    (COUNT(*) - SUM(renewed_flag)) AS did_not_renew_count,

    (COUNT(*) - SUM(renewed_flag)) / COUNT(*) AS did_not_renew_rate,
    SUM(renewed_flag) / COUNT(*) AS did_renew_rate
  FROM final_rows
  GROUP BY
    report_year,
    period_type,
    period_start,
    period_end
)

/* detailed breakdown */
SELECT *
FROM summary_by_dims
ORDER BY
  report_year,
  period_type,
  did_renew_row_count DESC,
  ended_row_count DESC;

/* rollup totals */
SELECT *
FROM summary_rollup
ORDER BY
  report_year,
  period_type
;
