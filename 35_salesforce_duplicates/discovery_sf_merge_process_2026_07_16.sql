USE usat_sales_db;

SELECT "0 snapshot data" AS label, ds.* FROM salesforce_account_duplicate_snapshot AS ds LIMIT 10;
SELECT "0 snapshot data" AS label, FORMAT(COUNT(*), 0) FROM salesforce_account_duplicate_snapshot AS ds LIMIT 10;
SELECT "0 snapshot data" AS label, FORMAT(COUNT(*), 0) FROM salesforce_account_duplicate_snapshot AS ds WHERE foundation_constituent like "true" LIMIT 10;
-- SELECT "0a api usage" AS label, a.* FROM salesforce_merge_api_usage AS a ORDER BY created_at_mtn DESC;

SELECT "0 parallel settings" AS label, ms.* FROM salesforce_merge_settings AS ms ORDER BY updated_at_mtn DESC;

SELECT "1 queue" AS label, q.* FROM salesforce_merge_queue AS q ORDER BY created_at_mtn DESC;
SELECT "1a stage baseline" AS label, b.* FROM salesforce_merge_stage_baseline AS b ORDER BY created_at;

SELECT "2 merge run" AS label, r.* FROM salesforce_merge_run AS r ORDER BY created_at_mtn DESC;

SELECT "3 snapshot" AS label, ps.* FROM salesforce_merge_premerge_snapshot AS ps ORDER BY created_at_mtn DESC;
SELECT "3a snapshot" AS label, account, role, source_key, FORMAT(COUNT(*), 0) FROM salesforce_merge_premerge_snapshot AS ps GROUP BY 2,3,4 ORDER BY 2,3 DESC,4 DESC;

SELECT "4 snapshot" AS label, ps.* FROM salesforce_merge_postmerge_snapshot AS ps ORDER BY created_at_mtn DESC;

SELECT "5 history" AS label, h.* FROM salesforce_merge_history AS h ORDER BY created_at_mtn DESC;

SELECT "6 excel sheet" AS label, d.* FROM salesforce_merge_dossier AS d ORDER BY created_at_mtn DESC;

-- TRUNCATE
-- TRUNCATE `usat_sales_db`.`salesforce_merge_dossier`;
-- TRUNCATE `usat_sales_db`.`salesforce_merge_history`;
-- TRUNCATE `usat_sales_db`.`salesforce_merge_postmerge_snapshot`;
-- TRUNCATE `usat_sales_db`.`salesforce_merge_premerge_snapshot`;
-- TRUNCATE `usat_sales_db`.`salesforce_merge_queue`;
-- TRUNCATE `usat_sales_db`.`salesforce_merge_run`;
-- TRUNCATE `usat_sales_db`.`salesforce_merge_stage_baseline`;

-- DONT TRUNCATE
-- TRUNCATE `usat_sales_db`.`salesforce_merge_settings`;
-- TRUNCATE `usat_sales_db`.`salesforce_merge_events`;
-- TRUNCATE `usat_sales_db`.`salesforce_merge_api_usage`;
