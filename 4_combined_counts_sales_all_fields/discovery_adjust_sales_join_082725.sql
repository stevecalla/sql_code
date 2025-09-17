SET @start_purchased_on_date = '2025-01-01';
SET @end_purchased_on_date = '2025-12-31';
SET @end_membership_period_date = '2010-01-01';

-- Everything is preserved from profiles, then you only see membership_periods that are reachable through membership_applications.
-- If a membership_period exists without a corresponding membership_application (common for legacy/comped/imported periods), it will NOT appear here because you only reach periods via membership_applications.
-- Count result = 3,572,350
SELECT 
	FORMAT(COUNT(*), 0)
FROM profiles
	LEFT JOIN users users ON profiles.user_id = users.id -- xx
	LEFT JOIN members ON profiles.id = members.memberable_id
	LEFT JOIN membership_applications ON profiles.id = membership_applications.profile_id
	LEFT JOIN membership_periods ON membership_periods.id = membership_applications.membership_period_id
	LEFT JOIN registration_audit_membership_application ON membership_applications.id = registration_audit_membership_application.membership_application_id -- xx
	LEFT JOIN registration_audit ON registration_audit_membership_application.audit_id = registration_audit.id
	LEFT JOIN order_products ON membership_applications.id = order_products.purchasable_id -- xx
	LEFT JOIN orders ON order_products.order_id = orders.id -- xx
	LEFT JOIN transactions ON orders.id = transactions.order_id -- xx
	LEFT JOIN membership_types ON membership_applications.membership_type_id = membership_types.id -- xx
	LEFT JOIN events ON events.id = membership_applications.event_id -- xx
;

-- Everything is preserved from membership_periods, then you only see child data if it exists. Even if applications (or orders/transactions/audits) are missing, the period still counts, and fan-out doesn’t change results because you count DISTINCT mp.id.
-- COUNT = 4,728,170
SELECT
  COUNT(DISTINCT mp.id) 																AS count_total_periods, -- 4,728,170
  COUNT(DISTINCT CASE WHEN mp.purchased_on IS NULL THEN mp.id END)         				AS count_null_purchased_on, -- COUNT = 621,722
  COUNT(DISTINCT CASE WHEN mp.created_at IS NULL THEN mp.id END)         				AS count_null_created_at, -- COUNT = 0
  COUNT(DISTINCT CASE WHEN mp.purchased_on <  '2025-08-27 00:00:00' THEN mp.id END) 	AS count_before_082725, -- COUNT = 4,106,340
  COUNT(DISTINCT CASE WHEN mp.purchased_on >= '2025-08-27 00:00:00' THEN mp.id END) 	AS count_after_082725 -- COUNT = 108
FROM membership_periods mp
	-- who the period belongs to
	LEFT JOIN members   m  ON m.id = mp.member_id
	LEFT JOIN profiles  p  ON p.id = m.memberable_id -- 
	LEFT JOIN users     u  ON u.id = p.user_id -- xx

	-- applications tied to the period
	LEFT JOIN membership_applications ma ON ma.membership_period_id = mp.id -- joins on ma / mp membership period rather than ma profile id
		-- (optional, if you also want to enforce profile consistency)
		-- AND ma.profile_id = p.id

	-- audits for the period, and the app↔audit bridge
	LEFT JOIN registration_audit_membership_application rama ON rama.membership_application_id = ma.id -- xx
	LEFT JOIN registration_audit ra ON rama.audit_id = ra.id -- xx

	-- commerce trail from an application
	LEFT JOIN order_products op ON op.purchasable_id = ma.id -- xx
	LEFT JOIN orders         o  ON o.id = op.order_id -- xx
	LEFT JOIN transactions   tx ON tx.order_id = o.id -- xx

	-- app metadata
	LEFT JOIN membership_types mt ON mt.id = ma.membership_type_id -- xx
	LEFT JOIN events          e  ON e.id = ma.event_id -- xx
;

-- The RIGHT JOINs make membership_periods → members → profiles the preserved side.
-- This keeps all membership_periods, even when no membership_application exists. That alone can add a huge number of rows vs Query 1.
-- Count result = 5,758,667
SELECT 
	FORMAT(COUNT(*), 0)
FROM membership_applications -- 1,322,131
	LEFT JOIN order_products ON (membership_applications.id = order_products.purchasable_id) -- 1,341,369
	LEFT JOIN orders ON (order_products.order_id = orders.id) -- 1,341,369
	LEFT JOIN registration_audit ON (membership_applications.membership_period_id = registration_audit.membership_period_id) -- 1,341,475
	LEFT JOIN registration_audit_membership_application ON (registration_audit.id = registration_audit_membership_application.audit_id) -- 1,341,477
	RIGHT JOIN membership_periods ON (membership_applications.membership_period_id = membership_periods.id) -- 4,747,185
	LEFT JOIN membership_types ON (membership_applications.membership_type_id = membership_types.id) -- 4,747,186
	RIGHT JOIN members ON (membership_periods.member_id = members.id) -- 4,908,355
	RIGHT JOIN profiles ON (members.memberable_id = profiles.id) -- 5,717,854
	LEFT JOIN users ON (profiles.user_id = users.id) -- 5,717,855
	LEFT JOIN events ON (membership_applications.event_id = events.id) -- 5,717,855
	LEFT JOIN transactions ON (orders.id = transactions.order_id) -- 5,758,726
;

-- How many distinct membership periods?
SELECT * FROM membership_periods mp ORDER BY mp.purchased_on DESC LIMIT 10;

SELECT
  COUNT(DISTINCT mp.id) 																AS count_total_periods, -- 4,728,170
  COUNT(DISTINCT CASE WHEN mp.purchased_on IS NULL THEN mp.id END)         				AS count_null_purchased_on, -- 621,722
  COUNT(DISTINCT CASE WHEN mp.created_at IS NULL THEN mp.id END)         				AS count_null_created_at, -- 0
  COUNT(DISTINCT CASE WHEN mp.purchased_on <  '2025-08-27 00:00:00' THEN mp.id END) 	AS count_before_082725, -- Count result = 4,106,340
  COUNT(DISTINCT CASE WHEN mp.purchased_on >= '2025-08-27 00:00:00' THEN mp.id END) 	AS count_after_082725 -- 108
FROM membership_periods mp
;

-- =============================
-- Example: “All periods” as ground truth
SELECT
  COUNT(DISTINCT mp.id) 																AS count_total_periods, -- 4,728,170
  COUNT(DISTINCT CASE WHEN mp.purchased_on IS NULL THEN mp.id END)         				AS count_null_purchased_on, -- COUNT = 621,722
  COUNT(DISTINCT CASE WHEN mp.created_at IS NULL THEN mp.id END)         				AS count_null_created_at, -- COUNT = 0
  COUNT(DISTINCT CASE WHEN mp.purchased_on <  '2025-08-27 00:00:00' THEN mp.id END) 	AS count_before_082725, -- COUNT = 4,106,340
  COUNT(DISTINCT CASE WHEN mp.purchased_on >= '2025-08-27 00:00:00' THEN mp.id END) 	AS count_after_082725 -- COUNT = 108
FROM membership_periods mp -- all = 4,728,180, before 8/27/25 = 4,106,340
	LEFT JOIN members m  ON m.id = mp.member_id -- all = 4,728,180, before 8/27/25 = 4,106,340
	LEFT JOIN profiles p ON p.id = m.memberable_id -- same
	LEFT JOIN membership_applications ma ON ma.membership_period_id = mp.id -- same
	LEFT JOIN order_products op ON op.purchasable_id = ma.id -- same
	LEFT JOIN orders o ON o.id = op.order_id -- same
	LEFT JOIN transactions t ON t.order_id = o.id -- same
	LEFT JOIN registration_audit_membership_application rma ON rma.membership_application_id = ma.id -- same
	LEFT JOIN registration_audit ra ON ra.id = rma.audit_id -- same
WHERE 1 = 1
;
-- How many distinct membership applications?
SELECT * FROM membership_applications ma ORDER BY ma.created_at DESC LIMIT 10;

SELECT 
	FORMAT(COUNT(DISTINCT ma.id), 0)															AS count_total_applications, -- 1,322,127
	FORMAT(COUNT(DISTINCT CASE WHEN ma.created_at IS NULL THEN ma.id END), 0)        			AS count_null_created_at, -- COUNT = 0
	FORMAT(COUNT(DISTINCT CASE WHEN ma.created_at <  '2025-08-27 00:00:00' THEN ma.id END), 0) 	AS count_before_082725, -- COUNT = 1,322,000
	FORMAT(COUNT(DISTINCT CASE WHEN ma.created_at >= '2025-08-27 00:00:00' THEN ma.id END), 0) 	AS count_after_082725 -- COUNT = 127
FROM membership_applications ma
WHERE ma.id IS NOT NULL
;

-- Example: “All applications” as ground truth
-- COUNT = 1,322,105
SELECT
	FORMAT(COUNT(DISTINCT ma.id), 0)															AS count_total_applications, -- 1,322,127
	FORMAT(COUNT(DISTINCT CASE WHEN ma.created_at IS NULL THEN ma.id END), 0)        			AS count_null_created_at, -- COUNT = 0
	FORMAT(COUNT(DISTINCT CASE WHEN ma.created_at <  '2025-08-27 00:00:00' THEN ma.id END), 0) 	AS count_before_082725, -- COUNT = 1,322,000
	FORMAT(COUNT(DISTINCT CASE WHEN ma.created_at >= '2025-08-27 00:00:00' THEN ma.id END), 0) 	AS count_after_082725 -- COUNT = 127
FROM membership_applications ma
	LEFT JOIN membership_periods mp ON mp.id = ma.membership_period_id
	LEFT JOIN members m  ON m.id = mp.member_id
	LEFT JOIN profiles p ON p.id = m.memberable_id
	LEFT JOIN order_products op ON op.purchasable_id = ma.id
	LEFT JOIN orders o ON o.id = op.order_id
	LEFT JOIN transactions t ON t.order_id = o.id
	LEFT JOIN registration_audit_membership_application rma ON rma.membership_application_id = ma.id
	LEFT JOIN registration_audit ra ON ra.id = rma.audit_id
;

-- ========== OTHER QUERIES ===========================
-- How many periods have no application?
-- Count result = 3,528,204
SELECT 
	FORMAT(COUNT(*), 0) AS periods_without_application
FROM membership_periods mp
	LEFT JOIN membership_applications ma ON ma.membership_period_id = mp.id
WHERE ma.id IS NULL
;

-- Query 1 “distinct periods”
-- Count result = 1,199,933
SELECT 
	FORMAT(COUNT(DISTINCT membership_periods.id), 0)
FROM profiles
	LEFT JOIN members ON profiles.id = members.memberable_id
	LEFT JOIN membership_applications ON profiles.id = membership_applications.profile_id
	LEFT JOIN membership_periods ON membership_periods.id = membership_applications.membership_period_id
;

-- Query 2 “distinct periods”
-- Count result = 4,728,093
SELECT 
	FORMAT(COUNT(DISTINCT membership_periods.id), 0)
FROM membership_applications
	RIGHT JOIN membership_periods ON membership_applications.membership_period_id = membership_periods.id
	RIGHT JOIN members ON membership_periods.member_id = members.id
	RIGHT JOIN profiles ON members.memberable_id = profiles.id
;


