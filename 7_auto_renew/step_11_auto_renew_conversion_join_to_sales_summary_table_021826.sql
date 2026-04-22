SET @day_window = 7;

WITH
sales_daily AS (
  SELECT
    DATE(s.purchased_on_date_adjusted_mp) AS dt,
    COUNT(DISTINCT s.id_profiles) AS purchase_count_distinct_profiles
  FROM usat_sales_db.sales_key_stats_2015 s
  WHERE s.origin_flag_category LIKE '%source_usat_direct%'
    AND s.new_member_category_6_sa IN ('Silver','Gold','3-Year','One-Day - $15')
  GROUP BY DATE(s.purchased_on_date_adjusted_mp)
),

sales_purchasers_by_day AS (
  SELECT
    DATE(s.purchased_on_date_adjusted_mp) AS dt,
    s.id_profiles
  FROM usat_sales_db.sales_key_stats_2015 s
  WHERE s.origin_flag_category LIKE '%source_usat_direct%'
    AND s.new_member_category_6_sa IN ('Silver','Gold','3-Year','One-Day - $15')
  GROUP BY DATE(s.purchased_on_date_adjusted_mp), s.id_profiles
),

braintree_daily AS (
  SELECT
    a.created_at_date_braintree_subscriptions AS dt,
    COUNT(DISTINCT a.id_profiles) AS auto_renew_signed_up_count_distinct_profiles
  FROM usat_sales_db.all_auto_renew_data_raw a
  GROUP BY a.created_at_date_braintree_subscriptions
),

matches AS (
  SELECT
    sp.dt,
    sp.id_profiles,
    MAX(CASE WHEN ar.id_profiles IS NOT NULL THEN 1 ELSE 0 END) AS matched_0_to_7
  FROM sales_purchasers_by_day sp
  LEFT JOIN usat_sales_db.all_auto_renew_data_raw ar
    ON ar.id_profiles = sp.id_profiles
   AND ar.created_at_date_braintree_subscriptions BETWEEN sp.dt
                                                    AND DATE_ADD(sp.dt, INTERVAL @day_window DAY)
  GROUP BY sp.dt, sp.id_profiles
),

matched_daily AS (
  SELECT
    dt,
    COUNT(*) AS unique_purchasers,
    SUM(matched_0_to_7) AS purchasers_with_sub_0_to_7_days,
    ROUND(SUM(matched_0_to_7) / NULLIF(COUNT(*), 0), 4) AS conversion_rate_0_to_7
  FROM matches
  GROUP BY dt
)

SELECT
  sd.dt,

  sd.purchase_count_distinct_profiles,
  COALESCE(bd.auto_renew_signed_up_count_distinct_profiles, 0) AS auto_renew_signed_up_count_distinct_profiles,

  -- (1) all signups (distinct profiles) / all purchasers (distinct profiles)
  ROUND(
    COALESCE(bd.auto_renew_signed_up_count_distinct_profiles, 0)
    / NULLIF(sd.purchase_count_distinct_profiles, 0),
    4
  ) AS signup_per_purchase_rate,

  -- (2) matched unique purchasers within 0-7 days / unique purchasers
  md.unique_purchasers,
  md.purchasers_with_sub_0_to_7_days,
  md.conversion_rate_0_to_7,

  -- abs variance (counts)
  (COALESCE(bd.auto_renew_signed_up_count_distinct_profiles, 0) - COALESCE(md.purchasers_with_sub_0_to_7_days, 0))
    AS conversion_abs_variance,

  -- rate variance (all-rate minus matched-rate)
  ROUND(
    ROUND(
      COALESCE(bd.auto_renew_signed_up_count_distinct_profiles, 0)
      / NULLIF(sd.purchase_count_distinct_profiles, 0),
      4
    ) - COALESCE(md.conversion_rate_0_to_7, 0),
    4
  ) AS conversion_rate_variance,

  -- percent variance vs matched-rate
  ROUND(
    (
      ROUND(
        COALESCE(bd.auto_renew_signed_up_count_distinct_profiles, 0)
        / NULLIF(sd.purchase_count_distinct_profiles, 0),
        4
      ) - COALESCE(md.conversion_rate_0_to_7, 0)
    ) / NULLIF(md.conversion_rate_0_to_7, 0),
    4
  ) AS conversion_rate_variance_pct

FROM sales_daily sd
LEFT JOIN braintree_daily bd
  ON bd.dt = sd.dt
LEFT JOIN matched_daily md
  ON md.dt = sd.dt
ORDER BY sd.dt DESC
LIMIT 1000
;
