USE usat_sales_db;

-- Drop the database if it exists
-- DROP DATABASE IF EXISTS usat_sales_db;

-- CREATE RENTAL RECORD TABLE
-- CREATE DATABASE usat_sales_db;

DESCRIBE all_membership_sales_data;

SELECT * FROM all_membership_sales_data LIMIT 100;

SELECT DISTINCT(real_membership_types_sa) FROM all_membership_sales_data;

SELECT DISTINCT(new_member_category_6_sa) FROM all_membership_sales_data;

SELECT 
	purchased_on_year_mp, 
    FORMAT(SUM(CASE WHEN real_membership_types_sa IN ("adult_annual", "elite", "youth_annual") THEN 1 ELSE 0 END), 0) AS annual,
    FORMAT(SUM(CASE WHEN real_membership_types_sa IN ("one_day") THEN 1 ELSE 0 END), 0) AS one_day,
    FORMAT(SUM(CASE WHEN real_membership_types_sa NOT IN ("adult_annual", "elite", "youth_annual", "one_day") THEN 1 ELSE 0 END), 0) AS other, -- should be 0
    FORMAT(COUNT(*), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
FROM all_membership_sales_data 
GROUP BY purchased_on_year_mp WITH ROLLUP 
ORDER BY purchased_on_year_mp;

SET @date_string = "Fri Jun 11 2021 12:03:17 GMT-0600 (Mountain Daylight Time)";

-- Create the table if it doesn't exist
CREATE TABLE IF NOT EXISTS test_table (
	test_date_time_mtn DATETIME,
    test_date_time_utc DATETIME,
    test_date DATE
);

SELECT * FROM test_table;

INSERT INTO test_table (test_date_time_mtn)
SELECT 
        STR_TO_DATE(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(
                    @date_string, 
                    ' GMT', 1
                ),
                ' ', 
                -5
            ),
            '%a %b %d %Y %H:%i:%s'
        ) AS test_date_time_mtn;

SELECT * FROM test_table;

INSERT INTO test_table (test_date_time_utc)
SELECT 
    -- Add 6 hours to adjust the time to GMT/UTC
    ADDDATE(
        STR_TO_DATE(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(
                    @date_string, 
                    ' GMT', 1
                ),
                ' ', 
                -5
            ),
            '%a %b %d %Y %H:%i:%s'
        ),
        INTERVAL 6 HOUR
    ) AS test_date_time_utc;

SELECT * FROM test_table;

INSERT INTO test_table (test_date)
SELECT 
        STR_TO_DATE(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(
                    @date_string, 
                    ' GMT', 1
                ),
                ' ', 
                -5
            ),
            '%a %b %d %Y %H:%i:%s'
        ) AS test_date;

SELECT * FROM test_table;


