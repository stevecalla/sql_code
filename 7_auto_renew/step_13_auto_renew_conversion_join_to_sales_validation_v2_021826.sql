SET @dt = '2026-01-01';

WITH
-- Signups on the day
signups AS (
  SELECT DISTINCT
    ar.id_profiles
  FROM usat_sales_db.all_auto_renew_data_raw ar
  WHERE ar.created_at_date_braintree_subscriptions = @dt
    AND ar.id_profiles IS NOT NULL
),

-- Qualifying purchasers on the same day (your filtered purchase definition)
purchasers_filtered_same_day AS (
  SELECT DISTINCT
    s.id_profiles
  FROM usat_sales_db.sales_key_stats_2015 s
  WHERE DATE(s.purchased_on_date_adjusted_mp) = @dt
    AND s.origin_flag_category LIKE '%source_usat_direct%'
    AND s.new_member_category_6_sa IN ('Silver','Gold','3-Year','One-Day - $15')
    AND s.id_profiles IS NOT NULL
),

-- Most recent purchase row per profile (ANY purchase, regardless of filters)
last_purchase_any AS (
  SELECT
    x.id_profiles,
    x.purchased_on_date_adjusted_mp,
    x.origin_flag_category,
    x.new_member_category_6_sa,
    x.sales_revenue,
    x.sales_units
  FROM (
    SELECT
      s.*,
      ROW_NUMBER() OVER (
        PARTITION BY s.id_profiles
        ORDER BY s.purchased_on_date_adjusted_mp DESC
      ) AS rn
    FROM usat_sales_db.sales_key_stats_2015 s
    WHERE s.id_profiles IS NOT NULL
  ) x
  WHERE x.rn = 1
)

SELECT
  @dt AS signup_dt,
  su.id_profiles,

  lp.purchased_on_date_adjusted_mp AS most_recent_purchase_ts,
  DATE(lp.purchased_on_date_adjusted_mp) AS most_recent_purchase_dt,
  lp.origin_flag_category AS most_recent_origin_flag_category,
  lp.new_member_category_6_sa AS most_recent_new_member_category_6_sa,
  lp.sales_units AS most_recent_sales_units,
  lp.sales_revenue AS most_recent_sales_revenue

FROM signups su
LEFT JOIN purchasers_filtered_same_day p
  ON p.id_profiles = su.id_profiles
LEFT JOIN last_purchase_any lp
  ON lp.id_profiles = su.id_profiles
WHERE p.id_profiles IS NULL
ORDER BY most_recent_purchase_ts DESC, su.id_profiles
LIMIT 5000;
