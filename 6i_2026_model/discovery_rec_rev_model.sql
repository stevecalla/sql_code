-- ========= STEP 1 ========
-- GET REVENUE ESTIMATE
-- ========= STEP 1 ========
SELECT
	month_goal,
    -- FORMAT(SUM(sales_rev_2025_goal), 0),
    -- FORMAT(SUM(sales_rev_2025_actual), 0), -- march '25 = 651,073.65 b/f unknown change; 651,079.65
    -- FORMAT(SUM(goal_v_actual_rev_diff_abs), 0),
    
    -- 2026 GOAL
    "2026" AS year_label_2026,
    FORMAT(SUM(sales_rev_2026_goal), 0),
    FORMAT(SUM(sales_rev_2026_goal_nonbulk), 0),
    FORMAT(SUM(sales_rev_2026_goal_bulk), 0),
    
    -- -- 2025 Estimate
    "2025" AS year_label_2025,
    FORMAT(SUM(sales_rev_2025_estimate), 0),
    FORMAT(SUM(sales_rev_2025_estimate_nonbulk), 0),
    FORMAT(SUM(sales_rev_2025_estimate_bulk), 0)
    
FROM sales_model_2026
GROUP BY 1, 2
ORDER BY 1, 2
;

DROP TABLE IF EXISTS sales_model_rec_rev_1_sales_estimate;
CREATE TABLE IF NOT EXISTS sales_model_rec_rev_1_sales_estimate
    WITH RECURSIVE
        sales_estimate_2025 AS (
            SELECT 
                month_goal,
                type_goal,
                "2025" AS year,
                SUM(sales_rev_2025_estimate) AS sales_estimate
            FROM sales_model_2026
            WHERE month_goal > 8                 -- 2025-09..12
            GROUP BY 1, 2
        ),
        sales_estimate_2026 AS (
            SELECT 
                month_goal,
                type_goal,
                "2026" AS year,
                SUM(sales_rev_2026_goal_nonbulk) AS sales_estimate
            FROM sales_model_2026
            GROUP BY 1, 2
        ),
        combined_sales_estimate AS (
            SELECT * FROM sales_estimate_2025
            UNION ALL
            SELECT * FROM sales_estimate_2026
        ),
        -- Generate 0..15 (Sep-2025 -> Dec-2026 is 16 months total)
        months AS (
            SELECT 0 AS months_out
            UNION ALL
            SELECT months_out + 1 FROM months WHERE months_out < 15
        )
        SELECT
            c.year,
            c.month_goal,
            c.type_goal,
            m.months_out,
            -- the projected year-month after applying months_out
            DATE_FORMAT(
                DATE_ADD(
                STR_TO_DATE(CONCAT(c.year,'-', LPAD(c.month_goal,2,'0'), '-01'), '%Y-%m-%d'),
                INTERVAL m.months_out MONTH
                ),
                '%Y-%m'
            ) AS projected_ym,
            YEAR(
                DATE_ADD(
                    STR_TO_DATE(CONCAT(c.year,'-', LPAD(c.month_goal,2,'0'), '-01'), '%Y-%m-%d'),
                    INTERVAL m.months_out MONTH
                )
            ) AS projected_year,
            MONTH(
            DATE_ADD(STR_TO_DATE(CONCAT(c.year,'-', LPAD(c.month_goal,2,'0'), '-01'), '%Y-%m-%d'),
                    INTERVAL m.months_out MONTH)
            ) AS projected_month,
            c.sales_estimate
        FROM combined_sales_estimate c
            JOIN months m
        WHERE DATE_ADD(
                STR_TO_DATE(CONCAT(c.year,'-', LPAD(c.month_goal,2,'0'), '-01'), '%Y-%m-%d'),
                INTERVAL m.months_out MONTH
            ) <= '2026-12-01'               -- cap at 2026-12
        ORDER BY c.year, c.month_goal, c.type_goal, m.months_out
;

SELECT * FROM sales_model_rec_rev_1_sales_estimate LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM sales_model_rec_rev_1_sales_estimate;

-- ========= STEP 2 ========
-- GET ALLOCATION ESTIMATE
-- ========= STEP 2 ========
-- SELECT MAX(purchased_on_mp) FROM all_membership_sales_data_2015_left LIMIT 10;
-- -- REC REV BASE DATA
-- SELECT * FROM rev_recognition_base_data LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_base_data LIMIT 10; -- '1,462,855'
-- REC REV ALLOCATED DATA
-- SELECT * FROM rev_recognition_allocation_data LIMIT 10;
-- SELECT * FROM rev_recognition_allocation_data LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data LIMIT 10; -- '4,832,391'
-- SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data  LIMIT 10; -- '4,832,391'
-- -- SALES MODEL
-- SELECT * FROM sales_model_2026 LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM sales_model_2026 LIMIT 10;

DROP TABLE IF EXISTS sales_model_rec_rev_2_allocation_estimate;
CREATE TABLE IF NOT EXISTS sales_model_rec_rev_2_allocation_estimate
    WITH base AS (
        -- determines the % of revenue for each purchase month that is recognized in future months by real membership type
        SELECT
            purchased_on_adjusted_year_month,
            purchased_on_date_adjusted_mp_year,
            purchased_on_date_adjusted_mp_month,
            real_membership_types_sa,
            revenue_year_month,
            revenue_year_date,
            revenue_month_date,
            TIMESTAMPDIFF(
                MONTH,
                STR_TO_DATE(CONCAT(purchased_on_adjusted_year_month, '-01'), '%Y-%m-%d'),
                STR_TO_DATE(CONCAT(revenue_year_month, '-01'), '%Y-%m-%d')
            ) AS months_from_purchase,
            SUM(monthly_revenue) AS total_revenue,
            ROUND(
                SUM(monthly_revenue) /
                NULLIF(SUM(SUM(monthly_revenue)) OVER (PARTITION BY purchased_on_adjusted_year_month, real_membership_types_sa), 0)
            , 4) AS pct_of_total_num
        FROM rev_recognition_allocation_data AS a
        WHERE 1 = 1
            AND purchased_on_date_adjusted_mp_year >= 2024
            -- AND purchased_on_date_adjusted_mp_month = 1
        GROUP BY
            purchased_on_adjusted_year_month,
            purchased_on_date_adjusted_mp_year,
            purchased_on_date_adjusted_mp_month,
            real_membership_types_sa,
            revenue_year_month,
            revenue_year_date,
            revenue_month_date
        )
        , limit_v1 AS (
            SELECT
                b.*,
            FROM base AS b
            WHERE 1 = 1
            AND
                (
                    (
                        purchased_on_date_adjusted_mp_year > 2024
                        OR (purchased_on_date_adjusted_mp_year = 2024 AND purchased_on_date_adjusted_mp_month >= 9)
                    )
                    AND
                    (
                        purchased_on_date_adjusted_mp_year < 2025
                        OR (purchased_on_date_adjusted_mp_year = 2025 AND purchased_on_date_adjusted_mp_month <= 8)
                    )
                )
        )
        , limit_v2 AS (
            SELECT
                l.*,
                now() AS created_at_mtn
            FROM limit_v1 AS l
            WHERE 1 = 1
                AND 
                (
                    revenue_year_date < 2025
                    OR (revenue_year_date = 2025 AND revenue_month_date <= 12)
                )
        ORDER BY
            purchased_on_adjusted_year_month,
            real_membership_types_sa,
            revenue_year_month,
            revenue_year_date,
            revenue_month_date
        )
        SELECT * FROM limit_v2
;

SELECT * FROM sales_model_rec_rev_2_allocation_estimate LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM sales_model_rec_rev_2_allocation_estimate;

-- ========= STEP 3 ========
-- JOIN REVENUE ESTIMATE WITH ALLOCAITON ESTIMATE
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
        FORMAT(SUM(rec_revenue), 2),
        now() AS created_at_mtn
    FROM rec_rev_base
    GROUP BY 1, 2, 3, 4
    ORDER BY 1, 2, 3, 4
;

-- ========= STEP 4 ========
-- GET CURRENT RECOGNIZED REVENUE
-- ========= STEP 4 ========
WITH current_recognized_revenue AS (
	SELECT
		revenue_year_month,
		revenue_year_date,
		revenue_month_date,
        real_membership_types_sa,
		FORMAT(SUM(monthly_revenue), 0) AS total_revenue,
        now() AS created_at_mt
	FROM rev_recognition_allocation_data AS a
	WHERE 1 = 1
		AND STR_TO_DATE(
          CONCAT(purchased_on_date_adjusted_mp_year, '-', LPAD(purchased_on_date_adjusted_mp_month, 2, '0'), '-01'),
          '%Y-%m-%d'
        ) < '2025-09-01'
		AND revenue_year_date >= 2025
        AND revenue_year_date < 2027
	GROUP BY 1, 2, 3, 4
	ORDER BY 1, 2, 3, 4
	-- LIMIT 10
	)
	SELECT * FROM current_recognized_revenue
;

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
        a.*,
        c.*,
        rec_revenue + current_revenue AS total_revenue,
        now() AS created_at_mtn
    FROM allocation_estimate AS a
        LEFT JOIN current_rec_revenue AS c ON a.projected_year = c.revenue_year_date
            AND a.projected_month = c.revenue_month_date
            AND a.type_goal = c.real_membership_types_sa
    ORDER BY 1, 2
;
