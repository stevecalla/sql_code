USE usat_sales_db;

SELECT * FROM all_participation_data_raw LIMIT 10;
SELECT COUNT(*), SUM(count_all_participation) FROM all_participation_data_raw;
SELECT "participation data", start_date_year_races, COUNT(*), SUM(count_all_participation) FROM all_participation_data_raw GROUP BY 2;

-- *************************************
-- MERGE WITH REGIONS
-- *************************************
SELECT 

FROM all_participation_data_raw
GROUP BY start_date_year_races WITH ROLLUP
;
-- *************************************

-- *************************************
-- MERGE WITH SALES
-- *************************************
SELECT 

FROM all_participation_data_raw
GROUP BY start_date_year_races WITH ROLLUP
;
-- *************************************