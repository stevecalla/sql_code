STATE CHAMPIONSHIP

USE vapor;

SELECT '0) sample records' AS query_label, sc.* FROM `State Champs` AS sc LIMIT 10;
SELECT '1) count all records' AS query_label, FORMAT(COUNT(*), 0) FROM `State Champs` AS sc LIMIT 10;
SELECT '2) count by distinct state' AS query_label, state_code, FORMAT(COUNT(*), 0) AS record_count FROM `State Champs` GROUP BY state_code ORDER BY state_code ASC;
SELECT '2a) count by distinct race_type_name' AS query_label, race_type_name, FORMAT(COUNT(*), 0) AS record_count FROM `State Champs` GROUP BY race_type_name ORDER BY race_type_name ASC;

SELECT '3) count by MA / FL' AS query_label, sc.state_code, FORMAT(COUNT(*), 0) FROM `State Champs` AS sc WHERE state_code IN ('MA', 'FL') GROUP BY state_code ORDER BY state_code LIMIT 10;
SELECT '4) count MA/FL; Triathlon' AS query_label, state_code, FORMAT(COUNT(*), 0) FROM `State Champs` WHERE state_code IN ('MA', 'FL') AND race_type_name = 'Triathlon' GROUP BY state_code ORDER BY state_code LIMIT 10;
SELECT '5) count MA/FL; Triathlon; ranking not null' AS query_label, state_code, FORMAT(COUNT(*), 0) FROM `State Champs` WHERE state_code IN ('MA', 'FL') AND race_type_name = 'Triathlon' AND state_ranking IS NOT NULL GROUP BY state_code ORDER BY state_code LIMIT 10;
SELECT '6) count MA/FL; Triathlon; ranking is null' AS query_label, state_code, FORMAT(COUNT(*), 0) FROM `State Champs` WHERE state_code IN ('MA', 'FL') AND race_type_name = 'Triathlon' AND state_ranking IS NULL GROUP BY state_code ORDER BY state_code LIMIT 10;

SELECT '7) ranked members for MA/FL; triathlon' AS query_label, sc.* FROM `State Champs` AS sc WHERE state_code IN ('MA', 'FL') AND race_type_name = 'Triathlon' ORDER BY state_code, race_results_count, state_ranking, last_name, first_name;
SELECT '8) ranked members for MA/FL; triathlon; ranking not null' AS query_label, sc.* FROM `State Champs` AS sc WHERE state_code IN ('MA', 'FL')  AND race_type_name = 'Triathlon' AND state_ranking IS NOT NULL ORDER BY state_code, race_results_count, state_ranking, last_name, first_name;
SELECT '9) ranked members for MA/FL; triathlon; ranking is null' AS query_label, sc.* FROM `State Champs` AS sc WHERE state_code IN ('MA', 'FL')  AND race_type_name = 'Triathlon' AND state_ranking IS NULL ORDER BY state_code, race_results_count, state_ranking, last_name, first_name;

SELECT
	'10) ranked members for MA/FL; triathlon; ranking is null' AS query_label,
    ROW_NUMBER() OVER (ORDER BY state_code, state_ranking, last_name, first_name) AS row_count,
	sc.* 
FROM `State Champs` AS sc
WHERE 
	state_code IN ('MA', 'FL') 
    AND race_type_name IN ('Triathlon', 'Triathlon Off-Road')    
    AND state_ranking IS NOT NULL 
    AND gender_id = 1 
    AND race_age BETWEEN 55 AND 59 
    -- AND last_name = 'Reback' -- John 
ORDER BY state_code, state_ranking, last_name, first_name
LIMIT 1 -- only for test
;

SELECT
	'11) distritibution of athletes by race count' AS query_label,
	sc.race_results_count,
    FORMAT(SUM(CASE WHEN state_code IN ('FL') THEN 1 END), 0) AS race_results_fl_count,
    FORMAT(SUM(CASE WHEN state_code IN ('MA') THEN 1 END), 0) AS race_results_ma_count,
    FORMAT(COUNT(*), 0) AS total_count
FROM `State Champs` AS sc
WHERE 
	state_code IN ('MA', 'FL') 
    AND race_type_name IN ('Triathlon', 'Triathlon Off-Road')    
    -- AND state_ranking IS NOT NULL 
    -- AND gender_id = 1 
    -- AND race_age BETWEEN 55 AND 59 
    -- AND last_name = 'Reback' -- John 
GROUP BY sc.race_results_count WITH ROLLUP
ORDER BY sc.race_results_count ASC
;