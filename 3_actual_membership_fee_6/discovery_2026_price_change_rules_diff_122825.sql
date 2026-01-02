-- 0) Make sure the join grain is actually unique (or you’ll create many-to-many explosions)
-- Run this once per table:
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT CONCAT_WS('#', id_membership_periods_sa, real_membership_types_sa, new_member_category_6_sa)) AS distinct_keys
FROM sales_key_stats_2015
;

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT CONCAT_WS('#', id_membership_periods_sa, real_membership_types_sa, new_member_category_6_sa)) AS distinct_keys
FROM sales_key_stats_2015_old_price_rules_v2
;

-- 1) Make the join keys indexed (composite, same order)
ALTER TABLE sales_key_stats_2015
  ADD INDEX idx_diff_key (id_membership_periods_sa, real_membership_types_sa, new_member_category_6_sa)
;

ALTER TABLE sales_key_stats_2015_old_price_rules_v2
  ADD INDEX idx_diff_key (id_membership_periods_sa, real_membership_types_sa, new_member_category_6_sa)
;

ALTER TABLE sales_key_stats_2015
  ADD INDEX idx_diff_cover (
    id_membership_periods_sa,
    real_membership_types_sa,
    new_member_category_6_sa,
    sales_units,
    sales_revenue,
    actual_membership_fee_6_rule_sa
  );

ALTER TABLE sales_key_stats_2015_old_price_rules_v2
  ADD INDEX idx_diff_cover (
    id_membership_periods_sa,
    real_membership_types_sa,
    new_member_category_6_sa,
    sales_units,
    sales_revenue,
    actual_membership_fee_6_rule_sa
  );


-- 1a) (if necessary) Make the join keys indexed (composite, same order)
-- ALTER TABLE sales_key_stats_2015
--   ADD INDEX idx_diff_key (id_membership_periods_sa)
-- ;

-- ALTER TABLE sales_key_stats_2015_old_price_rules_v2
--   ADD INDEX idx_diff_key (id_membership_periods_sa)
-- ;

-- A) Show BOTH versions of any mismatched row (first col = source table)
WITH
joined AS (
  SELECT
    a.id_membership_periods_sa,
    a.real_membership_types_sa,
    a.new_member_category_6_sa,

    a.sales_units   AS a_sales_units,
    b.sales_units   AS b_sales_units,

    a.sales_revenue AS a_sales_revenue,
    b.sales_revenue AS b_sales_revenue,

    a.actual_membership_fee_6_rule_sa AS a_rule,
    b.actual_membership_fee_6_rule_sa AS b_rule
  FROM sales_key_stats_2015_old_price_rules_v2 a
  JOIN sales_key_stats_2015 b
    ON  b.id_membership_periods_sa   = a.id_membership_periods_sa
    AND b.real_membership_types_sa   = a.real_membership_types_sa
    AND b.new_member_category_6_sa   = a.new_member_category_6_sa
),
diff_keys AS (
  SELECT *
  FROM joined
  WHERE
       NOT (a_sales_units   <=> b_sales_units)
    OR NOT (a_sales_revenue <=> b_sales_revenue)
    OR NOT (a_rule         <=> b_rule)
)
SELECT
  'old_price_rules_v2' AS source_table,
  id_membership_periods_sa,
  real_membership_types_sa,
  new_member_category_6_sa,
  a_sales_units   AS sales_units,
  a_sales_revenue AS sales_revenue,
  a_rule          AS actual_membership_fee_6_rule_sa
FROM diff_keys

UNION ALL

SELECT
  'current' AS source_table,
  id_membership_periods_sa,
  real_membership_types_sa,
  new_member_category_6_sa,
  b_sales_units   AS sales_units,
  b_sales_revenue AS sales_revenue,
  b_rule          AS actual_membership_fee_6_rule_sa
FROM diff_keys

ORDER BY
  id_membership_periods_sa,
  real_membership_types_sa,
  new_member_category_6_sa,
  source_table;

-- B) (Optional) One-row summary showing exactly what changed
-- This is handy if you want a compact “diff report”.
-- EXPLAIN
SELECT
  a.id_membership_periods_sa,
  a.real_membership_types_sa,
  a.new_member_category_6_sa,

  a.sales_units AS old_sales_units,
  b.sales_units AS new_sales_units,

  a.sales_revenue AS old_sales_revenue,
  b.sales_revenue AS new_sales_revenue,

  a.actual_membership_fee_6_rule_sa AS old_rule,
  b.actual_membership_fee_6_rule_sa AS new_rule,

  CONCAT_WS(', ',
    IF(NOT (a.sales_units   <=> b.sales_units),   'sales_units',   NULL),
    IF(NOT (a.sales_revenue <=> b.sales_revenue), 'sales_revenue', NULL),
    IF(NOT (a.actual_membership_fee_6_rule_sa <=> b.actual_membership_fee_6_rule_sa), 'rule', NULL)
  ) AS diff_fields
FROM sales_key_stats_2015_old_price_rules_v2 a
JOIN sales_key_stats_2015 b
  ON  b.id_membership_periods_sa = a.id_membership_periods_sa
  AND b.real_membership_types_sa = a.real_membership_types_sa
  AND b.new_member_category_6_sa = a.new_member_category_6_sa
WHERE
     NOT (a.sales_units   <=> b.sales_units)
  OR NOT (a.sales_revenue <=> b.sales_revenue)
  OR NOT (a.actual_membership_fee_6_rule_sa <=> b.actual_membership_fee_6_rule_sa)
ORDER BY a.id_membership_periods_sa, a.real_membership_types_sa, a.new_member_category_6_sa;

-- C) Don’t forget “missing keys” (rows in one table but not the other)
EXPLAIN
SELECT 'missing_in_current' AS issue, a.*
FROM sales_key_stats_2015_old_price_rules_v2 a
LEFT JOIN sales_key_stats_2015 b
  ON  b.id_membership_periods_sa = a.id_membership_periods_sa
  AND b.real_membership_types_sa = a.real_membership_types_sa
  AND b.new_member_category_6_sa = a.new_member_category_6_sa
WHERE b.id_membership_periods_sa IS NULL

UNION ALL

SELECT 'missing_in_old' AS issue, b.*
FROM sales_key_stats_2015 b
LEFT JOIN sales_key_stats_2015_old_price_rules_v2 a
  ON  a.id_membership_periods_sa = b.id_membership_periods_sa
  AND a.real_membership_types_sa = b.real_membership_types_sa
  AND a.new_member_category_6_sa = b.new_member_category_6_sa
WHERE a.id_membership_periods_sa IS NULL;



