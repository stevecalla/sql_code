-- SELECT * FROM sales_key_stats_2015 LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM sales_key_stats_2015 LIMIT 10;
-- SELECT DISTINCT(real_membership_types_sa), FORMAT(COUNT(*), 0) FROM sales_key_stats_2015 GROUP BY 1 LIMIT 10;
-- CREATE INDEX idx_sales_years ON sales_key_stats_2015 (starts_year_mp, ends_year_mp);
-- CREATE INDEX idx_sales_profile_type ON sales_key_stats_2015 (id_profiles, real_membership_types_sa);

-- QUESTION: USE PROFILE ID OR MEMBER NUMBER?
-- SELECT
-- 	"PROFILE LIST",
--     id_profiles,
--     COUNT(DISTINCT id_profiles) AS count_distinct,
--     COUNT(*) AS total_count
-- FROM sales_key_stats_2015
-- WHERE 1 = 1
--     AND (starts_year_mp <= 2024 AND ends_year_mp >= 2024)
-- GROUP BY id_profiles WITH ROLLUP
-- ORDER BY 2 DESC
;

-- ========================================================================
-- QUERY BLOCK DESCRIPTION
-- ========================================================================
-- 1. Query: Unique Member Counts by Year
--    ------------------------------------
--    For each year in the selected range, this query calculates:
--      - Unique count of members based on `id_profiles`
--      - Unique count based on `member_number_members_sa`
--    It joins the `sales_key_stats_2015` table using membership validity
--    windows (start and end years), providing a high-level trend of
--    membership reach per year.
-- ========================================================================
-- QUERY BLOCK DESCRIPTION
-- ========================================================================
WITH years AS (
        SELECT 2015 AS y UNION ALL SELECT 2016 UNION ALL SELECT 2017 UNION ALL
        SELECT 2018 UNION ALL SELECT 2019 UNION ALL SELECT 2020 UNION ALL SELECT 2021 UNION ALL 
        SELECT 2022 UNION ALL SELECT 2023 UNION ALL SELECT 2024 UNION ALL SELECT 2025
    )
    SELECT
        "query_by_year",
        'active membership during year',
        y.y,
        FORMAT(COUNT(DISTINCT s.id_profiles), 0) AS total_unique_members_id_profiles,
        FORMAT(COUNT(DISTINCT s.member_number_members_sa), 0) AS total_unique_members_id_profiles_member_number_members_sa
    FROM sales_key_stats_2015 s
        JOIN years y ON y.y BETWEEN s.starts_year_mp AND s.ends_year_mp
    GROUP BY y.y
    ORDER BY y.y
;

-- ANY MEMBERSHIP DURING THE YEAR AS LONG AS IT WAS CREATED PRIOR TO THE CURRENT DATE
-- ANNUALS & ONE DAYS MEMBERSHIPS EFFECTIVE/ACTIVE ANY TIME IN THE YEAR AS LONG THEY ARE CREATED PRIOR TO TODAY
WITH years AS (
        SELECT 2015 AS y UNION ALL SELECT 2016 UNION ALL SELECT 2017 UNION ALL
        SELECT 2018 UNION ALL SELECT 2019 UNION ALL SELECT 2020 UNION ALL SELECT 2021 UNION ALL 
        SELECT 2022 UNION ALL SELECT 2023 UNION ALL SELECT 2024 UNION ALL SELECT 2025
    )
    SELECT
        "query_by_year",
        'active membership during year but created prior to yesterday i.e. 07/20/XX',
        STR_TO_DATE(CONCAT(y.y, DATE_FORMAT(CURDATE(), '-%m-%d')), '%Y-%m-%d') AS date_today,
        STR_TO_DATE(CONCAT(y.y, DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '-%m-%d')), '%Y-%m-%d') AS date_yesterday,
        y.y,
        FORMAT(COUNT(DISTINCT s.id_profiles), 0) AS total_unique_members_id_profiles,
        FORMAT(COUNT(DISTINCT s.member_number_members_sa), 0) AS total_unique_members_id_profiles_member_number_members_sa
    FROM sales_key_stats_2015 s
        JOIN years y ON y.y BETWEEN s.starts_year_mp AND s.ends_year_mp
            -- and membership created at prior to today
            -- AND s.created_at_date_mp <= CONCAT(y.y, '-12-31') -- FOR FULL YEAR DON'T FILTER LIKE THIS B/C CREATED COULD BE IN A FUTURE YEAR
            -- NOTE: didn't use created on mp b/c some times the created on date can be greater than purchase on date
            -- AND s.created_at_date_mp <= STR_TO_DATE(CONCAT(y.y, DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '-%m-%d')), '%Y-%m-%d') -- date yesterday
            -- NOTE: used purchased on adjusted to reflect when the event/race date is before the purchase date
            AND purchased_on_date_adjusted_mp <= STR_TO_DATE(CONCAT(y.y, DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '-%m-%d')), '%Y-%m-%d') -- date yesterday
    GROUP BY y.y
    ORDER BY y.y
;

-- ========================================================================
-- QUERY BLOCK DESCRIPTION
-- ========================================================================
-- 2. Query: Best Membership Per Member Per Year (All Memberships Valid)
--    -------------------------------------------------------------------
--    This CTE-based query:
--      - Explodes each membership across the years it spans
--      - Calculates total memberships per profile per year
--      - Ranks memberships by type priority (adult_annual > youth > one_day > elite > other)
--      - Selects the best-ranked membership per profile per year
--    The final output groups by year, membership type, and new member category,
--    showing how many unique profiles had that best membership and the total count
--    of all their memberships that year.
-- ========================================================================
-- QUERY BLOCK DESCRIPTION
-- ========================================================================
WITH years AS (
        SELECT 2022 AS y UNION ALL SELECT 2023 UNION ALL SELECT 2024 UNION ALL SELECT 2025

        -- SELECT 2015 AS y UNION ALL SELECT 2016 UNION ALL SELECT 2017 UNION ALL
        -- SELECT 2018 UNION ALL SELECT 2019 UNION ALL SELECT 2020 UNION ALL
        -- SELECT 2021 UNION ALL SELECT 2022 UNION ALL SELECT 2023 UNION ALL SELECT 2024
    )
    , exploded_years AS (
        SELECT
            s.id_profiles,
            s.id_membership_periods_sa,
            s.real_membership_types_sa,
            s.new_member_category_6_sa,
            s.starts_mp,
            s.starts_month_mp,
            s.starts_year_mp,
            s.ends_mp,
            s.ends_month_mp,
            s.ends_year_mp,
            s.created_at_date_mp,
            s.purchased_on_date_mp,
            s.purchased_on_date_adjusted_mp,
            y.y AS year
        FROM sales_key_stats_2015 s
            JOIN years y ON y.y BETWEEN s.starts_year_mp AND s.ends_year_mp
            -- and membership created at prior to today
            -- AND s.created_at_date_mp <= CONCAT(y.y, '-07-20') 
            -- AND s.created_at_date_mp <= STR_TO_DATE(CONCAT(y.y, DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '-%m-%d')), '%Y-%m-%d') -- date yesterday
        -- WHERE s.id_profiles IN (54, 57)
        -- WHERE s.id_profiles IN (57)
    )
    -- SELECT * FROM exploded_years ORDER BY s.id_profiles, y.y;

    -- ✅ Apply date filter *before* ranking to ensure proper match
    , filtered_years AS (
        SELECT 
            *
        FROM exploded_years
        WHERE 1 = 1
            -- and membership created at prior to today
            AND s.created_at_date_mp <= CONCAT(y.y, '-07-20') 
            -- NOTE: didn't use created on mp b/c some times the created on date can be greater than purchase on date
            -- AND created_at_date_mp <= STR_TO_DATE(CONCAT(year, DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '-%m-%d')), '%Y-%m-%d') 
            -- NOTE: used purchased on adjusted to reflect when the event/race date is before the purchase date
            -- AND purchased_on_date_adjusted_mp <= STR_TO_DATE(CONCAT(year, DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '-%m-%d')), '%Y-%m-%d') 
    )

    , membership_counts_by_profile_year AS (
        SELECT
            year,
            id_profiles,
            COUNT(DISTINCT(fy.id_membership_periods_sa)) AS total_memberships_for_year
        -- FROM exploded_years AS e
        FROM filtered_years AS fy
        GROUP BY year, id_profiles
    ),

    ranked_memberships AS (
        SELECT
            -- e.*,
            fy.*,
            ROW_NUMBER() OVER ( -- row number ensures each record has a unique number while rank can result in ties
                PARTITION BY year, id_profiles
                ORDER BY
                    CASE
                        WHEN real_membership_types_sa = 'adult_annual' THEN 1
                        WHEN real_membership_types_sa = 'youth_annual' THEN 2
                        WHEN real_membership_types_sa = 'one_day' THEN 3
                        WHEN real_membership_types_sa = 'elite' THEN 4
                        ELSE 5
                    END,
                    ends_mp ASC -- row number breaks ties by using, ASC takes the earliest ends_mp date (in the given year)
            ) AS membership_type_priority
        -- FROM exploded_years e
        FROM filtered_years AS fy
    )
    
    -- SELECT * FROM ranked_memberships ORDER BY id_profiles, year;

    , best_memberships AS (
        SELECT 
            rm.*, 
            mc.total_memberships_for_year
        FROM ranked_memberships rm
            JOIN membership_counts_by_profile_year mc ON rm.year = mc.year AND rm.id_profiles = mc.id_profiles
        -- WHERE rm.membership_type_priority = 1
    )

    SELECT
        "query_with_member_type_category_detail",
        "valid if mp start year <= year and mp end year => year",
        year,
        -- real_membership_types_sa AS membership_type,
        -- new_member_category_6_sa AS new_member_category,
        -- starts_mp,
        -- starts_month_mp,
        -- starts_year_mp,
        -- ends_mp,
        -- ends_month_mp,
        -- ends_year_mp,
        -- created_at_date_mp,
        -- purchased_on_date_adjusted_mp,
        CASE 
            -- WHEN created_at_date_mp <= STR_TO_DATE(CONCAT(year, DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '-%m-%d')), '%Y-%m-%d') THEN 1 
            WHEN purchased_on_date_adjusted_mp <= STR_TO_DATE(CONCAT(year, DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '-%m-%d')), '%Y-%m-%d') THEN 1   
            ELSE 0 
        END AS is_year_to_date,
        STR_TO_DATE(DATE_FORMAT(CURDATE(), '%Y-%m-%d'), '%Y-%m-%d') AS date_today,
		STR_TO_DATE(DATE_FORMAT(CURDATE() - INTERVAL 1 DAY, '%Y-%m-%d'), '%Y-%m-%d') AS date_yesterday,
        COUNT(DISTINCT id_profiles) AS unique_profiles,
        SUM(total_memberships_for_year) AS total_memberships_all_profiles_that_year
    FROM best_memberships
    WHERE membership_type_priority = 1
    GROUP BY 
        year,
        -- real_membership_types_sa, 
        -- new_member_category_6_sa, 
        -- starts_mp,
        -- starts_month_mp,
        -- starts_year_mp,
        -- ends_mp,
        -- ends_month_mp,
        -- ends_year_mp, 
        -- created_at_date_mp,
        -- purchased_on_date_adjusted_mp,
        date_today,
        date_yesterday,
        is_year_to_date
    ORDER BY 
        is_year_to_date,
        year
        -- real_membership_types_sa
;

-- ========================================================================
-- QUERY BLOCK DESCRIPTION
-- ========================================================================
-- 3. Query: Best Membership Per Member Per Year (One-Day Rule Applied)
--    ------------------------------------------------------------------
--    Similar to Query 2, but:
--      - Applies special handling for 'one_day' memberships: includes them only
--        if the membership started in the target year
--      - For all other types, includes them only if valid on 12/31 of the target year
--    This ensures that 'one_day' memberships are not overcounted across years,
--    and that long-term memberships are evaluated based on year-end status.
-- ========================================================================
-- QUERY BLOCK DESCRIPTION
-- ========================================================================
-- WITH years AS (
--         SELECT 2022 AS y UNION ALL SELECT 2023 UNION ALL SELECT 2024 UNION ALL SELECT 2025
--         -- SELECT 2015 AS y UNION ALL SELECT 2016 UNION ALL SELECT 2017 UNION ALL
--         -- SELECT 2018 UNION ALL SELECT 2019 UNION ALL SELECT 2020 UNION ALL
--         -- SELECT 2021 UNION ALL SELECT 2022 UNION ALL SELECT 2023 UNION ALL SELECT 2024
    
--     ),
--     exploded_years AS (
--         SELECT
--             s.id_profiles,
--             s.real_membership_types_sa,
--             s.new_member_category_6_sa,
--             s.starts_mp,
--             s.ends_mp,
--             y.y AS year
--         FROM sales_key_stats_2015 s
--         JOIN years y ON (
--             -- ONE-DAY memberships: include if the start year matches the analysis year
--             (s.real_membership_types_sa = 'one_day' AND YEAR(s.starts_mp) = y.y)
--             OR
--             -- ALL OTHERS: include if membership is valid on Dec 31 of the year
--             (
--                 s.real_membership_types_sa != 'one_day'
--                 AND s.starts_mp <= STR_TO_DATE(CONCAT(y.y, '-12-31'), '%Y-%m-%d')
--                 AND s.ends_mp   >= STR_TO_DATE(CONCAT(y.y, '-12-31'), '%Y-%m-%d')
--             )
--         )
--     ),

--     membership_counts_by_profile_year AS (
--         SELECT
--             year,
--             id_profiles,
--             COUNT(*) AS total_memberships_for_year
--         FROM exploded_years
--         GROUP BY year, id_profiles
--     ),

--     ranked_memberships AS (
--         SELECT
--             e.year,
--             e.id_profiles,
--             e.real_membership_types_sa,
--             e.new_member_category_6_sa,
--             e.starts_mp,
--             ROW_NUMBER() OVER (
--                 PARTITION BY e.year, e.id_profiles
--                 ORDER BY
--                     CASE
--                         WHEN e.real_membership_types_sa = 'adult_annual' THEN 1
--                         WHEN e.real_membership_types_sa = 'youth_annual' THEN 2
--                         WHEN e.real_membership_types_sa = 'one_day' THEN 3
--                         WHEN e.real_membership_types_sa = 'elite' THEN 4
--                         ELSE 5
--                     END,
--                     e.ends_mp ASC
--             ) AS membership_type_priority
--         FROM exploded_years e
--     ),

--     best_memberships AS (
--         SELECT 
--             rm.*, 
--             mc.total_memberships_for_year
--         FROM ranked_memberships rm
--             JOIN membership_counts_by_profile_year mc ON rm.year = mc.year AND rm.id_profiles = mc.id_profiles
--         WHERE rm.membership_type_priority = 1
--     )

--     SELECT
--         "query_with_member_type_category_detail",
--         "one_day is same start year, annual is valid 12/31",
--         year,
--         -- real_membership_types_sa AS membership_type,
--         -- new_member_category_6_sa AS new_member_category,
--         COUNT(DISTINCT id_profiles) AS unique_profiles,
--         SUM(total_memberships_for_year) AS total_memberships_all_profiles_that_year
--     FROM best_memberships
--     -- GROUP BY year, real_membership_types_sa, new_member_category_6_sa
--     -- ORDER BY year, real_membership_types_sa
--     GROUP BY year
--     ORDER BY year
-- ;