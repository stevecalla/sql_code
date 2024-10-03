USE usat_sales_db;

-- SET @member_category = '3-year';
-- SET @year_1 = 2023;
-- SET @year_2 = 2024;

-- #1) SECTION: STATS = UNIQUE MEMBER NUMBERS
    SELECT
        COUNT(DISTINCT(member_number_members_sa)),
        COUNT(member_number_members_sa)
    FROM all_membership_sales_data_2015_left;
-- =================================================

-- #2) SECTION: STATS = TOTAL BY YEAR
    SELECT
        purchased_on_year_adjusted_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2015_left
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp WITH ROLLUP;
-- =================================================


-- #3) SECTION: STATS = TOTAL BY YEAR BY MONTH
    SELECT
        purchased_on_year_adjusted_mp,
        purchased_on_month_adjusted_mp,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2015_left
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp WITH ROLLUP
    ORDER BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp;
-- =================================================
-- ++++++++++++++++++++++++++++++++++++++++++++++++++

-- #4) SECTION: STATS = TOTAL BY YEAR BY REAL TYPE
    SELECT
        purchased_on_year_adjusted_mp,
        real_membership_types_sa,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2015_left
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp, real_membership_types_sa WITH ROLLUP; 
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- #5) SECTION: STATS = TOTAL BY YEAR BY NEW MEMBER CATEGORY
    SELECT
        purchased_on_year_adjusted_mp,
        new_member_category_6_sa,
        FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
        FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
        FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(DISTINCT(member_number_members_sa))), 2) AS revenue_per_member,
        FORMAT((SUM(actual_membership_fee_6_sa) / COUNT(*)), 2) AS revenue_per_sale,
        FORMAT((COUNT(*) / COUNT(DISTINCT(member_number_members_sa))), 2) AS sales_per_member
    FROM all_membership_sales_data_2015_left
    -- WHERE new_member_category_6_sa IN (@member_category);
    GROUP BY purchased_on_year_adjusted_mp, new_member_category_6_sa WITH ROLLUP; 

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- #6) SECTION: STATS = TOTAL BY YEAR, REAL TYPE, MEMBER CATEGORY, MEMBER NUMBER, MEMBERSHIP ID
-- BASE QUERY TO CREATE TABLE AT create_2015_key_stats_093024.sql
    SELECT
        member_number_members_sa,  -- Unique member number
        id_membership_periods_sa,  -- ID of the membership period
        real_membership_types_sa,  -- Type of membership
        new_member_category_6_sa,   -- Category of new members
        
        purchased_on_mp,            -- Exact date of purchase
        purchased_on_adjusted_mp,
        starts_mp,
        ends_mp,
        
        purchased_on_year_mp,       -- Year of purchase
        purchased_on_quarter_mp,    -- Quarter of purchase
        purchased_on_month_mp,       -- Month of purchase
        
        purchased_on_year_adjusted_mp,       -- Year of purchase
        purchased_on_quarter_adjusted_mp,    -- Quarter of purchase
        purchased_on_month_adjusted_mp,       -- Month of purchase
        
        YEAR(starts_mp) AS starts_year_mp,
        QUARTER(starts_mp) AS starts_quarter_mp,
        MONTH(starts_mp) AS starts_month_mp,
        YEAR(ends_mp) AS ends_year_mp,
        QUARTER(ends_mp) AS ends_quarter_mp,
        MONTH(ends_mp) AS ends_month_mp,

        -- Key dates
        created_at_members,
        created_at_mp,
        created_at_profiles,
        created_at_users,

        -- Calculate the first purchase date for each member using a window function
        first_created_at_members,
        first_created_at_mp,
        first_created_at_profiles,
        first_created_at_users,
        first_purchased_on_mp,
        first_purchased_on_adjusted_mp,
        first_starts_mp,
        
        SUM(CASE WHEN first_occurrence_any_purchase = 1 THEN 1 ELSE 0 END) AS first_occurrence_any_purchase,  -- Count unique members (1 for first occurrence, 0 otherwise)
        SUM(CASE WHEN first_purchase_by_year = 1 THEN 1 ELSE 0 END) AS first_purchase_by_year,  -- Count unique members (1 for first occurrence, 0 otherwise)
        SUM(CASE WHEN first_purchase_by_year_month = 1 THEN 1 ELSE 0 END) AS first_purchase_by_year_month,  -- Count unique members (1 for first occurrence, 0 otherwise)

        COUNT(id_membership_periods_sa) AS sales_units,  -- Total number of sales units
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
            purchased_on_adjusted_mp,
            starts_mp,
            ends_mp,
            
            purchased_on_year_mp,       -- Year of purchase from original data
            purchased_on_month_mp,       -- Month of purchase from original data
            purchased_on_quarter_mp,    -- Quarter of purchase from original data
            
            purchased_on_year_adjusted_mp,
            purchased_on_quarter_adjusted_mp,
            purchased_on_month_adjusted_mp,

            -- Key dates
            created_at_members,
            created_at_mp,
            created_at_profiles,
            created_at_users,

            -- Calculate the first purchase date for each member using a window function
            MIN(purchased_on_mp) OVER (PARTITION BY member_number_members_sa) AS first_purchased_on_mp,
            MIN(purchased_on_adjusted_mp) OVER (PARTITION BY member_number_members_sa) AS first_purchased_on_adjusted_mp,
            MIN(created_at_members) OVER (PARTITION BY member_number_members_sa) AS first_created_at_members,
            MIN(created_at_mp) OVER (PARTITION BY member_number_members_sa) AS first_created_at_mp,
            MIN(created_at_profiles) OVER (PARTITION BY member_number_members_sa) AS first_created_at_profiles,
            MIN(created_at_users) OVER (PARTITION BY member_number_members_sa) AS first_created_at_users,
            MIN(starts_mp) OVER (PARTITION BY member_number_members_sa) AS first_starts_mp,
            
            actual_membership_fee_6_sa,  -- Membership fee from original data
            
            -- First occurrence of any purchase for each member
            ROW_NUMBER() OVER (
                PARTITION BY member_number_members_sa 
                ORDER BY purchased_on_adjusted_mp
            ) AS first_occurrence_any_purchase,
            
            -- First purchase by year for each member
            ROW_NUMBER() OVER (
                PARTITION BY member_number_members_sa, purchased_on_year_adjusted_mp
                ORDER BY purchased_on_adjusted_mp
            ) AS first_purchase_by_year,
            
            -- First purchase by year by month for each member
            ROW_NUMBER() OVER (
                PARTITION BY member_number_members_sa, purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp 
                ORDER BY purchased_on_adjusted_mp
            ) AS first_purchase_by_year_month,

            COUNT(*) OVER (PARTITION BY member_number_members_sa) AS total_purchases  -- Total purchases for each member

        FROM all_membership_sales_data_2015_left  -- Source table containing membership sales data
        LIMIT 100

    ) AS member_data  -- Alias for the derived table

    GROUP BY 
        member_number_members_sa,  -- Grouping by member number
        id_membership_periods_sa,  -- Grouping by membership period ID
        real_membership_types_sa,   -- Grouping by membership type
        new_member_category_6_sa,    -- Grouping by new member category
        purchased_on_mp,             -- Grouping by exact purchase date
        purchased_on_adjusted_mp,
        starts_mp,
        ends_mp,
        purchased_on_year_mp,       -- Grouping by year of purchase
        purchased_on_quarter_mp,    -- Grouping by quarter of purchase
        purchased_on_month_mp,        -- Grouping by month of purchase
        purchased_on_year_adjusted_mp,       
        purchased_on_quarter_adjusted_mp,    
        purchased_on_month_adjusted_mp  
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
        purchased_on_month_mp       -- Grouping by month of purchase
    LIMIT 100;
-- ##################################################

-- #6) SECTION: CREATE TABLE
    --  SEE create_2015_key_stats_093024.sql
-- ??????????????????????????????????????????????????

-- #7) SECTION: TBD

-- ??????????????????????????????????????????????????

-- #8) SECTION: TBD

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- #9) SECTION: TBD

-- ))))))))))))))))))))))))))))))))))))))))))))))))))

-- #10) SECTION: TBD

-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



