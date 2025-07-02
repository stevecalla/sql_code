USE usat_sales_db;

SELECT * FROM sales_key_stats_2015 LIMIT 10;
SELECT * FROM event_data_metrics LIMIT 10;

SELECT 
	id_sanctioning_events,
    event_type_id_events,
    id_membership_periods_sa,
    real_membership_types_sa,
    new_member_category_6_sa
FROM sales_key_stats_2015 
WHERE id_sanctioning_events IN (350398)
LIMIT 10
;

SELECT
    LEFT(id_sanctioning_events, 6),
    id_sanctioning_events,
    COUNT(DISTINCT(id_sanctioning_events))
FROM event_data_metrics
WHERE 1 = 1
	AND id_sanctioning_events IS NOT NULL
	AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
GROUP BY 1, 2
ORDER BY 1 DESC, 2
;

WITH event_metrics_cte AS (
    -- 1. Extract distinct sanctioning IDs from event_data_metrics
    SELECT
        id_sanctioning_events,
        LEFT(id_sanctioning_events, 6) AS id_sanctioning_events_6_digits,
        starts_year_events
    FROM event_data_metrics
    WHERE 1 = 1
		AND id_sanctioning_events IS NOT NULL
        AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
),
sales_data_cte AS (
    -- 2. Extract sales data with first 6 chars for join
    SELECT
        id_sanctioning_events,
        LEFT(id_sanctioning_events, 6) AS id_sanctioning_events_6_digits,
        name_events,
        starts_year_events,
        COUNT(DISTINCT id_membership_periods_sa) AS sales_units,
        SUM(sales_revenue) AS sales_revenue
    FROM sales_key_stats_2015
    WHERE 1 = 1
		AND id_sanctioning_events IS NOT NULL
        AND starts_year_events IN (YEAR(CURDATE()), YEAR(CURDATE()) - 1)
        -- AND starts_year_events IN (YEAR(CURDATE()))
		-- AND id_sanctioning_events IN (307440)
	GROUP BY
        id_sanctioning_events,
        name_events,
        starts_year_events
)
-- 3. Merge (join) sales with event metrics
SELECT
    s.id_sanctioning_events AS sales_id_sanctioning_events,
    em. id_sanctioning_events_6_digits,
    REPLACE(s.name_events, '"', '') AS name_events,
    s.starts_year_events,
    s.sales_units,
    s.sales_revenue,
    COUNT(DISTINCT s.id_sanctioning_events) AS count_unique_events
FROM sales_data_cte s
	LEFT JOIN event_metrics_cte em ON s.id_sanctioning_events_6_digits = em.id_sanctioning_events_6_digits
WHERE 1 = 1
	-- AND s.id_sanctioning_events IN (307440)
GROUP BY
    s.id_sanctioning_events,
    em.id_sanctioning_events,
    s.name_events,
    s.starts_year_events
ORDER BY s.id_sanctioning_events
-- LIMIT 10
;
