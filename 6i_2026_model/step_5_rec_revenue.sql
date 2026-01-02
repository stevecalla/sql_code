-- ========= STEP 5 ========
-- JOIN STEP 3 ALLOCATION ESTIMATE & STEP 4 CURRENT RECOGNIZED REVENUE
-- ========= STEP 5 ========
WITH rec_rev_base AS (
    SELECT
        s.*,
        a.pct_of_total_num,
        a.pct_of_total_num * s.sales_estimate AS rec_revenue
    FROM sales_model_rec_rev_1_sales_estimate AS s
        LEFT JOIN sales_model_rec_rev_2_allocation_estimate AS a
            ON s.month_goal = a.purchased_on_date_adjusted_mp_month
            AND s.type_goal = real_membership_types_sa
            AND s.months_out = months_from_purchase
    ORDER BY 1, 2, 3, 4, 5
    )
    , allocation_estimate AS (
        SELECT 
            projected_ym,
            projected_year,
            projected_month,
            type_goal,
            SUM(rec_revenue) AS rec_revenue
        FROM rec_rev_base
        GROUP BY 1, 2, 3, 4
        ORDER BY 1, 2, 3, 4
    )
    , current_rec_revenue AS (
        SELECT
            revenue_year_month,
            revenue_year_date,
            revenue_month_date,
            real_membership_types_sa,
            SUM(monthly_revenue) AS current_revenue
        FROM rev_recognition_allocation_data AS a
        WHERE 1 = 1
            AND revenue_year_date >= 2025
            AND revenue_year_date < 2027
        GROUP BY 1, 2, 3, 4
        ORDER BY 1, 2, 3, 4
    )
    SELECT
		"step_5_join_step_3_allocation_estimate_and_step_4_current_recognized_revenue" AS query_label,
        a.*,
        c.*,
        rec_revenue + current_revenue AS total_revenue,
        now() AS created_at_mtn
    FROM allocation_estimate AS a
        LEFT JOIN current_rec_revenue AS c ON a.projected_year = c.revenue_year_date
            AND a.projected_month = c.revenue_month_date
            AND a.type_goal = c.real_membership_types_sa
    ORDER BY 2, 3
;
