SELECT * FROM usat_sales_db.all_runsignup_data_raw_affiliate_urls;

CREATE TABLE usat_sales_db.all_runsignup_data_raw_affiliate_urls_copy_042126 
LIKE usat_sales_db.all_runsignup_data_raw_affiliate_urls;

INSERT INTO usat_sales_db.all_runsignup_data_raw_affiliate_urls_copy_042126 
SELECT *
FROM usat_sales_db.all_runsignup_data_raw_affiliate_urls;

SELECT * FROM usat_sales_db.all_runsignup_data_raw_affiliate_urls_copy_042126;

-- =============================================
SELECT * FROM usat_sales_db.all_runsignup_data_raw_missing_id;

CREATE TABLE usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226 
LIKE usat_sales_db.all_runsignup_data_raw_missing_id;

INSERT INTO usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226 
SELECT *
FROM usat_sales_db.all_runsignup_data_raw_missing_id;

SELECT * FROM usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226;