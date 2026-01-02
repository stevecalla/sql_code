-- SELECT * FROM sales_key_stats_2015 LIMIT 10;	
-- SELECT FORMAT(COUNT(*), 0) FROM sales_key_stats_2015 LIMIT 10;	
-- SELECT DISTINCT(real_membership_types_sa), FORMAT(COUNT(*), 0) FROM sales_key_stats_2015 GROUP BY 1 LIMIT 10;	
-- CREATE INDEX idx_sales_years ON sales_key_stats_2015 (starts_year_mp, ends_year_mp);	
-- CREATE INDEX idx_sales_profile_type ON sales_key_stats_2015 (id_profiles, real_membership_types_sa);	
	
-- QUESTION: USE PROFILE ID OR MEMBER NUMBER?	
-- SELECT	
-- 	PROFILE LIST,
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
    SELECT 2018 UNION ALL SELECT 2019 UNION ALL SELECT 2020 UNION ALL	
    SELECT 2021 UNION ALL SELECT 2022 UNION ALL SELECT 2023 UNION ALL 
    SELECT 2024	UNION ALL SELECT 2025 UNION ALL
    SELECT 2026
    
    -- SELECT 2022 AS y UNION ALL SELECT 2023 UNION ALL SELECT 2024	
)	
SELECT	
	"query_by_year" AS query_label,
    y.y,	
    FORMAT(COUNT(DISTINCT s.id_profiles), 0) AS total_unique_members_id_profiles,	
    FORMAT(COUNT(DISTINCT s.member_number_members_sa), 0) AS total_unique_members_id_profiles_member_number_members_sa	
FROM years y	
LEFT JOIN sales_key_stats_2015 s	
    ON s.starts_year_mp <= y.y AND s.ends_year_mp >= y.y	
GROUP BY y.y	
ORDER BY y.y	
;	
	
-- ========================================================================	
-- QUERY BLOCK DESCRIPTION	
-- ========================================================================	
-- 2. Query: Best Membership Per Member Per Year (All Memberships Valid)	
--    -------------------------------------------------------------------	
--    This CTE-based query:	
--      - Explodes each membership across the years It spans	
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
    SELECT 2015 AS y UNION ALL SELECT 2016 UNION ALL SELECT 2017 UNION ALL	
    SELECT 2018 UNION ALL SELECT 2019 UNION ALL SELECT 2020 UNION ALL	
    SELECT 2021 UNION ALL SELECT 2022 UNION ALL SELECT 2023 UNION ALL 
    SELECT 2024	UNION ALL SELECT 2025 UNION ALL
    SELECT 2026
    
    -- SELECT 2022 AS y UNION ALL SELECT 2023 UNION ALL SELECT 2024		
),	
exploded_years AS (	
    SELECT	
        s.id_profiles,	
        s.real_membership_types_sa,	
        s.new_member_category_6_sa,	
        s.starts_mp,	
        s.ends_mp,	
        y.y AS year	
    FROM sales_key_stats_2015 s	
    JOIN years y ON y.y BETWEEN s.starts_year_mp AND s.ends_year_mp	
	-- WHERE s.id_profiles IN (54, 57)
    -- WHERE s.id_profiles IN (57)	
)	
,membership_counts_by_profile_year AS (	
    SELECT	
        year,	
        id_profiles,	
        COUNT(*) AS total_memberships_for_year	
    FROM exploded_years	
    GROUP BY year, id_profiles	
),	
	
ranked_memberships AS (	
    SELECT	
        e.year,	
        e.id_profiles,	
        e.real_membership_types_sa,	
        e.new_member_category_6_sa,	
        e.starts_mp,	
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
    FROM exploded_years e	
),	
	
best_memberships AS (	
    SELECT 	
        rm.*, 	
        mc.total_memberships_for_year	
    FROM ranked_memberships rm	
    JOIN membership_counts_by_profile_year mc	
      ON rm.year = mc.year AND rm.id_profiles = mc.id_profiles	
    WHERE rm.membership_type_priority = 1	
)	
	
SELECT	
    year,	
    real_membership_types_sa AS membership_type,	
    new_member_category_6_sa AS new_member_category,	
    COUNT(DISTINCT id_profiles) AS unique_profiles,	
    SUM(total_memberships_for_year) AS total_memberships_all_profiles_that_year	
FROM best_memberships	
GROUP BY year, real_membership_types_sa, new_member_category_6_sa	
ORDER BY year, real_membership_types_sa
;	
