USE usat_sales_db;

SELECT * FROM salesforce_account_duplicate_snapshot LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM salesforce_account_duplicate_snapshot LIMIT 10;
SELECT * FROM salesforce_account_duplicate_snapshot WHERE salesforce_merge_id <> '';
SELECT COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE salesforce_merge_id <> '';
SELECT last_name, first_name, GROUP_CONCAT(salesforce_merge_id), COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE salesforce_merge_id <> '' GROUP BY 1,2;

SELECT * FROM salesforce_duplicate_exact_group LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM salesforce_duplicate_exact_group LIMIT 10;
SELECT * FROM salesforce_duplicate_exact_group WHERE Merge_ids__c IS NOT NULL AND TRIM(Merge_ids__c) <> '' AND REPLACE(TRIM(Merge_ids__c), ';', '') <> '';
SELECT COUNT(*) FROM salesforce_duplicate_exact_group WHERE Merge_ids__c IS NOT NULL AND TRIM(Merge_ids__c) <> '' AND REPLACE(TRIM(Merge_ids__c), ';', '') <> '';

SELECT * FROM salesforce_duplicate_consolidated_cluster LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM salesforce_duplicate_consolidated_cluster LIMIT 10;
SELECT * FROM salesforce_duplicate_consolidated_cluster WHERE Merge_ids__c IS NOT NULL AND TRIM(Merge_ids__c) <> '' AND REPLACE(TRIM(Merge_ids__c), ';', '') <> '';
SELECT COUNT(*) FROM salesforce_duplicate_consolidated_cluster WHERE Merge_ids__c IS NOT NULL AND TRIM(Merge_ids__c) <> '' AND REPLACE(TRIM(Merge_ids__c), ';', '') <> '';

SELECT * FROM salesforce_duplicate_merge_id_review LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM salesforce_duplicate_merge_id_review LIMIT 10;
SELECT bucket__c, FORMAT(COUNT(*), 0) FROM salesforce_duplicate_merge_id_review GROUP BY 1 LIMIT 10;