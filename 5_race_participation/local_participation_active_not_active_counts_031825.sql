SELECT * FROM usat_sales_db.all_participation_data_with_membership_match LIMIT 10;
SELECT COUNT(*) FROM usat_sales_db.all_participation_data_with_membership_match LIMIT 10;

SELECT 
    is_active_membership,
    real_membership_types_sa,
    -- age_as_race_results_bin,
    name_event_type,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2025 THEN 1 ELSE 0 END), 0) AS race_year_2025,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2024 THEN 1 ELSE 0 END), 0) AS race_year_2024,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2023 THEN 1 ELSE 0 END), 0) AS race_year_2023,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2022 THEN 1 ELSE 0 END), 0) AS race_year_2022,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2021 THEN 1 ELSE 0 END), 0) AS race_year_2021,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2020 THEN 1 ELSE 0 END), 0) AS race_year_2020,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2019 THEN 1 ELSE 0 END), 0) AS race_year_2019,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2018 THEN 1 ELSE 0 END), 0) AS race_year_2018,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2017 THEN 1 ELSE 0 END), 0) AS race_year_2017,
    FORMAT(SUM(CASE WHEN start_date_year_races = 2016 THEN 1 ELSE 0 END), 0) AS race_year_2016,
    FORMAT(SUM(CASE WHEN start_date_year_races <= 2015 THEN 1 ELSE 0 END), 0) AS race_year_less_than_2015,
    FORMAT(COUNT(*), 0) AS total_count
FROM usat_sales_db.all_participation_data_with_membership_match
WHERE 1 = 1
	AND rn = 1 -- ONLY RETURNS THE FIRST MATCH IF THERE ARE DUPLICATES
-- GROUP BY is_active_membership, 2, 3 WITH ROLLUP
GROUP BY is_active_membership, 2, 3 WITH ROLLUP
;