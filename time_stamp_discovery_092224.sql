USE usat_sales_db;

SET @purchase_on = '2024-09-05 18:06:41';
SET @purchase_on_v2 = '2024-12-10';

SET @end_mp = '2024-12-03';

SELECT 
    ROUND(TIMESTAMPDIFF(DAY, @purchase_on, @end_mp), 0) AS days_difference,  -- Calculate month difference
    ROUND(TIMESTAMPDIFF(DAY, @purchase_on, @end_mp) / 30, 0) AS month_difference,  -- Calculate month difference
    
    ROUND(TIMESTAMPDIFF(DAY, @purchase_on_v2, @end_mp), 0) AS days_difference,  -- Calculate month difference
    ROUND(TIMESTAMPDIFF(DAY, @purchase_on_v2, @end_mp) / 30, 0) AS month_difference,  -- Calculate month difference
	CASE 
        WHEN YEAR(@purchase_on) = YEAR(@end_mp) AND MONTH(@purchase_on) = MONTH(@end_mp) THEN 'Same Month'
        ELSE CONCAT('Difference: ', TIMESTAMPDIFF(MONTH, @purchase_on, @end_mp)) 
    END AS purchase_on_difference,

    CASE 
        WHEN YEAR(@purchase_on_v2) = YEAR(@end_mp) AND MONTH(@purchase_on_v2) = MONTH(@end_mp) THEN 'Same Month'
        ELSE CONCAT('Difference: ', TIMESTAMPDIFF(MONTH, @purchase_on_v2, @end_mp)) 
    END AS purchase_on_v2_difference;
