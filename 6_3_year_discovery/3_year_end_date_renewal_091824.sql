USE usat_sales_db;
SET @member_category = '3-year';

-- #1) QUERY SHOWS MEMBERSHIP END PERIOD COUNT BY YEAR OF END DATE
SELECT 
	YEAR(ends_mp),
    FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
    FORMAT(COUNT(*), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
FROM all_membership_sales_data
WHERE new_member_category_6_sa IN (@member_category)
GROUP BY YEAR(ends_mp) WITH ROLLUP
ORDER BY YEAR(ends_mp);

-- #2) QUERY SHOWS MEMBERSHIP END PERIOD COUNT BY YEAR, QUAARTER, MONTH OF END DATE
SELECT 
	YEAR(ends_mp),
    QUARTER(ends_mp),
    MONTH(ends_mp),
    FORMAT(COUNT(*), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
FROM all_membership_sales_data
WHERE new_member_category_6_sa IN (@member_category)
GROUP BY YEAR(ends_mp), QUARTER(ends_mp), MONTH(ends_mp) WITH ROLLUP
ORDER BY YEAR(ends_mp), QUARTER(ends_mp), MONTH(ends_mp);

-- #3) MEMBERS WITH END DATE IN JAN 2024
SELECT 
    member_number_members_sa
FROM all_membership_sales_data
WHERE   
    new_member_category_6_sa IN (@member_category)
    AND YEAR(ends_mp) IN (2024)
    AND MONTH(ends_mp) IN (1)
ORDER BY member_number_members_sa;

-- CTE = MEMBERS WITH 3-YEAR PURCHASE WITH END PERIOD IN JANUARY 2024
WITH members_ends_period_jan_2024 AS (
    SELECT 
        member_number_members_sa
    FROM all_membership_sales_data
    WHERE   
        new_member_category_6_sa IN (@member_category)
        AND
        YEAR(ends_mp) IN (2024)
        AND
        MONTH(ends_mp) IN (1)
    ORDER BY member_number_members_sa
)

-- SELECT * FROM members_ends_period_jan_2024

-- QUERY = 3-YEAR MEMBERS WITH END > JAN 2024 WITH 
-- SELECT
--     sa.member_number_members_sa,
--     sa.id_membership_periods_sa,
--     sa.real_membership_types_sa,
--     sa.new_member_category_6_sa,
--     sa.purchased_on_mp,
--     sa.starts_mp,
--     sa.ends_mp
-- FROM all_membership_sales_data AS sa
--     JOIN members_ends_period_jan_2024 AS me ON sa.member_number_members_sa = me.member_number_members_sa
-- WHERE YEAR(sa.ends_mp) > 2023
-- ORDER BY 
--     sa.member_number_members_sa,
--     sa.ends_mp;

,
purchases AS (
    SELECT
        sa.member_number_members_sa,
        sa.id_membership_periods_sa,
        sa.real_membership_types_sa,
        sa.new_member_category_6_sa,
        sa.purchased_on_mp,
        sa.starts_mp,
        sa.ends_mp
    FROM all_membership_sales_data AS sa
        JOIN members_ends_period_jan_2024 AS me ON sa.member_number_members_sa = me.member_number_members_sa
    WHERE YEAR(sa.ends_mp) > 2023
    ORDER BY 
        sa.member_number_members_sa,
        sa.ends_mp
)

SELECT 
    COUNT(DISTINCT(member_number_members_sa)),
    COUNT(*)
FROM purchases;

-- CTE = 3-YEAR ENDS JANUARY 2024 BY MEMBER NUMBER OF PURCHASES
WITH members_ends_period_jan_2024 AS (
    SELECT 
        member_number_members_sa
    FROM 
        all_membership_sales_data
    WHERE   
        new_member_category_6_sa IN (@member_category)
        AND YEAR(ends_mp) = 2024
        AND MONTH(ends_mp) = 1
),

-- CTE = SELECTING PURCHASES AFTER JANUARY 2024
purchases AS (
    SELECT
        sa.member_number_members_sa,
        sa.id_membership_periods_sa,
        sa.real_membership_types_sa,
        sa.new_member_category_6_sa,
        sa.purchased_on_mp,
        sa.starts_mp,
        sa.ends_mp
    FROM all_membership_sales_data AS sa
		JOIN members_ends_period_jan_2024 AS me ON sa.member_number_members_sa = me.member_number_members_sa
    WHERE YEAR(sa.ends_mp) > 2023
)

-- BUCKETING BY NUMBER OF PURCHASES
SELECT 
    member_number_members_sa,
    COUNT(*) AS number_of_purchases
FROM purchases
GROUP BY member_number_members_sa WITH ROLLUP
ORDER BY number_of_purchases DESC;

-- CTE = MEMBERS WITH 3-YEAR PURCHASE WITH END PERIOD IN JANUARY 2024
WITH members_ends_period_2024 AS (
    SELECT 
		DISTINCT
        member_number_members_sa,
        ends_mp
    FROM all_membership_sales_data
    WHERE   
        new_member_category_6_sa IN (@member_category)
        AND YEAR(ends_mp) = 2024
        -- AND MONTH(ends_mp) = 1
        AND MONTH(ends_mp) < 13
)

-- SELECT * FROM members_ends_period_2024; -- 4,547
,
-- -- CTE = SELECTING PURCHASES AFTER 2023s
purchases AS (
    SELECT
        sa.member_number_members_sa,
        MIN(sa.ends_mp) AS min_ends_mp, -- first/min ends period date should be 2023
        COUNT(sa.ends_mp) AS purchases
    FROM all_membership_sales_data AS sa
		JOIN members_ends_period_2024 AS me ON sa.member_number_members_sa = me.member_number_members_sa
    WHERE YEAR(sa.ends_mp) > 2023
    GROUP BY sa.member_number_members_sa
)

-- SELECT * FROM purchases;
-- SELECT MONTH(min_ends_mp), COUNT(*) FROM purchases GROUP BY MONTH(min_ends_mp) WITH ROLLUP;

-- COUNTING NUMBER OF PURCHASES PER MEMBER
, purchase_counts AS (
    SELECT 
        member_number_members_sa,
        MONTH(min_ends_mp) AS min_ends_mp,
        SUM(purchases) AS number_of_purchases
    FROM purchases
    GROUP BY member_number_members_sa, MONTH(min_ends_mp)
    ORDER BY member_number_members_sa, MONTH(min_ends_mp)
)

-- SELECT * FROM purchase_counts;
-- COUNTING HOW MANY MEMBERS HAD A SPECIFIC NUMBER OF PURCHASES
SELECT 
    number_of_purchases,
    SUM(CASE WHEN min_ends_mp = 1 THEN 1 ELSE 0 END) AS jan,
    SUM(CASE WHEN min_ends_mp = 2 THEN 1 ELSE 0 END) AS feb,
    SUM(CASE WHEN min_ends_mp = 3 THEN 1 ELSE 0 END) AS mar,
    SUM(CASE WHEN min_ends_mp = 4 THEN 1 ELSE 0 END) AS apr,
    SUM(CASE WHEN min_ends_mp = 5 THEN 1 ELSE 0 END) AS may,
    SUM(CASE WHEN min_ends_mp = 6 THEN 1 ELSE 0 END) AS jun,
    SUM(CASE WHEN min_ends_mp = 7 THEN 1 ELSE 0 END) AS jul,
    SUM(CASE WHEN min_ends_mp = 8 THEN 1 ELSE 0 END) AS aug,
    SUM(CASE WHEN min_ends_mp = 9 THEN 1 ELSE 0 END) AS sep,
    SUM(CASE WHEN min_ends_mp = 10 THEN 1 ELSE 0 END) AS oct,
    SUM(CASE WHEN min_ends_mp = 11 THEN 1 ELSE 0 END) AS nov,
    SUM(CASE WHEN min_ends_mp = 12 THEN 1 ELSE 0 END) AS dec_12,
    COUNT(DISTINCT(member_number_members_sa)) AS member_count,
    SUM(number_of_purchases) AS purchase_count
FROM purchase_counts
GROUP BY number_of_purchases WITH ROLLUP
ORDER BY number_of_purchases;