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
comparison_data AS (
    SELECT 
        current_year_data.purchased_on_date_adjusted_mp AS current_year_date,
        prior_year_data.prior_year_date,
        
        current_year_data.total_sales_revenue AS current_revenue,
        prior_year_data.total_sales_revenue_prior AS prior_revenue,
        
        current_year_data.total_sales_units AS current_units,
        prior_year_data.total_sales_units_prior AS prior_units,
        
        current_year_data.revenue_per_unit AS current_revenue_per_unit,
        prior_year_data.revenue_per_unit_prior AS prior_revenue_per_unit,
        
        -- Absolute and percentage differences
        current_year_data.total_sales_revenue - prior_year_data.total_sales_revenue_prior AS revenue_diff_abs,
        CASE 
            WHEN prior_year_data.total_sales_revenue_prior = 0 THEN NULL
            ELSE (current_year_data.total_sales_revenue - prior_year_data.total_sales_revenue_prior) / prior_year_data.total_sales_revenue_prior * 100
        END AS revenue_diff_pct,
        
        current_year_data.total_sales_units - prior_year_data.total_sales_units_prior AS units_diff_abs,
        CASE 
            WHEN prior_year_data.total_sales_units_prior = 0 THEN NULL
            ELSE (current_year_data.total_sales_units - prior_year_data.total_sales_units_prior) / prior_year_data.total_sales_units_prior * 100
        END AS units_diff_pct,
        
        current_year_data.revenue_per_unit - prior_year_data.revenue_per_unit_prior AS revenue_per_unit_diff_abs,
        CASE 
            WHEN prior_year_data.revenue_per_unit_prior = 0 THEN NULL
            ELSE (current_year_data.revenue_per_unit - prior_year_data.revenue_per_unit_prior) / prior_year_data.revenue_per_unit_prior * 100
        END AS revenue_per_unit_diff_pct
    FROM 
        current_year_data
    LEFT JOIN 
        prior_year_data
    ON current_year_data.purchased_on_date_adjusted_mp = DATE_ADD(prior_year_data.prior_year_date, INTERVAL 1 YEAR)
),
formatted_data AS (
    SELECT 
        CASE 
            WHEN DAYNAME(current_year_date) = 'Sunday' THEN 'SU'
            WHEN DAYNAME(current_year_date) = 'Monday' THEN 'M'
            WHEN DAYNAME(current_year_date) = 'Tuesday' THEN 'TU'
            WHEN DAYNAME(current_year_date) = 'Wednesday' THEN 'W'
            WHEN DAYNAME(current_year_date) = 'Thursday' THEN 'TH'
            WHEN DAYNAME(current_year_date) = 'Friday' THEN 'F'
            WHEN DAYNAME(current_year_date) = 'Saturday' THEN 'SA'
        END AS current_year_day_abbr,
        CASE 
            WHEN DAYNAME(prior_year_date) = 'Sunday' THEN 'SU'
            WHEN DAYNAME(prior_year_date) = 'Monday' THEN 'M'
            WHEN DAYNAME(prior_year_date) = 'Tuesday' THEN 'TU'
            WHEN DAYNAME(prior_year_date) = 'Wednesday' THEN 'W'
            WHEN DAYNAME(prior_year_date) = 'Thursday' THEN 'TH'
            WHEN DAYNAME(prior_year_date) = 'Friday' THEN 'F'
            WHEN DAYNAME(prior_year_date) = 'Saturday' THEN 'SA'
        END AS prior_year_day_abbr,
        DATE_FORMAT(current_year_date, '%c/%e/%y') AS current_year_date_part, -- Format as M/D/YY
        DATE_FORMAT(prior_year_date, '%c/%e/%y') AS prior_year_date_part, -- Format as M/D/YY
        DAY(current_year_date) AS sort_order, -- Use the day of the month for sorting
        current_year_date,
        prior_year_date,
        current_revenue,
        prior_revenue,
        current_units,
        prior_units,
        current_revenue_per_unit,
        prior_revenue_per_unit,
        revenue_diff_abs,
        revenue_diff_pct,
        units_diff_abs,
        units_diff_pct,
        revenue_per_unit_diff_abs,
        revenue_per_unit_diff_pct
    FROM 
        comparison_data
)
SELECT 
    CONCAT(current_year_day_abbr, current_year_date_part) AS current_year_date, -- Final date format as requested
    CONCAT('$', FORMAT(current_revenue, 0)) AS current_revenue,
    CONCAT('$', FORMAT(prior_revenue, 0)) AS prior_revenue,
    CONCAT('$', FORMAT(revenue_diff_abs, 0)) AS revenue_diff_abs,
    CONCAT(FORMAT(revenue_diff_pct, 0), '%') AS revenue_diff_pct,
    FORMAT(current_units, 0) AS current_units,
    FORMAT(prior_units, 0) AS prior_units,
    FORMAT(units_diff_abs, 0) AS units_diff_abs,
    CONCAT(FORMAT(units_diff_pct, 0), '%') AS units_diff_pct,
    CONCAT('$', FORMAT(current_revenue_per_unit, 2)) AS current_revenue_per_unit,
    CONCAT('$', FORMAT(prior_revenue_per_unit, 2)) AS prior_revenue_per_unit,
    CONCAT('$', FORMAT(revenue_per_unit_diff_abs, 2)) AS revenue_per_unit_diff_abs,
    CONCAT(FORMAT(revenue_per_unit_diff_pct, 0), '%') AS revenue_per_unit_diff_pct,
    CONCAT(prior_year_day_abbr, prior_year_date_part) AS prior_year_date, -- Final date format as requested
    sort_order -- Sort order by the day of the month
FROM 
    formatted_data
UNION ALL
SELECT
    'Grand Total',
    CONCAT('$', FORMAT(SUM(current_revenue), 0)) AS current_revenue,
    CONCAT('$', FORMAT(SUM(prior_revenue), 0)) AS prior_revenue,
    CONCAT('$', FORMAT(SUM(revenue_diff_abs), 0)) AS revenue_diff_abs,
    CONCAT(FORMAT(AVG(revenue_diff_pct), 0), '%') AS revenue_diff_pct,
    
    FORMAT(SUM(current_units), 0) AS current_units,
    FORMAT(SUM(prior_units), 0) AS prior_units,
    FORMAT(SUM(units_diff_abs), 0) AS units_diff_abs,
    CONCAT(FORMAT(AVG(units_diff_pct), 0), '%') AS units_diff_pct,
    
--     CONCAT('$', FORMAT(AVG(current_revenue_per_unit), 2)) AS current_revenue_per_unit,
--     CONCAT('$', FORMAT(AVG(prior_revenue_per_unit), 2)) AS prior_revenue_per_unit,
--     CONCAT('$', FORMAT(AVG(revenue_per_unit_diff_abs), 2)) AS revenue_per_unit_diff_abs,
--     CONCAT(FORMAT(AVG(revenue_per_unit_diff_pct), 0), '%') AS revenue_per_unit_diff_pct,
    
	CONCAT('$', FORMAT(SUM(current_revenue) / NULLIF(SUM(current_units), 0), 2)) AS current_revenue_per_unit, -- Corrected
    CONCAT('$', FORMAT(SUM(prior_revenue) / NULLIF(SUM(prior_units), 0), 2)) AS prior_revenue_per_unit, -- Corrected
    CONCAT('$', FORMAT((SUM(current_revenue) / NULLIF(SUM(current_units), 0)) - (SUM(prior_revenue) / NULLIF(SUM(prior_units), 0)), 2)) AS revenue_per_unit_diff_abs, -- Corrected
    CONCAT(FORMAT(
        CASE 
            WHEN SUM(prior_revenue) / NULLIF(SUM(prior_units), 0) = 0 THEN NULL
            ELSE ((SUM(current_revenue) / NULLIF(SUM(current_units), 0)) - (SUM(prior_revenue) / NULLIF(SUM(prior_units), 0))) / (SUM(prior_revenue) / NULLIF(SUM(prior_units), 0)) * 100
        END, 0
    ), '%') AS revenue_per_unit_diff_pct, -- Corrected
    
    'Grand Total',
    32 AS sort_order -- Ensure Grand Total is at the bottom
FROM 
    comparison_data
ORDER BY 
    sort_order;
    
