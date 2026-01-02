-- ========================
-- FINDS MP WITH UPGRADED FROM ID; MATCHES WITH THE UPGRADE TO RECORD; SHOWS CHARGE INFORMATION
-- ========================
-- SELECT * FROM membership_periods LIMIT 10;

-- #1 ADD RETAIL SALES PRICE - FOR UPGRADED TO ID
WITH step_1_upgraded_to_sales_price_custom_fx AS (
	SELECT
		ROW_NUMBER() OVER (ORDER BY mp.id) AS row_num,
		"step_1_upgraded_to_sales_price_custom_fx" AS query_label,

		mp.id,
		mp.upgraded_from_id,
		mp.purchased_on,
		mt.name,

		-- SALES PRICE STATEMENT
		CASE 
			WHEN LOWER(mt.name) LIKE '%gold%' THEN 99
			WHEN LOWER(mt.name) LIKE '%gold%' AND mp.purchased_on >= '2025-12-15' THEN 99.99

			WHEN LOWER(mt.name) IN ('3-Year Adult Annual Membership', 'Silver 3-year Membership: Unlimited racing and expanded benefits') AND mp.purchased_on < '2024-10-26' 	THEN 145
			WHEN LOWER(mt.name) IN ('3-Year Adult Annual Membership', 'Silver 3-year Membership: Unlimited racing and expanded benefits') AND mp.purchased_on < '2025-01-17'  	THEN 150
			WHEN LOWER(mt.name) IN ('3-Year Adult Annual Membership', 'Silver 3-year Membership: Unlimited racing and expanded benefits') AND mp.purchased_on < '2025-12-15'  	THEN 165
			WHEN LOWER(mt.name) IN ('3-Year Adult Annual Membership', 'Silver 3-year Membership: Unlimited racing and expanded benefits') 										THEN 175
			
			WHEN LOWER(mt.name) IN ('1-Year Adult Annual Membership') AND mp.purchased_on < '2024-01-01'  	THEN 50 -- '2023-09-19 00:00:00'
			WHEN LOWER(mt.name) IN ('1-Year Adult Annual Membership') AND mp.purchased_on < '2025-02-04'  	THEN 60
			WHEN LOWER(mt.name) IN ('1-Year Adult Annual Membership') AND mp.purchased_on < '2025-12-15'  	THEN 64
			WHEN LOWER(mt.name) IN ('1-Year Adult Annual Membership') 										THEN 69

			WHEN LOWER(mt.name) IN ('Platinum Membership: USA Triathlon Foundation') AND mp.purchased_on < '2024-01-01'  	THEN 400 -- '2022-11-28 12:14:12', '2024-03-07 13:16:47'
			WHEN LOWER(mt.name) IN ('Platinum Membership: USA Triathlon Foundation') AND mp.purchased_on < '2025-02-04'  	THEN 400
			WHEN LOWER(mt.name) IN ('Platinum Membership: USA Triathlon Foundation') AND mp.purchased_on < '2025-12-15'  	THEN 400
			WHEN LOWER(mt.name) IN ('Platinum Membership: USA Triathlon Foundation') 										THEN 400

			WHEN LOWER(mt.name) IN ('Platinum Membership - Team USA') AND mp.purchased_on < '2024-01-01'  	THEN 400 -- '2022-01-21 11:45:54' '2021-12-08 18:52:53'
			WHEN LOWER(mt.name) IN ('Platinum Membership - Team USA') AND mp.purchased_on < '2025-02-04'  	THEN 400
			WHEN LOWER(mt.name) IN ('Platinum Membership - Team USA') AND mp.purchased_on < '2025-12-15'  	THEN 400
			WHEN LOWER(mt.name) IN ('Platinum Membership - Team USA') 										THEN 400
			
			ELSE "NEED A PRICE"
		END AS sales_price_custom_fx,
		
		-- CREATED AT DATES
		NOW() AS created_at_mtn,
		UTC_TIMESTAMP() AS created_at_utc,

		COUNT(*) OVER () AS count_total_rows

	FROM membership_periods AS mp
		LEFT JOIN membership_applications 		AS ma 	ON ma.membership_period_id = mp.id
		LEFT JOIN membership_types 				AS mt 	ON mt.id = ma.membership_type_id

	WHERE 1 = 1
		AND mp.upgraded_from_id IS NOT NULL
		AND mp.terminated_on IS NULL
)
	-- #2 CREATE UPSELL VALUE - FOR UPGRADED TO MP ID
	, step_2_upgraded_to_upsell_value_calculation AS (
		SELECT 
			ROW_NUMBER() OVER (ORDER BY mp.id) AS row_num,
			"step_2_upgraded_to_upsell_value_calculation" AS query_label,

			mp.id,
			sp.id AS id_mp_sp,
			mp.upgraded_from_id,
			mt.name,

			-- MEMEMBERSHIP TO CHARGE DETAILS: order info (from TO chain)
			MIN(op.amount_per) 		AS amount_per,
			MIN(op.discount) 		AS discount,
			MIN(op.amount_refunded) AS amount_refunded,
			MIN(rama.price_paid) 	AS rama_price_paid,

			-- SALES PRICE CUSTOM FX
			sp.sales_price_custom_fx,
			CASE
				WHEN sp.sales_price_custom_fx = (COALESCE(MIN(op.amount_per), 0) + COALESCE(MIN(rama.price_paid), 0)) 
					THEN sp.sales_price_custom_fx - (COALESCE(MIN(op.discount), 0)) - (COALESCE(MIN(op.amount_refunded), 0))

				WHEN sp.sales_price_custom_fx <> (COALESCE(MIN(op.amount_per), 0) + COALESCE(MIN(rama.price_paid), 0)) 
					THEN sp.sales_price_custom_fx

				ELSE 'opps error'
			END AS recognized_value_custom_fx,
			
			CASE
				WHEN sp.sales_price_custom_fx = (COALESCE(MIN(op.amount_per), 0) + COALESCE(MIN(rama.price_paid), 0)) 
					THEN (COALESCE(MIN(op.discount), 0)) + (COALESCE(MIN(op.amount_refunded), 0))

				WHEN sp.sales_price_custom_fx <> (COALESCE(MIN(op.amount_per), 0) + COALESCE(MIN(rama.price_paid), 0)) 
					THEN ROUND(sp.sales_price_custom_fx - (COALESCE(MIN(op.amount_per), 0) + COALESCE(MIN(rama.price_paid), 0)), 2)

				ELSE 'opps error'
			END AS upsell_value_custom_fx,

			CASE
				WHEN sp.sales_price_custom_fx = (COALESCE(MIN(op.amount_per), 0) + COALESCE(MIN(rama.price_paid), 0)) THEN "1) sales_price_custom = price_paid"
				WHEN sp.sales_price_custom_fx <> (COALESCE(MIN(op.amount_per), 0) + COALESCE(MIN(rama.price_paid), 0)) THEN "2) sales_price_custom <> price_paid"
				ELSE 'opps error'
			END AS recognized_value_rule_custom_fx,

			COUNT(*) AS count_records, -- to count underlying records for fan out
			
			-- CREATED AT DATES
			NOW() AS created_at_mtn,
			UTC_TIMESTAMP() AS created_at_utc,
			
		COUNT(*) OVER () AS count_total_rows
		
		FROM membership_periods AS mp
			LEFT JOIN membership_applications 		AS ma 	ON ma.membership_period_id = mp.id
			LEFT JOIN membership_types 				AS mt 	ON mt.id = ma.membership_type_id

			LEFT JOIN order_products 				AS op 	ON op.purchasable_id = ma.id
			LEFT JOIN registration_audit 							AS ra 		ON mp.id = ra.membership_period_id
			LEFT JOIN registration_audit_membership_application 	AS rama 	ON ra.id = rama.audit_id
			
			LEFT JOIN step_1_upgraded_to_sales_price_custom_fx 	AS sp 	ON sp.id = mp.id
		
		WHERE 1 = 1
			AND mp.upgraded_from_id IS NOT NULL
			AND mp.terminated_on IS NULL

		GROUP BY mp.id
	)
	-- SELECT * FROM step_2_upgraded_to_upsell_value_calculation;

	-- #3 CREATE RECOGNIZED REVENUE VALUE - FOR UPGRADED FROM MP ID
	, step_3_upgraded_from_rec_revenue_calculation AS (

		SELECT
			ROW_NUMBER() OVER (ORDER BY frm.id) AS row_num,
			"step_3_upgraded_from_rec_revenue_calculation" AS query_label,

			frm.id AS frm_mp_id,
			too.id AS too_mp_id,

			-- MEMBERSHIP FROM CHARGE DETAILS: order info(from FROM chain)
			op_frm.cart_label AS frm_cart_label,
			op_frm.amount_per AS frm_amount_per,
			op_frm.discount AS frm_discount,
			op_frm.amount_refunded AS frm_amount_refunded,
			rama_frm.price_paid AS frm_rama_price_paid,

			upsell_value_custom_fx,
			ROUND((COALESCE(MIN(op_frm.amount_per), 0) + COALESCE(MIN(rama_frm.price_paid), 0)) - upsell_value_custom_fx, 2) AS recognized_value_custom_fx,
			CASE
				WHEN ROUND((COALESCE(MIN(op_frm.amount_per), 0) + COALESCE(MIN(rama_frm.price_paid), 0)) - upsell_value_custom_fx, 2) < 0 THEN 1
				ELSE 0
			END AS is_negative_recognized_value,

			COUNT(*) AS count_records, -- to count underlying records for fan out
			
			-- CREATED AT DATES
			NOW() AS created_at_mtn,
			UTC_TIMESTAMP() AS created_at_utc

		FROM membership_periods AS too

			-- who the (TO) period belongs to
			JOIN members 		AS m_to ON m_to.id = too.member_id
			JOIN profiles 		AS p_to ON p_to.id = m_to.memberable_id
			LEFT JOIN users 	AS u_to ON u_to.id = p_to.user_id

			-- 🔗 upgrade linkage: (TO) period upgraded FROM prior (FROM) period
			-- =======================================
				-- INNER JOIN from too → frm.
				-- An inner join keeps only rows where the join condition matches.
				-- So any too row with too.upgraded_from_id IS NULL or pointing to a non-existent frm.id is excluded.
				-- Net effect: you only return membership periods that have an “upgraded from” period (and that referenced period exists).
			-- =======================================
			JOIN membership_periods 	AS frm 		ON too.upgraded_from_id = frm.id
			JOIN members 				AS m_frm 	ON m_frm.id 			= frm.member_id
			JOIN profiles 				AS p_frm 	ON p_frm.id 			= m_frm.memberable_id
			    
			-- === FROM chain ===
			LEFT JOIN membership_applications 	AS ma_frm 	ON ma_frm.membership_period_id = frm.id
			LEFT JOIN order_products 			AS op_frm 	ON op_frm.purchasable_id = ma_frm.id
			LEFT JOIN orders 					AS o_frm 	ON o_frm.id = op_frm.order_id

			LEFT JOIN registration_audit 							AS ra_frm 	ON frm.id = ra_frm.membership_period_id
			LEFT JOIN registration_audit_membership_application 	AS rama_frm ON ra_frm.id = rama_frm.audit_id

			LEFT JOIN step_2_upgraded_to_upsell_value_calculation AS up ON too.id = up.id
		
		WHERE 1 = 1
			AND too.upgraded_from_id IS NOT NULL
			AND too.terminated_on IS NULL

		GROUP BY too.id

	)
	
	-- SELECT * FROM step_3_upgraded_from_rec_revenue_calculation;

	, step4_upgraded_from_field_match_records AS (

		SELECT
			ROW_NUMBER() OVER (ORDER BY p_to.id, too.starts, too.id) AS row_num,
			"upgraded_from_field_match_records" AS query_label,

			-- IDS
			p_frm.id AS p_frm_id,
			p_to.id AS p_to_id,	
			frm.id AS frm_mp_id,
			too.id AS too_mp_id,

			-- PERIODS
			DATE_FORMAT(CURDATE(), '%Y-%m') AS current_month_year,
			CASE
				WHEN frm.starts IS NULL THEN NULL
				ELSE (
					frm.starts < DATE_ADD(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
					AND COALESCE(frm.ends, '9999-12-31') >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
				)
			END AS frm_overlaps_current_month_year,

			CASE
				WHEN too.starts IS NULL THEN NULL
				ELSE (
					too.starts < DATE_ADD(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
					AND COALESCE(too.ends, '9999-12-31') >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
				)
			END AS too_overlaps_current_month_year,

			-- MEMBERSHIP UPGRADED FROM DETAILS
			frm.starts AS frm_starts,
			frm.ends AS frm_ends,

			-- MEMBERSHIP SPAN - FRM MP ID
			TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) AS frm_months_span, -- 12 month calc
			-- TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) + 1 AS frm_months_span, -- 13 month calc

			CASE 
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) = 11 THEN "1) 11_months_no_change"
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) = 12 THEN "1a) 12_months_no_change"
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) = 36 THEN "1b) 36_months_no_change"
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) = 37 THEN "1c) 37_months_no_change"
				ELSE "2) possible_upsell"
			END AS frm_upsell_rev_rule,
			CASE 
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) = 12 THEN 0
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) = 13 THEN 0
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) = 36 THEN 0
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(frm.starts, '%Y-%m-01'), DATE_FORMAT(frm.ends,   '%Y-%m-01')) = 37 THEN 0
				ELSE 1
			END AS frm_is_legit_upsell,

			-- MEMBERSHIP UPGRADED TO DETAILS
			too.starts AS too_starts,
			too.ends AS too_ends,

			-- MEMBERSHIP SPAN - FRM MP ID
			TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) AS too_months_span, -- 12 MONTH CALC
			-- TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) + 1 AS too_months_span, -- 13 MONTH CALC

			CASE 
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) = 11 THEN "1) 11_months_no_change"
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) = 12 THEN "1a) 12_months_no_change"
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) = 36 THEN "1b) 36_months_no_change"
				WHEN TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')) = 37 THEN "1c) 37_months_no_change"
				ELSE "2) possible_upsell"
			END AS too_upsell_rev_rule,

			-- MEMBERSHIP FROM CHARGE DETAILS: order info(from FROM chain)
			op_frm.cart_label AS frm_cart_label,
			op_frm.amount_per AS frm_amount_per,
			op_frm.discount AS frm_discount,
			op_frm.amount_refunded AS frm_amount_refunded,
			rama_frm.price_paid AS frm_rama_price_paid,

			-- RECOGNIZED VALUE CALCS - TO MEMBERSHIP ID
			up.recognized_value_custom_fx AS frm_recognized_value_custom_fx,
			up.is_negative_recognized_value AS frm_is_negative_recognized_value,

			-- MEMEMBERSHIP TO CHARGE DETAILS: order info (from TO chain)
			op_to.cart_label AS too_cart_label,
			op_to.amount_per AS too_amount_per,
			op_to.discount AS too_discount,
			op_to.amount_refunded AS too_amount_refunded,
			rama_to.price_paid AS too_rama_price_paid,

			-- RECOGNIZED VALUE CALCS - TO MEMBERSHIP ID
			sp.sales_price_custom_fx AS too_sales_price_custom_fx,
			sp.recognized_value_custom_fx AS too_recognized_value_custom_fx,
			ROUND(sp.recognized_value_custom_fx / TIMESTAMPDIFF(MONTH, DATE_FORMAT(too.starts, '%Y-%m-01'), DATE_FORMAT(too.ends,   '%Y-%m-01')), 2) too_recognized_value_per_month_custom_fx,
			sp.upsell_value_custom_fx AS to_upsell_value_custom_fx,
			sp.recognized_value_rule_custom_fx AS too_recognized_value_rule_custom_fx,

			-- OTHER DETAILS
			ma_frm.id AS frm_id_ma,
			ma_to.id AS to_id_ma,

			mt_frm.name AS frm_name_mt,  -- MEMBERSHIP TYPES
			mt_to.name AS to_name_mt,	-- MEMBERSHIP TYPES

			frm.purchased_on AS frm_purchased_on_mp, -- frm mp created at
			too.purchased_on AS to_purchased_on_mp,	-- too mp created at
			
			frm.created_at AS frm_created_at_mp, -- frm mp created at
			too.created_at AS to_created_at_mp,	-- too mp created at

			p_frm.deleted_at AS frm_deleted_at_profile,
			p_to.deleted_at AS too_deleted_at_profile,

			-- COUNTS
			COUNT(DISTINCT frm.id) AS count_mp_frm_id,
			COUNT(*) AS count_records,
			COUNT(*) OVER () AS count_total_rows,

			-- CREATED AT DATES
			NOW() AS created_at_mtn,
			UTC_TIMESTAMP() AS created_at_utc

		FROM membership_periods AS too

			-- who the (TO) period belongs to
			JOIN members 		AS m_to ON m_to.id = too.member_id
			JOIN profiles 		AS p_to ON p_to.id = m_to.memberable_id
			LEFT JOIN users 	AS u_to ON u_to.id = p_to.user_id

			-- 🔗 upgrade linkage: (TO) period upgraded FROM prior (FROM) period
			-- =======================================
				-- INNER JOIN from too → frm.
				-- An inner join keeps only rows where the join condition matches.
				-- So any too row with too.upgraded_from_id IS NULL or pointing to a non-existent frm.id is excluded.
				-- Net effect: you only return membership periods that have an “upgraded from” period (and that referenced period exists).
			-- =======================================
			JOIN membership_periods 	AS frm 		ON too.upgraded_from_id = frm.id
			JOIN members 				AS m_frm 	ON m_frm.id 			= frm.member_id
			JOIN profiles 				AS p_frm 	ON p_frm.id 			= m_frm.memberable_id

			-- === FROM chain ===
			LEFT JOIN membership_applications 	AS ma_frm 	ON ma_frm.membership_period_id = frm.id
			LEFT JOIN order_products 			AS op_frm 	ON op_frm.purchasable_id = ma_frm.id
			LEFT JOIN orders 					AS o_frm 	ON o_frm.id = op_frm.order_id
			LEFT JOIN transactions 				AS t_frm 	ON t_frm.order_id = o_frm.id

			LEFT JOIN registration_audit 							AS ra_frm 	ON frm.id = ra_frm.membership_period_id
			LEFT JOIN registration_audit_membership_application 	AS rama_frm ON ra_frm.id = rama_frm.audit_id
			
			LEFT JOIN membership_types 		AS mt_frm ON mt_frm.id = ma_frm.membership_type_id
			
			-- === TO chain ===
			LEFT JOIN membership_applications 		AS ma_to 	ON ma_to.membership_period_id = too.id
			LEFT JOIN order_products 				AS op_to 	ON op_to.purchasable_id = ma_to.id
			LEFT JOIN orders 						AS o_to 	ON o_to.id = op_to.order_id
			LEFT JOIN transactions 					AS t_to 	ON t_to.order_id = o_to.id

			LEFT JOIN registration_audit 							AS ra_to 	ON too.id = ra_to.membership_period_id
			LEFT JOIN registration_audit_membership_application 	AS rama_to 	ON ra_to.id = rama_to.audit_id
			
			LEFT JOIN membership_types 				AS mt_to 	ON mt_to.id = ma_to.membership_type_id

			-- CTE JOINS
			LEFT JOIN step_2_upgraded_to_upsell_value_calculation AS sp ON sp.id = too.id
			LEFT JOIN step_3_upgraded_from_rec_revenue_calculation AS up ON too_mp_id = too.id
			
		WHERE 1 = 1
			AND too.upgraded_from_id IS NOT NULL
			AND too.terminated_on IS NULL

		GROUP BY p_to.id, too.starts, too.id -- used to prevent join fan out
		HAVING 1 = 1
			-- AND (frm_upsell_rev_rule IS NULL OR too_upsell_rev_rule IS NULL)
			-- AND (frm_overlaps_current_month_year = 1 OR too_overlaps_current_month_year = 1)

		ORDER BY p_to.id, too.starts, too.id
	)

	SELECT * FROM step4_upgraded_from_field_match_records
;