    USE usat_sales_db;

SELECT * FROM sales_data_actual_v_goal;

SELECT
	quarter_actual,
	month_actual,
    SUM(sales_rev_2025_goal),
    SUM(sales_rev_2025_actual), -- march '25 = 651,073.65 b/f unknown change; 651,079.65
    SUM(goal_v_actual_rev_diff_abs)
    
FROM sales_data_actual_v_goal
GROUP BY 1, 2
ORDER BY 1, 2
;