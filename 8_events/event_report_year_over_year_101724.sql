USE usat_sales_db;

SELECT * FROM sales_key_stats_2015 LIMIT 10;

-- CREATE INDEX idx_name_events ON sales_key_stats_2015 (name_events);
-- CREATE INDEX idx_year_month ON sales_key_stats_2015 (purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp);
-- CREATE INDEX idx_purchase_date ON sales_key_stats_2015 (purchased_on_adjusted_mp);

-- SUMMARIZE DATA BY EVENT BY YEAR
SELECT 
	REGEXP_REPLACE(
        LOWER(REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(
                            name_events, 
                            '^\\b[0-9]{4}\\s*|\\s*\\b[0-9]{4}\\b', ''  -- Remove year at start or end
                        ),  
                        'The\\s+\\b[0-9]{1,2}(st|nd|rd|th)\\s*', ''  -- Remove "The" followed by series number
                    ), 
                    '\\b[0-9]{1,2}(st|nd|rd|th)\\s*', ''  -- Remove series number
                ), 
                '-', '' -- Replace - with a single space
            ), 
            '/', ' ' -- Replace / with a single space
        )),
     '\\s+', ' ' -- Replace multiple spaces with a single space
    ) AS cleaned_event_name
    
    -- real_membership_types_sa
        -- STATS-- STATS
    , FORMAT(COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2023 THEN member_number_members_sa END), 0) AS distinct_member_count_2023
    , FORMAT(COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2024 THEN member_number_members_sa END), 0) AS distinct_member_count_2024
    , (
        COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2024 THEN member_number_members_sa END) - 
        COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2023 THEN member_number_members_sa END)
    ) AS variance_distinct_member_count

    , FORMAT(COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2023 THEN id_membership_periods_sa END), 0) AS distinct_membership_period_2023
    , FORMAT(COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2024 THEN id_membership_periods_sa END), 0) AS distinct_membership_period_2024
    
    , (
        COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2024 THEN id_membership_periods_sa END) - 
        COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2023 THEN id_membership_periods_sa END)
    ) AS variance_distinct_membership_period
        
	, GROUP_CONCAT(DISTINCT name_events ORDER BY purchased_on_year_adjusted_mp SEPARATOR ', ') AS original_event_names_distinct  -- Concatenate original event names
    , GROUP_CONCAT(DISTINCT id_events ORDER BY purchased_on_year_adjusted_mp SEPARATOR ', ') AS id_events_distinct  -- Concatenate event IDs

FROM sales_key_stats_2015
WHERE 
    purchased_on_year_adjusted_mp IN (2023, 2024)
    AND purchased_on_month_adjusted_mp IN (8)
GROUP BY cleaned_event_name WITH ROLLUP
ORDER BY cleaned_event_name ASC;


-- look at the end dates for Chicago
SELECT 
	name_events
    , id_events
    , real_membership_types_sa
    , purchased_on_year_adjusted_mp
    , created_at_events
    , starts_events
    , ends_events
    , COUNT(DISTINCT id_membership_periods_sa)
	, SUM(sales_revenue)
FROM sales_key_stats_2015
WHERE 
	LOWER(name_events) LIKE '%chicago%'
	AND purchased_on_year_adjusted_mp IN (2023, 2024)
    AND purchased_on_month_adjusted_mp IN (8)
GROUP BY 1, 2, 3, 4, 5, 6, 7
ORDER BY 3 ASC
;

-- get raw data for the chicago query above for Sam
SELECT 
	name_events
    , id_membership_periods_sa
    , id_events
    , real_membership_types_sa
    , purchased_on_year_adjusted_mp
    , created_at_events
    , starts_events
    , ends_events
FROM sales_key_stats_2015
WHERE 
	LOWER(name_events) LIKE '%chicago%'
	AND purchased_on_year_adjusted_mp IN (2023)
    AND purchased_on_month_adjusted_mp IN (8)
ORDER BY 1, 2, 3 ASC
;

-- get raw data for the chicago query above for Sam
SELECT     
	member_number_members_sa
	, name_events
    , id_events
    , real_membership_types_sa
    , starts_mp
    , ends_mp
    , COUNT(*)
FROM sales_key_stats_2015
WHERE 
	LOWER(name_events) LIKE '%chicago%'
	AND purchased_on_year_adjusted_mp IN (2023)
    AND purchased_on_month_adjusted_mp IN (8)
GROUP BY 1, 2, 3, 4, 5, 6
ORDER BY 1, 2, 3 ASC
;

-- EXTRACT RAW DATA FOR SAM
SELECT
	-- member_number_members_sa
--     , id_events
--     , purchased_on_year_adjusted_mp
--     
--     , FORMAT(COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2023 THEN id_membership_periods_sa END), 0) AS distinct_membership_period_2023
--     , FORMAT(COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2024 THEN id_membership_periods_sa END), 0) AS distinct_membership_period_2024
    id_events
    , COUNT(DISTINCT member_number_members_sa) AS member_count_distinct
    , COUNT(id_membership_periods_sa) AS membership_period_id_count
    
    , FORMAT(COUNT(DISTINCT CASE WHEN purchased_on_year_adjusted_mp = 2023 THEN id_membership_periods_sa END), 0) AS distinct_membership_period_2023
FROM sales_key_stats_2015
WHERE 
    purchased_on_year_adjusted_mp IN (2023, 2024)
    AND purchased_on_month_adjusted_mp IN (8)
    -- AND id_events IN (29690, 32253, 30790)
    AND id_events IN (30150)
-- GROUP BY purchased_on_year_adjusted_mp, member_number_members_sa, id_events
GROUP BY id_events
-- HAVING membership_period_id_count > 1
-- ORDER BY purchased_on_year_adjusted_mp, member_number_members_sa ASC;

