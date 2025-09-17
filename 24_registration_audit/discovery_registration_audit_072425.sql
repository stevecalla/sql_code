-- SELECT "registration_audit", ra.* FROM registration_audit AS ra LIMIT 10;
-- SELECT "registration_companies", rc.* FROM registration_companies AS rc ORDER BY name ASC;
-- SELECT "registration_audit_membership_application", rama.* FROM registration_audit_membership_application AS rama LIMIT 10;
-- SELECT "membership_periods", mp.* FROM membership_periods AS mp LIMIT 10;
-- SELECT "registration_audit", ra.* FROM registration_audit AS ra WHERE ra.membership_period_id IN (5125396, 5124769, 5124776) LIMIT 10;
-- SELECT "membership_periods", mp.* FROM membership_periods AS mp WHERE mp.id IN (5125396, 5124769) LIMIT 10;
-- SELECT "registration_audit", ra.* FROM registration_audit AS ra WHERE DATE(ra.created_at) = "2025-08-05" LIMIT 10000;
SELECT "membership_applications", ma.* FROM membership_applications AS ma LIMIT 10;

-- reg audit counts
SELECT 
	ra.registration_company_id
	, rc.name
    , FORMAT(COUNT(*), 0)
    , COUNT(*) AS count
FROM registration_audit AS ra
	LEFT JOIN registration_companies AS rc ON ra.registration_company_id = rc.id
GROUP BY 1, 2
ORDER BY count DESC
-- LIMIT 10
;

-- UPDATED AT: Last two calendar days in local time (e.g., today + yesterday)
SELECT 
  'membership periods' AS label,
  'updated at count today / yesterday >=' AS description,
  TIMESTAMP(DATE(CONVERT_TZ(UTC_TIMESTAMP(), 'UTC', 'America/Denver')) - INTERVAL 1 DAY) AS mt_yesterday_start,
  FORMAT(COUNT(*), 0) AS record_count,
  UTC_TIMESTAMP() AS current_date_time_utc,
  CONVERT_TZ(UTC_TIMESTAMP(), 'UTC', 'America/Denver') AS current_date_time_mtn
FROM membership_periods mp
WHERE mp.updated_at >= TIMESTAMP(DATE(CONVERT_TZ(UTC_TIMESTAMP(), 'UTC', 'America/Denver')) - INTERVAL 1 DAY)
ORDER BY mp.updated_at DESC
LIMIT 10;

-- RA WITH RAMA PRICE PAID AND NO MEMBERSHIP ID?
	SELECT * FROM registration_audit WHERE id = 2520555;
    SELECT
        ""
        , ra.id AS id_ra
        , ra.created_at as created_at_ra
        , ra.processed_at as processed_at_ra
        , ra.membership_period_id AS membership_period_id_ra
        , ma.membership_period_id AS membership_period_id_ma
        , mp.id AS membership_period_id_mp
        , rama.price_paid AS price_paid_rama
        , CASE WHEN rama.price_paid IS NULL THEN 0 ELSE 1 END AS has_price_paid_rama
        , TIMEDIFF(ra.processed_at, ra.created_at) AS time_diff_hms
        , CASE WHEN ra.membership_period_id IS NOT NULL THEN 1 ELSE 0 END AS has_ra_membership_period_id
        , CASE WHEN TIMESTAMPDIFF(HOUR, ra.created_at, ra.processed_at) >= 1 THEN 1 ELSE 0 END AS is_processed_over_1_hour
        , TIME_TO_SEC(TIMEDIFF(ra.processed_at, ra.created_at)) AS time_diff_seconds
    FROM registration_audit AS ra
        LEFT JOIN registration_audit_membership_application AS rama ON ra.id = rama.audit_id
		LEFT JOIN membership_applications AS ma ON ma.id = rama.membership_application_id
        LEFT JOIN membership_periods AS mp ON mp.id = ma.membership_period_id
    WHERE 1 = 1
		-- AND ra.created_at >= "2025-07-01"
        AND ra.created_at >= "2024-01-01"
        AND ra.created_at <= "2025-06-30"
    HAVING 1 = 1
        AND has_price_paid_rama = 1
        AND ra.membership_period_id IS NULL
        -- AND id_ra = 2520555
    ORDER BY ra.id ASC, price_paid_rama
    -- LIMIT 500
;

WITH test AS (
    SELECT
        ""
        -- , ra.*
        , ra.id AS id_ra
        , ra.membership_period_id AS membership_period_id_ra
        , ra.confirmation_number AS confirmation_number_ra
        , ra.registration_company_id AS registration_company_id_ra
        , rc.name AS name_rc
        , rama.price_paid AS price_paid_rama
        , CASE WHEN rama.price_paid IS NULL THEN 0 ELSE 1 END AS has_price_paid_rama
        , ra.created_at as created_at_ra
        , ra.processed_at as processed_at_ra
        , mp.id
        , mp.created_at AS created_at_mp
        , mp.purchased_on AS purchased_on_mp
        , TIMEDIFF(ra.processed_at, ra.created_at) AS time_diff_hms
        , CASE WHEN mp.id IS NOT NULL THEN 1 ELSE 0 END AS has_membership_period_id
        , CASE WHEN TIMESTAMPDIFF(HOUR, ra.created_at, ra.processed_at) >= 1 THEN 1 ELSE 0 END AS is_processed_over_1_hour
        , TIME_TO_SEC(TIMEDIFF(ra.processed_at, ra.created_at)) AS time_diff_seconds
    FROM registration_audit AS ra
        LEFT JOIN registration_companies AS rc ON ra.registration_company_id = rc.id
        LEFT JOIN registration_audit_membership_application AS rama ON ra.id = rama.audit_id
		LEFT JOIN membership_applications AS ma ON ma.id = rama.membership_application_id
        LEFT JOIN membership_periods AS mp ON mp.id = ma.membership_period_id

        -- LEFT JOIN membership_periods AS mp ON mp.id = ra.membership_period_id -- can't use if registration audit membership id is blank
    WHERE 1 = 1
        AND DATE(ra.created_at) >= "2025-07-16"
        -- AND DATE(mp.purchased_on) = "2025-08-05"
        -- AND processed_at IS NULL
        -- AND DATE(ra.processed_at) >= "2025-07-25"
        -- AND rc.name = "Ticket Socket"
    HAVING has_price_paid_rama = 1
    ORDER BY ra.id ASC
    -- LIMIT 500
    )
    -- SELECT * FROM test;

    SELECT 
        is_processed_over_1_hour,
		has_membership_period_id,
        DATE_FORMAT(created_at_ra, '%Y-%m-%d') AS created_at_date_ra,
        DATE_FORMAT(processed_at_ra, '%Y-%m-%d') AS processed_at_date_ra,
    	DATE_FORMAT(created_at_mp, '%Y-%m-%d') AS created_at_mp,
        DATE_FORMAT(purchased_on_mp, '%Y-%m-%d') AS purchased_on_mp,
        FORMAT(COUNT(*), 0) AS record_count,
        FORMAT(SUM(price_paid_rama), 0) AS price_paid
    FROM test
    -- -- WHERE processed_at_ra IS NULL
    -- -- GROUP BY 1, 2, 3 WITH ROLLUP
    GROUP BY 1, 2, 3, 4, 5, 6
    ORDER BY 3, 2, 1;

    SELECT 
        is_processed_over_1_hour,
        has_membership_period_id,
        DATE_FORMAT(created_at_ra, '%Y-%m') AS created_at_date_ra,
        DATE_FORMAT(processed_at_ra, '%Y-%m') AS processed_at_date_ra,
        DATE_FORMAT(created_at_mp, '%Y-%m') AS created_at_mp,
        DATE_FORMAT(purchased_on_mp, '%Y-%m') AS purchased_on_mp,
        -- price_paid_rama,
        FORMAT(COUNT(*), 0) AS record_count,
        FORMAT(SUM(price_paid_rama), 0) AS price_paid
    FROM test
    GROUP BY 1, 2, 3, 4, 5, 6
    ORDER BY 3, 2, 1
;