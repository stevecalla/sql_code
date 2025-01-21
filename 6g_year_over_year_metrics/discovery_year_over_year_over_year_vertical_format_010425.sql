SET @current_year_date = CURDATE();
SET @prior_year_date = @current_year_date - INTERVAL 1 YEAR;
SET @two_year_prior_date = @current_year_date - INTERVAL 2 YEAR;

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
        -- AND purchased_on_date_adjusted_mp <= @current_year_date
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
        -- AND purchased_on_date_adjusted_mp <= @prior_year_date
    GROUP BY purchased_on_date_adjusted_mp
),
two_year_prior_data AS (
    SELECT 
        purchased_on_date_adjusted_mp AS two_year_prior_date,
        SUM(sales_revenue) AS total_sales_revenue_two_year_prior,
        SUM(sales_units) AS total_sales_units_two_year_prior,
        SUM(sales_revenue) / NULLIF(SUM(sales_units), 0) AS revenue_per_unit_two_year_prior
    FROM usat_sales_db.sales_key_stats_2015
    WHERE 
        purchased_on_date_adjusted_mp >= DATE_FORMAT(@two_year_prior_date, '%Y-%m-01') 
        AND purchased_on_date_adjusted_mp <= @two_year_prior_date - INTERVAL 1 DAY
    GROUP BY purchased_on_date_adjusted_mp
),
comparison_data AS (
    SELECT 
        current_year_data.purchased_on_date_adjusted_mp AS current_year_date,
        prior_year_data.prior_year_date,
        two_year_prior_data.two_year_prior_date,
        current_year_data.total_sales_revenue AS current_revenue,
        prior_year_data.total_sales_revenue_prior AS prior_revenue,
        two_year_prior_data.total_sales_revenue_two_year_prior AS two_year_prior_revenue,
        current_year_data.total_sales_units AS current_units,
        prior_year_data.total_sales_units_prior AS prior_units,
        two_year_prior_data.total_sales_units_two_year_prior AS two_year_prior_units,
        current_year_data.revenue_per_unit AS current_revenue_per_unit,
        prior_year_data.revenue_per_unit_prior AS prior_revenue_per_unit,
        two_year_prior_data.revenue_per_unit_two_year_prior AS two_year_prior_revenue_per_unit
    FROM current_year_data
    LEFT JOIN prior_year_data 
        ON current_year_data.purchased_on_date_adjusted_mp = DATE_ADD(prior_year_data.prior_year_date, INTERVAL 1 YEAR)
    LEFT JOIN two_year_prior_data 
        ON current_year_data.purchased_on_date_adjusted_mp = DATE_ADD(two_year_prior_data.two_year_prior_date, INTERVAL 2 YEAR)
)
SELECT 
    metric_name,
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
    current_year_value,
    prior_year_value, 
    two_year_prior_value,
    diff_abs,
    diff_abs_2yr,
    diff_pct,
    diff_pct_2yr,
    sort_priority_metric,
    sort_priority_date,
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
    CONCAT(
        CASE 
            WHEN DAYNAME(two_year_prior_date) = 'Sunday' THEN 'SU'
            WHEN DAYNAME(two_year_prior_date) = 'Monday' THEN 'M'
            WHEN DAYNAME(two_year_prior_date) = 'Tuesday' THEN 'TU'
            WHEN DAYNAME(two_year_prior_date) = 'Wednesday' THEN 'W'
            WHEN DAYNAME(two_year_prior_date) = 'Thursday' THEN 'TH'
            WHEN DAYNAME(two_year_prior_date) = 'Friday' THEN 'F'
            WHEN DAYNAME(two_year_prior_date) = 'Saturday' THEN 'SA'
        END,
        DATE_FORMAT(two_year_prior_date, '%c/%e/%y')
    ) AS prior_year_date,
    YEAR(current_year_date) AS current_year,
    MONTH(current_year_date) AS current_month,
    DAY(current_year_date) AS current_day,
    WEEKDAY(current_year_date) AS current_weekday,
    CASE WHEN current_year_date = "Grand Total" THEN 1 ELSE 0 END AS is_grand_total
FROM (
    -- Sales Revenue Rows
    SELECT 
        'Sales Revenue' AS metric_name,
        current_year_date,
        prior_year_date,
        two_year_prior_date,
        CONCAT('$', FORMAT(current_revenue, 0)) AS current_year_value,
        CONCAT('$', FORMAT(prior_revenue, 0)) AS prior_year_value,
        CONCAT('$', FORMAT(two_year_prior_revenue, 0)) AS two_year_prior_value,
        CONCAT('$', FORMAT(current_revenue - prior_revenue, 0)) AS diff_abs,
        CONCAT('$', FORMAT(current_revenue - two_year_prior_revenue, 0)) AS diff_abs_2yr,
        CONCAT(FORMAT(
            CASE 
                WHEN prior_revenue = 0 THEN NULL
                ELSE (current_revenue - prior_revenue) / prior_revenue * 100
            END, 0
        ), '%') AS diff_pct,
        CONCAT(FORMAT(
            CASE 
                WHEN two_year_prior_revenue = 0 THEN NULL
                ELSE (current_revenue - two_year_prior_revenue) / two_year_prior_revenue * 100
            END, 0
        ), '%') AS diff_pct_2yr,
        1 AS sort_priority_metric,
        DAY(current_year_date) AS sort_priority_date
    FROM comparison_data
    UNION ALL
    -- Units Rows
    SELECT 
        'Units' AS metric_name,
        current_year_date,
        prior_year_date,
        two_year_prior_date,
        FORMAT(current_units, 0) AS current_year_value,
        FORMAT(prior_units, 0) AS prior_year_value,
        FORMAT(two_year_prior_units, 0) AS two_year_prior_value,
        FORMAT(current_units - prior_units, 0) AS diff_abs,
        FORMAT(current_units - two_year_prior_units, 0) AS diff_abs_2yr,
        CONCAT(FORMAT(
            CASE 
                WHEN prior_units = 0 THEN NULL
                ELSE (current_units - prior_units) / prior_units * 100
            END, 0
        ), '%') AS diff_pct,
        CONCAT(FORMAT(
            CASE 
                WHEN two_year_prior_units = 0 THEN NULL
                ELSE (current_units - two_year_prior_units) / two_year_prior_units * 100
            END, 0
        ), '%') AS diff_pct_2yr,
        2 AS sort_priority_metric,
        DAY(current_year_date) AS sort_priority_date
    FROM comparison_data
    UNION ALL
    -- Revenue Per Unit Rows
    SELECT 
        'Revenue Per Unit' AS metric_name,
        current_year_date,
        prior_year_date,
        two_year_prior_date,
        CONCAT('$', FORMAT(current_revenue / NULLIF(current_units, 0), 2)) AS current_year_value,
        CONCAT('$', FORMAT(prior_revenue / NULLIF(prior_units, 0), 2)) AS prior_year_value,
        CONCAT('$', FORMAT(two_year_prior_revenue / NULLIF(two_year_prior_units, 0), 2)) AS two_year_prior_value,
        CONCAT('$', FORMAT((current_revenue / NULLIF(current_units, 0)) - (prior_revenue / NULLIF(prior_units, 0)), 2)) AS diff_abs,
        CONCAT('$', FORMAT((current_revenue / NULLIF(current_units, 0)) - (two_year_prior_revenue / NULLIF(two_year_prior_units, 0)), 2)) AS diff_abs_2yr,
        CONCAT(FORMAT(
            CASE 
                WHEN prior_revenue / NULLIF(prior_units, 0) = 0 THEN NULL
                ELSE ((current_revenue / NULLIF(current_units, 0)) - (prior_revenue / NULLIF(prior_units, 0))) / (prior_revenue / NULLIF(prior_units, 0)) * 100
            END, 0
        ), '%') AS diff_pct,
        CONCAT(FORMAT(
            CASE 
                WHEN two_year_prior_revenue / NULLIF(two_year_prior_units, 0) = 0 THEN NULL
                ELSE ((current_revenue / NULLIF(current_units, 0)) - (two_year_prior_revenue / NULLIF(two_year_prior_units, 0))) / (two_year_prior_revenue / NULLIF(two_year_prior_units, 0)) * 100
            END, 0
        ), '%') AS diff_pct_2yr,
        3 AS sort_priority_metric,
        DAY(current_year_date) AS sort_priority_date
    FROM comparison_data
    UNION ALL
    -- Grand Total Rows for Sales Revenue
    SELECT 
        'Sales Revenue' AS metric_name,
        'Grand Total' AS current_year_date,
        'Grand Total' AS prior_year_date,
        'Grand Total' AS two_year_prior_date,
        CONCAT('$', FORMAT(SUM(current_revenue), 0)) AS current_year_value,
        CONCAT('$', FORMAT(SUM(prior_revenue), 0)) AS prior_year_value,
        CONCAT('$', FORMAT(SUM(two_year_prior_revenue), 0)) AS two_year_prior_value,
        CONCAT('$', FORMAT(SUM(current_revenue) - SUM(prior_revenue), 0)) AS diff_abs,
        CONCAT('$', FORMAT(SUM(current_revenue) - SUM(two_year_prior_revenue), 0)) AS diff_abs_2yr,
        CONCAT(FORMAT(
            CASE 
                WHEN SUM(prior_revenue) = 0 THEN NULL
                ELSE (SUM(current_revenue) - SUM(prior_revenue)) / SUM(prior_revenue) * 100
            END, 0
        ), '%') AS diff_pct,
        CONCAT(FORMAT(
            CASE 
                WHEN SUM(two_year_prior_revenue) = 0 THEN NULL
                ELSE (SUM(current_revenue) - SUM(two_year_prior_revenue)) / SUM(two_year_prior_revenue) * 100
            END, 0
        ), '%') AS diff_pct_2yr,
        1 AS sort_priority_metric,
        999 AS sort_priority_date
    FROM comparison_data
    UNION ALL
    -- Grand Total Rows for Units
    SELECT 
        'Units' AS metric_name,
        'Grand Total' AS current_year_date,
        'Grand Total' AS prior_year_date,
        'Grand Total' AS two_year_prior_date,
        FORMAT(SUM(current_units), 0) AS current_year_value,
        FORMAT(SUM(prior_units), 0) AS prior_year_value,
        FORMAT(SUM(two_year_prior_units), 0) AS two_year_prior_value,
        FORMAT(SUM(current_units) - SUM(prior_units), 0) AS diff_abs,
        FORMAT(SUM(current_units) - SUM(two_year_prior_units), 0) AS diff_abs_2yr,
        CONCAT(FORMAT(
            CASE 
                WHEN SUM(prior_units) = 0 THEN NULL
                ELSE (SUM(current_units) - SUM(prior_units)) / SUM(prior_units) * 100
            END, 0
        ), '%') AS diff_pct,
        CONCAT(FORMAT(
            CASE 
                WHEN SUM(two_year_prior_units) = 0 THEN NULL
                ELSE (SUM(current_units) - SUM(two_year_prior_units)) / SUM(two_year_prior_units) * 100
            END, 0
        ), '%') AS diff_pct_2yr,
        2 AS sort_priority_metric,
        999 AS sort_priority_date
    FROM comparison_data
    UNION ALL
    -- Grand Total Rows for Revenue Per Unit
    SELECT
        'Revenue Per Unit' AS metric_name,
        'Grand Total' AS current_year_date,
        'Grand Total' AS prior_year_date,
        'Grand Total' AS two_year_prior_date,
        CONCAT('$', FORMAT(SUM(current_revenue) / NULLIF(SUM(current_units), 0), 2)) AS current_year_value,
        CONCAT('$', FORMAT(SUM(prior_revenue) / NULLIF(SUM(prior_units), 0), 2)) AS prior_year_value,
        CONCAT('$', FORMAT(SUM(two_year_prior_revenue) / NULLIF(SUM(two_year_prior_units), 0), 2)) AS two_year_prior_value,
        CONCAT('$', FORMAT((SUM(current_revenue) / NULLIF(SUM(current_units), 0)) - (SUM(prior_revenue) / NULLIF(SUM(prior_units), 0)), 2)) AS diff_abs,
        CONCAT('$', FORMAT((SUM(current_revenue) / NULLIF(SUM(current_units), 0)) - (SUM(two_year_prior_revenue) / NULLIF(SUM(two_year_prior_units), 0)), 2)) AS diff_abs_2yr,
        CONCAT(FORMAT(
            CASE 
                WHEN SUM(prior_revenue) / NULLIF(SUM(prior_units), 0) = 0 THEN NULL
                ELSE ((SUM(current_revenue) / NULLIF(SUM(current_units), 0)) - (SUM(prior_revenue) / NULLIF(SUM(prior_units), 0))) / (SUM(prior_revenue) / NULLIF(SUM(prior_units), 0)) * 100
            END, 0
        ), '%') AS diff_pct,
        CONCAT(FORMAT(
            CASE 
                WHEN SUM(two_year_prior_revenue) / NULLIF(SUM(two_year_prior_units), 0) = 0 THEN NULL
                ELSE ((SUM(current_revenue) / NULLIF(SUM(current_units), 0)) - (SUM(prior_revenue) / NULLIF(SUM(two_year_prior_units), 0))) / (SUM(two_year_prior_revenue) / NULLIF(SUM(two_year_prior_units), 0)) * 100
            END, 0
        ), '%') AS diff_pct_2yr,
        3 AS sort_priority_metric,
        999 AS sort_priority_date
    FROM comparison_data 
) AS long_format
ORDER BY 
    sort_priority_metric,
    sort_priority_date;
