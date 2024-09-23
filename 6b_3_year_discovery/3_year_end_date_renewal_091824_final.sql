USE usat_sales_db;
SET @member_category = '3-year';
SET @year_1 = 2023;
SET @year_2 = 2024;

-- #1) SECTION: STATS = TOTALS
    SELECT 
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE new_member_category_6_sa IN (@member_category);
-- ==================================================

-- #2) SECTION: STATS = BY MEMBER
    SELECT 
        DISTINCT member_number_members_sa,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE new_member_category_6_sa IN (@member_category)
    GROUP BY member_number_members_sa
    ORDER BY CAST(member_number_members_sa AS UNSIGNED);
-- ++++++++++++++++++++++++++++++++++++++++++++++++++

-- #3) SECTION: STATS = BY MEMBERSHIP END PERIOD DATE = YEAR
    SELECT 
        YEAR(ends_mp),
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE new_member_category_6_sa IN (@member_category)
    GROUP BY YEAR(ends_mp) WITH ROLLUP
    ORDER BY YEAR(ends_mp);
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- #4) SECTION: STATS = BY MEMBERSHIP END PERIOD DATE = YEAR, QUAARTER, MONTH
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
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- #5) SECTION: STATS = BY MEMBERS, END DATE IN JAN 2024 = 117
    SELECT 
        member_number_members_sa,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(*), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
    FROM all_membership_sales_data
    WHERE   
        new_member_category_6_sa IN (@member_category)
        AND YEAR(ends_mp) IN (@year_2024)
        AND MONTH(ends_mp) IN (1)
	GROUP BY member_number_members_sa
    ORDER BY CAST(member_number_members_sa AS UNSIGNED);
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- #6) SECTION: STATS = BY MEMBERS, END DATE IN 2024 = 4,540 UNIQUE
    -- CTE to select members with an end date in 2024
    WITH members_with_ends_in_2024 AS (
        SELECT 
            DISTINCT member_number_members_sa
        FROM all_membership_sales_data
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND YEAR(ends_mp) = @year_2024                         -- Only include members with end date in 2024
    ),

    -- CTE to count purchases in 2024 for those members
    purchases_in_2023_2024 AS (
        SELECT
            mw.member_number_members_sa,
            COUNT(sa.purchased_on_mp) AS sales_units,           -- Count of purchases for each member
            SUM(sa.actual_membership_fee_6_sa) AS sales_revenue    -- Total revenue from purchases
        FROM members_with_ends_in_2024 AS mw
        LEFT JOIN all_membership_sales_data AS sa 
            ON mw.member_number_members_sa = sa.member_number_members_sa
            -- AND YEAR(sa.purchased_on_mp) IN (@year_2024)         -- Filter for purchases made in 2024
            AND YEAR(sa.purchased_on_mp) IN (@year_1, @year_2)       -- Filter for purchases made in 2023 & 2024
        GROUP BY mw.member_number_members_sa                         -- Group by member number
    )

    -- Final selection of members and their purchase data
    SELECT 
        mw.member_number_members_sa, 
        FORMAT(COUNT(DISTINCT(mw.member_number_members_sa)), 0) AS member_count,
        FORMAT(COALESCE(p.sales_units, 0), 0) AS sales_units,           -- Replace NULL with 0 for members without purchases
        FORMAT(COALESCE(p.sales_revenue, 0), 0) AS sales_revenue              -- Replace NULL with 0 for revenue
    FROM members_with_ends_in_2024 AS mw
    LEFT JOIN purchases_in_2023_2024 AS p 
        ON mw.member_number_members_sa = p.member_number_members_sa  -- Join to get purchase data
    GROUP BY mw.member_number_members_sa                         -- Group by member number
    ORDER BY CAST(mw.member_number_members_sa AS UNSIGNED);                           -- Order by member number
-- ##################################################

-- #7) SECTION: ROLLUP = MEMBERS BY SALES UNITS BY END MONTH
    -- Query returns a pivot of members by 2024 end date with a summary of the number of purchases made for each end month cohort
    -- CTE to select members with an end date in 2024
	WITH members_with_ends_in_2024 AS (
		SELECT 
			DISTINCT member_number_members_sa,
			ends_mp  -- Include     ends_mp for pivoting later
		FROM all_membership_sales_data
		WHERE   
			new_member_category_6_sa IN (@member_category)  -- Filter by member category
			AND YEAR(ends_mp) = @year_2024                         -- Only include members with end date in 2024
	),

	-- CTE to count purchases in 2024 for those members
	purchases_in_2023_2024 AS (
		SELECT
			mw.member_number_members_sa,
			mw.ends_mp,  -- Include ends_mp here as well
			COUNT(sa.purchased_on_mp) AS sales_units,           -- Count of purchases for each member
			SUM(sa.actual_membership_fee_6_sa) AS sales_revenue    -- Total revenue from purchases
		FROM members_with_ends_in_2024 AS mw
		LEFT JOIN all_membership_sales_data AS sa 
			ON mw.member_number_members_sa = sa.member_number_members_sa
			-- AND YEAR(sa.purchased_on_mp) IN (@year_2023)         -- Filter for purchases made in 2024
			-- AND YEAR(sa.purchased_on_mp) IN (@year_2024)         -- Filter for purchases made in 2024
			AND YEAR(sa.purchased_on_mp) IN (@year_1, @year_2)       -- Filter for purchases made in 2023 & 2024
		GROUP BY mw.member_number_members_sa, mw.ends_mp            -- Group by member number and ends_mp
	)

    -- SELECT * FROM purchases_in_2023_2024;

	-- Final selection and pivoting the results
	SELECT 
		sales_units,
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
		FORMAT(SUM(sales_revenue), 0) as sales_revenue
	FROM purchases_in_2023_2024
	GROUP BY sales_units WITH ROLLUP
	ORDER BY sales_units;  -- Order by purchase count
-- ??????????????????????????????????????????????????

-- #8) SECTION: VERIFY = SAMPLE SALES BY MEMBER
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
    ORDER BY CAST(member_number_members_sa AS UNSIGNED);
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- #9) SECTION: VERIFY = ALL SALES BY MEMBER
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
			AND YEAR(ends_mp) = @year_2024                         -- Only include members with end date in 2024
	),

	-- CTE to count purchases in 2024 for those members
	purchases_in_2023_2024 AS (
		SELECT
            mw.member_number_members_sa,
            sa.id_membership_periods_sa,
            sa.purchased_on_mp,
            sa.starts_mp,
            sa.ends_mp,
            sa.real_membership_types_sa,
            sa.new_member_category_6_sa
        FROM members_with_ends_in_2024 AS mw
		LEFT JOIN all_membership_sales_data AS sa 
            ON mw.member_number_members_sa = sa.member_number_members_sa
			-- AND YEAR(sa.purchased_on_mp) IN (@year_2024)         -- Filter for purchases made in 2024
			AND YEAR(sa.purchased_on_mp) IN (@year_1, @year_2)       -- Filter for purchases made in 2023 & 2024
		-- 1003056983 = 0, 31444 = 0, 102401766 = 2, '123516892' = 1, '128065' = 1, '135463408' = 0
		-- WHERE mw.member_number_members_sa IN (31444, 102401766, 123516892, 128065, 135463408, 1003056983)
	)

    SELECT * FROM purchases_in_2023_2024; 
-- ))))))))))))))))))))))))))))))))))))))))))))))))))

-- #10) SECTION: ROLLUP = MEMBERS BY NEW MEMBER CATEGORY BY END MONTH
    WITH members_with_ends_in_2024 AS (
        SELECT 
            DISTINCT member_number_members_sa,
            ends_mp  -- Include ends_mp for pivoting later
        FROM all_membership_sales_data
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND YEAR(ends_mp) = @year_2024                         -- Only include members with end date in 2024
    ),

    -- CTE to count purchases in 2024 for those members and capture their category
    purchases_in_2023_2024 AS (
        SELECT
            mw.member_number_members_sa,
            sa.new_member_category_6_sa,  -- Use category from the purchases data
            mw.ends_mp,  -- Include ends_mp for pivoting later
            COUNT(sa.purchased_on_mp) AS sales_units,           -- Count of purchases for each member
            SUM(sa.actual_membership_fee_6_sa) AS sales_revenue    -- Total revenue from purchases
        FROM members_with_ends_in_2024 AS mw
        LEFT JOIN all_membership_sales_data AS sa 
            ON mw.member_number_members_sa = sa.member_number_members_sa
            -- AND YEAR(sa.purchased_on_mp) IN (@year_2024)         -- Filter for purchases made in 2024
            AND YEAR(sa.purchased_on_mp) IN (@year_1, @year_2)       -- Filter for purchases made in 2023 & 2024
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
        FORMAT(SUM(sales_revenue), 0) AS sales_revenue
    FROM purchases_in_2023_2024
    GROUP BY new_member_category_6_sa  -- Group by category and purchase count
    ORDER BY new_member_category_6_sa -- Order by product
    -- ORDER BY member_count DESC;  -- Order by category and then purchase count
-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

-- #11) SECTION: ROLLUP = MEMBERS BY 2023/2024 PURCHASE VS 3-YEAR END
    WITH members_with_ends_in_2024 AS (
        SELECT 
            DISTINCT member_number_members_sa,
            ends_mp  -- Include ends_mp for pivoting later
        FROM all_membership_sales_data
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND YEAR(ends_mp) = @year_2024                         -- Only include members with end date in 2024
    ),

    -- CTE to count purchases in 2024 for those members and capture their category
    purchases_in_2023_2024 AS (
        SELECT
            mw.member_number_members_sa,
            sa.new_member_category_6_sa,  -- Use category from the purchases data
            mw.ends_mp,  -- Include ends_mp for pivoting later
            sa.purchased_on_mp,  -- Include purchased_on_mp for month difference calculation
            COUNT(sa.purchased_on_mp) AS sales_units,           -- Count of purchases for each member
            SUM(sa.actual_membership_fee_6_sa) AS sales_revenue    -- Total revenue from purchases
        FROM members_with_ends_in_2024 AS mw
        LEFT JOIN all_membership_sales_data AS sa 
            ON mw.member_number_members_sa = sa.member_number_members_sa
            -- AND YEAR(sa.purchased_on_mp) IN (@year_2024)         -- Filter for purchases made in 2024
            AND YEAR(sa.purchased_on_mp) IN (@year_1, @year_2)       -- Filter for purchases made in 2023 & 2024
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
        FORMAT(SUM(sales_revenue), 0) AS sales_revenue
    FROM purchases_in_2023_2024
    GROUP BY month_difference  -- Group by category, purchase count, and month difference
    ORDER BY month_difference;  -- Order by category and then purchase count
-- ##################################################

-- #12) SECTION: VERIFY = SAMPLE 2023/2024 PURCHASE VS 2024 3-YEAR END
    WITH members_with_ends_in_2024 AS (
        SELECT 
            DISTINCT member_number_members_sa,
            ends_mp  -- Include ends_mp for month difference calculation
        FROM all_membership_sales_data
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND YEAR(ends_mp) = @year_2024                         -- Only include members with end date in 2024
    ),

    -- CTE to count purchases in 2024 for those members
    purchases_in_2023_2024 AS (
        SELECT
            mw.member_number_members_sa,
            mw.ends_mp,  -- Include ends_mp for verification
            MIN(sa.purchased_on_mp) AS purchased_on_mp,  -- Use MIN to avoid grouping issues
            COUNT(sa.purchased_on_mp) AS sales_units,           -- Count of purchases for each member
            SUM(sa.actual_membership_fee_6_sa) AS sales_revenue    -- Total revenue from purchases
        FROM members_with_ends_in_2024 AS mw
        LEFT JOIN all_membership_sales_data AS sa 
            ON mw.member_number_members_sa = sa.member_number_members_sa
            -- AND YEAR(sa.purchased_on_mp) IN (@year_2024)         -- Filter for purchases made in 2024
            AND YEAR(sa.purchased_on_mp) IN (@year_1, @year_2)       -- Filter for purchases made in 2023 & 2024
        GROUP BY mw.member_number_members_sa, mw.ends_mp           -- Group by member number and ends_mp
    )

    -- Final selection of members and their purchase data
    SELECT 
        mw.member_number_members_sa, 
        COALESCE(p.sales_units, 0) AS sales_units,           -- Replace NULL with 0 for members without purchases
        COALESCE(p.sales_revenue, 0) AS sales_revenue,            -- Replace NULL with 0 for revenue
        p.purchased_on_mp,  -- Include purchased_on_mp for verification
        mw.ends_mp,  -- Include ends_mp for verification
        -- Calculate the correct month difference
        -- TIMESTAMPDIFF(MONTH, p.purchased_on_mp, mw.ends_mp) AS month_difference  -- Calculate month difference
        ROUND(TIMESTAMPDIFF(DAY, p.purchased_on_mp, mw.ends_mp) / 30, 0) AS month_difference -- Calculate month difference
    FROM members_with_ends_in_2024 AS mw
    LEFT JOIN purchases_in_2023_2024 AS p ON mw.member_number_members_sa = p.member_number_members_sa  -- Join to get purchase data
    -- WHERE MONTH(mw.ends_mp) IN (12) AND TIMESTAMPDIFF(MONTH, p.purchased_on_mp, mw.ends_mp) < 3
    WHERE MONTH(mw.ends_mp) IN (12) AND ROUND(TIMESTAMPDIFF(DAY, p.purchased_on_mp, mw.ends_mp) / 30, 0) < 3
    ORDER BY CAST(mw.member_number_members_sa AS UNSIGNED);                             -- Order by member number
-- ##################################################

-- #14) SECTION: ROLLUP = MEMBERS BY MAX END PERIOD BY 2024 3-YEAR END
    WITH members_with_ends_in_2024 AS (
        SELECT 
            DISTINCT member_number_members_sa,
            ends_mp  -- Include ends_mp for pivoting later
        FROM all_membership_sales_data
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND YEAR(ends_mp) = @year_2024                         -- Only include members with end date in 2024
    ),

    -- CTE to count purchases in 2024 for those members and capture their category
    purchases_in_all_years AS (
        SELECT
            mw.member_number_members_sa,
            mw.ends_mp,  -- Include ends_mp for pivoting later
            max(sa.ends_mp) AS max_ends_mp,
            COUNT(sa.purchased_on_mp) AS sales_units,           -- Count of purchases for each member
            SUM(sa.actual_membership_fee_6_sa) AS sales_revenue    -- Total revenue from purchases
        FROM members_with_ends_in_2024 AS mw
        LEFT JOIN all_membership_sales_data AS sa 
            ON mw.member_number_members_sa = sa.member_number_members_sa
        GROUP BY mw.member_number_members_sa, mw.ends_mp  -- Group by member number, category, ends_mp, and purchased_on_mp
    )

    -- VERIFY SAMPLE OF RESULTS
    -- SELECT 
    --     * 
    -- FROM purchases_in_all_years
    -- WHERE member_number_members_sa IN (362537495, 2100434783, 2100346362)
    -- -- ORDER BY CAST(member_number_members_sa AS UNSIGNED), ends_mp, max_ends_mp;
    -- ORDER BY CAST(member_number_members_sa AS UNSIGNED), max_ends_mp;

    -- -- Final selection and pivoting the results
    SELECT 
        YEAR(max_ends_mp) AS max_year_ends_mp,
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
        FORMAT(SUM(sales_revenue), 0) AS sales_revenue
    FROM purchases_in_all_years
    GROUP BY max_year_ends_mp WITH ROLLUP -- Group by YEAR / MONTH
    ORDER BY max_year_ends_mp;  -- Order by YEAR
-- ##################################################

-- #15) SECTION: VERIFY = SAMPLE 2023/2024 PURCHASE VS 2024 3-YEAR END
    SELECT 
        member_number_members_sa,
        id_membership_periods_sa,
        real_membership_types_sa,
        new_member_category_6_sa
        purchased_on_mp,
        starts_mp,
        ends_mp
    FROM all_membership_sales_data
    WHERE member_number_members_sa IN (362537495, 2100434783, 2100346362)
    ORDER BY CAST(member_number_members_sa AS UNSIGNED);

    -- SAMPLE
    -- # member_number_members_sa	new_member_category_6_sa	ends_mp	max_ends_mp	sales_units	sales_revenue
    -- 2100434783	1-Year $50	2024-11-28	2022-01-01	1	50.00
    -- 2100346362	1-Year $50	2024-12-22	2022-01-06	1	50.00
    -- 2100425236	One Day - $15	2024-06-01	2022-01-09	1	15.00
    -- 2100150941	1-Year $50	2024-08-09	2022-01-12	1	50.00
    -- 546378018	1-Year $50	2024-12-30	2022-01-21	1	50.00
    -- 1910266010	1-Year $50	2024-12-10	2022-01-21	1	50.00
-- ##################################################

-- #16) SECTION: ROLLUP = MEMBERS BY MAX END PERIOD YEAR MONTH BY 2024 3-YEAR END
    WITH members_with_ends_in_2024 AS (
        SELECT 
            DISTINCT member_number_members_sa,
            ends_mp  -- Include ends_mp for pivoting later
        FROM all_membership_sales_data
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND YEAR(ends_mp) = @year_2024                         -- Only include members with end date in 2024
    ),

    -- CTE to count purchases in 2024 for those members and capture their category
    purchases_in_all_years AS (
        SELECT
            mw.member_number_members_sa,
            mw.ends_mp,  -- Include ends_mp for pivoting later
            max(sa.ends_mp) AS max_ends_mp,
            COUNT(sa.purchased_on_mp) AS sales_units,           -- Count of purchases for each member
            SUM(sa.actual_membership_fee_6_sa) AS sales_revenue    -- Total revenue from purchases
        FROM members_with_ends_in_2024 AS mw
        LEFT JOIN all_membership_sales_data AS sa 
            ON mw.member_number_members_sa = sa.member_number_members_sa
        GROUP BY mw.member_number_members_sa, mw.ends_mp  -- Group by member number, category, ends_mp, and purchased_on_mp
    )

    -- VERIFY SAMPLE OF RESULTS
    -- SELECT 
    --     * 
    -- FROM purchases_in_all_years
    -- WHERE member_number_members_sa IN (362537495, 2100434783, 2100346362)
    -- -- ORDER BY CAST(member_number_members_sa AS UNSIGNED), ends_mp, max_ends_mp;
    -- ORDER BY CAST(member_number_members_sa AS UNSIGNED), max_ends_mp;

    -- -- Final selection and pivoting the results
    SELECT 
        YEAR(max_ends_mp) AS max_year_ends_mp,
        MONTH(max_ends_mp) AS max_month_ends_mp,
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
        FORMAT(SUM(sales_revenue), 0) AS sales_revenue
    FROM purchases_in_all_years
    GROUP BY max_year_ends_mp, max_month_ends_mp WITH ROLLUP -- Group by YEAR / MONTH
    ORDER BY max_year_ends_mp, max_month_ends_mp;  -- Order by YEAR
-- ##################################################

-- #17) SECTION: ROLLUP = WHAT PRODUCT IS MAX END PRODUCT?
    WITH members_with_ends_in_2024 AS (
        SELECT 
            DISTINCT member_number_members_sa,
            ends_mp  -- Include ends_mp for pivoting later
        FROM all_membership_sales_data
        WHERE   
            new_member_category_6_sa IN (@member_category)  -- Filter by member category
            AND YEAR(ends_mp) = @year_2024                         -- Only include members with end date in 2024
    ),

    -- CTE to count purchases in 2024 for those members and capture their category
    purchases_in_all_years AS (
        SELECT
            mw.member_number_members_sa,
            mw.ends_mp,  -- Include ends_mp for pivoting later
            sa.new_member_category_6_sa,
            COUNT(sa.purchased_on_mp) AS sales_units,           -- Count of purchases for each member
            SUM(sa.actual_membership_fee_6_sa) AS sales_revenue    -- Total revenue from purchases
        FROM members_with_ends_in_2024 AS mw
        LEFT JOIN all_membership_sales_data AS sa 
            ON mw.member_number_members_sa = sa.member_number_members_sa
        GROUP BY mw.member_number_members_sa, mw.ends_mp, sa.new_member_category_6_sa -- Group by member number, category, ends_mp, and purchased_on_mp
    )

    -- VERIFY SAMPLE OF RESULTS
    -- SELECT 
    --     * 
    -- FROM purchases_in_all_years
    -- WHERE member_number_members_sa IN (362537495, 2100434783, 2100346362)
    -- -- ORDER BY CAST(member_number_members_sa AS UNSIGNED), ends_mp, max_ends_mp;
    -- ORDER BY CAST(member_number_members_sa AS UNSIGNED), max_ends_mp;

    -- -- Final selection and pivoting the results
    SELECT 
        new_member_category_6_sa,
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
        FORMAT(SUM(sales_revenue), 0) AS sales_revenue
    FROM purchases_in_all_years
    GROUP BY new_member_category_6_sa WITH ROLLUP -- Group by new_member_category
    ORDER BY new_member_category_6_sa;  -- Order by new member category
-- ##################################################



