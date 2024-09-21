USE usat_sales_db;
SET @member_category = '3-year';
SET @year_end = '2024';

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
    FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
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
    AND YEAR(ends_mp) IN (@year_end)
    AND MONTH(ends_mp) IN (1)
ORDER BY member_number_members_sa;

-- ==================================================
-- Query returns purchases by member number = 4,540 unique members for 2024
-- CTE to select members with an end date in 2024
WITH members_with_ends_in_2024 AS (
    SELECT 
        DISTINCT member_number_members_sa
    FROM all_membership_sales_data
    WHERE   
        new_member_category_6_sa IN (@member_category)  -- Filter by member category
        AND YEAR(ends_mp) = @year_end                         -- Only include members with end date in 2024
),

-- CTE to count purchases in 2024 for those members
purchases_in_2024 AS (
    SELECT
        mw.member_number_members_sa,
        COUNT(sa.purchased_on_mp) AS purchase_count,           -- Count of purchases for each member
        SUM(sa.actual_membership_fee_6_sa) AS total_revenue    -- Total revenue from purchases
    FROM members_with_ends_in_2024 AS mw
    LEFT JOIN all_membership_sales_data AS sa 
        ON mw.member_number_members_sa = sa.member_number_members_sa
        AND YEAR(sa.purchased_on_mp) = @year_end                     -- Filter for purchases made in 2024
    GROUP BY mw.member_number_members_sa                         -- Group by member number
)

-- Final selection of members and their purchase data
SELECT 
    mw.member_number_members_sa, 
    COALESCE(p.purchase_count, 0) AS purchase_count,           -- Replace NULL with 0 for members without purchases
    COALESCE(p.total_revenue, 0) AS total_revenue              -- Replace NULL with 0 for revenue
FROM members_with_ends_in_2024 AS mw
LEFT JOIN purchases_in_2024 AS p 
    ON mw.member_number_members_sa = p.member_number_members_sa  -- Join to get purchase data
ORDER BY mw.member_number_members_sa;                             -- Order by member number

-- ************************************************
-- Query returns a pivot of members by 2024 end date with a summary of the number of purchases made for each end month cohort
-- CTE to select members with an end date in 2024
	WITH members_with_ends_in_2024 AS (
		SELECT 
			DISTINCT member_number_members_sa,
			ends_mp  -- Include ends_mp for pivoting later
		FROM all_membership_sales_data
		WHERE   
			new_member_category_6_sa IN (@member_category)  -- Filter by member category
			AND YEAR(ends_mp) = @year_end                         -- Only include members with end date in 2024
	),

	-- CTE to count purchases in 2024 for those members
	purchases_in_2024 AS (
		SELECT
			mw.member_number_members_sa,
			mw.ends_mp,  -- Include ends_mp here as well
			COUNT(sa.purchased_on_mp) AS purchase_count,           -- Count of purchases for each member
			SUM(sa.actual_membership_fee_6_sa) AS total_revenue    -- Total revenue from purchases
		FROM members_with_ends_in_2024 AS mw
		LEFT JOIN all_membership_sales_data AS sa 
			ON mw.member_number_members_sa = sa.member_number_members_sa
			AND YEAR(sa.purchased_on_mp) = @year_end                -- Filter for purchases made in 2024
		GROUP BY mw.member_number_members_sa, mw.ends_mp            -- Group by member number and ends_mp
	)

    -- SELECT * FROM purchases_in_2024;

	-- Final selection and pivoting the results
	SELECT 
		purchase_count,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 1 THEN member_number_members_sa END) AS January,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 2 THEN member_number_members_sa END) AS February,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 3 THEN member_number_members_sa END) AS March,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 4 THEN member_number_members_sa END) AS April,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 5 THEN member_number_members_sa END) AS May,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 6 THEN member_number_members_sa END) AS June,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 7 THEN member_number_members_sa END) AS July,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 8 THEN member_number_members_sa END) AS August,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 9 THEN member_number_members_sa END) AS September,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 10 THEN member_number_members_sa END) AS October,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 11 THEN member_number_members_sa END) AS November,
		COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 12 THEN member_number_members_sa END) AS December,
		FORMAT(COUNT(DISTINCT member_number_members_sa), 0) AS member_count,
		FORMAT(SUM(total_revenue), 0) as total_revenue
	FROM purchases_in_2024
	GROUP BY purchase_count WITH ROLLUP
	ORDER BY purchase_count;  -- Order by purchase count

-- ?????????????????????????????????????????????????
-- ?????????????????????????????????????????????????
-- verify some sample data to ensure the purchase information in 2024 is correct
SELECT
    member_number_members_sa,
    id_membership_periods_sa,
    purchased_on_mp,
    starts_mp,
    ends_mp,
    real_membership_types_sa,
    new_member_category_6_sa
FROM all_membership_sales_data
-- 1003056983 = 0, 31444 = 0, 102401766 = 2, '123516892' = 1, '128065' = 1, '135463408' = 0
WHERE member_number_members_sa IN (31444, 102401766, 123516892, 128065, 135463408, 1003056983)
ORDER BY member_number_members_sa ASC; 

-- Query returns a pivot of members by 2024 end date with a summary of the number of purchases made for each end month cohort
-- CTE to select members with an end date in 2024
	WITH members_with_ends_in_2024 AS (
		SELECT 
            member_number_members_sa,
            id_membership_periods_sa,
            purchased_on_mp,
            starts_mp,
            ends_mp,
            real_membership_types_sa,
            new_member_category_6_sa
		FROM all_membership_sales_data
		WHERE   
			new_member_category_6_sa IN (@member_category)  -- Filter by member category
			AND YEAR(ends_mp) = @year_end                         -- Only include members with end date in 2024
	),

	-- CTE to count purchases in 2024 for those members
	purchases_in_2024 AS (
		SELECT
            mw.member_number_members_sa,
            sa.id_membership_periods_sa,
            sa.purchased_on_mp,
            sa.starts_mp,
            sa.ends_mp,
            sa.real_membership_types_sa,
            sa.new_member_category_6_sa
        FROM members_with_ends_in_2024 AS mw
		LEFT JOIN all_membership_sales_data AS sa ON mw.member_number_members_sa = sa.member_number_members_sa
			AND YEAR(sa.purchased_on_mp) = @year_end                     -- Filter for purchases made in 2024
		-- 1003056983 = 0, 31444 = 0, 102401766 = 2, '123516892' = 1, '128065' = 1, '135463408' = 0
		-- WHERE mw.member_number_members_sa IN (31444, 102401766, 123516892, 128065, 135463408, 1003056983)
	)

    SELECT * FROM purchases_in_2024; 

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Return the number of members by new_member_category_6_sa from the 2024 purchase by the 2024 end date
-- CTE to select members with an end date in 2024
-- CTE to select members with an end date in 2024
WITH members_with_ends_in_2024 AS (
    SELECT 
        DISTINCT member_number_members_sa,
        ends_mp  -- Include ends_mp for pivoting later
    FROM all_membership_sales_data
    WHERE   
        new_member_category_6_sa IN (@member_category)  -- Filter by member category
        AND YEAR(ends_mp) = @year_end                         -- Only include members with end date in 2024
),

-- CTE to count purchases in 2024 for those members and capture their category
purchases_in_2024 AS (
    SELECT
        mw.member_number_members_sa,
        sa.new_member_category_6_sa,  -- Use category from the purchases data
        mw.ends_mp,  -- Include ends_mp for pivoting later
        COUNT(sa.purchased_on_mp) AS purchase_count,           -- Count of purchases for each member
        SUM(sa.actual_membership_fee_6_sa) AS total_revenue    -- Total revenue from purchases
    FROM members_with_ends_in_2024 AS mw
    LEFT JOIN all_membership_sales_data AS sa 
        ON mw.member_number_members_sa = sa.member_number_members_sa
        AND YEAR(sa.purchased_on_mp) = @year_end                     -- Filter for purchases made in 2024
    GROUP BY mw.member_number_members_sa, sa.new_member_category_6_sa, mw.ends_mp  -- Group by member number, category, and ends_mp
)

-- Final selection and pivoting the results
SELECT 
    new_member_category_6_sa,  -- Category as the first column
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 1 THEN member_number_members_sa END) AS January,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 2 THEN member_number_members_sa END) AS February,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 3 THEN member_number_members_sa END) AS March,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 4 THEN member_number_members_sa END) AS April,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 5 THEN member_number_members_sa END) AS May,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 6 THEN member_number_members_sa END) AS June,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 7 THEN member_number_members_sa END) AS July,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 8 THEN member_number_members_sa END) AS August,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 9 THEN member_number_members_sa END) AS September,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 10 THEN member_number_members_sa END) AS October,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 11 THEN member_number_members_sa END) AS November,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 12 THEN member_number_members_sa END) AS December,
    COUNT(DISTINCT member_number_members_sa) AS member_count,
    FORMAT(SUM(total_revenue), 0) AS total_revenue
FROM purchases_in_2024
GROUP BY new_member_category_6_sa  -- Group by category and purchase count
ORDER BY member_count DESC;  -- Order by category and then purchase count

-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
-- CTE to select members with an end date in 2024
WITH members_with_ends_in_2024 AS (
    SELECT 
        DISTINCT member_number_members_sa,
        ends_mp  -- Include ends_mp for pivoting later
    FROM all_membership_sales_data
    WHERE   
        new_member_category_6_sa IN (@member_category)  -- Filter by member category
        AND YEAR(ends_mp) = @year_end                         -- Only include members with end date in 2024
),

-- CTE to count purchases in 2024 for those members and capture their category
purchases_in_2024 AS (
    SELECT
        mw.member_number_members_sa,
        sa.new_member_category_6_sa,  -- Use category from the purchases data
        mw.ends_mp,  -- Include ends_mp for pivoting later
        sa.purchased_on_mp,  -- Include purchased_on_mp for month difference calculation
        COUNT(sa.purchased_on_mp) AS purchase_count,           -- Count of purchases for each member
        SUM(sa.actual_membership_fee_6_sa) AS total_revenue    -- Total revenue from purchases
    FROM members_with_ends_in_2024 AS mw
    LEFT JOIN all_membership_sales_data AS sa 
        ON mw.member_number_members_sa = sa.member_number_members_sa
        AND YEAR(sa.purchased_on_mp) = @year_end                     -- Filter for purchases made in 2024
    GROUP BY mw.member_number_members_sa, sa.new_member_category_6_sa, mw.ends_mp, sa.purchased_on_mp  -- Group by member number, category, ends_mp, and purchased_on_mp
)

-- Final selection and pivoting the results
SELECT 
    -- TIMESTAMPDIFF(MONTH, purchased_on_mp, ends_mp) AS month_difference,  -- Calculate month difference
    ROUND(TIMESTAMPDIFF(DAY, purchased_on_mp, ends_mp) / 30, 0) as month_difference, -- Calculate month difference
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 1 THEN member_number_members_sa END) AS January,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 2 THEN member_number_members_sa END) AS February,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 3 THEN member_number_members_sa END) AS March,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 4 THEN member_number_members_sa END) AS April,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 5 THEN member_number_members_sa END) AS May,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 6 THEN member_number_members_sa END) AS June,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 7 THEN member_number_members_sa END) AS July,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 8 THEN member_number_members_sa END) AS August,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 9 THEN member_number_members_sa END) AS September,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 10 THEN member_number_members_sa END) AS October,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 11 THEN member_number_members_sa END) AS November,
    COUNT(DISTINCT CASE WHEN MONTH(ends_mp) = 12 THEN member_number_members_sa END) AS December,
    FORMAT(COUNT(DISTINCT member_number_members_sa), 0) AS member_count,
    FORMAT(SUM(total_revenue), 0) AS total_revenue
FROM purchases_in_2024
GROUP BY month_difference  -- Group by category, purchase count, and month difference
ORDER BY month_difference;  -- Order by category and then purchase count

-- #########################################################
-- CTE to select members with an end date in 2024
WITH members_with_ends_in_2024 AS (
    SELECT 
        DISTINCT member_number_members_sa,
        ends_mp  -- Include ends_mp for month difference calculation
    FROM all_membership_sales_data
    WHERE   
        new_member_category_6_sa IN (@member_category)  -- Filter by member category
        AND YEAR(ends_mp) = @year_end                         -- Only include members with end date in 2024
),

-- CTE to count purchases in 2024 for those members
purchases_in_2024 AS (
    SELECT
        mw.member_number_members_sa,
        mw.ends_mp,  -- Include ends_mp for verification
        MIN(sa.purchased_on_mp) AS purchased_on_mp,  -- Use MIN to avoid grouping issues
        COUNT(sa.purchased_on_mp) AS purchase_count,           -- Count of purchases for each member
        SUM(sa.actual_membership_fee_6_sa) AS total_revenue    -- Total revenue from purchases
    FROM members_with_ends_in_2024 AS mw
    LEFT JOIN all_membership_sales_data AS sa 
        ON mw.member_number_members_sa = sa.member_number_members_sa
        AND YEAR(sa.purchased_on_mp) = @year_end                     -- Filter for purchases made in 2024
    GROUP BY mw.member_number_members_sa, mw.ends_mp           -- Group by member number and ends_mp
)

-- Final selection of members and their purchase data
SELECT 
    mw.member_number_members_sa, 
    COALESCE(p.purchase_count, 0) AS purchase_count,           -- Replace NULL with 0 for members without purchases
    COALESCE(p.total_revenue, 0) AS total_revenue,            -- Replace NULL with 0 for revenue
    p.purchased_on_mp,  -- Include purchased_on_mp for verification
    mw.ends_mp,  -- Include ends_mp for verification
    -- Calculate the correct month difference
    -- TIMESTAMPDIFF(MONTH, p.purchased_on_mp, mw.ends_mp) AS month_difference  -- Calculate month difference
    ROUND(TIMESTAMPDIFF(DAY, p.purchased_on_mp, mw.ends_mp) / 30, 0) AS month_difference -- Calculate month difference
FROM members_with_ends_in_2024 AS mw
LEFT JOIN purchases_in_2024 AS p ON mw.member_number_members_sa = p.member_number_members_sa  -- Join to get purchase data
-- WHERE MONTH(mw.ends_mp) IN (12) AND TIMESTAMPDIFF(MONTH, p.purchased_on_mp, mw.ends_mp) < 3
WHERE MONTH(mw.ends_mp) IN (12) AND ROUND(TIMESTAMPDIFF(DAY, p.purchased_on_mp, mw.ends_mp) / 30, 0) < 3
ORDER BY mw.member_number_members_sa;                             -- Order by member number



