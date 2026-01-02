-- ========================
-- FINDS MP WITH UPGRADED FROM ID; MATCHES WITH THE UPGRADE TO RECORD; SHOWS CHARGE INFORMATION
-- ========================
SELECT
	-- ROW_NUMBER() OVER (ORDER BY p_to.id, too.starts, too.id) AS row_num,
	ROW_NUMBER() OVER (ORDER BY too.id_profiles) AS row_num,

	-- IDS
	frm.id_profiles AS p_frm_id,
	too.id_profiles AS p_to_id,	

	frm.id_membership_periods_sa AS frm_mp_id,
	too.id_membership_periods_sa AS too_mp_id,

	-- -- PERIODS
	-- DATE_FORMAT(CURDATE(), '%Y-%m') AS current_month_year,
	-- CASE
	-- 	WHEN frm.starts IS NULL THEN NULL
	-- 	ELSE (
	-- 		frm.starts < DATE_ADD(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
	-- 		AND COALESCE(frm.ends, '9999-12-31') >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
	-- 	)
	-- END AS frm_overlaps_current_month_year,

	-- CASE
	-- 	WHEN too.starts IS NULL THEN NULL
	-- 	ELSE (
	-- 		too.starts < DATE_ADD(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
	-- 		AND COALESCE(too.ends, '9999-12-31') >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
	-- 	)
	-- END AS too_overlaps_current_month_year,

	-- -- MEMBERSHIP UPGRADED FROM DETAILS
	-- frm.starts AS frm_starts,
	-- frm.ends AS frm_ends,
	-- TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) + 1 AS frm_months_span,
	-- CASE 
	-- 	WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) + 1 = 12 THEN "1) 12_months_no_change"
	-- 	WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) + 1 = 13 THEN "1a) 13_months_no_change"
	-- 	WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) + 1 = 36 THEN "1b) 36_months_no_change"
	-- 	WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) + 1 = 37 THEN "1c) 37_months_no_change"
	-- 	ELSE null
	-- END AS frm_upsell_rev_rule,

	-- -- MEMBERSHIP UPGRADED TO DETAILS
	-- too.starts AS too_starts,
	-- too.ends AS too_ends,
	-- TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) + 1 AS too_months_span,
	-- CASE 
	-- 	WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) + 1 = 12 THEN "1) 12_months_no_change"
	-- 	WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) + 1 = 13 THEN "1a) 13_months_no_change"
	-- 	WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) + 1 = 36 THEN "1b) 36_months_no_change"
	-- 	WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) + 1 = 37 THEN "1c) 37_months_no_change"
	-- 	ELSE null
	-- END AS too_upsell_rev_rule,

	-- -- MEMBERSHIP FROM CHARGE DETAILS: order info(from FROM chain)
	-- op_frm.cart_label AS frm_cart_label,
	-- op_frm.amount_per AS frm_amount_per,
	-- op_frm.discount AS frm_discount,
	-- op_frm.amount_refunded AS frm_amount_refunded,
	-- rama_frm.price_paid AS frm_rama_price_paid,

	-- -- MEMEMBERSHIP TO CHARGE DETAILS: order info (from TO chain)
	-- op_to.cart_label AS too_cart_label,
	-- op_to.amount_per AS too_amount_per,
	-- op_to.discount AS too_discount,
	-- op_to.amount_refunded AS too_amount_refunded,
	-- rama_to.price_paid AS too_rama_price_paid,

	-- -- OTHER DETAILS
	-- ma_frm.id AS frm_id_ma,
	-- ma_to.id AS to_id_ma,

	-- mt_frm.name AS frm_name_mt,  -- MEMBERSHIP TYPES
	-- mt_to.name AS to_name_mt,	-- MEMBERSHIP TPES

	-- frm.created_at AS frm_created_at, 	-- frm mp created at
	-- too.created_at AS to_created_at,	-- too mp created at

	-- p_frm.deleted_at AS frm_deleted_at_profile,
	-- p_to.deleted_at AS too_deleted_at_profile,

	-- -- COUNTS
	-- COUNT(DISTINCT frm.id) AS count_mp_frm_id,
	-- COUNT(*) AS count_records,
	-- COUNT(*) OVER () AS count_total_rows,

	-- CREATED AT DATES
	NOW() AS created_at_mtn,
	UTC_TIMESTAMP() AS created_at_utc

-- FROM membership_periods AS too
FROM all_membership_sales_data_2015_left AS too

	-- who the (TO) period belongs to
	-- JOIN members AS m_to ON m_to.id = too.member_id
	-- JOIN profiles AS p_to ON p_to.id = m_to.memberable_id
	-- LEFT JOIN users AS u_to ON u_to.id = p_to.user_id

	-- 🔗 upgrade linkage: (TO) period upgraded FROM prior (FROM) period
	-- JOIN membership_periods AS frm ON too.upgraded_from_id = frm.id
	JOIN all_membership_sales_data_2015_left AS frm ON too.upgraded_from_id_mp = frm.id_membership_periods_sa
	
	-- JOIN members AS m_frm ON m_frm.id = frm.member_id
	-- JOIN profiles AS p_frm ON p_frm.id = m_frm.memberable_id

	-- === FROM chain ===
	-- LEFT JOIN membership_applications AS ma_frm ON ma_frm.membership_period_id = frm.id
	-- LEFT JOIN order_products AS op_frm ON op_frm.purchasable_id = ma_frm.id
	-- LEFT JOIN orders AS o_frm ON o_frm.id = op_frm.order_id
	-- LEFT JOIN transactions AS t_frm ON t_frm.order_id = o_frm.id

	-- LEFT JOIN registration_audit AS ra_frm ON frm.id = ra_frm.membership_period_id
	-- LEFT JOIN registration_audit_membership_application AS rama_frm ON ra_frm.id = rama_frm.audit_id
    
	-- LEFT JOIN membership_types AS mt_frm ON mt_frm.id = ma_frm.membership_type_id
    
	-- -- === TO chain ===
	-- LEFT JOIN membership_applications AS ma_to ON ma_to.membership_period_id = too.id
	-- LEFT JOIN order_products AS op_to ON op_to.purchasable_id = ma_to.id
	-- LEFT JOIN orders AS o_to ON o_to.id = op_to.order_id
	-- LEFT JOIN transactions AS t_to ON t_to.order_id = o_to.id

	-- LEFT JOIN registration_audit AS ra_to ON too.id = ra_to.membership_period_id
	-- LEFT JOIN registration_audit_membership_application AS rama_to ON ra_to.id = rama_to.audit_id
    
	-- LEFT JOIN membership_types AS mt_to ON mt_to.id = ma_to.membership_type_id

WHERE 1 = 1
	-- AND
-- GROUP BY p_to.id, too.starts, too.id -- used to prevent join fan out
-- GROUP BY too.id_profiles
-- HAVING 1 = 1
	-- AND (frm_upsell_rev_rule IS NULL OR too_upsell_rev_rule IS NULL)
	-- AND (frm_overlaps_current_month_year = 1 OR too_overlaps_current_month_year = 1)
-- ORDER BY p_to.id, too.starts, too.id
ORDER BY too.id_profiles
;