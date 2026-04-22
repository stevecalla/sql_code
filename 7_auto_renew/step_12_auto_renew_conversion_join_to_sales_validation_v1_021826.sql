SET @dt = '2026-01-01';
-- SET @dt = '2025-12-31';

WITH signups AS (
  SELECT DISTINCT ar.id_profiles
  FROM usat_sales_db.all_auto_renew_data_raw ar
  WHERE ar.created_at_date_braintree_subscriptions = @dt
    AND ar.id_profiles IS NOT NULL
),
sales_any_same_day AS (
  SELECT DISTINCT s.id_profiles
  FROM usat_sales_db.sales_key_stats_2015 s
  WHERE DATE(s.purchased_on_date_adjusted_mp) = @dt
    AND s.id_profiles IS NOT NULL
),
sales_filtered_same_day AS (
  SELECT DISTINCT s.id_profiles
  FROM usat_sales_db.sales_key_stats_2015 s
  WHERE DATE(s.purchased_on_date_adjusted_mp) = @dt
    AND s.origin_flag_category LIKE '%source_usat_direct%'
    AND s.new_member_category_6_sa IN ('Silver','Gold','3-Year','One-Day - $15')
    AND s.id_profiles IS NOT NULL
)
SELECT
  su.id_profiles,
  CASE WHEN a.id_profiles IS NOT NULL THEN 1 ELSE 0 END AS has_any_purchase_same_day,
  CASE WHEN f.id_profiles IS NOT NULL THEN 1 ELSE 0 END AS has_filtered_purchase_same_day
FROM signups su
LEFT JOIN sales_any_same_day a
  ON a.id_profiles = su.id_profiles
LEFT JOIN sales_filtered_same_day f
  ON f.id_profiles = su.id_profiles
WHERE f.id_profiles IS NULL
ORDER BY su.id_profiles
LIMIT 5000;
