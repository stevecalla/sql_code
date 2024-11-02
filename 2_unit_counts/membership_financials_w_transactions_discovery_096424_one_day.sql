-- USE vapor;

-- -- One Day Consolidated Purchase 6
-- -- { fixed [Member Number (Members)],[Created At Membership Periods], [Starts], [Ends], [Membership Type Id (Membership Periods)], [Sanctioning Event Id], [Origin Flag (Membership Periods)], [Payment Type], [Race Type Id], [Distance Type Id], [Order Id], [Confirmation Code]: 
-- -- max(if [Real Membership Types] = "One Day" then [Id (Membership Periods)] END)}

-- SET @year = 2021;
-- SET @start_date = '2023-01-01 09:00:00';
-- SET @end_date = '2023-01-01 12:00:00';

WITH membership_sales_one_day_purchase_6 AS (
    SELECT 
        members.member_number AS member_number_members,
        MAX(membership_periods.id) as max_membership_period_id,
        CASE
            WHEN membership_periods.membership_type_id IN (1, 2, 3, 52, 55, 60, 62, 64, 65, 66, 67, 68, 70, 71, 73, 74, 75, 85, 89, 91, 93, 96, 98, 99, 101, 103, 104, 112, 113, 114, 117, 119) THEN 'adult_annual'
            WHEN membership_periods.membership_type_id IN (4, 51, 54, 61, 94, 107) THEN 'youth_annual'
            WHEN membership_periods.membership_type_id IN (5, 46, 47, 72, 97, 100, 115, 118) THEN 'one_day'
            WHEN membership_periods.membership_type_id IN (56, 58, 81, 105) THEN 'club'
            WHEN membership_periods.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) THEN 'elite'
            ELSE "other"
        END AS real_membership_types,

        DATE(membership_periods.created_at) AS created_at_membership_periods,

        YEAR(membership_periods.purchased_on) as purchased_on_year_membership_periods,

        membership_periods.starts AS starts,
        membership_periods.ends AS ends,
        membership_periods.membership_type_id AS membership_type_id_membership_periods,
        events.sanctioning_event_id AS sanctioning_event_id,
        membership_periods.origin_flag AS origin_flag_membership_periods,
        membership_applications.payment_type AS payment_type,
        membership_applications.race_type_id AS race_type_id,
        membership_applications.distance_type_id AS distance_type_id,
        order_products.order_id AS order_id,
        membership_applications.confirmation_code AS confirmation_code,
        membership_periods.membership_type_id
        
    FROM membership_applications
        LEFT JOIN order_products ON (membership_applications.id = order_products.purchasable_id)
        LEFT JOIN orders ON (order_products.order_id = orders.id)
        LEFT JOIN registration_audit ON (membership_applications.membership_period_id = registration_audit.membership_period_id)
        LEFT JOIN registration_audit_membership_application ON (registration_audit.id = registration_audit_membership_application.audit_id)
        RIGHT JOIN membership_periods ON (membership_applications.membership_period_id = membership_periods.id)
        LEFT JOIN membership_types ON (membership_applications.membership_type_id = membership_types.id)
        RIGHT JOIN members ON (membership_periods.member_id = members.id)
        RIGHT JOIN profiles ON (members.memberable_id = profiles.id)
        LEFT JOIN users ON (profiles.user_id = users.id)
        LEFT JOIN events ON (membership_applications.event_id = events.id)
        LEFT JOIN transactions ON (orders.id = transactions.order_id)
    
    WHERE
        -- #1 = ~80,947 records for = 2021
        -- year(membership_periods.purchased_on) = @year
        year(membership_periods.purchased_on) >= @year
        -- #2 = 78,027 is allowable below; where purchased = 2021
        -- #3 = 78,071; where purchased = 2021
        AND membership_periods.id NOT IN (4652554) 
        -- #4 = 78,071; where purchased = 2021
        AND membership_periods.membership_type_id NOT IN (56, 58, 81, 105) 
        -- #5 = 78,071; where purchased = 2021
        AND membership_periods.membership_type_id > 0
        -- #6 = 78,024; where purchased = 2021
        AND membership_periods.terminated_on IS NULL
        -- #7 = 40,735; where purchased = 2021
        AND membership_periods.ends >= '2022-01-01'

        -- todo: use case for bronze 6 relay being priced at $23; added rule above if rama.price_paid = 6 then price at 6
        -- AND membership_periods.id IN (4698020, 4636868) 

        -- todo: revenue is off at 46 but should be 13 + 13 or 26; i think it's 23 for each?
        -- AND members.member_number IN (3281)

        -- todo: SHOULD HAVE 2 UNIQUE member_period_id but consolidates to the max?
        -- AND members.member_number IN (3281)

        -- GENERAL DATA CHECKS
        -- one day = 21, 521, 572, 3281 = ALL MATCH IN TABLEAU
        -- AND members.member_number IN (2, 7, 9, 21, 24, 386, 406, 477, 521, 572, 3281)

        -- #2 = 78,072; where purchased = 2021
        AND (CASE 
            WHEN membership_periods.membership_type_id IN (5, 46, 47, 72, 97, 100, 115, 118) THEN 1
            ELSE 0 END ) = 1 -- one_day only
        -- is allowable
        AND 
        (CASE
            -- WHEN `Created At (Membership Periods)` <= TIMESTAMP('2021-12-16 06:25:14') 
            WHEN membership_periods.created_at <= '2021-12-16 06:25:14'
                -- AND `Source` = 'Membership System/RTAV Classic' 
                AND CASE
                        WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
                        WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
                        WHEN membership_types.name IS NOT NULL THEN 'Other'
                        -- ELSE 'null' -- Optional, for cases where none of the conditions are met
                    END = 'Membership System/RTAV Classic'
                -- AND `Deleted` IS NULL 
                AND CASE
                        WHEN 
                            members.deleted_at IS NOT NULL OR 
                            membership_periods.deleted_at IS NOT NULL OR 
                            profiles.deleted_at IS NOT NULL OR 
                            users.deleted_at IS NOT NULL THEN 'deleted'
                        ELSE 'active'  -- You can use 'active' or another label based on your preference
                    END = 'active'
                -- AND `Captured and Processed` = 'C&P'            
                AND CASE
                        WHEN transactions.captured = 1 AND transactions.processed = 1 THEN 'C&P'
                        ELSE 'Other'  -- You can use 'Other' or another label based on your preference
                    END = 'C&P'
                -- AND `Deleted At (Order Products)` IS NULL 
                AND order_products.deleted_at IS NULL
                -- AND `Purchasable Type` = 'membership-application' 
                AND order_products.purchasable_type IN ('membership-application')
            THEN 'Allowable'

            WHEN 
                -- `Source` = 'Membership System/RTAV Classic' 
                CASE
                    WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
                    WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
                    WHEN membership_types.name IS NOT NULL THEN 'Other'
                    -- ELSE 'null' -- Optional, for cases where none of the conditions are met
                END = 'Membership System/RTAV Classic'
            --     AND `Deleted` IS NULL 
                AND CASE
                        WHEN members.deleted_at IS NOT NULL OR 
                            membership_periods.deleted_at IS NOT NULL OR 
                            profiles.deleted_at IS NOT NULL OR 
                            users.deleted_at IS NOT NULL THEN 'deleted'
                        ELSE 'active'  -- You can use 'active' or another label based on your preference
                    END = 'active'
            --     AND `Captured and Processed` = 'C&P'           
                AND CASE
                        WHEN transactions.captured = 1 AND transactions.processed = 1 THEN 'C&P'
                        ELSE 'Other'  -- You can use 'Other' or another label based on your preference
                    END = 'C&P'
            --     AND `Deleted At (Order Products)` IS NULL  
                AND order_products.deleted_at IS NULL
            --     AND `Purchasable Processed At` IS NOT NULL 
                AND order_products.purchasable_processed_at IS NOT NULL
            --     AND `Purchasable Type` = 'membership-application'
                AND order_products.purchasable_type IN ('membership-application')
            THEN 'Allowable'

            WHEN 
                -- `Source` = 'RTAV Batch'
                CASE
                    WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
                    WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
                    WHEN membership_types.name IS NOT NULL THEN 'Other'
                    -- ELSE 'null' -- Optional, for cases where none of the conditions are met
                END = 'RTAV Batch'
                --     AND `Deleted` IS NULL
                AND CASE
                        WHEN members.deleted_at IS NOT NULL OR 
                            membership_periods.deleted_at IS NOT NULL OR 
                            profiles.deleted_at IS NOT NULL OR 
                            users.deleted_at IS NOT NULL THEN 'deleted'
                        ELSE 'active'  -- You can use 'active' or another label based on your preference
                    END = 'active'
            THEN 'Allowable'

            WHEN 
                -- `Source` = 'Other' 
                CASE
                    WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
                    WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
                    WHEN membership_types.name IS NOT NULL THEN 'Other'
                    -- ELSE 'null' -- Optional, for cases where none of the conditions are met
                END = 'Other'
            --     AND `Deleted` IS NULL
                AND CASE
                        WHEN members.deleted_at IS NOT NULL OR 
                            membership_periods.deleted_at IS NOT NULL OR 
                            profiles.deleted_at IS NOT NULL OR 
                            users.deleted_at IS NOT NULL THEN 'deleted'
                        ELSE 'active'  -- You can use 'active' or another label based on your preference
                    END = 'active'
            THEN 'Allowable'

            WHEN 
                -- `Source` IS NULL
                CASE
                    WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
                    WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
                    WHEN membership_types.name IS NOT NULL THEN 'Other'
                    -- ELSE 'null' -- Optional, for cases where none of the conditions are met
                END IS NULL
                --     AND `Deleted` IS NULL
                AND CASE
                        WHEN members.deleted_at IS NOT NULL OR 
                            membership_periods.deleted_at IS NOT NULL OR 
                            profiles.deleted_at IS NOT NULL OR 
                            users.deleted_at IS NOT NULL THEN 'deleted'
                        ELSE 'active'  -- You can use 'active' or another label based on your preference
                    END = 'active'
            THEN 'Allowable'

            ELSE 'Not Allowable'
        END) = "Allowable"
    GROUP BY 
        members.member_number,
        Date(membership_periods.created_at),
        membership_periods.starts,
        membership_periods.ends,
        membership_periods.membership_type_id ,
        events.sanctioning_event_id,
        membership_periods.origin_flag ,
        membership_applications.payment_type ,
        membership_applications.race_type_id ,
        membership_applications.distance_type_id ,
        order_products.order_id ,
        membership_applications.confirmation_code,
        membership_periods.membership_type_id,
        CASE
            WHEN membership_periods.membership_type_id IN (1, 2, 3, 52, 55, 60, 62, 64, 65, 66, 67, 68, 70, 71, 73, 74, 75, 85, 89, 91, 93, 96, 98, 99, 101, 103, 104, 112, 113, 114, 117, 119) THEN 'adult_annual'
            WHEN membership_periods.membership_type_id IN (4, 51, 54, 61, 94, 107) THEN 'youth_annual'
            WHEN membership_periods.membership_type_id IN (5, 46, 47, 72, 97, 100, 115, 118) THEN 'one_day'
            WHEN membership_periods.membership_type_id IN (56, 58, 81, 105) THEN 'club'
            WHEN membership_periods.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) THEN 'elite'
            ELSE "other"
        END
    -- LIMIT 10
)

-- GET ALL DETAILED RECORDS = 46K for 2021
-- SELECT * FROM membership_sales_one_day_purchase_6
-- SELECT * FROM membership_sales_one_day_purchase_6 ORDER BY member_number_members

-- GET COUNT = 46K for 2021
-- SELECT
--     COUNT(DISTINCT max_membership_period_id) as purchases
-- FROM membership_sales_one_day_purchase_6

-- PROVIDES MEMBER & MEMBER PERIOD GRANULAR LEVEL PRICE
-- SELECT
--     purchased_on_year_membership_periods,
--     real_membership_types,
--     member_number_members,
--     max_membership_period_id,
--     new_member_category_6
-- FROM membership_sales_one_day_purchase_6
-- ORDER BY purchased_on_year_membership_periods

-- GET COUNT BY YEAR = 
SELECT
    purchased_on_year_membership_periods,
    FORMAT(COUNT(*), 0) AS total_count
FROM membership_sales_one_day_purchase_6
GROUP BY purchased_on_year_membership_periods WITH ROLLUP
ORDER BY purchased_on_year_membership_periods    
;
