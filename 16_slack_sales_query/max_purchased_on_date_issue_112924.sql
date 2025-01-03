SELECT * FROM vapor.membership_periods LIMIT 10;

SELECT COUNT(*) FROM vapor.membership_periods LIMIT 10;
SELECT * FROM vapor.membership_periods LIMIT 10;
SELECT 
	NOW() AS now_utc, 
    MAX(purchased_on) as max_purchase_on_timezone_unknown, 
    CONVERT_TZ(NOW(), 'UTC', 'America/Denver') AS now_mtn
FROM vapor.membership_periods LIMIT 10;

SELECT 
	id,
    origin_flag,
	NOW() AS now_utc, 
    CONVERT_TZ(NOW(), 'UTC', 'America/Denver') AS now_mtn,
    purchased_on AS purchase_on_timezone_unknown, 
    created_at,
    updated_at
FROM vapor.membership_periods 
WHERE DATE(purchased_on) = '2024-12-03'
ORDER BY purchased_on DESC
-- LIMIT 10
;