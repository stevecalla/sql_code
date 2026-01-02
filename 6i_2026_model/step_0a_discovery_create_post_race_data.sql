USE usat_sales_db;

SET @table_name = 'sales_model_2026_post_race_data'; -- need prepared statement to use; opted for easy setup

-- CREATE ACTUAL VS GOAL DATA
    DROP TABLE IF EXISTS sales_model_2026_post_race_data;

-- GET CURRENT DATE IN MTN (MST OR MDT) & UTC
    SET @created_at_mtn = (         
        SELECT CASE 
            WHEN UTC_TIMESTAMP() >= DATE_ADD(
                    DATE_ADD(CONCAT(YEAR(UTC_TIMESTAMP()), '-03-01'),
                        INTERVAL ((7 - DAYOFWEEK(CONCAT(YEAR(UTC_TIMESTAMP()), '-03-01')) + 1) % 7 + 7) DAY),
                    INTERVAL 2 HOUR)
            AND UTC_TIMESTAMP() < DATE_ADD(
                    DATE_ADD(CONCAT(YEAR(UTC_TIMESTAMP()), '-11-01'),
                        INTERVAL ((7 - DAYOFWEEK(CONCAT(YEAR(UTC_TIMESTAMP()), '-11-01')) + 1) % 7) DAY),
                    INTERVAL 2 HOUR)
            THEN DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL -6 HOUR), '%Y-%m-%d %H:%i:%s')
            ELSE DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL -7 HOUR), '%Y-%m-%d %H:%i:%s')
            END
    );
    SET @created_at_utc = DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d %H:%i:%s');

-- CREATE sales_model_2026_post_race_data
    CREATE TABLE IF NOT EXISTS sales_model_2026_post_race_data (
        year INT,
        month INT,
        `year_month` VARCHAR(50),

        type VARCHAR(50),
        category VARCHAR(50),

        sales_units INT,
        sales_revenue DECIMAL(10,2),

        -- Created at timestamps:
        created_at_mtn DATETIME,
        created_at_utc DATETIME
    );

SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'secure_file_priv';

-- LOAD sales_model_2026_post_race_data
    LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\data\\usat_sales_post_race_data\\2026_post_race_raw_data_010126.csv'
        INTO TABLE sales_model_2026_post_race_data
        FIELDS TERMINATED BY ','
        ENCLOSED BY '"'
        LINES TERMINATED BY '\n'
        IGNORE 1 LINES
        (
            year,
            month,
            `year_month`,
            type,
            category,
            sales_units,
            sales_revenue
        )
        SET
            created_at_mtn = @created_at_mtn,
            created_at_utc = @created_at_utc;
    ;

SELECT * FROM usat_sales_db.sales_model_2026_post_race_data;
SELECT FORMAT(COUNT(*), 0) FROM usat_sales_db.sales_model_2026_post_race_data;