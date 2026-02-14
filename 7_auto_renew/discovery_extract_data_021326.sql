SELECT 
    customer_id,
    status,
    bs.*
FROM braintree_subscriptions AS bs
WHERE 1 = 1
	AND bs.status NOT IN ('canceled', 'fail', 'past due') -- 17,846 records
ORDER BY customer_id
LIMIT 1000;

-- QUERY TO EXTRACT AUTO RENEW DATA
SELECT DISTINCT 
    bs.customer_id      AS customer_id_braintree_subscriptions,
    p.id                AS id_profiles,
    
    bp.product_id		AS product_id_braintree_plans,
    bp.plan_id          AS plan_id_braintree_plans,
    
    bs.status           AS status_braintree_subscriptions,
    -- ACTIVE FLAG
    CASE
		WHEN bs.status IN ('active', 'pending', 'success') THEN 1
        WHEN bs.status IN ('canceled', 'fail', 'past due') THEN 0
        ELSE "error_active_flag"
	END is_active_auto_renew_flag,
    
    bs.price            AS price_braintree_subscriptions,
    
    -- BRAINTREE DATES
    DATE_FORMAT(bs.next_billing_date, '%Y-%m-%d') AS next_billing_date_braintree_subscriptions,
    YEAR(bs.next_billing_date) AS next_billing_year_braintree_subscriptions,
    MONTH(bs.next_billing_date) AS next_billing_month_braintree_subscriptions,
    
    bs.created_at AS created_at_braintree_subscriptions,
    DATE_FORMAT(bs.created_at, '%Y-%m-%d') AS created_at_date_braintree_subscriptions,
    YEAR(bs.created_at) AS created_at_year_braintree_subscriptions,
    MONTH(bs.created_at) AS created_at_month_braintree_subscriptions,
    
    bs.updated_at AS updated_at_braintree_subscriptions,
    DATE_FORMAT(bs.updated_at, '%Y-%m-%d') AS updated_at_date_braintree_subscriptions,
	YEAR(bs.updated_at) AS updated_at_year_braintree_subscriptions,
	MONTH(bs.updated_at) AS updated_at_month_braintree_subscriptions
    
FROM braintree_subscriptions AS bs -- 21,191
	JOIN braintree_plans AS bp ON bs.purchasable_id = bp.product_id -- 21,191
	INNER JOIN customers AS c ON bs.customer_id = c.id -- 21,191
	INNER JOIN users AS u ON c.user_id = u.id -- 21,191
	INNER JOIN profiles AS p ON u.id = p.user_id -- 21,191
	INNER JOIN members AS m ON p.id = m.memberable_id -- 21,189
WHERE 1 = 1
	-- AND bs.status NOT IN ('canceled', 'fail', 'past due') -- 17,846 records
ORDER BY customer_id
;

SELECT 
    DATE_FORMAT(created_at, '%Y-%m-%d') AS created_date,
    COUNT(*) AS total_count,
    COUNT(DISTINCT customer_id),
    SUM(CASE WHEN status = 'active'   THEN 1 ELSE 0 END) AS active_count,
    SUM(CASE WHEN status = 'canceled' THEN 1 ELSE 0 END) AS canceled_count,
    SUM(CASE WHEN status = 'fail'     THEN 1 ELSE 0 END) AS fail_count,
    SUM(CASE WHEN status = 'past due' THEN 1 ELSE 0 END) AS past_due_count,
    SUM(CASE WHEN status = 'pending'  THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN status = 'success'  THEN 1 ELSE 0 END) AS success_count
FROM braintree_subscriptions AS bs
-- WHERE bs.purchasable_id = 104
GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d') WITH ROLLUP
HAVING 1 = 1
	-- AND fail_count > 0
	AND canceled_count > 0
ORDER BY DATE_FORMAT(created_at, '%Y-%m-%d') DESC
;

SELECT 
    DATE_FORMAT(next_billing_date, '%Y-%m-%d') AS next_billing_date,
    COUNT(*) AS total_count,
    SUM(CASE WHEN status = 'active'   THEN 1 ELSE 0 END) AS active_count,
    SUM(CASE WHEN status = 'pending'  THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN status = 'success'  THEN 1 ELSE 0 END) AS success_count,
    SUM(CASE WHEN status = 'canceled' THEN 1 ELSE 0 END) AS canceled_count,
    SUM(CASE WHEN status = 'fail'     THEN 1 ELSE 0 END) AS fail_count,
    SUM(CASE WHEN status = 'past due' THEN 1 ELSE 0 END) AS past_due_count
FROM braintree_subscriptions AS bs
-- WHERE bs.purchasable_id = 104
GROUP BY next_billing_date WITH ROLLUP
HAVING 1 = 1
	-- AND fail_count > 0
	-- AND canceled_count > 0
ORDER BY DATE_FORMAT(next_billing_date, '%Y-%m-%d') DESC
;
