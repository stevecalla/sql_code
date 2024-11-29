USE vapor;

SELECT COUNT(*) FROM membership_periods LIMIT 10;
SELECT * FROM membership_periods LIMIT 10;

SELECT 
	NOW() AS now_utc, 
    CONVERT_TZ(NOW(), 'UTC', 'America/Denver') AS now_mtn,
    
    -- raw max purchase on is greater than now due to subscription renewal timestamp issue
    MAX(purchased_on) as max_purchase_on_bad_timezone,
    
    -- adusted to use created_on (which is mtn) if the purchase_on is greater as a proxy
    (SELECT DATE_FORMAT(MAX(
          CASE WHEN purchased_on > created_at THEN CONVERT_TZ(purchased_on, 'UTC', 'America/Denver') 
			ELSE purchased_on 
          END), '%Y-%m-%d %H:%i:%s') 
    FROM membership_periods) AS max_purchase_on

FROM membership_periods LIMIT 10;

SELECT 
	id,
    origin_flag,
	NOW() AS now_utc,
	created_at AS created_at_mtn,
    updated_at AS created_at_mtn,
    CONVERT_TZ(NOW(), 'UTC', 'America/Denver') AS now_mtn,
    purchased_on AS purchase_on_timezone_unknown
    ,
    -- adusted to use created_on (which is mtn) if the purchase_on is greater as a proxy
    IF(purchased_on > created_at, created_at, purchased_on) AS test

FROM membership_periods 
WHERE DATE(purchased_on) = DATE(CONVERT_TZ(NOW(), 'UTC', 'America/Denver'))
ORDER BY origin_flag DESC, id DESC
-- LIMIT 10
;

