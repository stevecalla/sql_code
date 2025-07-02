USE usat_sales_db;

-- **************
-- Step 3: Step-by-Step Dynamic Pivot to Columns in MySQL 8.0+
 -- *************

 -- Step 1: Create the dynamic column list
SET SESSION group_concat_max_len = 1000000;

SELECT
  GROUP_CONCAT(
    DISTINCT CONCAT(
      'SUM(CASE WHEN real_membership_types_sa = ''',
      real_membership_types_sa,
      ''' AND new_member_category_6_sa = ''',
      new_member_category_6_sa,
      ''' THEN monthly_revenue ELSE 0 END) AS `',
      REPLACE(CONCAT(real_membership_types_sa, ' - ', new_member_category_6_sa), ' ', '_'), '`'
    )
  ) INTO @pivot_columns
FROM rev_recognition_allocation_data;

-- Step 2: Build the full SQL statement
SET @sql = CONCAT(
  'SELECT revenue_month, ',
  @pivot_columns,
  ' FROM rev_recognition_allocation_data ',
  'GROUP BY revenue_month ',
  'ORDER BY revenue_month;'
);

-- Step 3: Prepare and execute the statement
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
