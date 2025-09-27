-- [x] create 2026 figures
-- [x] create / breakout origin flat = bulk upload 'ADMIN_BULK_UPLOADER'
-- [] create 2025 estimate = 2025 forward = goal / 2025 past = actual
-- [] create 2026 RPU increases...

USE usat_sales_db;
SELECT * FROM sales_data_year_over_year LIMIT 10;
SELECT DISTINCT new_member_category_6_sa FROM sales_data_year_over_year LIMIT 100;
-- SELECT * FROM sales_model_2026 WHERE type_actual_bulk = "bulk_upload";

SELECT
	quarter_actual,
	month_actual,
    FORMAT(SUM(sales_rev_2025_goal), 0),
    FORMAT(SUM(sales_rev_2025_actual), 0), -- march '25 = 651,073.65 b/f unknown change; 651,079.65
    FORMAT(SUM(goal_v_actual_rev_diff_abs), 0),

    -- 2025 Estimate
    "2025" AS year_label_2025
    -- FORMAT(SUM(sales_rev_2025_estimate), 0)
    
FROM sales_data_actual_v_goal
GROUP BY 1, 2
ORDER BY 1, 2
;

-- SALES MODEL
SELECT * FROM sales_model_2026 LIMIT 10;
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