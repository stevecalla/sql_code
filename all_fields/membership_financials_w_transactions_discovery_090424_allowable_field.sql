USE vapor;

SELECT 
    *,
    -- USED FOR WHERE CLAUSE ALLOWABLE FIELD &/OR CUSTOM FIELDS
    membership_periods.created_at,
    order_products.deleted_at,
    order_products.purchasable_type,
    order_products.purchasable_processed_at,
    -- source
    CASE
        WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
        WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
        WHEN membership_types.name IS NOT NULL THEN 'Other'
        ELSE 'null' -- Optional, for cases where none of the conditions are met
    END AS source,
    -- source_2
    CASE
        WHEN registration_audit.registration_company_id = 1 THEN 'Designsensory'
        WHEN registration_audit.registration_company_id = 2 THEN 'Active'
        WHEN registration_audit.registration_company_id = 3 THEN 'RunSignUp'
        WHEN registration_audit.registration_company_id = 4 THEN 'SignMeUp'
        WHEN registration_audit.registration_company_id = 5 THEN 'Chronotrack'
        WHEN registration_audit.registration_company_id = 6 THEN 'TriRegistration'
        WHEN registration_audit.registration_company_id = 7 THEN 'GetMeRegistered'
        WHEN registration_audit.registration_company_id = 8 THEN 'Ticket Socket'
        WHEN registration_audit.registration_company_id = 9 THEN 'Haku Sports'
        WHEN registration_audit.registration_company_id = 10 THEN 'Race Roster'
        WHEN registration_audit.registration_company_id = 11 THEN 'Technology Projects'
        WHEN registration_audit.registration_company_id = 12 THEN 'Test'
        WHEN registration_audit.registration_company_id = 13 THEN 'RaceEntry'
        WHEN registration_audit.registration_company_id = 14 THEN 'RaceReach'
        WHEN registration_audit.registration_company_id = 15 THEN 'AthleteReg'
        WHEN registration_audit.registration_company_id = 16 THEN 'USA Triathlon'
        WHEN registration_audit.registration_company_id = 17 THEN 'Events.com'
        WHEN registration_audit.registration_company_id = 18 THEN 'Athlete Guild'
        WHEN registration_audit.registration_company_id = 19 THEN 'imATHLETE'
        WHEN registration_audit.registration_company_id = 20 THEN 'The Driven'
        WHEN registration_audit.registration_company_id = 21 THEN 'Enmotive'
        WHEN registration_audit.registration_company_id = 22 THEN 'Event Dog'
        WHEN registration_audit.registration_company_id = 23 THEN 'Acme-Usat'
        WHEN registration_audit.registration_company_id = 24 THEN 'Webconnex'
        WHEN registration_audit.registration_company_id = 25 THEN 'Trifind'
        WHEN registration_audit.registration_company_id = 26 THEN "Let's Do This"
        WHEN registration_audit.registration_company_id = 27 THEN 'Zippy Reg'
        WHEN registration_audit.registration_company_id IS NULL THEN 'Not Applicable'

        WHEN order_products.order_id IS NOT NULL THEN "Braintree"
        WHEN membership_applications.payment_type = 'chronotrack' THEN 'Chronotrack'

        ELSE registration_audit.registration_company_id  -- Converts the ID to string if it doesn't match any of the cases
    END AS source_2,

    -- is_braintree
    CASE
        WHEN order_products.order_id IS NOT NULL  THEN "Braintree"
        ELSE "Other"
    END AS is_braintree,
    -- registration_company
    CASE
        WHEN registration_audit.registration_company_id = 1 THEN 'Designsensory'
        WHEN registration_audit.registration_company_id = 2 THEN 'Active'
        WHEN registration_audit.registration_company_id = 3 THEN 'RunSignUp'
        WHEN registration_audit.registration_company_id = 4 THEN 'SignMeUp'
        WHEN registration_audit.registration_company_id = 5 THEN 'Chronotrack'
        WHEN registration_audit.registration_company_id = 6 THEN 'TriRegistration'
        WHEN registration_audit.registration_company_id = 7 THEN 'GetMeRegistered'
        WHEN registration_audit.registration_company_id = 8 THEN 'Ticket Socket'
        WHEN registration_audit.registration_company_id = 9 THEN 'Haku Sports'
        WHEN registration_audit.registration_company_id = 10 THEN 'Race Roster'
        WHEN registration_audit.registration_company_id = 11 THEN 'Technology Projects'
        WHEN registration_audit.registration_company_id = 12 THEN 'Test'
        WHEN registration_audit.registration_company_id = 13 THEN 'RaceEntry'
        WHEN registration_audit.registration_company_id = 14 THEN 'RaceReach'
        WHEN registration_audit.registration_company_id = 15 THEN 'AthleteReg'
        WHEN registration_audit.registration_company_id = 16 THEN 'USA Triathlon'
        WHEN registration_audit.registration_company_id = 17 THEN 'Events.com'
        WHEN registration_audit.registration_company_id = 18 THEN 'Athlete Guild'
        WHEN registration_audit.registration_company_id = 19 THEN 'imATHLETE'
        WHEN registration_audit.registration_company_id = 20 THEN 'The Driven'
        WHEN registration_audit.registration_company_id = 21 THEN 'Enmotive'
        WHEN registration_audit.registration_company_id = 22 THEN 'Event Dog'
        WHEN registration_audit.registration_company_id = 23 THEN 'Acme-Usat'
        WHEN registration_audit.registration_company_id = 24 THEN 'Webconnex'
        WHEN registration_audit.registration_company_id = 25 THEN 'Trifind'
        WHEN registration_audit.registration_company_id = 26 THEN "Let's Do This"
        WHEN registration_audit.registration_company_id = 27 THEN 'Zippy Reg'
        WHEN registration_audit.registration_company_id IS NULL THEN 'Not Applicable'
        ELSE registration_audit.registration_company_id  -- Converts the ID to string if it doesn't match any of the cases
    END AS registration_company,
    
    -- is_deleted
    CASE
      WHEN members.deleted_at IS NOT NULL OR 
           membership_periods.deleted_at IS NOT NULL OR 
           profiles.deleted_at IS NOT NULL OR 
           users.deleted_at IS NOT NULL THEN 'deleted'
      ELSE 'active'  -- You can use 'active' or another label based on your preference
    END AS is_deleted,
    -- captured_and_processed
    CASE
      WHEN transactions.captured = 1 AND transactions.processed = 1 THEN 'C&P'
      ELSE 'Other'  -- You can use 'Other' or another label based on your preference
    END AS captured_and_processed
    
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
    membership_periods.membership_type_id NOT IN (56, 58, 81, 105)
    AND membership_periods.id NOT IN (4652554)
    -- AND membership_periods.ends >= '2022-01-01'
ORDER BY membership_periods.created_at
LIMIT 100;

    -- allowable_status
    -- CASE
    --   WHEN membership_periods.created_at <= '2021-12-16 06:25:14'
    --        AND CASE
    --             WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
    --             ELSE 'null'
    --           END = 'Membership System/RTAV Classic'
    --        AND order_products.deleted_at IS NULL
    --        AND transactions.captured = 1 AND transactions.processed = 1 THEN 'Allowable'
    --   WHEN CASE
    --             WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
    --             ELSE 'null'
    --           END = 'Membership System/RTAV Classic'
    --        AND order_products.deleted_at IS NULL
    --        AND transactions.captured = 1 AND transactions.processed = 1
    --        AND order_products.purchasable_processed_at IS NOT NULL THEN 'Allowable'
    --   WHEN CASE
    --             WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
    --             ELSE 'null'
    --           END = 'RTAV Batch'
    --        AND order_products.deleted_at IS NULL THEN 'Allowable'
    --   WHEN CASE
    --             WHEN membership_types.name IS NOT NULL THEN 'Other'
    --             ELSE 'null'
    --           END = 'Other'
    --        AND order_products.deleted_at IS NULL THEN 'Allowable'
    --   WHEN CASE
    --             WHEN membership_types.name IS NOT NULL THEN 'Other'
    --             ELSE 'null'
    --           END IS NULL
    --        AND order_products.deleted_at IS NULL THEN 'Allowable'
    --   ELSE 'Not Allowable'  -- Optional, if you want a default value for cases not covered by the above conditions
    -- END AS allowable_status

    -- AND 
    -- CASE
    --   WHEN membership_periods.created_at <= '2021-12-16 06:25:14'
    --        AND CASE
    --             WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic' -- source
    --             ELSE 'null'
    --           END = 'Membership System/RTAV Classic'
    --        -- missing deleted
    --        AND transactions.captured = 1 AND transactions.processed = 1 -- captured_and_processed
    --        AND order_products.deleted_at IS NULL
    --        AND orders_products.purchasable_type = 'membership-applicaition' THEN 'Allowable'

    --   WHEN CASE
    --             WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
    --             ELSE 'null'
    --           END = 'Membership System/RTAV Classic'
    --        AND order_products.deleted_at IS NULL
    --        AND transactions.captured = 1 AND transactions.processed = 1
    --        AND order_products.purchasable_processed_at IS NOT NULL THEN 'Allowable'

    --   WHEN CASE
    --             WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
    --             ELSE 'null'
    --           END = 'RTAV Batch'
    --        AND order_products.deleted_at IS NULL THEN 'Allowable'

    --   WHEN CASE
    --             WHEN membership_types.name IS NOT NULL THEN 'Other'
    --             ELSE 'null'
    --           END = 'Other'
    --        AND order_products.deleted_at IS NULL THEN 'Allowable'

    --   WHEN CASE
    --             WHEN membership_types.name IS NOT NULL THEN 'Other'
    --             ELSE 'null'
    --           END IS NULL
    --        AND order_products.deleted_at IS NULL THEN 'Allowable'

    --   ELSE 'Not Allowable'  -- Optional, if you want a default value for cases not covered by the above conditions
    -- END = 'Allowable'


    -- sales purchases = countd([One Day Consolidated Purchase 6])+countd([Annual Consolidated Purchases 6])+countd([Coach Membership Purchases])
-- sales revenue = sum([Annual Consolidated Fee 6])+sum([One Day Consolidated Fee 6])+sum([Coach Membership Fee])
-- first_purchase_date = There is not one in the raw data. One would need to be made using the Purchased_On field in the Membership_Periods table
-- join with races and distance_types
