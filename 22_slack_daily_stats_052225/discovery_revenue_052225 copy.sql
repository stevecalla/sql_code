use usat_sales_db;

-- GET REVENUE / GOAL / ACTUAL DATA
-- SELECT "revenue_data" AS "table", r.* FROM sales_data_actual_v_goal AS r LIMIT 10;
-- SELECT "revenue_data" AS "table", FORMAT(COUNT(*), 0) FROM sales_data_actual_v_goal AS r LIMIT 10;
SELECT "revenue_data" AS "table", type_actual FROM sales_data_actual_v_goal AS r GROUP BY 2 LIMIT 10;
SELECT "revenue_data" AS "table", category_actual FROM sales_data_actual_v_goal AS r GROUP BY 2 ORDER BY 2 LIMIT 50;

-- First, the monthly data
WITH monthly_agg AS (
    SELECT 
        month_actual,
        is_year_to_date,
        is_current_month,
        0 AS is_ytd_row,
        created_at_mtn,

        -- 2025 GOAL
        SUM(sales_rev_2025_goal) AS sales_rev_2025_goal,
        SUM(sales_units_2025_goal) AS sales_units_2025_goal,
        NULLIF(SUM(sales_rev_2025_goal), 0) / NULLIF(SUM(sales_units_2025_goal), 0) AS sales_rpu_2025_goal,

        -- 2024 GOAL
        SUM(sales_rev_2024_goal) AS sales_rev_2024_goal,
        SUM(sales_units_2024_goal) AS sales_units_2024_goal,
        NULLIF(SUM(sales_rev_2024_goal), 0) / NULLIF(SUM(sales_units_2024_goal), 0) AS sales_rpu_2024_goal,

        -- 2025 ACTUAL
        SUM(sales_rev_2025_actual) AS sales_rev_2025_actual,
        SUM(sales_units_2025_actual) AS sales_units_2025_actual,
        NULLIF(SUM(sales_rev_2025_actual), 0) / NULLIF(SUM(sales_units_2025_actual), 0) AS sales_rpu_2025_actual,

        -- 2024 ACTUAL
        SUM(sales_rev_2024_actual) AS sales_rev_2024_actual,
        SUM(sales_units_2024_actual) AS sales_units_2024_actual,
        NULLIF(SUM(sales_rev_2024_actual), 0) / NULLIF(SUM(sales_units_2024_actual), 0) AS sales_rpu_2024_actual
    FROM sales_data_actual_v_goal
    WHERE 1 = 1
        AND is_year_to_date
        AND type_actual = "aa"
        -- AND category_actual = "3-Year"
    GROUP BY month_actual, is_year_to_date, is_current_month, created_at_mtn
),

-- Then, the YTD totals row
ytd_agg AS (
	-- query was providing an aggregate with null values when the filters produced no results
	-- the subquery below to eliminate this issue by using the additional where statement
    SELECT * FROM (
        SELECT 
            NULL AS month_actual,
            0 AS is_year_to_date,
            0 AS is_current_month,
            1 AS is_ytd_row,
            null AS created_at_mtn,

            -- 2025 GOAL
            SUM(sales_rev_2025_goal) AS sales_rev_2025_goal,
            SUM(sales_units_2025_goal) AS sales_units_2025_goal,
            NULLIF(SUM(sales_rev_2025_goal), 0) / NULLIF(SUM(sales_units_2025_goal), 0) AS sales_rpu_2025_goal,

            -- 2024 GOAL
            SUM(sales_rev_2024_goal) AS sales_rev_2024_goal,
            SUM(sales_units_2024_goal) AS sales_units_2024_goal,
            NULLIF(SUM(sales_rev_2024_goal), 0) / NULLIF(SUM(sales_units_2024_goal), 0) AS sales_rpu_2024_goal,

            -- 2025 ACTUAL
            SUM(sales_rev_2025_actual) AS sales_rev_2025_actual,
            SUM(sales_units_2025_actual) AS sales_units_2025_actual,
            NULLIF(SUM(sales_rev_2025_actual), 0) / NULLIF(SUM(sales_units_2025_actual), 0) AS sales_rpu_2025_actual,

            -- 2024 ACTUAL
            SUM(sales_rev_2024_actual) AS sales_rev_2024_actual,
            SUM(sales_units_2024_actual) AS sales_units_2024_actual,
            NULLIF(SUM(sales_rev_2024_actual), 0) / NULLIF(SUM(sales_units_2024_actual), 0) AS sales_rpu_2024_actual
        FROM sales_data_actual_v_goal
        WHERE is_current_month = 0 AND is_year_to_date = 1
        AND type_actual = "aa"
    ) AS sub
    -- Include the row if at least one of these fields is not null. In other words: Exclude the row if every single one of those fields is null.
	WHERE 1 = 1 AND (
        sales_rev_2025_goal IS NOT NULL OR
        sales_units_2025_goal IS NOT NULL OR
        sales_rev_2024_goal IS NOT NULL OR
        sales_units_2024_goal IS NOT NULL OR
        sales_rev_2025_actual IS NOT NULL OR
        sales_units_2025_actual IS NOT NULL OR
        sales_rev_2024_actual IS NOT NULL OR
        sales_units_2024_actual IS NOT NULL
    )
)
-- Final unified query with diffs
SELECT 
	*,
    
    -- ABS DIFFS: GOAL VS 2024 GOAL
    sales_rev_2025_goal - sales_rev_2024_goal AS abs_diff_rev_goal_vs_2024_goal,
    sales_units_2025_goal - sales_units_2024_goal AS abs_diff_units_goal_vs_2024_goal,
    sales_rpu_2025_goal - sales_rpu_2024_goal AS abs_diff_rpu_goal_vs_2024_goal,

    -- % DIFFS: GOAL VS 2024 GOAL
    (sales_rev_2025_goal - sales_rev_2024_goal) / NULLIF(sales_rev_2024_goal, 0) * 100 AS pct_diff_rev_goal_vs_2024_goal,
    (sales_units_2025_goal - sales_units_2024_goal) / NULLIF(sales_units_2024_goal, 0) * 100 AS pct_diff_units_goal_vs_2024_goal,
    (sales_rpu_2025_goal - sales_rpu_2024_goal) / NULLIF(sales_rpu_2024_goal, 0) * 100 AS pct_diff_rpu_goal_vs_2024_goal,
    
    -- ABS DIFFS: GOAL VS 2025
    sales_rev_2025_actual - sales_rev_2025_goal AS abs_diff_rev_goal_vs_2025_actual,
    sales_units_2025_actual - sales_units_2025_goal AS abs_diff_units_goal_vs_2025_actual,
    sales_rpu_2025_actual - sales_rpu_2025_goal AS abs_diff_rpu_goal_vs_2025_actual,

    -- % DIFFS: GOAL VS 2025
    (sales_rev_2025_actual - sales_rev_2025_goal) / NULLIF(sales_rev_2025_goal, 0) * 100 AS pct_diff_rev_goal_vs_2025_actual,
    (sales_units_2025_actual - sales_units_2025_goal) / NULLIF(sales_units_2025_goal, 0) * 100 AS pct_diff_units_goal_vs_2025_actual,
    (sales_rpu_2025_actual - sales_rpu_2025_goal) / NULLIF(sales_rpu_2025_goal, 0) * 100 AS pct_diff_rpu_goal_vs_2025_actual,

    -- ABS DIFFS: 2025 VS 2024
    sales_rev_2025_actual - sales_rev_2024_actual AS abs_diff_rev_2025_vs_2024_actual,
    sales_units_2025_actual - sales_units_2024_actual AS abs_diff_units_2025_vs_2024_actual,
    sales_rpu_2025_actual - sales_rpu_2024_actual AS abs_diff_rpu_2025_vs_2024_actual,

    -- % DIFFS: 2025 VS 2024
    (sales_rev_2025_actual - sales_rev_2024_actual) / NULLIF(sales_rev_2024_actual, 0) * 100 AS pct_diff_rev_2025_vs_2024_actual,
    (sales_units_2025_actual - sales_units_2024_actual) / NULLIF(sales_units_2024_actual, 0) * 100 AS pct_diff_units_2025_vs_2024_actual,
    (sales_rpu_2025_actual - sales_rpu_2024_actual) / NULLIF(sales_rpu_2024_actual, 0) * 100 AS pct_diff_rpu_2025_vs_2024_actual

FROM (
    SELECT * FROM monthly_agg
    UNION ALL
    SELECT * FROM ytd_agg
) AS combined_data
ORDER BY 
    is_ytd_row ASC,
    month_actual
;
