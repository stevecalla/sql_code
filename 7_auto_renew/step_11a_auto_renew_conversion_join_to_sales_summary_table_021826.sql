SET @day_window = 7;

WITH
sales_purchasers_by_day AS (
  SELECT
    DATE(s.purchased_on_date_adjusted_mp) AS purchased_on_date_adjusted_mp,
    s.id_profiles,
    real_membership_types_sa,
    new_member_category_6_sa,
    sales_units,
    sales_revenue
  FROM usat_sales_db.sales_key_stats_2015 s
  WHERE 1 = 1
	AND s.origin_flag_category LIKE '%source_usat_direct%'
    AND s.new_member_category_6_sa IN ('Silver','Gold','3-Year','One-Day - $15')
  ORDER BY DATE(s.purchased_on_date_adjusted_mp) DESC, s.id_profiles
)
-- SELECT * FROM sales_purchasers_by_day LIMIT 100;
-- SELECT purchased_on_date_adjusted_mp, COUNT(*) FROM sales_purchasers_by_day GROUP BY 1;

, auto_renew_signups_by_day AS (
  SELECT
    DATE(ar.created_at_date_braintree_subscriptions) AS created_at_date_braintree_subscriptions,
    ar.customer_id_braintree_subscriptions,
    ar.id_profiles,
    ar.product_id_braintree_plans,
    ar.plan_id_braintree_plans,
    ar.status_braintree_subscriptions,
    ar.is_active_auto_renew_flag,
    ar.price_braintree_subscriptions,
    ar.next_billing_date_braintree_subscriptions,
    ar.created_at_braintree_subscriptions,
    ar.updated_at_braintree_subscriptions
  FROM usat_sales_db.all_auto_renew_data_raw AS ar
  WHERE 1 = 1
  ORDER BY ar.created_at_date_braintree_subscriptions DESC, ar.id_profiles
)
-- SELECT * FROM auto_renew_signups_by_day LIMIT 100;
-- SELECT created_at_date_braintree_subscriptions, COUNT(*) FROM auto_renew_signups_by_day GROUP BY 1 ORDER BY 1 DESC;
-- SELECT 
-- 	sp.purchased_on_date_adjusted_mp, 
--     
--     COUNT(sp.id_profiles), 
--     COUNT(ar.customer_id_braintree_subscriptions),
--     
--     COUNT(DISTINCT sp.id_profiles), 
--     COUNT(DISTINCT ar.customer_id_braintree_subscriptions)
--     
-- FROM sales_purchasers_by_day AS sp
-- 	LEFT JOIN auto_renew_signups_by_day AS ar ON ar.id_profiles = sp.id_profiles
-- 		AND ar.created_at_date_braintree_subscriptions = sp.purchased_on_date_adjusted_mp
-- 		-- AND ar.created_at_date_braintree_subscriptions BETWEEN sp.purchased_on_date_adjusted_mp AND DATE_ADD(sp.purchased_on_date_adjusted_mp, INTERVAL @day_window DAY)
-- WHERE 1 = 1
-- 	AND purchased_on_date_adjusted_mp = '2026-01-01'
-- GROUP BY 1
-- ORDER BY 1 DESC
-- LIMIT 1000
-- ;

SELECT 
	*
FROM sales_purchasers_by_day AS sp
	LEFT JOIN auto_renew_signups_by_day AS ar ON ar.id_profiles = sp.id_profiles
		AND ar.created_at_date_braintree_subscriptions BETWEEN sp.purchased_on_date_adjusted_mp AND DATE_ADD(sp.purchased_on_date_adjusted_mp, INTERVAL @day_window DAY)
WHERE 1 = 1
	AND purchased_on_date_adjusted_mp = '2026-01-01'
ORDER BY sp.purchased_on_date_adjusted_mp DESC
LIMIT 1000
;
