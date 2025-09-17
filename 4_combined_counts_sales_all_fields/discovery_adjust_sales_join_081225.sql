-- SELECT * FROM orders LIMIT 1000;
-- SELECT * FROM order_products LIMIT 1000;

SET @profile_id = 923279; 	-- 58 ma; registration_audit WHERE id = 2520555; (missing id_mp_ra; many applications for same event) -- SELECT * FROM registration_audit WHERE id = 2520555;
-- SET @profile_id = 949580; 	-- 9 ma; ra.id = 2489259 
-- SET @profile_id = 54;		-- 7 ma (produced duplicates w/out grouping by id_ma)
-- SET @profile_id = 57;		-- 14 ma
-- SET @profile_id = 1282021; 		-- 1 ma; registration_audit WHERE id = 2514277; SELECT * FROM registration_audit WHERE id = 2514277;
-- SET @profile_id = 2665064; 			-- 2 ma; registration_audit WHERE id = 2468445; -- SELECT * FROM registration_audit WHERE id = 2468445;
-- SET @profile_id = '2835851';		-- 3 ma; registration_audit WHERE id = 2491686; (all applications for same event, missing id_mp_ra) SELECT * FROM registration_audit WHERE id = 2491686;

-- GET MEMBERSHIP APPLICATIONS
SELECT *
FROM membership_applications 
WHERE 1 = 1
	AND profile_id = @profile_id
;

-- GET PROFILE & RELATED MEMBERSHIP APPLICATIONS / PERIODS
SELECT 
	p.id AS id_p
    , u.id AS id_u
    , m.id AS id_m
    , ma.id AS id_ma
    , ma.profile_id AS profile_id_ma
    , ma.created_at AS created_at_ma
    , CONCAT(ma.first_name, ' ', ma.last_name) AS full_name_ma
    , ma.id AS id_ma
    , ma.origin_flag AS origin_flag_ma
	, rama.membership_application_id AS id_ma_rama
    , rama.price_paid AS price_paid_rama
    , ra.id AS id_ra
	, ra.created_at AS created_at_ra
    , ra.processed_at AS processed_at_ra
    , ra.confirmation_number
    , ra.membership_period_id AS id_mp_ra
	, op.purchasable_id AS purchasable_id_op
    , op.amount_per - op.discount - op.amount_refunded AS price_paid_op
	, o.id AS o_id
    , mp.id AS id_mp
    , mp.created_at AS created_at_mp
    , mp.deleted_at AS deleted_at_mp
    , mp.starts AS starts_mp
    , mp.ends AS ends_mp
    , mt.id AS id_mt
    , e.id AS id_e
FROM profiles p
    LEFT JOIN users u ON p.user_id = u.id
	LEFT JOIN members m ON p.id = m.memberable_id
    LEFT JOIN membership_applications ma ON p.id = ma.profile_id
    LEFT JOIN membership_periods AS mp ON mp.id = ma.membership_period_id
    LEFT JOIN registration_audit_membership_application rama ON ma.id = rama.membership_application_id
    LEFT JOIN registration_audit ra ON rama.audit_id = ra.id
    LEFT JOIN order_products op ON ma.id = op.purchasable_id
    LEFT JOIN orders o ON op.order_id = o.id
    LEFT JOIN transactions t ON o.id = t.order_id
    LEFT JOIN membership_types mt ON ma.membership_type_id = mt.id
    LEFT JOIN events e ON e.id = ma.event_id
WHERE 1 = 1
    AND p.id = @profile_id
GROUP BY id_ma, id_mp
LIMIT 1000
;

-- BEST PRACTICE FROM SAM = REG AUDIT TO MEMBERSHIP PERIOD ID
--     FROM registration_audit AS ra
--     	LEFT JOIN registration_audit_membership_application AS rama ON ra.id = rama.audit_id
-- 		LEFT JOIN membership_applications AS ma ON ma.id = rama.membership_application_id
--      LEFT JOIN membership_periods AS mp ON mp.id = ma.membership_period_id

-- ORIGINAL JOIN LOGIC
-- FROM membership_applications
--     LEFT JOIN order_products ON (membership_applications.id = order_products.purchasable_id)
--     LEFT JOIN orders ON (order_products.order_id = orders.id)
--     LEFT JOIN registration_audit ON (membership_applications.membership_period_id = registration_audit.membership_period_id)
--     LEFT JOIN registration_audit_membership_application ON (registration_audit.id = registration_audit_membership_application.audit_id)
--     RIGHT JOIN membership_periods ON (membership_applications.membership_period_id = membership_periods.id)
--     LEFT JOIN membership_types ON (membership_applications.membership_type_id = membership_types.id)
--     RIGHT JOIN members ON (membership_periods.member_id = members.id)
--     RIGHT JOIN profiles ON (members.memberable_id = profiles.id)
--     LEFT JOIN users ON (profiles.user_id = users.id)
--     LEFT JOIN events ON (membership_applications.event_id = events.id)
--     LEFT JOIN transactions ON (orders.id = transactions.order_id)
