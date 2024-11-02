USE usat_sales_db;

SELECT * FROM all_membership_sales_data_2015_left LIMIT 10;

-- CREATE INDEX idx_name_events ON all_membership_sales_data_2015_left (name_events);
-- CREATE INDEX idx_name_events_starts_events ON all_membership_sales_data_2015_left (name_events, starts_events);
-- ALTER TABLE all_membership_sales_data_2015_left 
-- ADD COLUMN name_events_lower VARCHAR(255) AS (LOWER(name_events));
-- CREATE INDEX idx_event_search ON all_membership_sales_data_2015_left (
--     starts_month_events,
--     starts_year_events,
--     purchased_on_mp,
--     purchased_on_adjusted_mp,
--     name_events_lower
-- );
-- CREATE INDEX idx_id_events ON all_membership_sales_data_2015_left (id_events);


SELECT
	DISTINCT(name_events),
    starts_events,
    COUNT(*)
FROM all_membership_sales_data_2015_left
WHERE LOWER(name_events) LIKE '%chicago%'  -- Case-insensitive search for 'Chicago'
GROUP BY 1, 2
-- LIMIT 10
;

SELECT
	DISTINCT(name_events),
    starts_events,
    COUNT(*)
FROM all_membership_sales_data_2015_left
WHERE 
	-- starts_month_events IN (8)
    starts_year_events IN (2023)
    -- AND purchased_on_mp > purchased_on_adjusted_mp
    AND purchased_on_month_mp IN (12)
    AND purchased_on_month_mp > purchased_on_month_adjusted_mp
	-- AND LOWER(name_events) LIKE '%chicago%'  -- Case-insensitive search for 'Chicago'
    -- AND name_events_lower LIKE LOWER('%Louisville%')
GROUP BY 1, 2
ORDER BY starts_events
-- LIMIT 10
;

SELECT
	DISTINCT(name_events),
    starts_events,
    COUNT(*)
FROM all_membership_sales_data_2015_left
WHERE LOWER(name_events) LIKE '%chicago%'  -- Case-insensitive search for 'Chicago'
-- WHERE LOWER(name_events) LIKE '%Kerrville Triathlon%'  -- Case-insensitive search
-- WHERE name_events_lower IN ('%chicago%', '%New York City Triathlon%', '%Kerrville Triathlon%', '%Brewhouse Triathlon%', '%W.I.L.D Hodag Mini-Triathlon%', '%Rock N RollMan%')
GROUP BY 1, 2
-- LIMIT 10
;

SELECT
	DISTINCT(name_events)
    , id_events
    , starts_events
    , member_number_members_sa
    , id_membership_periods_sa
    , purchased_on_mp
    , purchased_on_adjusted_mp
    , real_membership_types_sa
    , new_member_category_6_sa
    , COUNT(DISTINCT member_number_members_sa) AS member_count
    , COUNT(id_membership_periods_sa) AS sales_units
    , SUM(actual_membership_fee_6_sa) AS sales_revenue
FROM all_membership_sales_data_2015_left
WHERE 
	-- id_events IN (307658)
    -- LOWER(real_membership_types_sa) IN ('adult_annual')
	-- AND 
	YEAR(starts_mp) IN (2023)
    AND
	LOWER(name_events) LIKE '%chicago%'  -- Case-insensitive search for 'Chicago'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
-- LIMIT 10
;