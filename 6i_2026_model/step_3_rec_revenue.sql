-- ========= STEP 3 ========
-- JOIN REVENUE ESTIMATE WITH ALLOCATION ESTIMATE
-- CALC REV ALLOCATION
-- ========= STEP 3 ========
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
    -- SELECT * FROM rec_rev_base;
    SELECT 
        projected_ym,
        projected_year,
        projected_month,
        type_goal,
        FORMAT(SUM(rec_revenue), 2) AS rec_revenue,
        now() AS created_at_mtn
    FROM rec_rev_base
    GROUP BY 1, 2, 3, 4
    ORDER BY 1, 2, 3, 4
;