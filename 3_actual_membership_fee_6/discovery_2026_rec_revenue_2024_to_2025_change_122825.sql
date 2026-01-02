SELECT * FROM rev_recognition_allocation_data LIMIT 10;

SELECT 
	revenue_year_month,
    SUM(sales_units),
    SUM(monthly_revenue)
FROM rev_recognition_allocation_data
WHERE 1 = 1
	AND revenue_year_date >= 2024
    AND revenue_year_date < 2028
GROUP BY 1
ORDER BY 1
-- LIMIT 10
;