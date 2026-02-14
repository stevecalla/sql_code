USE vapor;

SELECT * FROM braintree_subscriptions AS b ORDER BY created_at DESC LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM braintree_subscriptions AS b;

-- #1 VERIFICATION
    -- DISTINCT TOTAL = 27,510, GRAND TOTAL = 32,492
    SELECT 
        DISTINCT 												-- not distinct = 17,855, distinct = 17,297
        b.customer_id
    FROM braintree_subscriptions AS b                  
    WHERE 
        b.deleted_at IS NULL 									-- 27,510
        AND b.status NOT IN ('canceled', 'fail', 'past due') 	-- 17,296
    ORDER BY 1;
-- *********************************

-- #2 - MORE VERIFICATION
    SELECT 
        DISTINCT
        b.customer_id
        , p.id AS profile_id
        , m.memberable_id
        -- , b.status                                           -- removed - b.customer_id can have muliple status
        -- , m.memberable_type                                  -- increases the count when added?
    FROM braintree_subscriptions AS b                           -- 
        INNER JOIN customers AS c ON b.customer_id = c.id       -- #2) 17,297
        INNER JOIN users AS u ON c.user_id = u.id               -- #3) see below
        INNER JOIN profiles AS p ON u.id = p.user_id            -- #4) see below
        INNER JOIN members AS m ON p.id = m.memberable_id    	-- #6) see below
        -- LEFT JOIN members AS m ON p.id = m.memberable_id     -- #5) see below
    WHERE 
        b.deleted_at IS NULL									-- 
        AND b.status NOT IN ('canceled', 'fail', 'past due') 	-- #1) 17,297
        AND u.deleted_at IS NULL								-- #3) 17,274
        AND p.deleted_at IS NULL								-- #4) 17,274
        AND m.deleted_at IS NULL								-- #5) 17,274 -- #6) 17,273
        -- AND m.memberable_id IS NOT NULL						-- 17,450 This shows only records that don't have a memerable_id
        -- AND m.memberable_id IS NULL							-- 19 This shows only records that don't have a memerable_id
        -- {members1.memberable_type} = "profiles"              -- what is this rule? which profiles field?
    ORDER BY 1;
-- *********************************

-- #3 - GET UNIQUE MEMBER NUMBER / STATS FOR AUTO-RENEW
WITH auto_renew_members AS (
    SELECT 
        b.customer_id
        , b.status
        , p.id AS profile_id
        , m.memberable_id
        , bp.label
        , bp.plan_id
        
        , CASE WHEN MIN(next_billing_date) IS NULL THEN 'is_null' ELSE MIN(next_billing_date) END AS min_next_billing_date
        , CASE WHEN YEAR(MIN(next_billing_date)) IS NULL THEN 'is_null' ELSE YEAR(MIN(next_billing_date)) END AS min_next_billing_year
        , CASE WHEN MONTH(MIN(next_billing_date)) IS NULL THEN 'is_null' ELSE MONTH(MIN(next_billing_date)) END AS min_next_billing_month

        -- , YEAR(MIN(next_billing_date)) AS min_next_billing_year
        -- , MONTH(MIN(next_billing_date)) AS min_next_billing_month
        
        , MIN(price) AS min_price
        , CASE WHEN MIN(price) < 50 THEN 1 ELSE 0 END AS `<= 50`
        , CASE WHEN MIN(price) >= 50 AND price < 70 THEN 1 ELSE 0 END AS `> 50 & < 70`
        , CASE WHEN MIN(price) > 70 AND price < 120 THEN 1 ELSE 0 END AS `> 70 & < 120`
        , CASE WHEN MIN(price) >= 120 THEN 1 ELSE 0 END AS `>= 120`

        , COUNT(DISTINCT b.customer_id) AS distinct_count
        , COUNT(b.customer_id) AS total_count
        , CASE WHEN m.memberable_id IS NULL THEN 1 ELSE 0 END AS is_blank_merberable_id
        , GROUP_CONCAT(b.status) AS status_values
        , GROUP_CONCAT(b.next_billing_date) AS next_billing_date_values
        , GROUP_CONCAT(b.price) AS price_values

    FROM braintree_subscriptions AS b
        INNER JOIN braintree_plans AS bp ON b.braintree_plans_id = bp.id  -- 
        INNER JOIN customers AS c ON b.customer_id = c.id       -- #2) 17,297
        INNER JOIN users AS u ON c.user_id = u.id               -- #3) see below
        INNER JOIN profiles AS p ON u.id = p.user_id            -- #4) see below
        INNER JOIN members AS m ON p.id = m.memberable_id    	-- #6) see below
        -- LEFT JOIN members AS m ON p.id = m.memberable_id     -- #5) see below
    WHERE 
        b.deleted_at IS NULL									-- 
        AND b.status NOT IN ('canceled', 'fail', 'past due') 	-- #1) 17,296
        AND u.deleted_at IS NULL								-- #3) 17,274
        AND p.deleted_at IS NULL								-- #4) 17,274
        AND m.deleted_at IS NULL								-- #5) 17,273 -- #6) 17,272
        -- AND m.memberable_id IS NOT NULL						-- 17,450 This shows only records that don't have a memerable_id
        -- AND m.memberable_id IS NULL							-- 19 This shows only records that don't have a memerable_id
        -- {members1.memberable_type} = "profiles"              -- what is this rule? which profiles field?
    GROUP BY 1, 2, 3
    ORDER BY 1
)

-- SELECT * FROM auto_renew_members
-- SELECT DISTINCT(b.plan_id), COUNT(*) FROM auto_renew_members GROUP BY plan_id

SELECT 
    min_next_billing_year,
    FORMAT(AVG(min_price), 2) AS average_min_price, -- Currency formatting
    FORMAT(SUM(`<= 50`), 0) AS 'unknown',            -- Number formatting
    FORMAT(SUM(`> 50 & < 70`), 0) AS 'likely silver', -- Number formatting
    FORMAT(SUM(`> 70 & < 120`), 0) AS 'likely gold',  -- Number formatting
    FORMAT(SUM(`>= 120`), 0) AS 'likely 3-year',      -- Number formatting
    FORMAT(SUM(distinct_count), 0) AS total_distinct_count, -- Number formatting
    FORMAT(SUM(total_count), 0) AS total_count,         -- Number formatting
    
    FORMAT(SUM(CASE WHEN plan_id = 'silver' THEN 1 ELSE 0 END), 0) AS count_silver,
    FORMAT(SUM(CASE WHEN plan_id = '3yrsilver' THEN 1 ELSE 0 END), 0) AS count_3yrsilver,
    FORMAT(SUM(CASE WHEN plan_id = 'gold' THEN 1 ELSE 0 END), 0) AS count_gold,
    FORMAT(SUM(CASE WHEN plan_id = '1yadultmem' THEN 1 ELSE 0 END), 0) AS count_1yadultmem,
    FORMAT(SUM(CASE WHEN plan_id IN ('silver', '3yrsilver', 'gold', '1yadultmem') THEN 1 ELSE 0 END), 0) AS count_plan_id

FROM auto_renew_members
GROUP BY min_next_billing_year WITH ROLLUP
ORDER BY min_next_billing_year

;
-- *********************************

-- GIVE SAM PRICE = 0 DATA
-- SELECT
--     *
-- FROM braintree_subscriptions AS b
-- WHERE 
--     price < 50
--     AND b.status NOT IN ('canceled', 'fail', 'past due')
-- ;

-- GIVE SAM NEXT BILLING DATE IS BLANK
-- SELECT
--     *
-- FROM braintree_subscriptions AS b
-- WHERE 
--     next_billing_date IS NULL
--     AND b.status NOT IN ('canceled', 'fail', 'past due')
-- ;
