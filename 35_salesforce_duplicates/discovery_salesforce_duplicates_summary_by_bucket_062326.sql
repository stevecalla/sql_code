USE usat_sales_db;

-- =====================================================================
-- PHASE 4a: how many ACCOUNTS in each bucket (+ a TOTAL row)
-- =====================================================================

-- Same building blocks as Phase 3:
--   ours = accounts we flagged (clusters split into one row per account),
--          carrying the signal flags so we can name the bucket.
WITH ours AS (
  SELECT DISTINCT
    TRIM(jt.account_id)    AS account_id,   -- DISTINCT so we count each account once
    c.Has_Exact_Flag__c    AS has_exact,
    c.Has_Fuzzy_Flag__c    AS has_fuzzy,
    c.Has_Nickname_Flag__c AS has_nick
  FROM salesforce_duplicate_consolidated_cluster c
  JOIN JSON_TABLE(
         CONCAT('["', REPLACE(c.Record_Ids__c, ';', '","'), '"]'),
         '$[*]' COLUMNS (account_id VARCHAR(20) PATH '$')
       ) jt ON TRUE
  WHERE c.Record_Ids__c IS NOT NULL AND c.Record_Ids__c <> ''
),
--   sf = accounts Salesforce marked to merge
sf AS (
  SELECT salesforce_account_id AS account_id
  FROM salesforce_account_duplicate_snapshot
  WHERE salesforce_merge_id <> ''
),
-- review = every account labeled with its bucket (same names as Phase 3)
review AS (
  SELECT
    o.account_id,
    CASE
      WHEN s.account_id IS NOT NULL THEN 'in_both'
      WHEN ( (LOWER(o.has_exact) IN ('true','1','yes','y'))
           + (LOWER(o.has_fuzzy) IN ('true','1','yes','y'))
           + (LOWER(o.has_nick ) IN ('true','1','yes','y')) ) > 1 THEN 'multi_signal'
      WHEN LOWER(o.has_exact) IN ('true','1','yes','y') THEN 'exact_only'
      WHEN LOWER(o.has_fuzzy) IN ('true','1','yes','y') THEN 'fuzzy_only'
      WHEN LOWER(o.has_nick ) IN ('true','1','yes','y') THEN 'nickname_only'
      ELSE 'ours_unknown'
    END AS bucket
  FROM ours o LEFT JOIN sf s ON s.account_id = o.account_id
  WHERE o.account_id <> ''
  UNION ALL
  SELECT s.account_id, 'sf_only'
  FROM sf s LEFT JOIN ours o ON o.account_id = s.account_id
  WHERE o.account_id IS NULL
)
-- count each bucket; WITH ROLLUP appends a grand-total row (bucket = NULL -> "TOTAL")
SELECT
  COALESCE(bucket, 'TOTAL')  AS bucket,
  FORMAT(COUNT(*), 0)        AS accounts
FROM review
GROUP BY bucket WITH ROLLUP
ORDER BY
  GROUPING(bucket),   -- the TOTAL row (grouping = 1) sorts to the bottom
  FIELD(bucket, 'in_both', 'exact_only', 'fuzzy_only', 'nickname_only',
               'multi_signal', 'ours_unknown', 'sf_only');