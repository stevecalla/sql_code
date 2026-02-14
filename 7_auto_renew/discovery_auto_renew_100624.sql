 USE vapor;

SELECT * FROM braintree_subscriptions LIMIT 10; -- 49,861
SELECT "count_query" AS query_label, COUNT(*) FROM braintree_subscriptions LIMIT 10; -- 49,861

SELECT 
    DISTINCT(status), 
	"status_query" AS query_label,
    COUNT(DISTINCT customer_id) AS distinct_customer_count,
    COUNT(*) FROM braintree_subscriptions 
GROUP BY status WITH ROLLUP -- status: "active", "canceled", "fail", "past due", "pending", "success"
;

SELECT 
    COUNT(DISTINCT customer_id) AS distinct_customer_count, 
    COUNT(customer_id) 
FROM braintree_subscriptions LIMIT 10; -- distinct = 38,676; total 49,861

-- 1 - NEXT BILLING BY YEAR
    SELECT 
        YEAR(next_billing_date),
        SUM(CASE WHEN YEAR(next_billing_date) NOT IN (2024, 2025, 2026, 2027, 2028, 2029) THEN 1 ELSE 0 END) AS `other`,
        SUM(CASE WHEN YEAR(next_billing_date) = 2024 THEN 1 ELSE 0 END) AS `next_2024`,
        SUM(CASE WHEN YEAR(next_billing_date) = 2025 THEN 1 ELSE 0 END) AS `next_2025`,
        SUM(CASE WHEN YEAR(next_billing_date) = 2026 THEN 1 ELSE 0 END) AS `next_2026`,
        SUM(CASE WHEN YEAR(next_billing_date) = 2027 THEN 1 ELSE 0 END) AS `next_2027`,
        SUM(CASE WHEN YEAR(next_billing_date) = 2028 THEN 1 ELSE 0 END) AS `next_2028`,
        SUM(CASE WHEN YEAR(next_billing_date) = 2029 THEN 1 ELSE 0 END) AS `next_2029`,
        SUM(CASE WHEN YEAR(next_billing_date) > 2029 THEN 1 ELSE 0 END) AS `next_2030+`,
        FORMAT(COUNT(*), 0)
    FROM braintree_subscriptions bs
    WHERE  
        bs.deleted_at IS NULL 
        AND bs.status NOT IN ('canceled', 'fail', 'past due') -- 17,846 records
    GROUP BY 1 WITH ROLLUP
    ORDER BY 1 ASC;
-- *********************************

-- 2 - NEXT BILLING BY YEAR, MONTH, DATE
    SELECT 
        YEAR(next_billing_date),
        MONTH(next_billing_date),
        next_billing_date,

        SUM(CASE WHEN YEAR(next_billing_date) = 2024 THEN 1 ELSE 0 END) AS `next_2024`,
        SUM(CASE WHEN YEAR(next_billing_date) = 2025 THEN 1 ELSE 0 END) AS `next_2025`,
        SUM(CASE WHEN YEAR(next_billing_date) = 2026 THEN 1 ELSE 0 END) AS `next_2026`,
        SUM(CASE WHEN YEAR(next_billing_date) > 2026 THEN 1 ELSE 0 END) AS `next_2027+`,

        FORMAT(COUNT(*), 0)

    FROM braintree_subscriptions bs
    WHERE  
        bs.deleted_at IS NULL 
        AND bs.status NOT IN ('canceled', 'fail', 'past due') -- 17,846 records
    GROUP BY 1,2,3 WITH ROLLUP
    ORDER BY 1 ASC;
-- *********************************

-- 3 - CREATED AT DATE
    SELECT 
        YEAR(created_at),
        SUM(CASE WHEN YEAR(created_at) < 2021 THEN 1 ELSE 0 END) AS `created_at_<2021`,
        SUM(CASE WHEN YEAR(created_at) = 2021 THEN 1 ELSE 0 END) AS `created_at_2021`,
        SUM(CASE WHEN YEAR(created_at) = 2022 THEN 1 ELSE 0 END) AS `created_at_2022`,
        SUM(CASE WHEN YEAR(created_at) = 2023 THEN 1 ELSE 0 END) AS `created_at_2023`,
        SUM(CASE WHEN YEAR(created_at) = 2024 THEN 1 ELSE 0 END) AS `created_at_2024`,
        SUM(CASE WHEN YEAR(created_at) = 2025 THEN 1 ELSE 0 END) AS `created_at_2025`,
        SUM(CASE WHEN YEAR(created_at) = 2026 THEN 1 ELSE 0 END) AS `created_at_2026`,
        SUM(CASE WHEN YEAR(created_at) >= 2027 THEN 1 ELSE 0 END) AS `created_at_2027+`,
        FORMAT(COUNT(*), 0)
    FROM braintree_subscriptions bs
    WHERE  
        bs.deleted_at IS NULL 
        AND bs.status NOT IN ('canceled', 'fail', 'past due') -- 17,846 records
    GROUP BY 1 WITH ROLLUP
    ORDER BY 1 ASC;
-- *********************************

-- 4 - BY PRICE GROUPING
    SELECT 
        price,
        SUM(CASE WHEN price < 50 THEN 1 ELSE 0 END) AS `<= 50`,
        SUM(CASE WHEN price >= 50 AND price < 70 THEN 1 ELSE 0 END) AS `> 50 & < 70`,
        SUM(CASE WHEN price > 70 AND price < 120 THEN 1 ELSE 0 END) AS `> 70 & < 120`,
        SUM(CASE WHEN price >= 120 THEN 1 ELSE 0 END) AS `>= 120`,
        FORMAT(COUNT(*), 0)
    FROM braintree_subscriptions bs
    WHERE  
        bs.deleted_at IS NULL 
        AND bs.status NOT IN ('canceled', 'fail', 'past due') -- 17,846 records
    GROUP BY 1 WITH ROLLUP
    ORDER BY 1 ASC;
-- *********************************

-- 5 - BY NEXT BILLING YEAR BY PRICE
    SELECT 
        YEAR(next_billing_date),
        SUM(CASE WHEN price < 50 THEN 1 ELSE 0 END) AS `<= 50`,
        SUM(CASE WHEN price >= 50 AND price < 70 THEN 1 ELSE 0 END) AS `> 50 & < 70`,
        SUM(CASE WHEN price > 70 AND price < 120 THEN 1 ELSE 0 END) AS `> 70 & < 120`,
        SUM(CASE WHEN price >= 120 THEN 1 ELSE 0 END) AS `>= 120`,
        FORMAT(COUNT(*), 0)
    FROM braintree_subscriptions bs
    WHERE  
        bs.deleted_at IS NULL 
        AND bs.status NOT IN ('canceled', 'fail', 'past due') -- 17,846 records
    GROUP BY 1 WITH ROLLUP
    ORDER BY 1 ASC;
-- *********************************

-- 6 - BY NEXT BILLING DATE BY STATUS
    SELECT 
        YEAR(next_billing_date),
        status,
        SUM(CASE WHEN price < 50 THEN 1 ELSE 0 END) AS `<= 50`,
        SUM(CASE WHEN price >= 50 AND price < 70 THEN 1 ELSE 0 END) AS `> 50 & < 70`,
        SUM(CASE WHEN price > 70 AND price < 120 THEN 1 ELSE 0 END) AS `> 70 & < 120`,
        SUM(CASE WHEN price >= 120 THEN 1 ELSE 0 END) AS `>= 120`,
        FORMAT(COUNT(*), 0)
    FROM braintree_subscriptions bs
    WHERE  
        bs.deleted_at IS NULL 
        AND bs.status NOT IN ('canceled', 'fail', 'past due') -- 17,846 records
    GROUP BY 1,2 WITH ROLLUP
    ORDER BY 1 ASC;
-- *********************************

-- 7 - BY UPDATED AT YEAR
    SELECT 
        YEAR(updated_at),

        SUM(CASE WHEN YEAR(updated_at) < 2021 THEN 1 ELSE 0 END) AS `updated_at_<2021`,
        SUM(CASE WHEN YEAR(updated_at) = 2021 THEN 1 ELSE 0 END) AS `updated_at_2021`,
        SUM(CASE WHEN YEAR(updated_at) = 2022 THEN 1 ELSE 0 END) AS `updated_at_2022`,
        SUM(CASE WHEN YEAR(updated_at) = 2023 THEN 1 ELSE 0 END) AS `updated_at_2023`,
        SUM(CASE WHEN YEAR(updated_at) = 2024 THEN 1 ELSE 0 END) AS `updated_at_2024`,
        SUM(CASE WHEN YEAR(updated_at) > 2024 THEN 1 ELSE 0 END) AS `updated_at_2025+`,

        FORMAT(COUNT(*), 0)

    FROM braintree_subscriptions bs
    WHERE  
        bs.deleted_at IS NULL 
        AND bs.status NOT IN ('canceled', 'fail', 'past due') -- 17,846 records
    GROUP BY 1 WITH ROLLUP
    ORDER BY 1 ASC;
-- *********************************

-- 8 - BY UPDATED AT YEAR
    SELECT 
        status,
        YEAR(updated_at),
        MONTH(updated_at),

        SUM(CASE WHEN YEAR(updated_at) < 2021 THEN 1 ELSE 0 END) AS `updated_at_<2021`,
        SUM(CASE WHEN YEAR(updated_at) = 2021 THEN 1 ELSE 0 END) AS `updated_at_2021`,
        SUM(CASE WHEN YEAR(updated_at) = 2022 THEN 1 ELSE 0 END) AS `updated_at_2022`,
        SUM(CASE WHEN YEAR(updated_at) = 2023 THEN 1 ELSE 0 END) AS `updated_at_2023`,
        SUM(CASE WHEN YEAR(updated_at) = 2024 THEN 1 ELSE 0 END) AS `updated_at_2024`,
        SUM(CASE WHEN YEAR(updated_at) > 2024 THEN 1 ELSE 0 END) AS `updated_at_2025+`,

        FORMAT(COUNT(*), 0)

    FROM braintree_subscriptions bs
    WHERE bs.deleted_at IS NULL 
        AND bs.status IN ('canceled', 'fail', 'past due') -- 17,846 records
    GROUP BY 1 WITH ROLLUP
    ORDER BY 1 ASC;
-- *********************************

-- DETERMINE THE CORRECT JOINS
SELECT DISTINCT 
    customer_id,
    COUNT(DISTINCT customer_id) AS distinct_customer_count,
    COUNT(customer_id) AS total_customer_count

FROM braintree_subscriptions AS b -- DISTINCT 27,508 / TOTAL 32,489
     INNER JOIN customers AS c ON b.customer_id = c.id -- DISTINCT 27,508 / TOTAL 32,489
     INNER JOIN users AS u ON c.user_id = u.id -- DISTINCT 27,508 / TOTAL 32,489
     INNER JOIN profiles AS p ON u.id = p.user_id -- DISTINCT 27,508 / TOTAL 32,489
     -- INNER JOIN members AS m ON p.id = m.memberable_id -- DISTINCT 27,477 / TOTAL 32,738
     LEFT JOIN members AS m ON p.id = m.memberable_id -- DISTINCT 27,508 / TOTAL 32,773
GROUP BY customer_id WITH ROLLUP
-- HAVING total_customer_count > 2;
;

-- DISTINCT TOTAL = 27,510, GRAND TOTAL = 32,492
SELECT 
	DISTINCT 												-- without distinct 17,854, with distinct 17,296
    b.customer_id
    , b.status
FROM braintree_subscriptions AS b                  
WHERE 
	b.deleted_at IS NULL 									-- 27,510
	AND b.status NOT IN ('canceled', 'fail', 'past due') 	-- 17,296
ORDER BY 1
;

-- 
SELECT 
	DISTINCT
    b.customer_id
    , b.status
    , p.id AS profile_id
    , m.memberable_id
    -- , m.memberable_type                                  -- increases the count when added?
FROM braintree_subscriptions AS b                           -- 27,510
	INNER JOIN customers AS c ON b.customer_id = c.id       -- 27,510
	INNER JOIN users AS u ON c.user_id = u.id               -- 27,510
	INNER JOIN profiles AS p ON u.id = p.user_id            -- 27,510
    -- INNER JOIN members AS m ON p.id = m.memberable_id    -- 27,479
    LEFT JOIN members AS m ON p.id = m.memberable_id        -- 27,510
WHERE 
	b.deleted_at IS NULL									-- 27,510
	AND b.status NOT IN ('canceled', 'fail', 'past due') 	-- 17,475
	AND u.deleted_at IS NULL								-- 17,451
	AND p.deleted_at IS NULL								-- 17,451
    AND m.deleted_at IS NULL								-- 17,469
	AND m.memberable_id IS NOT NULL							-- 17,450 This shows only records that don't have a memerable_id
	-- AND m.memberable_id IS NULL							-- 19 This shows only records that don't have a memerable_id
    -- {members1.memberable_type} = "profiles"              -- what is this rule? which profiles field?
ORDER BY 1, 2
;


-- CANCELLED
    SELECT 
        customer_id,
        created_at,
        updated_at,
        status,

        FORMAT(COUNT(*), 0)

    FROM braintree_subscriptions bs
    WHERE  
        bs.deleted_at IS NULL 
        AND bs.status IN ('canceled', 'fail', 'past due') -- 17,846 records
    GROUP BY 1 WITH ROLLUP
    ORDER BY 1 ASC;
-- *********************************

-- COUNT BY STATUS
    SELECT 
        DATE_FORMAT(updated_at, '%y-%m-%d') AS updated_at_date,  -- Format the date
        FORMAT(SUM(CASE WHEN status = 'canceled' THEN 1 ELSE 0 END), 0) AS count_canceled,
        FORMAT(SUM(CASE WHEN status = 'fail' THEN 1 ELSE 0 END), 0) AS count_fail,
        FORMAT(SUM(CASE WHEN status = 'past due' THEN 1 ELSE 0 END), 0) AS count_past_due,
        FORMAT(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END), 0) AS count_active,
        FORMAT(SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END), 0) AS count_pending,
        FORMAT(SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END), 0) AS count_success,
        FORMAT(SUM(CASE WHEN status NOT IN ('canceled', 'fail', 'past due', 'active', 'pending', 'success') THEN 1 ELSE 0 END), 0) AS count_other
    FROM braintree_subscriptions bs
    WHERE  
        bs.deleted_at IS NULL 
        -- AND bs.status IN ('canceled', 'fail', 'past due') 
    GROUP BY updated_at_date
    ORDER BY updated_at_date ASC;
-- *********************************

-- COUNT BY NEXT BILLING DATE
    SELECT 
        DATE_FORMAT(next_billing_date, '%y-%m-%d') AS next_billing_date,  -- Format the date
        FORMAT(SUM(CASE WHEN status = 'canceled' THEN 1 ELSE 0 END), 0) AS count_canceled,
        FORMAT(SUM(CASE WHEN status = 'fail' THEN 1 ELSE 0 END), 0) AS count_fail,
        FORMAT(SUM(CASE WHEN status = 'past due' THEN 1 ELSE 0 END), 0) AS count_past_due,
        FORMAT(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END), 0) AS count_active,
        FORMAT(SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END), 0) AS count_pending,
        FORMAT(SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END), 0) AS count_success,
        FORMAT(SUM(CASE WHEN status NOT IN ('canceled', 'fail', 'past due', 'active', 'pending', 'success') THEN 1 ELSE 0 END), 0) AS count_other
    FROM braintree_subscriptions bs
    WHERE  
        bs.deleted_at IS NULL 
        -- AND bs.status IN ('canceled', 'fail', 'past due') 
    GROUP BY next_billing_date
    ORDER BY next_billing_date ASC;
-- *********************************

-- ORIGINAL JOIN PROVIDED BY SAM
    -- NOTE: created a simplified join above
    -- NOTE: result 27,479 different than 27,510 due to missing ids in the members table thus the inner join changed to left join
    -- SELECT 
    -- 	DISTINCT
    --     `braintree_subscriptions1`.`customer_id`
    --  FROM   (`vapor`.`profiles` `profiles1` INNER JOIN ((`vapor`.`braintree_subscriptions` `braintree_subscriptions1` INNER JOIN `vapor`.`customers` `customers1` ON `braintree_subscriptions1`.`customer_id`=`customers1`.`id`) INNER JOIN `vapor`.`users` `users1` ON `customers1`.`user_id`=`users1`.`id`) ON `profiles1`.`user_id`=`users1`.`id`) INNER JOIN `vapor`.`members` `members1` ON `profiles1`.`id`=`members1`.`memberable_id` 
    -- ;
 
