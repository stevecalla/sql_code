-- ========= STEP 5 ========
-- JOIN STEP 3 ALLOCATION ESTIMATE & STEP 4 CURRENT RECOGNIZED REVENUE
-- PURPOSE (Step 5):
-- Combine (A) forecast recognized revenue from modeled sales (allocation_estimate)
-- with (B) currently-known recognized revenue from actual purchases (current_rec_revenue),
-- producing total recognized revenue by recognized month (projected_year/month) and membership type.
--
-- NOTES:
-- 1) Use COALESCE on current_revenue (and/or rec_revenue) to avoid NULL totals when no match exists.
-- 2) Ensure modeled sales period does not overlap “current purchases” period to avoid double-counting.
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
            -- TODO: ALIGN WITH MEMBERSHIP SALES REVENUE PERIOD IN C:\Users\calla\development\usat\sql_code\6i_2026_model\step_0_discovery_actual_vs_goal_model_v1_with_post_race.sql
            AND STR_TO_DATE(
                CONCAT(purchased_on_date_adjusted_mp_year, '-', LPAD(purchased_on_date_adjusted_mp_month, 2, '0'), '-01'),
                '%Y-%m-%d'
            ) < '2025-09-01'
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
