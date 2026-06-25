USE usat_sales_db;

-- =====================================================================
-- PHASE 3: one row per account, labeled with how SF and our tool compare
-- =====================================================================

-- STEP 1: "ours" = the accounts our tool flagged.
-- Our consolidated table stores a whole cluster on one row, with the account IDs
-- bunched together in Record_Ids__c like "001AAA;001BBB". JSON_TABLE splits that
-- list back into one row per account so we can compare account-by-account.
-- We also carry the cluster's signal flags (was it found by exact / fuzzy / nickname).
WITH ours AS (
  SELECT
    TRIM(jt.account_id)    AS account_id,   -- one account, pulled out of the list
    c.Has_Exact_Flag__c    AS has_exact,     -- did this cluster match on exact?
    c.Has_Fuzzy_Flag__c    AS has_fuzzy,     -- ...on fuzzy?
    c.Has_Nickname_Flag__c AS has_nick       -- ...on nickname?
  FROM salesforce_duplicate_consolidated_cluster c
  JOIN JSON_TABLE(
         CONCAT('["', REPLACE(c.Record_Ids__c, ';', '","'), '"]'),  -- list -> JSON array
         '$[*]' COLUMNS (account_id VARCHAR(20) PATH '$')             -- array -> rows
       ) jt ON TRUE
  WHERE c.Record_Ids__c IS NOT NULL AND c.Record_Ids__c <> ''
),

-- STEP 2: "sf" = the accounts Salesforce marked to merge (merge ID is filled in).
sf AS (
  SELECT salesforce_account_id AS account_id, salesforce_merge_id
  FROM salesforce_account_duplicate_snapshot
  WHERE salesforce_merge_id <> ''            -- only accounts that actually have a merge ID
),

-- STEP 3: build the labeled list, then number the rows.
review AS (
  -- 3a: start from OUR accounts and look for a matching SF merge ID.
  --   found a match  -> "in_both" (SF and we agree)
  --   no match       -> name it by WHICH list found it:
  --                     exact_only / fuzzy_only / nickname_only, or
  --                     multi_signal if the cluster matched on more than one.
  SELECT
    o.account_id,
    CASE
      WHEN s.account_id IS NOT NULL THEN 'in_both'
      -- count how many signals are "on", then name the bucket
      WHEN ( (LOWER(o.has_exact) IN ('true','1','yes','y'))
           + (LOWER(o.has_fuzzy) IN ('true','1','yes','y'))
           + (LOWER(o.has_nick ) IN ('true','1','yes','y')) ) > 1 THEN 'multi_signal'
      WHEN LOWER(o.has_exact) IN ('true','1','yes','y') THEN 'exact_only'
      WHEN LOWER(o.has_fuzzy) IN ('true','1','yes','y') THEN 'fuzzy_only'
      WHEN LOWER(o.has_nick ) IN ('true','1','yes','y') THEN 'nickname_only'
      ELSE 'ours_unknown'   -- in our list but no signal flag (shouldn't normally happen)
    END AS bucket,
    s.salesforce_merge_id,
    -- which_list = the exact signal mix (e.g. "exact" or "fuzzy,nickname")
    NULLIF(CONCAT_WS(',',
      CASE WHEN LOWER(o.has_exact) IN ('true','1','yes','y') THEN 'exact'    END,
      CASE WHEN LOWER(o.has_fuzzy) IN ('true','1','yes','y') THEN 'fuzzy'    END,
      CASE WHEN LOWER(o.has_nick ) IN ('true','1','yes','y') THEN 'nickname' END
    ), '') AS which_list
  FROM ours o
  LEFT JOIN sf s ON s.account_id = o.account_id
  WHERE o.account_id <> ''

  UNION ALL

  -- 3b: add the SF accounts we did NOT flag.
  --   "sf_only" (SF marked it to merge, but it's missing from our list)
  SELECT
    s.account_id,
    'sf_only'  AS bucket,
    s.salesforce_merge_id,
    NULL       AS which_list                  -- not in our list, so no signal
  FROM sf s
  LEFT JOIN ours o ON o.account_id = s.account_id
  WHERE o.account_id IS NULL                  -- keep only the ones with no match on our side
)

-- STEP 4: number every row (1, 2, 3, ...) so it's easy to reference.
SELECT
  ROW_NUMBER() OVER (ORDER BY bucket, account_id) AS row_num,  -- the row number
  account_id,
  bucket,
  salesforce_merge_id,
  which_list
FROM review
ORDER BY row_num;