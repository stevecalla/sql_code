USE usat_sales_db;

-- ============================================================
-- 1) Snapshot table sanity checks
-- Purpose: Preview the source snapshot table and validate row counts,
-- especially ZIP-related fields used in duplicate matching.
-- ============================================================
SELECT '1.1 snapshot preview' AS query_label, s.* FROM salesforce_account_duplicate_snapshot s ORDER BY created_date DESC LIMIT 10;
SELECT '1.1 snapshot preview' AS query_label, s.salesforce_account_id, s.name, s.email, s.created_date, s.created_by_name FROM salesforce_account_duplicate_snapshot s ORDER BY created_date DESC LIMIT 20;
SELECT '1.2 snapshot row count' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot LIMIT 10; -- 696,032

SELECT '1.2 snapshot row count' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE match_composition <> "" LIMIT 10; -- 696,032
SELECT '1.2 snapshot row count' AS query_label, s.* FROM salesforce_account_duplicate_snapshot AS s WHERE match_composition <> "" LIMIT 10; -- 696,032
SELECT '1.2 snapshot row count' AS query_label, s.match_composition, FORMAT(COUNT(*), 0) FROM salesforce_account_duplicate_snapshot AS s WHERE match_composition <> "" GROUP BY 2 WITH ROLLUP LIMIT 10; -- 696,032

SELECT '1.2 snapshot foundation row count' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE foundation_constituent = "true" LIMIT 10; -- 42,137
SELECT '1.2 snapshot foundation row count' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE foundation_constituent = "true" AND member_number <> "" LIMIT 10; -- 25,678
-- ============================================================
-- 1a) Snapshot table sanity checks
-- Purpose: Ensure zip code is not blank
-- ============================================================
SELECT '1.3 billing postal blank count' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE billing_postal_code = "" LIMIT 10; -- 696,032
SELECT '1.4 billing postal populated count' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE billing_postal_code <> "" LIMIT 10; -- 0
SELECT '1.5 composite zip blank count' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE composite_zip_five_digit = "" LIMIT 10; -- 88,728
SELECT '1.6 composite zip populated count' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE composite_zip_five_digit <> "" LIMIT 10; -- 607,304
SELECT '1.7 mailing postal blank count' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE person_mailing_postal_code = "" LIMIT 10; -- 88,728
SELECT '1.8 mailing postal populated count' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE person_mailing_postal_code <> "" LIMIT 10; -- 607,304

-- ============================================================
-- 1b) Snapshot table sanity checks
-- Purpose: Ensure exact duplicate key = rule block key
-- ============================================================
SELECT '1.9 rule block = exact duplicate key' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot LIMIT 10; -- 696,054
SELECT '1.9 rule block = exact duplicate key' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE 1 = 1 AND rule_block_key <> "" AND exact_duplicate_key = rule_block_key LIMIT 10; -- 0

SELECT '1.9 rule block = exact duplicate key' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE 1 = 1 AND exact_duplicate_key <> "" LIMIT 10; -- 599,497
SELECT '1.9 rule block = rule block key' AS query_label, COUNT(*) FROM salesforce_account_duplicate_snapshot WHERE 1 = 1 AND rule_block_key <> "" LIMIT 10; -- 599,531

SELECT '1.9 exact key starts with name then equals rule block from gender forward' AS query_label, s.salesforce_account_id, s.exact_duplicate_key, s.rule_block_key 
FROM salesforce_account_duplicate_snapshot s WHERE 1 = 1 AND s.exact_duplicate_key LIKE CONCAT('%|', s.rule_block_key); -- 599,491

SELECT '1.11 rule block populated but exact duplicate key blank' AS query_label, t.*  FROM salesforce_account_duplicate_snapshot t
WHERE 1 = 1
    AND COALESCE(t.rule_block_key, '') <> ''
    AND COALESCE(t.exact_duplicate_key, '') = ''; -- 40

SELECT
    '1.10 exact key populated but does not end with rule block key' AS query_label,
    s.salesforce_account_id,
    s.exact_duplicate_key,
    s.rule_block_key
FROM salesforce_account_duplicate_snapshot s
WHERE 1 = 1
    AND s.exact_duplicate_key <> ''
    AND s.rule_block_key <> ''
    AND s.exact_duplicate_key NOT LIKE CONCAT('%|', s.rule_block_key);

-- ============================================================
-- 2) Consolidated cluster review
-- Purpose: Inspect consolidated duplicate clusters and check examples
-- where shared ZIP is blank or where a specific name appears in a group.
-- ============================================================
SELECT '2.1 consolidated cluster review' AS query_label, c.* FROM salesforce_duplicate_consolidated_cluster c;
SELECT '2.1 consolidated cluster review' AS query_label, FORMAT(COUNT(*), 0) FROM salesforce_duplicate_consolidated_cluster c;
SELECT '2.1 consolidated cluster review' AS query_label, FORMAT(COUNT(*), 0) FROM salesforce_duplicate_consolidated_cluster c WHERE Member_Numbers__c = '';
SELECT '2.2 consolidated cluster blank zip' AS query_label, c.* FROM salesforce_duplicate_consolidated_cluster c WHERE Shared_Composite_Zip__c = '';
SELECT '2.3 consolidated cluster Popp search' AS query_label, c.* FROM salesforce_duplicate_consolidated_cluster c WHERE Names_In_Group__c LIKE "%Popp%";

-- ============================================================
-- 3) Exact duplicate group review
-- Purpose: Inspect exact duplicate group output and validate records
-- with missing composite ZIP or a specific last name.
-- ============================================================
SELECT '3.1 exact duplicate group review' AS query_label, e.* FROM salesforce_duplicate_exact_group e;
SELECT '3.2 exact duplicate group blank zip' AS query_label, e.* FROM salesforce_duplicate_exact_group e WHERE Composite_Zip__c = '';
SELECT '3.3 exact duplicate group Popp search' AS query_label, e.* FROM salesforce_duplicate_exact_group e WHERE Last_Name__c LIKE "%Popp%";

-- ============================================================
-- 4) Fuzzy duplicate pair review
-- Purpose: Inspect fuzzy duplicate pair output and identify fuzzy pairs
-- where the first record has a blank composite ZIP.
-- ============================================================
SELECT '4.1 fuzzy duplicate pair review' AS query_label, f.* FROM salesforce_duplicate_fuzzy_pair f;
SELECT '4.2 fuzzy duplicate pair blank zip' AS query_label, f.* FROM salesforce_duplicate_fuzzy_pair f WHERE Composite_Zip_1__c = '';

-- ============================================================
-- 5) Nickname duplicate pair review
-- Purpose: Inspect nickname-based duplicate pair output and identify
-- nickname pairs where the first record has a blank composite ZIP.
-- ============================================================
SELECT '5.1 nickname duplicate pair review' AS query_label, n.* FROM salesforce_duplicate_nickname_pair n;
SELECT '5.2 nickname duplicate pair blank zip' AS query_label, n.* FROM salesforce_duplicate_nickname_pair n WHERE Composite_Zip_1__c = '';

-- ============================================================
-- 6) Full exact duplicate record detail
-- Purpose: Find all snapshot records that belong to an exact duplicate
-- group using normalized last name, first name, gender, birthdate, and ZIP.
-- This returns the full account-level rows for duplicate groups.
-- ============================================================
WITH duplicate_keys AS (
    SELECT
        clean_last_name,
        clean_first_name,
        gender_normalized,
        birthdate_normalized,
        composite_zip_five_digit,
        COUNT(*) AS duplicate_count
    FROM salesforce_account_duplicate_snapshot
    WHERE 1 = 1 AND clean_last_name <> '' AND clean_first_name <> '' AND gender_normalized <> '' AND birthdate_normalized <> '' AND composite_zip_five_digit <> ''
    GROUP BY clean_last_name, clean_first_name, gender_normalized, birthdate_normalized, composite_zip_five_digit
    HAVING COUNT(*) > 1
)
SELECT '6.1 full exact duplicate record detail' AS query_label, t.*
FROM salesforce_account_duplicate_snapshot t
JOIN duplicate_keys dup 
	ON t.clean_last_name = dup.clean_last_name 
    AND t.clean_first_name = dup.clean_first_name
    AND t.gender_normalized = dup.gender_normalized 
    AND t.birthdate_normalized = dup.birthdate_normalized 
    AND t.composite_zip_five_digit = dup.composite_zip_five_digit
WHERE 1 = 1
	-- AND member_number = "" --  13
    -- AND member_number <> "" -- 7,346
ORDER BY t.clean_last_name, t.clean_first_name, t.birthdate_normalized, t.composite_zip_five_digit;  -- 7,359

-- ============================================================
-- 7) Exact duplicate group key export
-- Purpose: Recreate the exact duplicate group key from the snapshot table
-- and aggregate all Salesforce Account IDs in each duplicate group.
-- This is useful for comparing against pipeline output.
-- ============================================================
USE usat_sales_db;

SET SESSION group_concat_max_len = 67108864;   -- same as the pipeline; avoids clipping ids

SELECT
    '7.1 exact duplicate group key export' AS query_label,
    CONCAT_WS('|', clean_last_name, clean_first_name, gender_normalized,
                   birthdate_normalized, composite_zip_five_digit)        AS exact_duplicate_key,
    COUNT(*)                                                              AS duplicate_count,
    GROUP_CONCAT(salesforce_account_id ORDER BY load_sequence SEPARATOR ',') AS ids
FROM salesforce_account_duplicate_snapshot
WHERE clean_last_name          <> ''
  AND clean_first_name         <> ''
  AND gender_normalized        <> ''
  AND birthdate_normalized     <> ''
  AND composite_zip_five_digit <> ''
GROUP BY clean_last_name, clean_first_name, gender_normalized, birthdate_normalized, composite_zip_five_digit
HAVING COUNT(*) > 1
ORDER BY MIN(load_sequence);

-- ============================================================
-- 8) Exact duplicate group count validation
-- Purpose: Count the number of exact duplicate groups and the total
-- number of records inside those groups. The expected total is 7,359.
-- This version also builds the same exact_duplicate_key and ids list.
-- ============================================================
USE usat_sales_db;

SET SESSION group_concat_max_len = 67108864;

SELECT '8.1 exact duplicate group count validation' AS query_label, COUNT(*) AS groups_1, SUM(duplicate_count) AS records_in_groups
FROM (
    SELECT
        CONCAT_WS('|', clean_last_name, clean_first_name, gender_normalized,
                       birthdate_normalized, composite_zip_five_digit) AS exact_duplicate_key,
        COUNT(*) AS duplicate_count,
        GROUP_CONCAT(salesforce_account_id ORDER BY load_sequence SEPARATOR ',') AS ids
    FROM salesforce_account_duplicate_snapshot
    WHERE clean_last_name          <> ''
      AND clean_first_name         <> ''
      AND gender_normalized        <> ''
      AND birthdate_normalized     <> ''
      AND composite_zip_five_digit <> ''
    GROUP BY clean_last_name, clean_first_name, gender_normalized, birthdate_normalized, composite_zip_five_digit
    HAVING COUNT(*) > 1
) g;
-- records_in_groups must = 7,359

-- ============================================================
-- 9) Lightweight exact duplicate count validation
-- Purpose: Same validation as above, but without generating the duplicate
-- key string or GROUP_CONCAT ids. Use this faster version when only counts
-- are needed.
-- ============================================================
SELECT '9.1 lightweight exact duplicate count validation' AS query_label, COUNT(*) AS groups_1, SUM(duplicate_count) AS records_in_groups
FROM (
  SELECT COUNT(*) AS duplicate_count
  FROM salesforce_account_duplicate_snapshot
  WHERE clean_last_name <> '' AND clean_first_name <> '' AND gender_normalized <> ''
    AND birthdate_normalized <> '' AND composite_zip_five_digit <> ''
  GROUP BY clean_last_name, clean_first_name, gender_normalized, birthdate_normalized, composite_zip_five_digit
  HAVING COUNT(*) > 1
) g; -- records_in_groups must = 7,359

-- ============================================================
-- 9) Lightweight exact duplicate count validation
-- Purpose: Breakout count by foundation
-- ============================================================
WITH duplicate_keys AS (
  SELECT clean_last_name, clean_first_name, gender_normalized, birthdate_normalized, composite_zip_five_digit, COUNT(*) AS duplicate_count
  FROM salesforce_account_duplicate_snapshot
  WHERE clean_last_name <> '' AND clean_first_name <> '' AND gender_normalized <> ''
    AND birthdate_normalized <> '' AND composite_zip_five_digit <> ''
  GROUP BY clean_last_name, clean_first_name, gender_normalized, birthdate_normalized, composite_zip_five_digit
  HAVING COUNT(*) > 1
)
SELECT '9.2 exact duplicate records by foundation constituent' AS query_label, s.foundation_constituent, COUNT(*) AS records_in_groups
FROM salesforce_account_duplicate_snapshot s
JOIN duplicate_keys d
  ON s.clean_last_name = d.clean_last_name
  AND s.clean_first_name = d.clean_first_name
  AND s.gender_normalized = d.gender_normalized
  AND s.birthdate_normalized = d.birthdate_normalized
  AND s.composite_zip_five_digit = d.composite_zip_five_digit
GROUP BY s.foundation_constituent WITH ROLLUP
ORDER BY s.foundation_constituent; -- non foundation 7,144, foundation 215

-- ============================================================
-- 10) Full exact duplicate record detail based on email
-- Purpose: Find all snapshot records that belong to an exact duplicate based on email
-- group using normalized last name, first name, gender, birthdate, and email.
-- ============================================================
WITH duplicate_keys  AS (
    SELECT
        clean_last_name,
        clean_first_name,
        gender_normalized,
        birthdate_normalized,
        email,
        COUNT(*) AS duplicate_count
    FROM salesforce_account_duplicate_snapshot
    WHERE 1 = 1 AND clean_last_name <> '' AND clean_first_name <> '' AND gender_normalized <> '' AND birthdate_normalized <> '' AND email <> ''
    GROUP BY clean_last_name, clean_first_name, gender_normalized, birthdate_normalized, email
    HAVING COUNT(*) > 1
)
SELECT '6.1 full exact duplicate record detail' AS query_label, t.*
FROM salesforce_account_duplicate_snapshot t
JOIN duplicate_keys dup 
	ON t.clean_last_name = dup.clean_last_name 
    AND t.clean_first_name = dup.clean_first_name
    AND t.gender_normalized = dup.gender_normalized 
    AND t.birthdate_normalized = dup.birthdate_normalized 
    AND t.email = dup.email
WHERE 1 = 1
	-- AND member_number = "" --  13
    -- AND member_number <> "" -- 7,346
ORDER BY t.clean_last_name, t.clean_first_name, t.birthdate_normalized, t.email;  -- 886

SELECT 'email population summary' AS query_label,
    COUNT(*) AS total_rows,
    SUM(email = '') AS email_blank,
    SUM(email <> '') AS email_populated,
    COUNT(DISTINCT email) AS distinct_emails
FROM salesforce_account_duplicate_snapshot;

SELECT 'email exact duplicate count validation' AS query_label, COUNT(*) AS groups_1, SUM(duplicate_count) AS records_in_groups
FROM (
    SELECT COUNT(*) AS duplicate_count
    FROM salesforce_account_duplicate_snapshot
    WHERE 1 = 1 AND clean_last_name <> '' AND clean_first_name <> '' AND gender_normalized <> '' AND birthdate_normalized <> '' AND email <> ''
    GROUP BY clean_last_name, clean_first_name, gender_normalized, birthdate_normalized, email
    HAVING COUNT(*) > 1
) g;

SELECT
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS row_num,
    email,
    FORMAT(COUNT(*), 0) AS count_of_records
FROM salesforce_account_duplicate_snapshot
GROUP BY email
-- HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC, email ASC;

SELECT
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS row_num,
    person_mailing_postal_code,
    FORMAT(COUNT(*), 0) AS count_of_records
FROM salesforce_account_duplicate_snapshot
GROUP BY person_mailing_postal_code
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC, person_mailing_postal_code ASC;