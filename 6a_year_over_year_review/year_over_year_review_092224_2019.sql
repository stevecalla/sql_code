USE usat_sales_db;
-- SET @member_category = '3-year';
-- SET @year_1 = 2023;
-- SET @year_2 = 2024;

-- #1) SECTION: STATS = UNIQUE MEMBER NUMBERS
    SELECT
        COUNT(DISTINCT(member_number_members_sa)),
        COUNT(member_number_members_sa)
    FROM all_membership_sales_data_2019;	
-- =================================================

-- #1) SECTION: STATS = TOTAL BY YEAR
    SELECT
        purchased_on_year_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2019
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_mp WITH ROLLUP;
-- =================================================

-- #2) SECTION: STATS = TOTAL BY YEAR BY MONTH
    SELECT
        purchased_on_year_mp,
        purchase_on_month_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2019
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_mp, purchase_on_month_mp WITH ROLLUP
    ORDER BY purchased_on_year_mp, purchase_on_month_mp;
-- =================================================
-- ++++++++++++++++++++++++++++++++++++++++++++++++++

-- #3) SECTION: STATS = TOTAL BY YEAR BY REAL TYPE
    SELECT
        purchased_on_year_mp,
        real_membership_types_sa,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2019
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_mp, real_membership_types_sa WITH ROLLUP; 
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- #4) SECTION: STATS = TOTAL BY YEAR BY NEW MEMBER CATEGORY
    SELECT
        purchased_on_year_mp,
        new_member_category_6_sa,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(member_number_members_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2019
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_mp, new_member_category_6_sa WITH ROLLUP; 

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- #5) SECTION: STATS = TOTAL BY YEAR, REAL TYPE, MEMBER CATEGORY, MEMBER NUMBER, MEMBERSHIP ID
    SELECT
        member_number_members_sa,  -- Unique member number
        id_membership_periods_sa,  -- ID of the membership period
        real_membership_types_sa,  -- Type of membership
        new_member_category_6_sa,   -- Category of new members
        purchased_on_mp,            -- Exact date of purchase
        starts_mp,
        ends_mp,
        purchased_on_year_mp,       -- Year of purchase
        purchased_on_quarter_mp,    -- Quarter of purchase
        purchase_on_month_mp,       -- Month of purchase
        YEAR(starts_mp) AS starts_year_mp,
        QUARTER(starts_mp) AS starts_quarter_mp,
        MONTH(starts_mp) AS starts_month_mp,
        YEAR(ends_mp) AS ends_year_mp,
        QUARTER(ends_mp) AS ends_quarter_mp,
        MONTH(ends_mp) AS ends_month_mp,
        
        SUM(CASE WHEN first_occurrence_any_purchase = 1 THEN 1 ELSE 0 END) AS first_occurrence_any_purchase,  -- Count unique members (1 for first occurrence, 0 otherwise)
        SUM(CASE WHEN first_purchase_by_year = 1 THEN 1 ELSE 0 END) AS first_purchase_by_year,  -- Count unique members (1 for first occurrence, 0 otherwise)
        SUM(CASE WHEN first_purchase_by_year_month = 1 THEN 1 ELSE 0 END) AS first_purchase_by_year_month,  -- Count unique members (1 for first occurrence, 0 otherwise)
        
        COUNT(member_number_members_sa) AS sales_units,  -- Total number of sales units
        SUM(actual_membership_fee_6_sa) AS sales_revenue,  -- Total revenue from membership fees

        total_purchases,  -- Total purchases for each 

        -- Determine member frequency category
        CASE 
            WHEN total_purchases = 1 THEN 'one_purchase'
            ELSE 'more_than_one_purchase'
        END AS member_frequency,  -- Frequency category for each member

        DATE_FORMAT(DATE_ADD(NOW(), INTERVAL -6 HOUR), '%Y-%m-%d') AS created_at_mtn,
        DATE_FORMAT(NOW(), '%Y-%m-%d') AS created_at_utc
    FROM (
        SELECT 
            member_number_members_sa,  -- Unique member number from original data
            id_membership_periods_sa,  -- Membership period ID from original data
            real_membership_types_sa,   -- Type of membership from original data
            new_member_category_6_sa,    -- Category of new members from original data
            purchased_on_mp,             -- Exact date of purchase from original data
            starts_mp,
            ends_mp,
            purchased_on_year_mp,       -- Year of purchase from original data
            purchase_on_month_mp,       -- Month of purchase from original data
            purchased_on_quarter_mp,    -- Quarter of purchase from original data
            actual_membership_fee_6_sa,  -- Membership fee from original data
            
            -- First occurrence of any purchase for each member
            ROW_NUMBER() OVER (
                PARTITION BY member_number_members_sa 
                ORDER BY purchased_on_mp
            ) AS first_occurrence_any_purchase,
            
            -- First purchase by year for each member
            ROW_NUMBER() OVER (
                PARTITION BY member_number_members_sa, purchased_on_year_mp
                ORDER BY purchased_on_mp
            ) AS first_purchase_by_year,
            
            -- First purchase by year by month for each member
            ROW_NUMBER() OVER (
                PARTITION BY member_number_members_sa, purchased_on_year_mp, purchase_on_month_mp 
                ORDER BY purchased_on_mp
            ) AS first_purchase_by_year_month,

            COUNT(*) OVER (PARTITION BY member_number_members_sa) AS total_purchases  -- Total purchases for each member
        FROM all_membership_sales_data_2019  -- Source table containing membership sales data
    ) AS member_data  -- Alias for the derived table
    GROUP BY 
        member_number_members_sa,  -- Grouping by member number
        id_membership_periods_sa,  -- Grouping by membership period ID
        real_membership_types_sa,   -- Grouping by membership type
        new_member_category_6_sa,    -- Grouping by new member category
        purchased_on_mp,             -- Grouping by exact purchase date
        starts_mp,
        ends_mp,
        purchased_on_year_mp,       -- Grouping by year of purchase
        purchased_on_quarter_mp,    -- Grouping by quarter of purchase
        purchase_on_month_mp        -- Grouping by month of purchase
    ORDER BY 
        member_number_members_sa,  -- Grouping by member number
        id_membership_periods_sa,  -- Grouping by membership period ID
        real_membership_types_sa,   -- Grouping by membership type
        new_member_category_6_sa,    -- Grouping by new member category
        purchased_on_mp,            -- Grouping by exact purchase date
        starts_mp,
        ends_mp,
        purchased_on_year_mp,       -- Grouping by year of purchase
        purchased_on_quarter_mp,    -- Grouping by quarter of purchase
        purchase_on_month_mp;       -- Grouping by month of purchase
-- ##################################################

-- #6) SECTION: CREATE TABLE
    DROP TABLE IF EXISTS usat_sales_db.sales_key_stats;

    CREATE TABLE usat_sales_db.sales_key_stats AS
        SELECT
            member_number_members_sa,  -- Unique member number
            id_membership_periods_sa,  -- ID of the membership period
            real_membership_types_sa,  -- Type of membership
            new_member_category_6_sa,   -- Category of new members
            purchased_on_mp,            -- Exact date of purchase
            starts_mp,
            ends_mp,
            purchased_on_year_mp,       -- Year of purchase
            purchased_on_quarter_mp,    -- Quarter of purchase
            purchase_on_month_mp,       -- Month of purchase
            YEAR(starts_mp) AS starts_year_mp,
            QUARTER(starts_mp) AS starts_quarter_mp,
            MONTH(starts_mp) AS starts_month_mp,
            YEAR(ends_mp) AS ends_year_mp,
            QUARTER(ends_mp) AS ends_quarter_mp,
            MONTH(ends_mp) AS ends_month_mp,
            
            SUM(CASE WHEN first_occurrence_any_purchase = 1 THEN 1 ELSE 0 END) AS first_occurrence_any_purchase,  -- Count unique members (1 for first occurrence, 0 otherwise)
            SUM(CASE WHEN first_purchase_by_year = 1 THEN 1 ELSE 0 END) AS first_purchase_by_year,  -- Count unique members (1 for first occurrence, 0 otherwise)
            SUM(CASE WHEN first_purchase_by_year_month = 1 THEN 1 ELSE 0 END) AS first_purchase_by_year_month,  -- Count unique members (1 for first occurrence, 0 otherwise)
            
            COUNT(member_number_members_sa) AS sales_units,  -- Total number of sales units
            SUM(actual_membership_fee_6_sa) AS sales_revenue,  -- Total revenue from membership fees

            total_purchases,  -- Total purchases for each member

            -- Determine member frequency category
            CASE 
                WHEN total_purchases = 1 THEN 'one_purchase'
                ELSE 'more_than_one_purchase'
            END AS member_frequency,  -- Frequency category for each member

            DATE_FORMAT(DATE_ADD(NOW(), INTERVAL -6 HOUR), '%Y-%m-%d') AS created_at_mtn,
            DATE_FORMAT(NOW(), '%Y-%m-%d') AS created_at_utc
        FROM (
            SELECT 
                member_number_members_sa,  -- Unique member number from original data
                id_membership_periods_sa,  -- Membership period ID from original data
                real_membership_types_sa,   -- Type of membership from original data
                new_member_category_6_sa,    -- Category of new members from original data
                purchased_on_mp,             -- Exact date of purchase from original data
                starts_mp,
                ends_mp,
                purchased_on_year_mp,       -- Year of purchase from original data
                purchase_on_month_mp,       -- Month of purchase from original data
                purchased_on_quarter_mp,    -- Quarter of purchase from original data
                actual_membership_fee_6_sa,  -- Membership fee from original data
                
                -- First occurrence of any purchase for each member
                ROW_NUMBER() OVER (
                    PARTITION BY member_number_members_sa 
                    ORDER BY purchased_on_mp
                ) AS first_occurrence_any_purchase,
                
                -- First purchase by year for each member
                ROW_NUMBER() OVER (
                    PARTITION BY member_number_members_sa, purchased_on_year_mp
                    ORDER BY purchased_on_mp
                ) AS first_purchase_by_year,
                
                -- First purchase by year by month for each member
                ROW_NUMBER() OVER (
                    PARTITION BY member_number_members_sa, purchased_on_year_mp, purchase_on_month_mp 
                    ORDER BY purchased_on_mp
                ) AS first_purchase_by_year_month,

                COUNT(*) OVER (PARTITION BY member_number_members_sa) AS total_purchases  -- Total purchases for each member
            FROM all_membership_sales_data_2019  -- Source table containing membership sales data
        ) AS member_data  -- Alias for the derived table
        GROUP BY 
            member_number_members_sa,  -- Grouping by member number
            id_membership_periods_sa,  -- Grouping by membership period ID
            real_membership_types_sa,   -- Grouping by membership type
            new_member_category_6_sa,    -- Grouping by new member category
            purchased_on_mp,             -- Grouping by exact purchase date
            starts_mp,
            ends_mp,
            purchased_on_year_mp,       -- Grouping by year of purchase
            purchased_on_quarter_mp,    -- Grouping by quarter of purchase
            purchase_on_month_mp        -- Grouping by month of purchase
        ORDER BY 
            member_number_members_sa,  -- Grouping by member number
            id_membership_periods_sa,  -- Grouping by membership period ID
            real_membership_types_sa,   -- Grouping by membership type
            new_member_category_6_sa,    -- Grouping by new member category
            purchased_on_mp,            -- Grouping by exact purchase date
            starts_mp,
            ends_mp,
            purchased_on_year_mp,       -- Grouping by year of purchase
            purchased_on_quarter_mp,    -- Grouping by quarter of purchase
            purchase_on_month_mp;       -- Grouping by month of purchase
-- ??????????????????????????????????????????????????

-- #7) SECTION: STATS = PIVOT BY MONTH
        SELECT
            purchased_on_year_mp AS year,
            'Member Count' AS metric,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 1 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS Jan,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 2 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS Feb,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 3 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS Mar,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 4 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS Apr,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 5 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS May,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 6 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS Jun,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 7 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS Jul,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 8 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS Aug,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 9 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS Sep,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 10 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS Oct,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 11 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS Nov,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 12 THEN COUNT(DISTINCT member_number_members_sa) END), 0) AS 'Dec'
        FROM all_membership_sales_data_2019
        GROUP BY purchased_on_year_mp

        UNION ALL

        SELECT
            purchased_on_year_mp AS year,
            'Sales Units' AS metric,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 1 THEN COUNT(*) END), 0) AS Jan,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 2 THEN COUNT(*) END), 0) AS Feb,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 3 THEN COUNT(*) END), 0) AS Mar,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 4 THEN COUNT(*) END), 0) AS Apr,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 5 THEN COUNT(*) END), 0) AS May,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 6 THEN COUNT(*) END), 0) AS Jun,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 7 THEN COUNT(*) END), 0) AS Jul,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 8 THEN COUNT(*) END), 0) AS Aug,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 9 THEN COUNT(*) END), 0) AS Sep,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 10 THEN COUNT(*) END), 0) AS Oct,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 11 THEN COUNT(*) END), 0) AS Nov,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 12 THEN COUNT(*) END), 0) AS 'Dec'
        FROM all_membership_sales_data_2019
        GROUP BY purchased_on_year_mp

        UNION ALL

        SELECT
            purchased_on_year_mp AS year,
            'Sales Revenue' AS metric,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 1 THEN actual_membership_fee_6_sa END), 0) AS Jan,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 2 THEN actual_membership_fee_6_sa END), 0) AS Feb,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 3 THEN actual_membership_fee_6_sa END), 0) AS Mar,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 4 THEN actual_membership_fee_6_sa END), 0) AS Apr,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 5 THEN actual_membership_fee_6_sa END), 0) AS May,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 6 THEN actual_membership_fee_6_sa END), 0) AS Jun,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 7 THEN actual_membership_fee_6_sa END), 0) AS Jul,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 8 THEN actual_membership_fee_6_sa END), 0) AS Aug,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 9 THEN actual_membership_fee_6_sa END), 0) AS Sep,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 10 THEN actual_membership_fee_6_sa END), 0) AS Oct,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 11 THEN actual_membership_fee_6_sa END), 0) AS Nov,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 12 THEN actual_membership_fee_6_sa END), 0) AS 'Dec'
        FROM all_membership_sales_data_2019
        GROUP BY purchased_on_year_mp

        UNION ALL

        SELECT
            purchased_on_year_mp AS year,
            'Revenue Per Member' AS metric,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 1 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 1 THEN member_number_members_sa END), 0), 2) AS Jan,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 2 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 2 THEN member_number_members_sa END), 0), 2) AS Feb,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 3 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 3 THEN member_number_members_sa END), 0), 2) AS Mar,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 4 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 4 THEN member_number_members_sa END), 0), 2) AS Apr,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 5 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 5 THEN member_number_members_sa END), 0), 2) AS May,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 6 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 6 THEN member_number_members_sa END), 0), 2) AS Jun,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 7 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 7 THEN member_number_members_sa END), 0), 2) AS Jul,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 8 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 8 THEN member_number_members_sa END), 0), 2) AS Aug,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 9 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 9 THEN member_number_members_sa END), 0), 2) AS Sep,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 10 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 10 THEN member_number_members_sa END), 0), 2) AS Oct,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 11 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 11 THEN member_number_members_sa END), 0), 2) AS Nov,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 12 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(DISTINCT CASE WHEN MONTH(purchased_on_mp) = 12 THEN member_number_members_sa END), 0), 2) AS 'Dec'
        FROM all_membership_sales_data_2019
        GROUP BY purchased_on_year_mp

        UNION ALL

        SELECT
            purchased_on_year_mp AS year,
            'Revenue Per Sale' AS metric,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 1 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 1 THEN 1 END), 0), 2) AS Jan,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 2 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 2 THEN 1 END), 0), 2) AS Feb,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 3 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 3 THEN 1 END), 0), 2) AS Mar,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 4 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 4 THEN 1 END), 0), 2) AS Apr,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 5 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 5 THEN 1 END), 0), 2) AS May,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 6 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 6 THEN 1 END), 0), 2) AS Jun,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 7 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 7 THEN 1 END), 0), 2) AS Jul,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 8 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 8 THEN 1 END), 0), 2) AS Aug,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 9 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 9 THEN 1 END), 0), 2) AS Sep,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 10 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 10 THEN 1 END), 0), 2) AS Oct,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 11 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 11 THEN 1 END), 0), 2) AS Nov,
            FORMAT(SUM(CASE WHEN MONTH(purchased_on_mp) = 12 THEN actual_membership_fee_6_sa END) / NULLIF(COUNT(CASE WHEN MONTH(purchased_on_mp) = 12 THEN 1 END), 0), 2) AS 'Dec'
        FROM all_membership_sales_data_2019
        GROUP BY purchased_on_year_mp;


-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- #7) SECTION: TBD

-- ??????????????????????????????????????????????????

-- #8) SECTION: TBD

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- #9) SECTION: TBD

-- ))))))))))))))))))))))))))))))))))))))))))))))))))

-- #10) SECTION: TBD

-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



