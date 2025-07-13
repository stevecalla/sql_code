USE usat_sales_db;

-- ================================================
-- EVENT DATA METRICS DISCOVERY
SELECT * FROM event_data_metrics LIMIT 10;
DESCRIBE event_data_metrics;
SHOW COLUMNS FROM event_data_metrics;
SELECT
        LEFT(id_sanctioning_events, 6),
        id_sanctioning_events,
        COUNT(DISTINCT(id_sanctioning_events))
    FROM event_data_metrics
    WHERE 1 = 1
        AND id_sanctioning_events IS NOT NULL
        AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
        AND id_sanctioning_events IN (350398)
    GROUP BY 1, 2
    ORDER BY 1 DESC, 2
;

-- DISCOVERY TO FIND EVENTS THAT HAVE A RACE DESIGNATION FOR SOME RACES BUT NOT OTHERS -- START
SELECT * FROM all_event_data_raw WHERE id_sanctioning_events IN (310487, 310484) LIMIT 100;
SELECT * FROM event_data_metrics WHERE id_sanctioning_events IN (310390,310484,310487,310540,310637,310651,310709,310758,311006,311019,311061,311096,311143,311203,311206,311443,311469,311479,311668,350292,350328,350630) LIMIT 100;

SELECT DISTINCT
    base.id_sanctioning_events AS base_id
FROM
    all_event_data_raw base
JOIN
    all_event_data_raw variant
    ON variant.id_sanctioning_events LIKE CONCAT(base.id_sanctioning_events, '-%')
WHERE
    -- Only consider base IDs that are just numbers (not already hyphenated)
    base.id_sanctioning_events NOT LIKE '%-%'
;

SELECT
    base.id_sanctioning_events AS base_id,
    base.id_races AS base_races_id,
    base.id_sanctioning_events AS variant_id,   -- For the base itself
    base.id_races AS variant_races_id
FROM all_event_data_raw base
WHERE base.id_sanctioning_events NOT LIKE '%-%'

UNION ALL

SELECT
    base.id_sanctioning_events AS base_id,
    base.id_races AS base_races_id,
    variant.id_sanctioning_events AS variant_id, -- For each hyphenated variant
    variant.id_races AS variant_races_id
FROM all_event_data_raw base
JOIN all_event_data_raw variant
    ON variant.id_sanctioning_events LIKE CONCAT(base.id_sanctioning_events, '-%')
WHERE base.id_sanctioning_events NOT LIKE '%-%'

ORDER BY base_id, variant_id;
-- DISCOVERY TO FIND EVENTS THAT HAVE A RACE DESIGNATION FOR SOME RACES BUT NOT OTHERS -- end

-- ================================================
-- SALES KEY STATS DISCOVERY
SELECT * FROM sales_key_stats_2015 LIMIT 10;
SELECT 
        s.starts_year_events, 
        FORMAT(SUM(s.sales_units), 0), 
        FORMAT(SUM(s.sales_revenue), 0)
    FROM sales_key_stats_2015 AS s
    WHERE 1 = 1
        -- AND id_sanctioning_events IS NOT NULL
        AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
    GROUP BY 1
ORDER BY 1
;

SELECT 
        s.starts_year_events, 
        FORMAT(SUM(s.sales_units), 0), 
        FORMAT(SUM(s.sales_revenue), 0)
    FROM sales_key_stats_2015 AS s
    WHERE 1 = 1
        -- AND id_sanctioning_events IS NOT NULL
        AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
    GROUP BY 1
ORDER BY 1
;

-- QUERY FOR 350398 THAT HAS BOTH ADULT & YOUTH EVENT
SELECT 
        id_sanctioning_events,
        id_sanctioning_events_and_type,
        event_type_id_events,
        id_membership_periods_sa,
        real_membership_types_sa,
        new_member_category_6_sa
    FROM sales_key_stats_2015 
    WHERE 1 = 1
        AND id_sanctioning_events IN (350398)
    LIMIT 1000
;

-- ================================================
-- INITIAL JOIN FOR EVENT & SALES DATA
-- RESULT IS MISSING EVENTS THAT EXIST IN SALES BUT NOT SANCTIONING
WITH event_metrics_cte AS (
    -- 1. Extract distinct sanctioning IDs from event_data_metrics
    SELECT
        em.id_sanctioning_events,
        LEFT(em.id_sanctioning_events, 6) AS id_sanctioning_events_6_digits,
        REPLACE(em.name_events, '"', '') AS name_events,
        em.starts_year_events,
        em.starts_events
    FROM event_data_metrics AS em
    WHERE 1 = 1
		-- AND id_sanctioning_events IS NOT NULL
        AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
        -- AND id_sanctioning_events IN (350398)
	GROUP BY 1, 2, 3, 4, 5
    )
    -- SELECT * FROM event_metrics_cte; -- COUNT 2,570
    , sales_data_cte AS (
        -- 2. Extract sales data with first 6 chars for join
        SELECT
            id_sanctioning_events,
            LEFT(id_sanctioning_events, 6) AS id_sanctioning_events_6_digits,
            id_sanctioning_events_and_type,
            REPLACE(name_events, '"', '') AS name_events,
            starts_year_events,
            COUNT(DISTINCT id_membership_periods_sa) AS sales_units,
            SUM(sales_revenue) AS sales_revenue
        FROM sales_key_stats_2015
        WHERE 1 = 1
            -- AND id_sanctioning_events IS NOT NULL
            AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
            -- AND starts_year_events IN (YEAR(CURDATE()))
            -- AND id_sanctioning_events IN (350398)
            -- AND id_sanctioning_events IN (307440)
        GROUP BY
            id_sanctioning_events,
            id_sanctioning_events_and_type,
            name_events,
            starts_year_events
    )
    -- SELECT * FROM sales_data_cte; -- 2,031
    -- SELECT 
	-- 	em.starts_year_events, 
    --     FORMAT(SUM(s.sales_units), 0), 
    --     FORMAT(SUM(s.sales_revenue), 0)
	-- FROM event_metrics_cte AS em 
	-- 	LEFT JOIN sales_data_cte AS s ON em.id_sanctioning_events = s.id_sanctioning_events_and_type 
	-- GROUP BY 1
    -- ;
    -- 3. Merge (join) sales with event metrics
    SELECT
        em.id_sanctioning_events_6_digits AS id_sanctioning_events_6_digits_em,
		em.id_sanctioning_events AS id_sanctioning_events_em,
        s.id_sanctioning_events_and_type AS id_sanctioning_events_and_type_s,
        em.name_events AS name_events_em,
		em.starts_year_events AS starts_year_events_em,
        s.sales_units,
        s.sales_revenue,
		COUNT(DISTINCT em.id_sanctioning_events) AS count_unique_events
    FROM event_metrics_cte AS em
        LEFT JOIN sales_data_cte AS s ON em.id_sanctioning_events = s.id_sanctioning_events_and_type
	GROUP BY 
        em.id_sanctioning_events_6_digits,
		em.id_sanctioning_events,
        s.id_sanctioning_events_and_type,
        em.name_events,
		em.starts_year_events,
        sales_units,
        sales_revenue
	ORDER BY
		em.id_sanctioning_events_6_digits,
		em.id_sanctioning_events
    -- LIMIT 10
;

-- Find membership sales that have no match in event_data_metrics
SELECT
        s.id_sanctioning_events,
        s.id_sanctioning_events_and_type,
        s.starts_year_events,
        SUM(s.sales_units),
        SUM(s.sales_revenue),
        COUNT(*) AS missing_sales
    FROM sales_key_stats_2015 s
        LEFT JOIN event_data_metrics em ON em.id_sanctioning_events = s.id_sanctioning_events_and_type
    WHERE 1 = 1
        AND s.starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
        AND em.id_sanctioning_events IS NULL
    GROUP BY s.id_sanctioning_events, s.id_sanctioning_events_and_type, s.starts_year_events
    ORDER BY s.id_sanctioning_events, s.id_sanctioning_events_and_type
    LIMIT 100
;

-- ================================================
-- FINAL QUERY THAT COMBINES BOTH EVENTS WITH SALES & SALES WITH NO SANCTIONED EVENT
-- CTE #1: All event metrics for the desired years
WITH event_metrics_cte AS (
    SELECT
        em.id_sanctioning_events,
        LEFT(em.id_sanctioning_events, 6) AS id_sanctioning_events_6_digits,
        REPLACE(em.name_events, '"', '') AS name_events,
        em.starts_year_events,
        em.starts_events
    FROM event_data_metrics AS em
    WHERE 1 = 1
        AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
	GROUP BY 1, 2, 3, 4, 5
    )
    -- SELECT * FROM event_metrics_cte; -- 2,570

    -- ================================================
    -- CTE #2: Aggregated sales by event for the same years
    , sales_data_cte AS (
        SELECT
            s.id_sanctioning_events,
            LEFT(s.id_sanctioning_events, 6) AS id_sanctioning_events_6_digits,
            s.id_sanctioning_events_and_type,
            REPLACE(s.name_events, '"', '') AS name_events,
            s.starts_year_events,
            COUNT(DISTINCT s.id_membership_periods_sa) AS sales_units,
            SUM(s.sales_revenue) AS sales_revenue
        FROM sales_key_stats_2015 s
        WHERE s.starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
        GROUP BY
            s.id_sanctioning_events,
            s.id_sanctioning_events_and_type,
            s.name_events,
            s.starts_year_events
    )
    -- SELECT * FROM sales_data_cte; -- 2,031

    -- ================================================
    -- CTE #3: Find all sales that have NO matching event in event_metrics_cte
    , missing_sales_cte AS (
        SELECT
            NULL AS id_sanctioning_events,
            CASE 
                WHEN em.name_events IS NULL THEN s.name_events
                ELSE em.name_events
            END as name_events_or_sales,
            -- NULL AS name_events,
            s.starts_year_events AS starts_year_events,
            s.id_sanctioning_events_and_type AS id_sanctioning_events_and_type,
            s.sales_units,
            s.sales_revenue,
            'missing_in_event_data_metrics' AS source
        FROM sales_data_cte s
        LEFT JOIN event_metrics_cte em ON em.id_sanctioning_events = s.id_sanctioning_events_and_type
            AND em.starts_year_events = s.starts_year_events
        WHERE em.id_sanctioning_events IS NULL
    )
    -- SELECT * FROM missing_sales_cte; -- 23
    -- ================================================
    -- FINAL UNION: All events (with possible sales) + "orphan" sales (not in event_data_metrics)
    , combined_event_sales_data_cte AS (
        SELECT
            em.id_sanctioning_events        AS id_sanctioning_events,
            em.name_events                  AS name_events_or_sales,
            em.starts_year_events           AS starts_year_events,
            s.id_sanctioning_events_and_type AS id_sanctioning_events_and_type,
            s.sales_units,
            s.sales_revenue,
            'from_event_data_metrics'       AS source
        FROM event_metrics_cte em
            LEFT JOIN sales_data_cte s ON em.id_sanctioning_events = s.id_sanctioning_events_and_type
                AND em.starts_year_events = s.starts_year_events

        UNION ALL

        -- Add the "orphan" sales from the missing_sales_cte
        SELECT *
        FROM missing_sales_cte

        ORDER BY id_sanctioning_events, id_sanctioning_events_and_type
    )
    SELECT * FROM combined_event_sales_data_cte ORDER BY 1, 2, 3

    -- SELECT 
	--     starts_year_events, 
    --     FORMAT(SUM(sales_units), 0), 
    --     FORMAT(SUM(sales_revenue), 0)
	-- FROM combined_event_sales_data_cte
	-- GROUP BY 1
    -- ORDER BY 1
;

-- ================================================
-- Step 1: Event data metrics for last two years
WITH event_metrics_cte AS (
    SELECT
        em.id_sanctioning_events,
        LEFT(em.id_sanctioning_events, 6) AS id_sanctioning_events_6_digits,
        REPLACE(em.name_events, '"', '') AS name_events,
        em.starts_year_events,
        MAX(em.starts_events) AS starts_events,
        MAX(em.start_date_races) AS start_date_races,
        em.status_events,
        em.state_code_events,
        em.zip_events,
        em.name_event_type,
        em.member_number_members AS RaceDirectorUserID,
        em.event_website_url,
        em.registration_url,
        em.email_users,
        em.created_at_events
    FROM event_data_metrics AS em
    WHERE 1=1
      AND em.starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
    GROUP BY
        em.id_sanctioning_events, em.name_events, em.starts_year_events,
        -- em.starts_events, em.start_date_races, 
        em.status_events,
        em.state_code_events, em.zip_events, em.name_event_type,
        em.member_number_members, em.event_website_url,
        em.registration_url, em.email_users, em.created_at_events
    )
    -- SELECT * FROM event_metrics_cte; -- 2709

    -- ================================================
    -- Step 2: Sales data aggregation (by event) for same years
    , sales_data_cte AS (
        SELECT
            s.id_sanctioning_events,
            LEFT(s.id_sanctioning_events, 6) AS id_sanctioning_events_6_digits,
            s.id_sanctioning_events_and_type,
            REPLACE(s.name_events, '"', '') AS name_events,
            s.starts_year_events,
            s.starts_events,
            s.status_events,
            s.state_code_events,
            s.zip_events,
            s.name_event_type,
            s.race_director_id_events,
            s.created_at_events,
            COUNT(DISTINCT s.id_membership_periods_sa) AS sales_units,
            SUM(s.sales_revenue) AS sales_revenue
        FROM sales_key_stats_2015 s
        WHERE 1 = 1
            AND s.starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
            AND s.id_sanctioning_events NOT IN (999999) -- exclude test event
        GROUP BY
            s.id_sanctioning_events,
            s.id_sanctioning_events_and_type,
            s.name_events,
            s.starts_year_events,
            s.starts_events,
            s.status_events,
            s.state_code_events,
            s.zip_events,
            s.name_event_type,
            s.race_director_id_events,
            s.created_at_events
    )
    -- SELECT * FROM sales_data_cte; -- 2031

    -- ================================================
    -- Step 3: "Orphan" sales (no event match)
    , missing_sales_cte AS (
        SELECT
            NULL AS id_sanctioning_events,
            s.name_events AS name_events_or_sales,
            s.starts_year_events AS starts_year_events,
            s.starts_events AS starts_events,
            NULL AS start_date_races,
            s.status_events AS status_events,
            s.state_code_events AS state_code_events,
            s.zip_events AS zip_events,
            s.name_event_type AS name_event_type,
            s.race_director_id_events AS RaceDirectorUserID,
            NULL AS event_website_url,
            NULL AS registration_url,
            NULL AS email_users,
            s.created_at_events AS created_at_events,
            s.id_sanctioning_events_and_type AS id_sanctioning_events_and_type,
            s.sales_units,
            s.sales_revenue,
            'from missing_in_event_data_metrics' AS source
        FROM sales_data_cte s
        LEFT JOIN event_metrics_cte em ON em.id_sanctioning_events = s.id_sanctioning_events_and_type
            AND em.starts_year_events = s.starts_year_events
        WHERE em.id_sanctioning_events IS NULL
    )
    -- SELECT * FROM missing_sales_cte; -- 23

    -- ================================================
    -- Step 4: Combine event details + sales data
    , combined_event_sales_data_cte AS (
        SELECT
            em.id_sanctioning_events AS ApplicationID,
            TRIM(BOTH '"' FROM em.name_events) AS Name,
            DATE_FORMAT(em.starts_events, '%Y-%m-%d') AS StartDate,
            DATE_FORMAT(em.start_date_races, '%Y-%m-%d') AS RaceDate,
            em.status_events AS Status,
            em.state_code_events AS 2LetterCode,
            em.zip_events AS ZipCode,
            em.name_event_type AS Value,
            em.RaceDirectorUserID,
            em.event_website_url AS Website,
            em.registration_url AS RegistrationWebsite,
            em.email_users AS Email,
            DATE_FORMAT(em.created_at_events, '%Y-%m-%d') AS CreatedDate,
            s.id_sanctioning_events_and_type,
            s.sales_units,
            s.sales_revenue,
            'from_event_data_metrics' AS source
        FROM event_metrics_cte em
            LEFT JOIN sales_data_cte s ON em.id_sanctioning_events = s.id_sanctioning_events_and_type
                AND em.starts_year_events = s.starts_year_events

        UNION ALL

        -- Include orphan sales
        SELECT
            id_sanctioning_events_and_type AS ApplicationID,
            name_events_or_sales AS Name,
            DATE_FORMAT(starts_events, '%Y-%m-%d') AS StartDate,
            NULL AS RaceDate,
            status_events AS Status,
            state_code_events AS 2LetterCode,
            zip_events AS ZipCode,
            name_event_type AS Value,
            RaceDirectorUserID,
            NULL AS Website,
            NULL AS RegistrationWebsite,
            NULL AS Email,
            DATE_FORMAT(created_at_events, '%Y-%m-%d') AS CreatedDate,
            id_sanctioning_events_and_type,
            sales_units,
            sales_revenue,
            source
        FROM missing_sales_cte
    )

    -- SELECT
    --     YEAR(StartDate),
    --     FORMAT(SUM(sales_units), 0) AS sales_units,
    --     FORMAT(SUM(sales_revenue), 0) AS sales_revenue
    -- FROM combined_event_sales_data_cte
    -- GROUP BY 1
    -- ORDER BY 1

    -- ================================================
    -- Step 5: Final select, ordered for clarity
    SELECT
        ApplicationID,
        Name,
        StartDate,
        RaceDate,
        Status,
        2LetterCode,
        ZipCode,
        Value,
        RaceDirectorUserID,
        Website,
        RegistrationWebsite,
        Email,
        CreatedDate,
        sales_units,
        sales_revenue,
        source
    FROM combined_event_sales_data_cte
    ORDER BY source ASC, ApplicationID, StartDate, Name
;

