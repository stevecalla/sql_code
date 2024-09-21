USE usat_sales_db;

SELECT * FROM all_membership_sales_data LIMIT 100;
-- Calculate the number of days elapsed this year up to today
SET @days_elapsed = DATEDIFF(CURDATE(), DATE(CONCAT(YEAR(CURDATE()), '-01-01'))) - 1;

SELECT
    id_mp,
    CURDATE(),
    purchased_on_mp,
    purchased_on_year_mp,
    CONCAT(purchased_on_year_mp, '-01-01') AS start_of_year,
    @days_elapsed AS days_elapsed,
	DATE_ADD(
		DATE(CONCAT(purchased_on_year_mp, '-01-01')), 
		INTERVAL @days_elapsed DAY
	) AS test,
	-- Calculate the date of the third Sunday in September for each year
    DATE_ADD(
        DATE(CONCAT(purchased_on_year_mp, '-09-01')), -- Start from September 1st
        INTERVAL ((7 - WEEKDAY(DATE(CONCAT(purchased_on_year_mp, '-09-01')))) + 13) DAY -- Days to third Sunday
    ) AS third_sunday_sept,
	-- Calculate the target date in the previous year
    DATE_SUB(
        DATE_ADD(
            DATE(CONCAT(purchased_on_year_mp, '-01-01')),  -- Start from January 1st of the previous year
            INTERVAL (WEEKDAY(CURDATE()) - WEEKDAY(DATE(CONCAT(YEAR(CURDATE()) - 1, '-01-01')))) DAY  -- Adjust to match the same day of the week
        ),
        INTERVAL (WEEKDAY(CURDATE()) - WEEKDAY(DATE(CONCAT(YEAR(CURDATE()) - 1, '-01-01')))) + 7 * (WEEK(CURDATE()) - 1) DAY  -- Adjust for the correct week
    ) AS same_weekday_last_year
FROM all_membership_sales_data
ORDER BY purchased_on_mp  -- Specify a column for ordering
LIMIT 10;
