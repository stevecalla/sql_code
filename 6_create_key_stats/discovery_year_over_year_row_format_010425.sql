SET @current_year_date = CURDATE();
SET @prior_year_date = @current_year_date - INTERVAL 1 YEAR;

WITH current_year_data AS (
    SELECT 
        purchased_on_date_adjusted_mp,
        SUM(sales_revenue) AS total_sales_revenue,
        SUM(sales_units) AS total_sales_units,
        SUM(sales_revenue) / NULLIF(SUM(sales_units), 0) AS revenue_per_unit
    FROM usat_sales_db.sales_key_stats_2015
    WHERE 
        purchased_on_date_adjusted_mp >= DATE_FORMAT(@current_year_date, '%Y-%m-01') 
        AND purchased_on_date_adjusted_mp <= @current_year_date - INTERVAL 1 DAY
    GROUP BY purchased_on_date_adjusted_mp
),
prior_year_data AS (
    SELECT 
        purchased_on_date_adjusted_mp AS prior_year_date,
        SUM(sales_revenue) AS total_sales_revenue_prior,
        SUM(sales_units) AS total_sales_units_prior,
        SUM(sales_revenue) / NULLIF(SUM(sales_units), 0) AS revenue_per_unit_prior
    FROM usat_sales_db.sales_key_stats_2015
    WHERE 
        purchased_on_date_adjusted_mp >= DATE_FORMAT(@prior_year_date, '%Y-%m-01') 
        AND purchased_on_date_adjusted_mp <= @prior_year_date - INTERVAL 1 DAY
    GROUP BY purchased_on_date_adjusted_mp
),
comparison_data AS (
    SELECT 
        current_year_data.purchased_on_date_adjusted_mp AS current_year_date,
        prior_year_data.prior_year_date,
        current_year_data.total_sales_revenue AS current_revenue,
        prior_year_data.total_sales_revenue_prior AS prior_revenue,
        current_year_data.total_sales_units AS current_units,
        prior_year_data.total_sales_units_prior AS prior_units,
        current_year_data.revenue_per_unit AS current_revenue_per_unit,
        prior_year_data.revenue_per_unit_prior AS prior_revenue_per_unit
    FROM 
        current_year_data
    LEFT JOIN 
        prior_year_data
    ON current_year_data.purchased_on_date_adjusted_mp = DATE_ADD(prior_year_data.prior_year_date, INTERVAL 1 YEAR)
)
SELECT  
    metric_name,
    metric_sort_priority,
    CONCAT(
        CASE 
            WHEN DAYNAME(current_year_date) = 'Sunday' THEN 'SU'
            WHEN DAYNAME(current_year_date) = 'Monday' THEN 'M'
            WHEN DAYNAME(current_year_date) = 'Tuesday' THEN 'TU'
            WHEN DAYNAME(current_year_date) = 'Wednesday' THEN 'W'
            WHEN DAYNAME(current_year_date) = 'Thursday' THEN 'TH'
            WHEN DAYNAME(current_year_date) = 'Friday' THEN 'F'
            WHEN DAYNAME(current_year_date) = 'Saturday' THEN 'SA'
        END,
        DATE_FORMAT(current_year_date, '%c/%e/%y')
    ) AS current_year_date,
    CONCAT(
        CASE 
            WHEN DAYNAME(prior_year_date) = 'Sunday' THEN 'SU'
            WHEN DAYNAME(prior_year_date) = 'Monday' THEN 'M'
            WHEN DAYNAME(prior_year_date) = 'Tuesday' THEN 'TU'
            WHEN DAYNAME(prior_year_date) = 'Wednesday' THEN 'W'
            WHEN DAYNAME(prior_year_date) = 'Thursday' THEN 'TH'
            WHEN DAYNAME(prior_year_date) = 'Friday' THEN 'F'
            WHEN DAYNAME(prior_year_date) = 'Saturday' THEN 'SA'
        END,
        DATE_FORMAT(prior_year_date, '%c/%e/%y')
    ) AS prior_year_date,
    date_sort_priority,
    data_type,
    data_value,
    YEAR(current_year_date) AS current_year,
    MONTH(current_year_date) AS current_month,
    DAY(current_year_date) AS current_day,
    WEEKDAY(current_year_date) AS current_weekday,
    CASE WHEN current_year_date = "Grand Total" THEN 1 ELSE 0 END AS is_grand_total
    -- is_grand_total
FROM (
    -- Sales Revenue Rows
    SELECT 'Sales Revenue' AS metric_name, 1 AS metric_sort_priority, current_year_date, prior_year_date, DAY(current_year_date) AS date_sort_priority, 'current_value' AS data_type, current_revenue AS data_value FROM comparison_data
    UNION ALL
    SELECT 'Sales Revenue', 1, current_year_date, prior_year_date, DAY(current_year_date), 'prior_value', prior_revenue FROM comparison_data
    UNION ALL
    SELECT 'Sales Revenue', 1, current_year_date, prior_year_date, DAY(current_year_date), 'diff_abs', current_revenue - prior_revenue AS data_value FROM comparison_data
    UNION ALL
    SELECT 'Sales Revenue', 1, current_year_date, prior_year_date, DAY(current_year_date), 'diff_pct', CASE WHEN prior_revenue = 0 THEN NULL ELSE (current_revenue - prior_revenue) / prior_revenue * 100 END AS data_value FROM comparison_data
    UNION ALL
    -- Units Rows
    SELECT 'Units' AS metric_name, 2 AS metric_sort_priority, current_year_date, prior_year_date, DAY(current_year_date), 'current_value', current_units FROM comparison_data
    UNION ALL
    SELECT 'Units', 2, current_year_date, prior_year_date, DAY(current_year_date), 'prior_value', prior_units FROM comparison_data
    UNION ALL
    SELECT 'Units', 2, current_year_date, prior_year_date, DAY(current_year_date), 'diff_abs', current_units - prior_units AS data_value FROM comparison_data
    UNION ALL
    SELECT 'Units', 2, current_year_date, prior_year_date, DAY(current_year_date), 'diff_pct', CASE WHEN prior_units = 0 THEN NULL ELSE (current_units - prior_units) / prior_units * 100 END AS data_value FROM comparison_data
    UNION ALL
    -- Revenue Per Unit Rows
    SELECT 'Revenue Per Unit' AS metric_name, 3 AS metric_sort_priority, current_year_date, prior_year_date, DAY(current_year_date), 'current_value', current_revenue_per_unit FROM comparison_data
    UNION ALL
    SELECT 'Revenue Per Unit', 3, current_year_date, prior_year_date, DAY(current_year_date), 'prior_value', prior_revenue_per_unit FROM comparison_data
    UNION ALL
    SELECT 'Revenue Per Unit', 3, current_year_date, prior_year_date, DAY(current_year_date), 'diff_abs', current_revenue_per_unit - prior_revenue_per_unit AS data_value FROM comparison_data
    UNION ALL
    SELECT 'Revenue Per Unit', 3, current_year_date, prior_year_date, DAY(current_year_date), 'diff_pct', CASE WHEN prior_revenue_per_unit = 0 THEN NULL ELSE (current_revenue_per_unit - prior_revenue_per_unit) / prior_revenue_per_unit * 100 END AS data_value FROM comparison_data
    -- Grand Totals
    UNION ALL
    SELECT 'Sales Revenue', 1, 'Grand Total', 'Grand Total', 999, 'current_value', SUM(current_revenue) FROM comparison_data
    UNION ALL
    SELECT 'Sales Revenue', 1, 'Grand Total', 'Grand Total', 999, 'prior_value', SUM(prior_revenue) FROM comparison_data
    UNION ALL
    SELECT 'Sales Revenue', 1, 'Grand Total', 'Grand Total', 999, 'diff_abs', SUM(current_revenue) - SUM(prior_revenue) FROM comparison_data
    UNION ALL
    SELECT 'Sales Revenue', 1, 'Grand Total', 'Grand Total', 999, 'diff_pct', CASE WHEN SUM(prior_revenue) = 0 THEN NULL ELSE (SUM(current_revenue) - SUM(prior_revenue)) / SUM(prior_revenue) * 100 END FROM comparison_data
    UNION ALL
    SELECT 'Units', 2, 'Grand Total', 'Grand Total', 999, 'current_value', SUM(current_units) FROM comparison_data
    UNION ALL
    SELECT 'Units', 2, 'Grand Total', 'Grand Total', 999, 'prior_value', SUM(prior_units) FROM comparison_data
    UNION ALL
    SELECT 'Units', 2, 'Grand Total', 'Grand Total', 999, 'diff_abs', SUM(current_units) - SUM(prior_units) FROM comparison_data
    UNION ALL
    SELECT 'Units', 2, 'Grand Total', 'Grand Total', 999, 'diff_pct', CASE WHEN SUM(prior_units) = 0 THEN NULL ELSE (SUM(current_units) - SUM(prior_units)) / SUM(prior_units) * 100 END FROM comparison_data
    UNION ALL
    SELECT 'Revenue Per Unit', 3, 'Grand Total', 'Grand Total', 999, 'current_value', SUM(current_revenue) / NULLIF(SUM(current_units), 0) FROM comparison_data
    UNION ALL
    SELECT 'Revenue Per Unit', 3, 'Grand Total', 'Grand Total', 999, 'prior_value', SUM(prior_revenue) / NULLIF(SUM(prior_units), 0) FROM comparison_data
    UNION ALL
    SELECT 'Revenue Per Unit', 3, 'Grand Total', 'Grand Total', 999, 'diff_abs', (SUM(current_revenue) / NULLIF(SUM(current_units), 0)) - (SUM(prior_revenue) / NULLIF(SUM(prior_units), 0)) FROM comparison_data
    UNION ALL
    SELECT 'Revenue Per Unit', 3, 'Grand Total', 'Grand Total', 999, 'diff_pct', CASE WHEN SUM(prior_revenue) / NULLIF(SUM(prior_units), 0) = 0 THEN NULL ELSE ((SUM(current_revenue) / NULLIF(SUM(current_units), 0)) - (SUM(prior_revenue) / NULLIF(SUM(prior_units), 0))) / (SUM(prior_revenue) / NULLIF(SUM(prior_units), 0)) * 100 END FROM comparison_data
) AS long_format
ORDER BY 
    metric_sort_priority,
    date_sort_priority,
    FIELD(data_type, 'current_value', 'prior_value', 'diff_abs', 'diff_pct');
