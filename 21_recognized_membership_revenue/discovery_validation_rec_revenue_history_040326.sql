-- SELECT * FROM rev_recognition_allocation_data LIMIT 10;
-- SHOW COLUMNS FROM rev_recognition_allocation_data;
-- SHOW COLUMNS FROM rev_recognition_allocation_data_history;
DROP TABLE rev_recognition_allocation_data_history;

-- DELETE FROM rev_recognition_allocation_data_history
-- 	WHERE 1 = 1
-- 	AND snapshot_version LIKE 'revenue_month_2025%'
-- ;

-- MAIN HISTORY TABLE
SELECT * FROM rev_recognition_allocation_data_history LIMIT 100;
SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data_history LIMIT 10000;
SELECT revenue_year_date, revenue_month_date, snapshot_version, FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data_history GROUP BY 1, 2, 3 ORDER BY 1, 2, 3 LIMIT 10000;

SHOW PROCESSLIST;

-- BACKUPS
SELECT * FROM rev_recognition_allocation_data_history_bck_2026_04_03_sys LIMIT 10000;
SELECT * FROM rev_recognition_allocation_data_history_bck_2026_04_03_usr7 LIMIT 10000;
SELECT * FROM rev_recognition_allocation_data_history_bck_2026_04_03_usr8 LIMIT 10000;

SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data_history_bck_2026_04_05_sys LIMIT 10000;
SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data_history_bck_2026_04_03_usr7 LIMIT 10000;
SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data_history_bck_2026_04_03_usr8 LIMIT 10000;
SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data_history_bck_2026_04_03_usr16 LIMIT 10000;

-- BY SNAPSHOT VERSION
SELECT * FROM rev_recognition_allocation_data_history WHERE snapshot_version LIKE 'revenue_month_2025%' LIMIT 100;
SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data_history WHERE snapshot_version LIKE 'revenue_month_2025%' LIMIT 10000;

-- EXPLAIN
SELECT 
    'rev_recognition_allocation_data' AS source,
    revenue_year_date,
    FORMAT(COUNT(*), 0) AS count_rows,
    FORMAT(SUM(monthly_revenue) / COUNT(*), 3) AS avg_monthly_revenue,
    FORMAT(SUM(monthly_revenue), 3) AS total_monthly_revenue,
    FORMAT(SUM(monthly_revenue_less_deduction), 3) AS total_monthly_revenue_less_deduction
FROM rev_recognition_allocation_data
WHERE 1 = 1
    AND revenue_year_date = 2026
    AND revenue_month_date = 1
GROUP BY 2

UNION ALL

SELECT 
    'rev_recognition_allocation_data_history' AS source,
    revenue_year_date,
    FORMAT(COUNT(*), 0) AS count_rows,
    FORMAT(SUM(monthly_revenue) / COUNT(*), 3) AS avg_monthly_revenue,
    FORMAT(SUM(monthly_revenue), 3) AS total_monthly_revenue,
    FORMAT(SUM(monthly_revenue_less_deduction), 3) AS total_monthly_revenue_less_deduction
FROM rev_recognition_allocation_data_history
WHERE 1 = 1
    AND revenue_year_date = 2026
    AND revenue_month_date = 1
    GROUP BY 2
ORDER BY 2
;