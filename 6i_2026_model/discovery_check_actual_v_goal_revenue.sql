-- [x] create 2026 figures
-- [x] create / breakout origin flat = bulk upload 'ADMIN_BULK_UPLOADER'
-- [x] create 2025 estimate = 2025 forward = goal / 2025 past = actual
-- [] create 2026 RPU increases...

USE usat_sales_db;

SELECT * FROM usat_sales_db.sales_data_year_over_year LIMIT 10;

SELECT * FROM sales_model_2026 LIMIT 10;
-- SELECT * FROM sales_model_2026 WHERE type_actual_bulk = "bulk_upload";

SELECT
	quarter_actual,
	month_actual,
    FORMAT(SUM(sales_rev_2025_goal), 0),
    FORMAT(SUM(sales_rev_2025_actual), 0), -- march '25 = 651,073.65 b/f unknown change; 651,079.65
    FORMAT(SUM(goal_v_actual_rev_diff_abs), 0),
    
    -- -- 2026 GOAL
    "2026" AS year_label_2026,
    FORMAT(SUM(sales_rev_2026_goal), 0)
    -- -- only sum 2026 goal where type is bulk_upload
	-- FORMAT(SUM(CASE WHEN type_goal_bulk = 'bulk_upload' THEN sales_rev_2026_goal ELSE 0 END), 0) AS bulk_rev,
	-- FORMAT(SUM(CASE WHEN type_goal_bulk = 'bulk_upload' THEN sales_units_2026_goal ELSE 0 END), 0)  AS bulk_units,
    
    -- -- 2025 Estimate
    "2025" AS year_label_2025,
    FORMAT(SUM(sales_rev_2025_estimate), 0)
    
-- FROM sales_data_actual_v_goal
FROM sales_model_2026
GROUP BY 1, 2
ORDER BY 1, 2
;