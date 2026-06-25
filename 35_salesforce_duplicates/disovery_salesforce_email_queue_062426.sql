USE usat_sales_db;

SELECT is_test, s.* FROM salesforce_email_queue_events AS s ORDER BY created_at_mtn DESC;

SELECT * FROM salesforce_email_queue_ask_log ORDER BY created_at_mtn DESC;

SELECT * FROM salesforce_email_queue_ask_corrections;

SELECT 
	env, 
    is_test, 
    COUNT(*) AS count_rows, 
    ROUND(SUM(ai_cost_usd),4) AS usd
FROM salesforce_email_queue_events
WHERE event_name='ai_call'
GROUP BY env, is_test;

-- UPDATE salesforce_email_queue_events
-- SET env = 'prod'
-- WHERE id > 0 AND (env IS NULL OR env = '');