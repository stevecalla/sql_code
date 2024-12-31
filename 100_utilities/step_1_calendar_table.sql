-- Switch to the newly created database
USE usat_membership_base_db;

DROP TABLE IF EXISTS step_1_calendar_table;

-- Increase the maximum recursion depth
SET @@cte_max_recursion_depth = 5000;

-- Create the calendar table
CREATE TABLE step_1_calendar_table AS
    WITH RECURSIVE calendar_generator AS (
        SELECT '2015-01-01' AS calendar_date
        UNION ALL
        SELECT DATE_ADD(calendar_date, INTERVAL 1 DAY)
        FROM calendar_generator
        WHERE calendar_date < '2027-12-31' -- Extend the range to 2027
    )
    SELECT
        calendar_date AS calendar_date,
        YEAR(calendar_date) AS year,
        QUARTER(calendar_date) AS quarter,
        MONTH(calendar_date) AS month,
        WEEK(calendar_date) AS week_of_year,
        DAY(calendar_date) AS day_of_year, -- actual day of month
        DAYNAME(calendar_date) AS day_of_week,
        DAYOFWEEK(calendar_date) AS day_of_week_numeric
    FROM calendar_generator;

-- Select the first 10 rows for verification
SELECT * FROM step_1_calendar_table LIMIT 10;
SELECT MIN(calendar_date), MAX(calendar_date), COUNT(*) FROM step_1_calendar_table LIMIT 10;