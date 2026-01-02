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
    
    -- 2025 Estimate
    "2025" AS year_label_2025,
    FORMAT(SUM(sales_rev_2025_estimate), 0),
    FORMAT(SUM(sales_rev_2025_estimate_nonbulk), 0),
    FORMAT(SUM(sales_rev_2025_estimate_bulk), 0)
    
FROM sales_model_2026
GROUP BY 1, 2
ORDER BY 1, 2
;

-- ========= STEP 1 ========
-- GET REVENUE ESTIMATE
-- ========= STEP 1 ========
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