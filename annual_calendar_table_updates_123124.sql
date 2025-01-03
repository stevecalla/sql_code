-- Drop the database if it exists
DROP DATABASE IF EXISTS usat_membership_base_db;

-- CREATE RENTAL RECORD TABLE
CREATE DATABASE usat_membership_base_db;

-- Switch to the newly created database
USE usat_membership_base_db;

-- ****************** CREATE CALENDAR TABLE START ********************
CREATE TABLE step_1_calendar_table (
    calendar_date DATE PRIMARY KEY,
    year INT,
    quarter INT,
    month INT,
    week_of_year INT,
    day_of_year INT,
    day_of_week VARCHAR(9),
    day_of_week_numeric INT,

    -- Create indexes on calendar_date
    INDEX idx_calendar_date (calendar_date)
);

SHOW INDEXES FROM step_1_calendar_table;

-- Insert data for the years 2015 and the last day of the current year
INSERT INTO step_1_calendar_table (calendar_date, year, quarter, month, week_of_year, day_of_year, day_of_week, day_of_week_numeric)
SELECT
    date_seq,
    YEAR(date_seq),
    QUARTER(date_seq),
    MONTH(date_seq),
    WEEK(date_seq),
    DAY(date_seq),
    DAYNAME(date_seq),
    DAYOFWEEK(date_seq)

FROM (
    SELECT
        DATE_ADD('2015-01-01', INTERVAL seq DAY) AS date_seq
    FROM (
        SELECT
            (t4*1000 + t3*100 + t2*10 + t1) - 1 AS seq
        FROM
            (SELECT 0 AS t1 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
            (SELECT 0 AS t2 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
            (SELECT 0 AS t3 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
            (SELECT 0 AS t4 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3) t4
    ) AS seq_table
    WHERE DATE_ADD('2015-01-01', INTERVAL seq DAY) BETWEEN '2015-01-01' AND DATE_ADD(LAST_DAY(DATE_ADD(NOW(), INTERVAL 12-MONTH(NOW()) MONTH)), INTERVAL 1 YEAR) -- two years from now
) AS calendar_data;

ALTER TABLE step_1_calendar_table
    ADD COLUMN created_at_mtn TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Select all records with a limit of 10
SELECT * FROM step_1_calendar_table;