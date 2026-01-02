-- ========= STEP 4 ========
-- GET CURRENT RECOGNIZED REVENUE
-- ========= STEP 4 ========
WITH current_recognized_revenue AS (
	SELECT
		"step_4_get_current_rec_revenue" AS query_label,
		revenue_year_month,
		revenue_year_date,
		revenue_month_date,
        real_membership_types_sa,
		FORMAT(SUM(monthly_revenue), 0) AS total_revenue,
        now() AS created_at_mtn
	FROM rev_recognition_allocation_data AS a
	WHERE 1 = 1
		AND revenue_year_date >= 2025
        AND revenue_year_date < 2027
	GROUP BY 2, 3, 4, 5
	ORDER BY 2, 3, 4, 5
	-- LIMIT 10
	)
	SELECT * FROM current_recognized_revenue
;