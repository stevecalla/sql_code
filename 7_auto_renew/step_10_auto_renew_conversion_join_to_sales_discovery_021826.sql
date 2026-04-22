SELECT * FROM usat_sales_db.sales_key_stats_2015 LIMIT 10;
SELECT * FROM usat_sales_db.sales_key_stats_2015 WHERE id_profiles = '35990';
SELECT * FROM usat_sales_db.sales_key_stats_2015 WHERE id_membership_periods_sa = '5258592';

SELECT 
    purchased_on_date_adjusted_mp,
    COUNT(*) AS purchase_count,
    COUNT(DISTINCT id_profiles) AS purchase_count
FROM usat_sales_db.sales_key_stats_2015
WHERE 1 = 1
    AND origin_flag_category LIKE '%source_usat_direct%'
    AND new_member_category_6_sa IN ('Silver','Gold','3-Year','One-Day - $15')
GROUP BY purchased_on_date_adjusted_mp
ORDER BY purchased_on_date_adjusted_mp DESC
LIMIT 1000
;

SELECT * FROM usat_sales_db.all_auto_renew_data_raw LIMIT 10;
SELECT * FROM usat_sales_db.all_auto_renew_data_raw WHERE id_profiles = '35990';

SELECT * FROM usat_sales_db.all_auto_renew_data_raw WHERE customer_id_braintree_subscriptions = '83630185003';

SELECT 
    created_at_date_braintree_subscriptions,
    COUNT(*) AS auto_renew_signed_up_count
FROM usat_sales_db.all_auto_renew_data_raw
WHERE 1 = 1
GROUP BY created_at_date_braintree_subscriptions
ORDER BY created_at_date_braintree_subscriptions DESC
LIMIT 1000
;

WITH sales_daily AS (
  SELECT
    DATE(purchased_on_date_adjusted_mp) AS dt,
    COUNT(*) AS purchase_count
  FROM usat_sales_db.sales_key_stats_2015
  WHERE origin_flag_category LIKE '%source_usat_direct%'
    AND new_member_category_6_sa IN ('Silver','Gold','3-Year','One-Day - $15')
  GROUP BY DATE(purchased_on_date_adjusted_mp)
),
braintree_daily AS (
  SELECT
    created_at_date_braintree_subscriptions AS dt,
    COUNT(*) AS auto_renew_signed_up_count
  FROM usat_sales_db.all_auto_renew_data_raw
  GROUP BY created_at_date_braintree_subscriptions
)
SELECT
  s.dt,
  s.purchase_count,
  COALESCE(b.auto_renew_signed_up_count, 0) AS auto_renew_signed_up_count,
  ROUND(COALESCE(b.auto_renew_signed_up_count, 0) / NULLIF(s.purchase_count, 0), 4) AS signup_per_purchase_rate
FROM sales_daily s
LEFT JOIN braintree_daily b
  ON b.dt = s.dt
ORDER BY s.dt DESC
LIMIT 1000;



