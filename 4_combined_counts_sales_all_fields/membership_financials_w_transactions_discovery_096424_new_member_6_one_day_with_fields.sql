USE vapor;

-- ONE DAY WITH ALL FIELDS = actual_membership_fee_6 CALCULATION
-- { fixed [Id (Membership Periods)] : max([Membership Fee 6])}

SET @year = 2025;
SET @membership_period_ends = '2008-01-01';
SET @start_date = '2025-01-01 00:00:00';
SET @end_date = '2025-01-31 23:59:59';

-- SECTION: STEP #1 - CREATE SOURCE 2 TODO: SET TIME PERIOD
    WITH source_2_type AS (
        SELECT 
            membership_periods.id AS id_membership_periods,
            registration_audit.registration_company_id,
            order_products.order_id AS order_id_order_products,
            order_products.order_id IS NOT NULL AS is_order_id_not_null,
            membership_applications.payment_type AS payment_type_membership_applications,
            membership_applications.payment_type = 'chronotrack' AS is_payment_type_chronotrack,
            YEAR(membership_periods.purchased_on) AS purchase_on_year_membership_periods, -- added to summarize by year

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
                WHEN registration_audit.registration_company_id IS NOT NULL THEN registration_audit.registration_company_id

                WHEN order_products.order_id IS NOT NULL THEN "Braintree"
                WHEN membership_applications.payment_type LIKE '%chronotrack%' THEN 'Chronotrack'

                ELSE NULL
            END AS source_2

        FROM membership_applications
            LEFT JOIN order_products ON membership_applications.id = order_products.purchasable_id
            LEFT JOIN orders ON order_products.order_id = orders.id
            LEFT JOIN registration_audit ON membership_applications.membership_period_id = registration_audit.membership_period_id
            LEFT JOIN registration_audit_membership_application ON registration_audit.id = registration_audit_membership_application.audit_id
            RIGHT JOIN membership_periods ON membership_applications.membership_period_id = membership_periods.id
            LEFT JOIN membership_types ON membership_applications.membership_type_id = membership_types.id
            RIGHT JOIN members ON membership_periods.member_id = members.id
            RIGHT JOIN profiles ON members.memberable_id = profiles.id
            LEFT JOIN users ON profiles.user_id = users.id
            LEFT JOIN events ON membership_applications.event_id = events.id
            LEFT JOIN transactions ON orders.id = transactions.order_id
            
        WHERE 
            membership_periods.membership_type_id NOT IN (56, 58, 81, 105)
            AND membership_periods.id NOT IN (4652554)

            -- AND YEAR(membership_periods.purchased_on) >= @year
            -- AND YEAR(membership_periods.purchased_on) IN (@year)

            AND membership_periods.purchased_on >= @start_date -- TODO:
            AND membership_periods.purchased_on <= @end_date -- TODO:

            AND membership_periods.ends >= @membership_period_ends
            AND membership_periods.membership_type_id > 0
            AND membership_periods.terminated_on IS NULL

            -- REVIEW LOGIC
            -- AND order_products.order_id IS NOT NULL
            -- AND membership_applications.payment_type LIKE '%chronotrack%'
            -- AND membership_periods.id IN (3370681) -- check terminated on is not null
        GROUP BY membership_periods.id
        -- LIMIT 100
    ),

-- SECTION: STEP #2 - CREATE KOZ ACCEPTION
    -- if [Sanctioning Event Id] IN ("309904","309539","309234","309538","309537","309232") AND [Origin Flag (Membership Periods)] = "ADMIN_BULK_UPLOADER" AND ISNULL([Source 2]) then "KOZ" END
    koz_acception AS (
        SELECT 
            st.id_membership_periods as id_membership_periods,
            st.source_2,
            st.purchase_on_year_membership_periods,
            ma.membership_period_id AS id_membership_periods_membership_applications,

            mp.origin_flag AS origin_flag_membership_periods,
            mp.origin_flag IN ("ADMIN_BULK_UPLOADER") AS is_origin_flag_membership_periods_admin_bulk,

            ev.id AS id_events,
            ev.sanctioning_event_id AS id_sanctioning_event,
            ev.sanctioning_event_id IN ("309904","309539","309234","309538","309537","309232") AS id_sanctioning_event_koz,

            CASE
                WHEN ev.sanctioning_event_id IN ("309232" , "309234", "309537", "309538", "309539", "309904")
                    AND mp.origin_flag IN ("ADMIN_BULK_UPLOADER")
                    AND st.source_2 IS NULL
                THEN 1
                ELSE 0
            END AS is_koz_acception

        FROM source_2_type AS st
            LEFT JOIN membership_applications AS ma ON st.id_membership_periods = ma.membership_period_id
            LEFT JOIN membership_periods AS mp ON st.id_membership_periods = mp.id
            LEFT JOIN events AS ev ON ma.event_id = ev.id

        -- WHERE
        --     ev.sanctioning_event_id IN ("309904","309539","309234","309538","309537","309232")
        --     AND 
        --     mp.origin_flag IN ("ADMIN_BULK_UPLOADER")
        --     AND 
        --     st.source_2 IS NULL
        GROUP BY st.id_membership_periods
    ),

-- SELECT 
--     *
-- FROM koz_acception 
-- LIMIT 10  
-- ;

-- SECTION: STEP #3 - 'Actual Membership Fee 6'
-- { fixed [Id (Membership Periods)] : max([Membership Fee 6])}
    actual_membership_fee_6 AS (
        SELECT 
            ka.id_membership_periods,
            ka.source_2,
            ka.is_koz_acception,
            mp.membership_type_id AS membership_type_id_membership_periods,
            -- real_membership_types
            CASE
                WHEN mp.membership_type_id IN (1, 2, 3, 52, 55, 60, 62, 64, 65, 66, 67, 68, 70, 71, 73, 74, 75, 85, 89, 91, 93, 96, 98, 99, 101, 103, 104, 112, 113, 114, 117, 119) THEN 'adult_annual'
                WHEN mp.membership_type_id IN (4, 51, 54, 61, 94, 107) THEN 'youth_annual'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100, 115, 118) THEN 'one_day'
                WHEN mp.membership_type_id IN (56, 58, 81, 105) THEN 'club'
                WHEN mp.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) THEN 'elite'
                ELSE "other"
            END AS real_membership_types,
            mp.purchased_on,
            mp.terminated_on, -- membership period terminated on IS NULL filtered out in the source_2 CTE query above

            ma.payment_type AS payment_type_membership_applications,  
            ra.registration_company_id,

            op.cart_label AS cart_label_order_products,
            op.amount_per AS amount_per_order_products,
            op.discount AS discount_order_products,
            op.amount_refunded AS amount_refunded_order_products,
            (op.amount_per - op.discount - op.amount_refunded) AS ms_or_classic_fee_2,
            ((op.amount_per - op.discount - op.amount_refunded)  > 0) AS ms_or_classic_fee_2_greater_than_zero,

            rama.price_paid AS price_paid_registration_audit_membership_application,
            rama.price_paid IS NOT NULL AS is_rama_price_paid_null,

            -- Membership Fee 6
            MAX(
                CASE
                
                    WHEN mp.terminated_on IS NOT NULL THEN 0 -- membership period terminated on ISNULL filtered in the source_2 CTE query above 
                    
                    WHEN events.id IN ('32774', '32775') AND mp.membership_type_id IN (115) THEN 14 -- tri for cure rule; sale is at $0 then race director is billed the membership fee; added 2/4/25

                    -- elseif [Source] = "Membership System/RTAV Classic" then [MS or Classic Fee 2] // essentially does it have an Order ID
                    -- [Source] 
                        -- has a rule such that if not isnull([Cart Label]) then "Membership System/RTAV Classic"
                    -- 'MS or Classic Fee 2' = if [Amount Per] - [Discount] - [Amount Refunded] > 0 then [Amount Per] - [Discount] - [Amount Refunded] else 0 END
                        -- amount per = order_products.amount_per 
                        -- Discount = order_products.discount
                        -- Amount Refunded = order_products.amount_refunded   
                        -- this rule applies the discount for the purchase of a one day then an annual
                    WHEN op.cart_label IS NOT NULL AND ((op.amount_per - op.discount - op.amount_refunded)  > 0) THEN (op.amount_per - op.discount - op.amount_refunded)
                    WHEN op.cart_label IS NOT NULL AND ((op.amount_per - op.discount - op.amount_refunded)  <= 0) THEN 0
                    
                    WHEN ra.registration_company_id IN (1) THEN 0 -- "Designsensory"
                    WHEN ra.registration_company_id IN (23) THEN 0 -- "Acme-Usat"

                    -- 'RTAV Batch Fee'
                    -- elseif [Source] = "RTAV Batch" then [RTAV Batch Fee] //essentially does it have an Audit ID
                    -- [Source] is elseif not isnull([Price Paid]) then "RTAV Batch"
                    -- WHEN rama.price_paid IS NOT NULL THEN 1
                    WHEN rama.price_paid IN (6.41)      THEN 6
                    WHEN rama.price_paid IN (10.68)     THEN 10
                    WHEN rama.price_paid IN (13.88)     THEN 13
                    WHEN rama.price_paid IN (16.01)     THEN 15
                    WHEN rama.price_paid IN (19.22)     THEN 18
                    WHEN rama.price_paid IN (24.55)     THEN 23
                    WHEN rama.price_paid IN (32.03)     THEN 30
                    WHEN rama.price_paid IN (38.43)     THEN 36
                    WHEN rama.price_paid IN (42.70)     THEN 40
                    WHEN rama.price_paid IN (53.38)     THEN 50
                    WHEN rama.price_paid IN (64.05)     THEN 60
                    WHEN rama.price_paid IN (105.68)    THEN 99  
                    WHEN rama.price_paid IS NOT NULL    THEN rama.price_paid -- assigns 6, 13, 18, 23 et al as appropriate

                    -- WHEN mp.origin_flag = "ADMIN_BULK_UPLOADER" AND ma.payment_type = "ironman-ticketsocket" THEN 23 -- remove 12/6/24 per Eric Passe replaced with below
                    WHEN mp.origin_flag = 'admin_bulk_uploader' and ma.payment_type = 'ironman-ticketsocket' and mp.membership_type_id in (115) then 23
                    WHEN mp.origin_flag = 'admin_bulk_uploader' and ma.payment_type = 'ironman-ticketsocket' and mp.membership_type_id in (112) then 60
                    WHEN mp.origin_flag = 'admin_bulk_uploader' and ma.payment_type = 'ironman-ticketsocket' and mp.membership_type_id in (113) then 99

                    -- 'KOZ Acception'
                    WHEN mp.origin_flag = "ADMIN_BULK_UPLOADER" AND ma.payment_type != "Chronotrack" AND ka.is_koz_acception IN (0) THEN 0 -- ISNULL('KOZ Acception')
                    WHEN mp.origin_flag = "RTAV_CLASSIC" THEN 0
                    WHEN ma.payment_type = "comped" THEN 0
                    WHEN ma.payment_type = "normal" AND mp.membership_type_id IN (74, 103) THEN 0 -- 'No Home Member ID' = "Lifetime"
                    -- 'KOZ Acception' & coach recert
                    WHEN
                        ma.confirmation_code IS NULL        AND 
                        ma.payment_type != "Chronotrack"    AND 
                        ma.payment_type != "stripe"         AND 
                        -- ISNULL('KOZ Acception')
                        ka.is_koz_acception IN (0)          AND 
                        -- ISNULL('Coach Recert')
                        CASE        
                            WHEN ma.payment_explanation LIKE '%recert%' THEN 'coach_recert'
                            WHEN ma.payment_explanation LIKE '%cert%' THEN 'coach_recert'
                            WHEN ma.payment_explanation LIKE '%coach%' THEN 'coach_recert'
                            WHEN ma.payment_type LIKE '%stripe%' THEN 'coach_recert' -- 2024 forward
                            ELSE NULL
                        END IS NULL THEN 0
                    WHEN mp.membership_type_id IN (2, 52, 65, 70, 73, 91, 93, 96, 98) THEN 100 -- 2year
                    WHEN mp.membership_type_id IN (3, 66, 68, 85, 89, 99, 119) AND mp.purchased_on < '2024-06-04 12:00:00' THEN 135 -- 3year
                    WHEN mp.membership_type_id IN (3, 66, 68, 85, 89, 99, 119) THEN 180 -- 3year
                    WHEN mp.membership_type_id IN (74, 103) THEN 1000 -- lifetime
                    WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND ma.event_id IN (30785, 30768, 30770) THEN 0 -- one-day; //these events were comped
                    -- 'KOZ Acception'
                    WHEN ka.is_koz_acception IN (1) AND mp.membership_type_id IN (4, 51, 54, 61, 94) THEN 10 -- youth = youth annual; 'KOZ Acception' = "KOZ"
                    WHEN ka.is_koz_acception THEN 15 -- 'KOZ Acception' = "KOZ"
                    WHEN mp.membership_type_id IN (4, 51, 54, 61, 94) THEN 10 -- youth = youth annual
                    WHEN mp.membership_type_id IN (112) THEN 60 -- silver
                    WHEN mp.membership_type_id IN (113) THEN 99 -- gold
                    WHEN mp.membership_type_id IN (114) THEN 400 -- platinum team usa
                    WHEN mp.membership_type_id IN (117) THEN 400 -- platinum foundation
                    WHEN mp.membership_type_id IN (115) THEN 23 -- bronze
                    WHEN ma.membership_type_id = 118 THEN 0 -- bronze
                    WHEN mp.membership_type_id IN (107) AND mp.purchased_on >= '2024-01-16 09:00:00' THEN 30 -- youth premier
                    WHEN mp.membership_type_id IN (55) AND mp.purchased_on >= '2024-01-16 09:00:00' THEN 40 -- young adult
                    WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mp.purchased_on >= '2024-01-16 09:00:00' THEN 23  -- one day
                    WHEN mp.membership_type_id IN (1, 60, 62, 64, 67, 71, 75, 104) AND mp.purchased_on >= '2024-01-16 09:00:00' THEN 60 -- 1year
                    WHEN mp.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) AND mp.purchased_on >= '2023-11-01 09:00:00' THEN 60 -- elite
                    WHEN mp.membership_type_id IN (107) THEN 25 -- youth premier
                    WHEN mp.membership_type_id IN (55) THEN 36 -- young adult
                    WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) THEN 15 -- one day
                    WHEN mp.membership_type_id IN (1, 60, 62, 64, 67, 71, 75, 104) THEN 50 -- 1 year
                    WHEN mp.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) THEN 50 -- elite
                    ELSE 0
                END
            ) AS max_membership_fee_6,

            COUNT(mp.purchased_on)

        FROM koz_acception AS ka
            LEFT JOIN membership_applications AS ma ON ka.id_membership_periods = ma.membership_period_id
            LEFT JOIN membership_periods AS mp ON ka.id_membership_periods = mp.id
            LEFT JOIN registration_audit AS ra ON ka.id_membership_periods = ra.membership_period_id
            LEFT JOIN order_products AS op ON ma.id = op.purchasable_id
            LEFT JOIN registration_audit_membership_application AS rama ON ra.id = rama.audit_id
            LEFT JOIN events ON ma.event_id = events.id

        -- WHERE 
            -- mp.terminated_on IS NULL
            -- ma.payment_type = "ironman-ticketsocket"
            -- ra.registration_company_id IN (1, 23)
            -- op.cart_label IS NOT NULL
            -- rama.price_paid IS NOT NULL
            -- mp.membership_type_id IN (107) AND mp.purchased_on >= '2024-01-16 09:00:00' -- THEN 30
            -- mp.membership_type_id IN (55) AND mp.purchased_on >= '2024-01-16 09:00:00' -- THEN 40

            -- use case for bronze 6 relay being priced at $23; added rule above if rama.price_paid = 6 then price at 6
            -- id_membership_periods IN (4698020, 4636868) 

        GROUP BY ka.id_membership_periods
    )

    , actual_membership_fee_6_rule AS ( 
        SELECT 
            ka.id_membership_periods,

            -- Membership Fee 6
            MAX(
                CASE
                    WHEN mp.terminated_on IS NOT NULL THEN '1_term_rule' -- membership period terminated on ISNULL filtered in the source_2 CTE query above 
                    
                    WHEN events.id IN ('32774', '32775') AND mp.membership_type_id IN (115) THEN '35_tri_for_cure' -- tri for cure rule; sale is at $0 then race director is billed the membership fee; added 02/04/25

                    -- elseif [Source] = "Membership System/RTAV Classic" then [MS or Classic Fee 2] // essentially does it have an Order ID
                    -- [Source] 
                        -- has a rule such that if not isnull([Cart Label]) then "Membership System/RTAV Classic"
                    -- 'MS or Classic Fee 2' = if [Amount Per] - [Discount] - [Amount Refunded] > 0 then [Amount Per] - [Discount] - [Amount Refunded] else 0 END
                        -- amount per = order_products.amount_per 
                        -- Discount = order_products.discount
                        -- Amount Refunded = order_products.amount_refunded   
                        -- this rule applies the discount for the purchase of a one day then an annual
                    WHEN op.cart_label IS NOT NULL AND ((op.amount_per - op.discount - op.amount_refunded)  > 0) THEN '2_ops_cart_>_0'
                    WHEN op.cart_label IS NOT NULL AND ((op.amount_per - op.discount - op.amount_refunded)  <= 0) THEN '3_ops_cart_<=_0'
                    
                    WHEN ra.registration_company_id IN (1) THEN '4_design_sensory' -- "Designsensory"
                    WHEN ra.registration_company_id IN (23) THEN '5_acme_usat' -- "Acme-Usat"

                    -- 'RTAV Batch Fee'
                    -- elseif [Source] = "RTAV Batch" then [RTAV Batch Fee] //essentially does it have an Audit ID
                    -- [Source] is elseif not isnull([Price Paid]) then "RTAV Batch"
                    -- WHEN rama.price_paid IS NOT NULL THEN 1
                    WHEN rama.price_paid IN (6.41)      THEN '7_rtav_batch_fee_6'
                    WHEN rama.price_paid IN (10.68)     THEN '7_rtav_batch_fee_10'
                    WHEN rama.price_paid IN (13.88)     THEN '7_rtav_batch_fee_13'
                    WHEN rama.price_paid IN (16.01)     THEN '7_rtav_batch_fee_15'
                    WHEN rama.price_paid IN (19.22)     THEN '7_rtav_batch_fee_18'
                    WHEN rama.price_paid IN (24.55)     THEN '7_rtav_batch_fee_23'
                    WHEN rama.price_paid IN (32.03)     THEN '7_rtav_batch_fee_30'
                    WHEN rama.price_paid IN (38.43)     THEN '7_rtav_batch_fee_36'
                    WHEN rama.price_paid IN (42.70)     THEN '7_rtav_batch_fee_40'
                    WHEN rama.price_paid IN (53.38)     THEN '7_rtav_batch_fee_50'
                    WHEN rama.price_paid IN (64.05)     THEN '7_rtav_batch_fee_60'
                    WHEN rama.price_paid IN (105.68)    THEN '7_rtav_batch_fee_99'
                    WHEN rama.price_paid IS NOT NULL    THEN '7_rtav_batch_fee_not_null' -- assigns 6, 13, 18, 23 et al as appropriate

                    -- WHEN mp.origin_flag = "ADMIN_BULK_UPLOADER" AND ma.payment_type = "ironman-ticketsocket" THEN 23 -- remove 12/6/24 per Eric Passe replaced with below
                    WHEN mp.origin_flag = 'admin_bulk_uploader' and ma.payment_type = 'ironman-ticketsocket' and mp.membership_type_id in (115) then '8_ironman_bulk_23' -- 23
                    WHEN mp.origin_flag = 'admin_bulk_uploader' and ma.payment_type = 'ironman-ticketsocket' and mp.membership_type_id in (112) then '8_ironman_bulk_60' -- 60
                    WHEN mp.origin_flag = 'admin_bulk_uploader' and ma.payment_type = 'ironman-ticketsocket' and mp.membership_type_id in (113) then '8_ironman_bulk_90' -- 99

                    -- 'KOZ Acception'
                    WHEN mp.origin_flag = "ADMIN_BULK_UPLOADER" AND ma.payment_type != "Chronotrack" AND ka.is_koz_acception IN (0) THEN '9_chronotrack_bulk_koz_0' -- 0 -- ISNULL('KOZ Acception')
                    WHEN mp.origin_flag = "RTAV_CLASSIC" THEN '10_origin_rtav_classic' -- 0
                    WHEN ma.payment_type = "comped" THEN  '11_payment_type_comp_0' -- 0
                    WHEN ma.payment_type = "normal" AND mp.membership_type_id IN (74, 103) THEN '12_payment_type_normal_lifetime_0' -- 0 -- 'No Home Member ID' = "Lifetime"

                    -- 'KOZ Acception' & coach recert
                    WHEN
                        ma.confirmation_code IS NULL        AND 
                        ma.payment_type != "Chronotrack"    AND 
                        ma.payment_type != "stripe"         AND 
                        -- ISNULL('KOZ Acception')
                        ka.is_koz_acception IN (0)          AND 
                        -- ISNULL('Coach Recert')
                        CASE        
                            WHEN ma.payment_explanation LIKE '%recert%' THEN 'coach_recert'
                            WHEN ma.payment_explanation LIKE '%cert%' THEN 'coach_recert'
                            WHEN ma.payment_explanation LIKE '%coach%' THEN 'coach_recert'
                            WHEN ma.payment_type LIKE '%stripe%' THEN 'coach_recert' -- 2024 forward
                            ELSE NULL
                        END IS NULL THEN '13_koz_acception_coach_recert_0' -- 0
                    WHEN mp.membership_type_id IN (2, 52, 65, 70, 73, 91, 93, 96, 98) THEN '14_2_year_100' -- 100 -- 2year
                    WHEN mp.membership_type_id IN (3, 66, 68, 85, 89, 99, 119) AND mp.purchased_on < '2024-06-04 12:00:00' THEN '15_3_year_135' -- 135 -- 3year
                    WHEN mp.membership_type_id IN (3, 66, 68, 85, 89, 99, 119) THEN '15_3_year_180' -- 180 -- 3year
                    WHEN mp.membership_type_id IN (74, 103) THEN '16_lifetime_1000' -- 1000 -- lifetime
                    WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND ma.event_id IN (30785, 30768, 30770) THEN '17_comped_events_0' --  0 -- one-day; //these events were comped
                    -- 'KOZ Acception'
                    WHEN ka.is_koz_acception IN (1) AND mp.membership_type_id IN (4, 51, 54, 61, 94) THEN '18_koz_acception_youth_annual_10' -- 10 -- youth = youth annual; 'KOZ Acception' = "KOZ"
                    WHEN ka.is_koz_acception THEN '19_koz_acception_15' -- 15 -- 'KOZ Acception' = "KOZ"
                    WHEN mp.membership_type_id IN (4, 51, 54, 61, 94) THEN '20_youth_annual_10' -- 10 -- youth = youth annual
                    WHEN mp.membership_type_id IN (112) THEN '21_silver_60' -- 60 -- silver
                    WHEN mp.membership_type_id IN (113) THEN '22_gold_99' -- 99 -- gold
                    WHEN mp.membership_type_id IN (114) THEN '23_platinum_team_usa_400' -- 400 -- platinum team usa
                    WHEN mp.membership_type_id IN (117) THEN '23_platinum_foundation_400' -- 400 -- platinum foundation
                    WHEN mp.membership_type_id IN (115) THEN '24_bronze_23' -- 23 -- bronze
                    WHEN ma.membership_type_id = 118 THEN '25_bronze_0' -- 0 -- bronze
                    WHEN mp.membership_type_id IN (107) AND mp.purchased_on >= '2024-01-16 09:00:00' THEN '26_youth_premier_>=_2024-01-16_30' -- 30 -- youth premier
                    WHEN mp.membership_type_id IN (55) AND mp.purchased_on >= '2024-01-16 09:00:00' THEN '27_youth_adult_>=_2024-01-16_40' -- 40 -- young adult
                    WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mp.purchased_on >= '2024-01-16 09:00:00' THEN '27_one_day_>=_2024-01-16_23' -- 23  -- one day
                    WHEN mp.membership_type_id IN (1, 60, 62, 64, 67, 71, 75, 104) AND mp.purchased_on >= '2024-01-16 09:00:00' THEN '28_1_year_>=_2024-01-16_60' -- 60 -- 1year
                    WHEN mp.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) AND mp.purchased_on >= '2023-11-01 09:00:00' THEN '29_elite_>=_2024-01-16_60' -- 60 -- elite
                    WHEN mp.membership_type_id IN (107) THEN '30_youth_premier_25' -- 25 -- youth premier
                    WHEN mp.membership_type_id IN (55) THEN '31_youth_adult_36' -- 36 -- young adult
                    WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) THEN '32_one_day_15' -- 15 -- one day
                    WHEN mp.membership_type_id IN (1, 60, 62, 64, 67, 71, 75, 104) THEN '33_1_year_50'-- 50 -- 1 year
                    WHEN mp.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) THEN '34_elite_50' -- 50 -- elite
                    ELSE 0
                END
            ) AS max_membership_fee_6_rule

        FROM koz_acception AS ka
            LEFT JOIN membership_applications AS ma ON ka.id_membership_periods = ma.membership_period_id
            LEFT JOIN membership_periods AS mp ON ka.id_membership_periods = mp.id
            LEFT JOIN registration_audit AS ra ON ka.id_membership_periods = ra.membership_period_id
            LEFT JOIN order_products AS op ON ma.id = op.purchasable_id
            LEFT JOIN registration_audit_membership_application AS rama ON ra.id = rama.audit_id
            LEFT JOIN events ON ma.event_id = events.id

        -- WHERE 
            -- mp.terminated_on IS NULL
            -- ma.payment_type = "ironman-ticketsocket"
            -- ra.registration_company_id IN (1, 23)
            -- op.cart_label IS NOT NULL
            -- rama.price_paid IS NOT NULL
            -- mp.membership_type_id IN (107) AND mp.purchased_on >= '2024-01-16 09:00:00' -- THEN 30
            -- mp.membership_type_id IN (55) AND mp.purchased_on >= '2024-01-16 09:00:00' -- THEN 40

            -- use case for bronze 6 relay being priced at $23; added rule above if rama.price_paid = 6 then price at 6
            -- id_membership_periods IN (4698020, 4636868) 

        GROUP BY ka.id_membership_periods
    )

, -- COMMA IS NECESSARY FOR CTE BUT NOT DIRECT SQL AS ABOVE

-- GET ALL RECORDS
-- SELECT 
--     *, 
--     COUNT(*)
-- FROM actual_membership_fee_6 AS mf  
-- GROUP BY mf.id_membership_periods

-- REVIEW MEMERSHIP FEES
-- SELECT 
--     max_membership_fee_6, 
--     COUNT(*)
-- FROM actual_membership_fee_6 AS mf  
-- GROUP BY max_membership_fee_6
-- ORDER BY COUNT(*)

-- SEARCH FOR DUPLICATE RECORDS
-- SELECT 
--     mf.id_membership_periods,
--     COUNT(*)
-- FROM actual_membership_fee_6 AS mf  
-- GROUP BY mf.id_membership_periods
-- HAVING COUNT(*) = 1

-- SECTION: STEP #4 - new_member_category_6
    new_member_category_6 AS (
        SELECT 
            mf.id_membership_periods AS id_membership_periods,
            mf.source_2 AS source_2,
            mf.is_koz_acception,
            mf.real_membership_types AS real_membership_types,
            mf.max_membership_fee_6 AS max_membership_fee_6,
            r.max_membership_fee_6_rule, 

            -- new_member_category_6
            CASE
                WHEN mp.membership_type_id IN (2, 52, 65, 70, 73, 91, 93, 96, 98) THEN '2-Year'
                WHEN mp.membership_type_id IN (3, 66, 68, 85, 89, 99, 119) THEN '3-Year'
                WHEN mp.membership_type_id IN (74, 103) THEN 'Lifetime'
                WHEN mp.membership_type_id IN (4, 51, 54, 61, 94) THEN 'Youth Annual'
                WHEN mp.membership_type_id IN (112) THEN 'Silver'
                WHEN mp.membership_type_id IN (113) THEN 'Gold'
                WHEN mp.membership_type_id IN (114) THEN 'Platinum - Team USA'
                WHEN mp.membership_type_id IN (117) THEN 'Platinum - Foundation'
                WHEN mp.membership_type_id IN (1, 60, 62, 64, 67, 71, 75, 104) AND mf.max_membership_fee_6 = 60 THEN 'Silver' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (1, 60, 62, 64, 67, 71, 75, 104) AND mf.max_membership_fee_6 = 60 THEN 'Silver' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (107) AND mf.max_membership_fee_6 = 30 THEN 'Youth Premier - $30' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (55) AND mf.max_membership_fee_6 = 40 THEN 'Young Adult - $40' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (107) AND mp.purchased_on < '2024-01-16 09:00:00' THEN 'Youth Premier - $25'
                WHEN mp.membership_type_id IN (55) AND mp.purchased_on < '2024-01-16 09:00:00' THEN 'Young Adult - $36'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mp.purchased_on < '2024-01-16 09:00:00' THEN 'One Day - $15'
                WHEN mp.membership_type_id IN (1, 60, 62, 64, 67, 71, 75, 104) AND mp.purchased_on < '2024-01-16 09:00:00' THEN '1-Year $50'
                WHEN mp.membership_type_id IN (107) AND mp.purchased_on IS NULL AND mp.created_at < '2024-01-16 09:00:00' THEN 'Youth Premier - $25'
                WHEN mp.membership_type_id IN (55) AND mp.purchased_on IS NULL AND mp.created_at < '2024-01-16 09:00:00' THEN 'Young Adult - $36'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mp.purchased_on IS NULL AND mp.created_at < '2024-01-16 09:00:00' THEN 'One Day - $15'
                WHEN mp.membership_type_id IN (1, 60, 62, 64, 67, 71, 75, 104) AND mp.purchased_on IS NULL AND mp.created_at < '2024-01-16 09:00:00' THEN '1-Year $50'
                WHEN mp.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) THEN 'Elite'
                WHEN mp.membership_type_id IN (107) THEN 'Youth Premier - $30'
                WHEN mp.membership_type_id IN (55) THEN 'Young Adult - $40'
                WHEN mp.membership_type_id IN (1, 60, 62, 64, 67, 71, 75, 104) THEN 'Silver'
                WHEN mp.membership_type_id IN (118) AND ma.membership_type_id = 118 THEN 'Bronze - AO'
                WHEN mp.membership_type_id IN (115) AND ma.membership_type_id = 118 THEN 'Bronze - AO'
                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 IN (6, 9, 9.61) THEN 'Bronze - $6/$9' -- 'Actual Membership Fee 6'
                
                WHEN events.id IN ('32774', '32775') AND mp.membership_type_id IN (115) THEN 'Bronze - $13' -- tri for cure rule; sale is at $0 then race director is billed the membership fee; added 2/4/25

                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 IN (13, 14, 14.95) THEN 'Bronze - $13/$14' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 = 15 THEN 'One Day - $15' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 IN (18, 21, 22.42) THEN 'Bronze - $18/$21' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 IN (23, 28) THEN 'Bronze - $23/$28' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 = 0 THEN 'Bronze - $0' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 = 17 THEN 'Bronze - Distance Upgrade' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 = 5 THEN 'Bronze - Distance Upgrade' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 = 7 THEN 'Bronze - Distance Upgrade' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 = 10 THEN 'Bronze - Distance Upgrade' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (115) AND mf.max_membership_fee_6 = 12 THEN 'Bronze - Distance Upgrade' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mf.max_membership_fee_6 = 6 THEN 'Bronze - $6' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mf.max_membership_fee_6 IN (13, 14) THEN 'Bronze - $13/$14' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mf.max_membership_fee_6 = 15 THEN 'One Day - $15' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mf.max_membership_fee_6 IN (18, 21) THEN 'Bronze - $18/$21' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mf.max_membership_fee_6 IN (23, 28) THEN 'Bronze - $23/$28' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mf.max_membership_fee_6 = 0 THEN 'Bronze - $0' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mf.max_membership_fee_6 = 17 THEN 'Bronze - Distance Upgrade' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mf.max_membership_fee_6 = 5 THEN 'Bronze - Distance Upgrade' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mf.max_membership_fee_6 = 7 THEN 'Bronze - Distance Upgrade' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) AND mf.max_membership_fee_6 = 10 THEN 'Bronze - Distance Upgrade' -- 'Actual Membership Fee 6'
                WHEN mp.membership_type_id IN (5, 46, 47, 72, 97, 100) THEN 'Club'
                ELSE 'Unknown'
            END AS new_member_category_6,
            COUNT(*) AS count

        FROM actual_membership_fee_6 AS mf
            LEFT JOIN actual_membership_fee_6_rule AS r ON mf.id_membership_periods = r.id_membership_periods 
            LEFT JOIN membership_applications AS ma ON mf.id_membership_periods = ma.membership_period_id
            LEFT JOIN membership_periods AS mp ON mf.id_membership_periods = mp.id
            LEFT JOIN events ON ma.event_id = events.id

        GROUP BY mf.id_membership_periods
    )

-- HAVE COUNT OF 2 = '3381399', '3396728'
-- SELECT 
--     * 
-- FROM new_member_category_6 AS mc
-- -- WHERE mc.id_membership_periods IN ('3381399', '3396728')
-- GROUP BY mc.id_membership_periods
-- ORDER BY mc.count DESC;
-- -- LIMIT 10

, -- COMMA IS NECESSARY FOR CTE BUT NOT DIRECT SQL AS ABOVE

-- SECTION: STEP #5 - ONE DAY SALES ACTUAL MEMBER FEE
    one_day_sales_actual_member_fee AS (
        SELECT 
            members.member_number AS member_number_members,
            MAX(membership_periods.id) as max_membership_period_id,
            max_membership_fee_6_rule, 
            mc.real_membership_types,
            -- CASE
            --     WHEN membership_periods.membership_type_id IN (1, 2, 3, 52, 55, 60, 62, 64, 65, 66, 67, 68, 70, 71, 73, 74, 75, 85, 89, 91, 93, 96, 98, 99, 101, 103, 104, 112, 113, 114, 117, 119) THEN 'adult_annual'
            --     WHEN membership_periods.membership_type_id IN (4, 51, 54, 61, 94, 107) THEN 'youth_annual'
            --     WHEN membership_periods.membership_type_id IN (5, 46, 47, 72, 97, 100, 115, 118) THEN 'one_day'
            --     WHEN membership_periods.membership_type_id IN (56, 58, 81, 105) THEN 'club'
            --     WHEN membership_periods.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) THEN 'elite'
            --     ELSE "other"
            -- END AS real_membership_types,
            
            mc.max_membership_fee_6 AS max_membership_fee_6,
            mc.new_member_category_6,
            mc.source_2,
            mc.is_koz_acception,

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
            
            LEFT JOIN new_member_category_6 AS mc ON membership_periods.id = mc.id_membership_periods   
        WHERE
            -- #1 = ~80,947 records for = 2021
            -- year(membership_periods.purchased_on) = @year

            -- year(membership_periods.purchased_on) >= @year

            membership_periods.purchased_on >= @start_date -- TODO:
            AND membership_periods.purchased_on <= @end_date -- TODO:

            -- #2 = 78,027 is allowable below; where purchased = 2021
            -- #3 = 78,071; where purchased = 2021
            
            AND 
            membership_periods.id NOT IN (4652554)
            -- #4 = 78,071; where purchased = 2021
            AND membership_periods.membership_type_id NOT IN (56, 58, 81, 105) 
            -- #5 = 78,071; where purchased = 2021
            AND membership_periods.membership_type_id > 0
            -- #6 = 78,024; where purchased = 2021
            AND membership_periods.terminated_on IS NULL
            -- #7 = 40,735; where purchased = 2021
            
            AND membership_periods.ends >= @membership_period_ends

            -- use case start period date before purchase period date
            -- AND year(membership_periods.purchased_on) IN (2024)
            -- AND year(membership_periods.starts) IN (2023)
            -- AND membership_periods.starts < DATE_FORMAT(membership_periods.purchased_on, '%Y-%m-%d')
            -- AND membership_periods.id IN (4568485, 4568489, 4568495, 4568512, 4568789, 4568809, 4568872, 4569507, 4569627, 4569799)

            -- use case for bronze 6 relay being priced at $23; added rule above if rama.price_paid = 6 then price at 6
            -- AND membership_periods.id IN (4698020, 4636868) 

            -- revenue is off at 46 but should be 13 + 13 or 26; i think it's 23 for each?
            -- AND members.member_number IN (3281)

            -- SHOULD HAVE 2 UNIQUE member_period_id but consolidates to the max?
            -- AND members.member_number IN (3281)

            -- GENERAL DATA CHECKS
            -- one day = 21, 521, 572, 3281 = ALL MATCH IN TABLEAU
            -- AND members.member_number IN (2, 7, 9, 21, 24, 386, 406, 477, 521, 572, 3281)

            -- #2 = 78,072; where purchased = 2021
            -- one day logic starts
            AND (CASE 
                    WHEN membership_periods.membership_type_id IN (5, 46, 47, 72, 97, 100, 115, 118) THEN 1
                    ELSE 0 
                END 
            ) = 1 -- one_day only
            -- one day logic ends

            -- is allowable
            AND 
            (CASE
                -- WHEN 'Created At (Membership Periods)' <= TIMESTAMP('2021-12-16 06:25:14') 
                WHEN membership_periods.created_at <= '2021-12-16 06:25:14'
                    -- AND 'Source' = 'Membership System/RTAV Classic' 
                    AND CASE
                            WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
                            WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
                            WHEN membership_types.name IS NOT NULL THEN 'Other'
                            -- ELSE 'null' -- Optional, for cases where none of the conditions are met
                        END = 'Membership System/RTAV Classic'
                    -- AND 'Deleted' IS NULL 
                    AND CASE
                            WHEN 
                                members.deleted_at IS NOT NULL OR 
                                membership_periods.deleted_at IS NOT NULL OR 
                                profiles.deleted_at IS NOT NULL OR 
                                users.deleted_at IS NOT NULL THEN 'deleted'
                            ELSE 'active'  -- You can use 'active' or another label based on your preference
                        END = 'active'
                    -- AND 'Captured and Processed' = 'C&P'            
                    AND CASE
                            WHEN transactions.captured = 1 AND transactions.processed = 1 THEN 'C&P'
                            ELSE 'Other'  -- You can use 'Other' or another label based on your preference
                        END = 'C&P'
                    -- AND 'Deleted At (Order Products)' IS NULL 
                    AND order_products.deleted_at IS NULL
                    -- AND 'Purchasable Type' = 'membership-application' 
                    AND order_products.purchasable_type IN ('membership-application')
                THEN 'Allowable'

                WHEN 
                    -- 'Source' = 'Membership System/RTAV Classic' 
                    CASE
                        WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
                        WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
                        WHEN membership_types.name IS NOT NULL THEN 'Other'
                        -- ELSE 'null' -- Optional, for cases where none of the conditions are met
                    END = 'Membership System/RTAV Classic'
                --     AND 'Deleted' IS NULL 
                    AND CASE
                            WHEN members.deleted_at IS NOT NULL OR 
                                membership_periods.deleted_at IS NOT NULL OR 
                                profiles.deleted_at IS NOT NULL OR 
                                users.deleted_at IS NOT NULL THEN 'deleted'
                            ELSE 'active'  -- You can use 'active' or another label based on your preference
                        END = 'active'
                --     AND 'Captured and Processed' = 'C&P'           
                    AND CASE
                            WHEN transactions.captured = 1 AND transactions.processed = 1 THEN 'C&P'
                            ELSE 'Other'  -- You can use 'Other' or another label based on your preference
                        END = 'C&P'
                --     AND 'Deleted At (Order Products)' IS NULL  
                    AND order_products.deleted_at IS NULL
                --     AND 'Purchasable Processed At' IS NOT NULL 
                    AND order_products.purchasable_processed_at IS NOT NULL
                --     AND 'Purchasable Type' = 'membership-application'
                    AND order_products.purchasable_type IN ('membership-application')
                THEN 'Allowable'

                WHEN 
                    -- 'Source' = 'RTAV Batch'
                    CASE
                        WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
                        WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
                        WHEN membership_types.name IS NOT NULL THEN 'Other'
                        -- ELSE 'null' -- Optional, for cases where none of the conditions are met
                    END = 'RTAV Batch'
                    --     AND 'Deleted' IS NULL
                    AND CASE
                            WHEN members.deleted_at IS NOT NULL OR 
                                membership_periods.deleted_at IS NOT NULL OR 
                                profiles.deleted_at IS NOT NULL OR 
                                users.deleted_at IS NOT NULL THEN 'deleted'
                            ELSE 'active'  -- You can use 'active' or another label based on your preference
                        END = 'active'
                THEN 'Allowable'

                WHEN 
                    -- 'Source' = 'Other' 
                    CASE
                        WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
                        WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
                        WHEN membership_types.name IS NOT NULL THEN 'Other'
                        -- ELSE 'null' -- Optional, for cases where none of the conditions are met
                    END = 'Other'
                --     AND 'Deleted' IS NULL
                    AND CASE
                            WHEN members.deleted_at IS NOT NULL OR 
                                membership_periods.deleted_at IS NOT NULL OR 
                                profiles.deleted_at IS NOT NULL OR 
                                users.deleted_at IS NOT NULL THEN 'deleted'
                            ELSE 'active'  -- You can use 'active' or another label based on your preference
                        END = 'active'
                THEN 'Allowable'

                WHEN 
                    -- 'Source' IS NULL
                    CASE
                        WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
                        WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
                        WHEN membership_types.name IS NOT NULL THEN 'Other'
                        -- ELSE 'null' -- Optional, for cases where none of the conditions are met
                    END IS NULL
                    --     AND 'Deleted' IS NULL
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
            DATE(membership_periods.created_at),
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
        -- LIMIT 1000 -- max_membership_fee_6_rule
    )

-- GET ALL DETAILED RECORDS = 46K for 2021
-- SELECT * FROM one_day_sales_actual_member_fee
-- SELECT * FROM one_day_sales_actual_member_fee ORDER BY member_number_members

-- GET COUNT = 46K for 2021
-- SELECT
--     COUNT(DISTINCT max_membership_period_id) as purchases
-- FROM one_day_sales_actual_member_fee

-- PROVIDES MEMBER & MEMBER PERIOD GRANULAR LEVEL PRICE
-- SELECT
--     purchased_on_year_membership_periods,
--     real_membership_types,
--     member_number_members,
--     max_membership_period_id,
--     new_member_category_6,
--     FORMAT(max_membership_fee_6, 0)
-- FROM one_day_sales_actual_member_fee
-- ORDER BY purchased_on_year_membership_periods

-- GET COUNT BY YEAR = 
-- SELECT
--     purchased_on_year_membership_periods,
--     FORMAT(COUNT(*), 0) AS total_count,
--     FORMAT(SUM(max_membership_fee_6), 0)
-- FROM one_day_sales_actual_member_fee
-- GROUP BY purchased_on_year_membership_periods WITH ROLLUP
-- ORDER BY purchased_on_year_membership_periods

    , -- COMMA IS NECESSARY FOR CTE BUT NOT DIRECT SQL AS ABOVE

-- SECTION: STEP #6 - jOIN WITH ALL FIELDS
    add_all_fields AS (
        SELECT 
            -- ALL FIELDS / ONE DAY SALES / ACTUAL MEMBER FEE TABLE (CTE)
            -- sa = sales actual
            sa.member_number_members AS member_number_members_sa,
            sa.max_membership_period_id AS id_membership_periods_sa,

            -- DERIVED FIELDS
                sa.real_membership_types AS real_membership_types_sa,
                sa.new_member_category_6 AS new_member_category_6_sa,
                sa.max_membership_fee_6 AS actual_membership_fee_6_sa,
                sa.max_membership_fee_6_rule,
                sa.max_membership_fee_6_rule AS actual_membership_fee_6_rule_sa,
                sa.source_2 AS source_2_sa,
                sa.is_koz_acception AS is_koz_acception_sa,

            -- EVENTS TABLE
                -- events.address AS address_events,
                -- events.allow_one_day_purchases AS allow_one_day_purchases_events,
                -- events.athlete_guide_url AS athlete_guide_url_events,
                -- events.certified_race_director AS certified_race_director_events,
                -- events.city AS city_events,
                -- events.country_code AS country_code_events,
                -- events.country_name AS country_name_events,
                -- events.country AS country_events,
                -- events.created_at AS created_at_events,
                -- events.deleted_at AS deleted_at_events,
                -- events.distance AS distance_events,
                -- events.ends AS ends_events,
                -- events.event_type_id AS type_id_events,
                -- events.event_website_url AS website_url_events,
                -- events.facebook_url AS facebook_url_events,
                -- events.featured_at AS featured_at_events,

                events.id AS id_events, -- fix tri for cure
                events.sanctioning_event_id AS id_sanctioning_event,

                CASE 
                    WHEN r.designation IS NOT NULL AND r.designation != '' 
                        THEN CONCAT(events.sanctioning_event_id, '-', r.designation)
                    ELSE events.sanctioning_event_id
                END AS id_sanctioning_events_and_type, -- TODO:
                CASE 
                    WHEN r.designation IS NOT NULL AND r.designation != '' THEN CONCAT(events.sanctioning_event_id, '-', r.designation)
                    WHEN events.event_type_id = 1 THEN CONCAT(events.sanctioning_event_id, '-', 'Adult Race')
                    WHEN events.event_type_id = 2 THEN CONCAT(events.sanctioning_event_id, '-', 'Adult Clinic')
                    WHEN events.event_type_id = 3 THEN CONCAT(events.sanctioning_event_id, '-', 'Youth Race')
                    WHEN events.event_type_id = 4 THEN CONCAT(events.sanctioning_event_id, '-', 'Youth Clinic')
                    ELSE events.sanctioning_event_id
                END AS id_sanctioning_events_and_type,

                -- events.instagram_url AS instagram_url_events,
                -- events.last_season_event_id AS last_season_event_id,

                events.name AS name_events, -- fix tri for cure

                -- events.qualification_deadline AS qualification_deadline_events,
                -- events.qualification_url AS qualification_url_events,
                -- events.race_director_id AS race_director_id_events,
                -- events.registration_company_event_id AS registration_company_event_id,
                -- events.registration_policy_url AS registration_policy_url_events,
                -- events.remote_id AS remote_id_events,
                -- events.sanctioning_event_id AS id_sanctioning_event,
                -- events.starts AS starts_events,
                -- events.state_code AS state_code_events,
                -- events.state_id AS state_id_events,
                -- events.state_name AS state_name_events,
                -- events.state AS state_events,
                -- events.status AS status_events,
                -- events.twitter_url AS twitter_url_events,
                -- events.updated_at AS updated_at_events,
                -- events.virtual AS virtual_events,
                -- events.youtube_url AS youtube_url_events,
                -- events.zip AS zip_events,
                -- SUBSTRING(events.overview, 1, 1024) AS overview_events,
                -- CONCAT('"', SUBSTRING(events.registration_information, 1, 1024), '"') AS registration_information_events,
                -- -- SUBSTRING(events.registration_information, 1, 1024) AS registration_information_events,
                -- SUBSTRING(events.registration_url, 1, 1024) AS registration_url_events,

           -- EVENT TYPE TABLE
            et.id AS id_event_types, -- TODO:
            events.event_type_id AS id_event_type_events, -- TODO:
            CASE
                WHEN r.designation IS NOT NULL THEN r.designation
                WHEN r.designation IS NULL AND events.event_type_id = 1 THEN 'Adult Race'
                WHEN r.designation IS NULL AND events.event_type_id = 2 THEN 'Adult Clinic'
                WHEN r.designation IS NULL AND events.event_type_id = 3 THEN 'Youth Race'
                WHEN r.designation IS NULL AND events.event_type_id = 4 THEN 'Youth Clinic'
                ELSE "missing_event_type_race_designation"
            END AS name_event_type, -- TODO:
            
            -- MEMBERS TABLE
                -- members.active AS active_members,
                -- members.created_at AS created_at_members,
                -- members.deleted_at AS deleted_at_members,
                -- members.id AS id_members,
                -- members.longevity_status AS longevity_status_members,
                -- members.member_number AS member_number_members,
                -- members.memberable_id AS memberable_id_members,
                -- members.memberable_type AS memberable_type_members,
                -- members.period_status AS period_status_members,
                -- members.referrer_code AS referrer_code_members,
                -- members.updated_at AS updated_at_members,

            -- MEMBERSHIP PERIODS TABLE
                mp.id AS id_mp,
                mp.created_at AS created_at_mp,
                mp.deleted_at AS deleted_at_mp,
                mp.ends AS ends_mp,
                mp.member_id AS member_id_mp,
                mp.membership_type_id AS membership_type_id_mp,
                mp.origin_flag AS origin_flag_mp,
                mp.origin_status AS origin_status_mp,
                mp.origin AS origin_mp,
                mp.period_status AS period_status_mp,
                mp.progress_status AS progress_status_mp,

                mp.purchased_on AS purchased_on_mp,
                YEAR(mp.purchased_on) AS purchased_on_year_mp,
                
                CASE   
                    WHEN mp.starts < DATE_FORMAT(mp.purchased_on, '%Y-%m-%d') THEN mp.starts
                    ELSE mp.purchased_on
                END AS purchase_on_adjusted_mp,

                CASE   
                    WHEN mp.starts < DATE_FORMAT(mp.purchased_on, '%Y-%m-%d') THEN MONTH(mp.starts)
                    ELSE MONTH(mp.purchased_on)
                END AS purchase_on_month_adjusted_mp,

                CASE   
                    WHEN mp.starts < DATE_FORMAT(mp.purchased_on, '%Y-%m-%d') THEN QUARTER(mp.starts)
                    ELSE QUARTER(mp.purchased_on)
                END AS purchase_on_quarter_adjusted_mp,

                CASE   
                    WHEN mp.starts < DATE_FORMAT(mp.purchased_on, '%Y-%m-%d') THEN YEAR(mp.starts)
                    ELSE YEAR(mp.purchased_on)
                END AS purchase_on_year_adjusted_mp,

                mp.remote_id AS remote_id_mp,
                mp.renewed_membership_period_id AS renewed_membership_period_id,
                mp.starts AS starts_mp,
                mp.state AS state_mp,
                mp.status AS status_mp,
                mp.terminated_on AS terminated_on_mp,
                mp.updated_at AS updated_at_mp,
                mp.upgraded_from_id AS upgraded_from_id_mp,
                mp.upgraded_to_id AS upgraded_to_id_mp,
                mp.waiver_status AS waiver_status_mp,

            -- MEMBERSHIP TYPES TABLE
                membership_types.created_at AS created_at_mt,
                membership_types.deleted_at AS deleted_at_mt,
                membership_types.extension_type AS extension_type_mt,
                membership_types.id AS id_mt,
                membership_types.membership_card_template_id AS membership_card_template_id_mt,
                membership_types.membership_licenses_type_id AS membership_licenses_type_id_mt,
                membership_types.name AS name_mt,
                membership_types.priority AS priority_mt,
                membership_types.published AS published_mt,
                membership_types.require_admin_approval AS require_admin_approval_mt,
                membership_types.tag_id AS tag_id_mt,
                membership_types.updated_at AS updated_at_mt,
                SUBSTRING(membership_types.short_description, 1, 1024) AS short_description_mt

            -- MEMBERSHIP APPLICATIONS TABLE
                -- ma.address AS address_ma,
                -- ma.application_type AS application_type_ma,
                -- ma.approval_status AS approval_status_ma,
                -- ma.city AS city_ma,
                -- ma.confirmation_code AS confirmation_code_ma,
                -- ma.country AS country_ma,
                -- ma.created_at AS created_at_ma,
                -- ma.date_of_birth AS date_of_birth_ma,
                -- ma.deleted_at AS deleted_at_ma,
                -- ma.distance_type_id AS distance_type_id_ma,
                -- ma.email AS email_ma,
                -- ma.event_id AS event_id_ma,
                -- ma.extension_type AS extension_type_ma,
                -- ma.first_name AS first_name_ma,
                -- ma.gender AS gender_ma,
                -- ma.id AS id_ma,
                -- ma.last_name AS last_name_ma,
                -- ma.membership_period_id AS membership_period_id_ma,
                -- ma.membership_type_id AS membership_type_id_ma,
                -- ma.middle_name AS middle_name_ma,
                -- ma.origin_flag AS origin_flag_ma,
                -- ma.outside_payment AS outside_payment_ma,
                -- ma.paper_waivers_signed AS paper_waivers_signed_ma,
                -- ma.payment_id AS payment_id_ma,
                -- ma.payment_type AS payment_type_ma,
                -- ma.phone AS phone_ma,
                -- ma.plan_id AS plan_id_ma,
                -- ma.profile_id AS profile_id_ma,
                -- ma.race_id AS race_id_ma,
                -- ma.race_type_id AS race_type_id_ma,
                -- ma.referral_code AS referral_code_ma,
                -- ma.state AS state_ma,
                -- ma.status AS status_ma,
                -- ma.updated_at AS updated_at_ma,
                -- ma.uuid AS uuid_ma,
                -- ma.zip AS zip_ma,
                -- SUBSTRING(ma.club_affiliations, 1, 1024) AS club_affiliations_ma,
                -- SUBSTRING( ma.denial_reason, 1, 1024) AS denial_reason_ma,
                -- SUBSTRING(ma.payment_explanation, 1, 1024) AS payment_explanation_ma,
                -- SUBSTRING(ma.upgrade_code, 1, 1024) AS upgrade_code_ma,

            -- ORDER PRODUCTS TABLE
                -- op.amount_charged_back AS amount_charged_back_orders_products,
                -- op.amount_per AS amount_per_orders_products,
                -- op.amount_refunded AS amount_refunded_orders_products,
                -- op.base_price AS base_price_orders_products,
                -- op.cart_description AS cart_description_orders_products,
                -- op.cart_label AS cart_label_orders_products,
                -- op.created_at AS created_at_orders_products,
                -- op.deleted_at AS deleted_at_orders_products, 
                -- op.discount AS discount_orders_products,
                -- op.id AS id_order_products,
                -- op.option_amount_per AS option_amount_per_orders_products,
                , op.order_id AS order_id_orders_products
                -- op.original_tax AS original_tax_orders_products,
                -- op.original_total AS original_total_orders_products,
                -- op.processed_at AS processed_at_orders_products,
                -- op.product_description AS product_description_orders_products,
                -- op.product_id AS product_id_orders_products,
                -- op.purchasable_id AS purchasable_id_orders_products,
                -- op.purchasable_processed_at AS purchasable_processed_at_orders_products,
                -- op.purchasable_type AS purchasable_type,
                -- op.quantity_refunded AS quantity_refunded_orders_products,
                -- op.quantity AS quantity_orders_products,
                -- op.sku AS sku_orders_products,
                -- op.status_id AS status_id_orders_products,
                -- op.tax AS tax_orders_products,
                -- op.title AS title_orders_products,
                -- op.total AS total_orders_products,
                -- op.tracking_number AS tracking_number_orders_products,
                -- op.updated_at AS updated_at_order_products,
                -- SUBSTRING(op.options_given, 1, 1024) AS options_given_orders_products,
                -- SUBSTRING(op.tax_info, 1, 1024) AS tax_info_orders_products,
            
            -- ORDERS TABLE
                -- orders.active AS active_orders,
                -- orders.address_2 AS address_2_orders,
                -- orders.address AS address_orders,
                -- orders.amount_charged_back AS amount_charged_back_orders,
                -- orders.amount_refunded AS amount_refunded_orders,
                -- orders.city AS city_orders,
                -- orders.confirmation_number AS confirmation_number_orders,
                -- orders.country AS country_orders,
                -- orders.created_at AS created_at_orders,
                -- orders.deleted_at AS deleted_at_orders,
                -- orders.discount_code AS discount_code_orders,
                -- orders.discount AS discount_orders,
                -- orders.email AS email_orders,
                -- orders.first_name AS first_name_orders,
                -- orders.group_id AS group_id_orders,
                -- orders.handling_charge AS handling_charge_orders,
                -- orders.handling_tax AS handling_tax_orders,
                -- orders.id AS id_orders,
                -- orders.in_hand_date AS in_hand_date_orders,
                -- orders.last_name AS last_name_orders,
                -- orders.original_tax AS original_tax_orders,
                -- orders.original_total AS original_total_orders,
                -- orders.phone AS phone_orders,
                -- orders.post_process_finished_at AS post_process_finished_at_orders,
                -- orders.post_process_started_at AS post_process_started_at_orders,
                -- orders.processed AS processed_orders,
                -- orders.quote_id AS quote_id_orders,
                -- orders.ship_on AS ship_on_orders,
                -- orders.shipping_address_2 AS shipping_address_2_orders,
                -- orders.shipping_address AS shipping_address_orders,
                -- orders.shipping_city AS shipping_city_orders,
                -- orders.shipping_company AS shipping_company_orders,
                -- orders.shipping_country AS shipping_country_orders,
                -- orders.shipping_first_name AS shipping_first_name_orders,
                -- orders.shipping_last_name AS shipping_last_name_orders,
                -- orders.shipping_method AS shipping_method_orders,
                -- orders.shipping_rate AS shipping_rate_orders,
                -- orders.shipping_state AS shipping_state_orders,
                -- orders.shipping_tax AS shipping_tax_orders,
                -- orders.shipping_zip AS shipping_zip_orders,
                -- orders.state AS state_orders_orders,
                -- orders.status_id AS status_id_orders,
                -- orders.store AS store_orders,
                -- orders.subtotal AS subtotal_orders,
                -- orders.tax_transaction_code AS tax_transaction_code_orders,
                -- orders.tax AS tax_orders,
                -- orders.total AS total_orders,
                -- orders.tracking AS tracking_orders,
                -- orders.upcharge AS upcharge_orders,
                -- orders.updated_at AS updated_at_orders,
                -- orders.user_id AS user_id_orders,
                -- orders.uuid AS uuid_orders,
                -- orders.zip AS zip_orders,
                -- SUBSTRING(orders.customer_note, 1, 1024) AS customer_note_orders,
                -- SUBSTRING(orders.internal_note, 1, 1024) AS internal_note_orders,

            -- PROFILES TABLE
                , profiles.primary_address_id
                , addresses.postal_code
                , addresses.state_code
                , addresses.state_name
                , addresses.country_name
                -- profiles.active AS active_profiles,
                -- profiles.anonymous AS anonymous_profiles,
                -- profiles.created_at AS created_at_profiles,
                -- profiles.date_of_birth AS date_of_birth_profiles,
                -- profiles.deceased_recorded_on AS deceased_recorded_on_profiles,
                -- profiles.deleted_at AS deleted_at_profiles,
                -- profiles.education_id AS education_id_profiles,
                -- profiles.ethnicity_id AS ethnicity_id_profiles,
                -- profiles.first_name AS first_name_profiles_profiles,
                -- profiles.gender_id AS gender_id_profiles,
                -- profiles.gender_opt_out AS gender_opt_out_profiles,
                -- profiles.id AS id_profiles,
                -- profiles.income_id AS income_id_profiles,
                -- profiles.is_us_citizen AS is_us_citizen_profiles,
                -- profiles.last_name AS last_name_profiles,
                -- profiles.marketo_lead_id_old AS marketo_lead_id_old_profiles,
                -- profiles.marketo_lead_id AS marketo_lead_id_profiles,
                -- profiles.merged_from_profile_id AS merged_from_profile_id,
                -- profiles.merged_to_profile_id AS merged_to_profile_id,
                -- profiles.middle_name AS middle_name_profiles,
                -- profiles.military_id AS military_id_profiles,
                -- profiles.name AS name_profiles,
                -- profiles.occupation_id AS occupation_id_profiles,
                -- profiles.para AS para_profiles,
                -- profiles.primary_address_id AS primary_address_id_profiles,
                -- profiles.primary_citizenship_id AS primary_citizenship_id_profiles,
                -- profiles.primary_email_id AS primary_email_id_profiles,
                -- profiles.primary_emergency_contact_id AS primary_emergency_contact_id_profiles,
                -- profiles.primary_phone_id AS primary_phone_id_profiles,
                -- profiles.remote_id AS remote_id_profiles_profiles,
                -- profiles.suffix AS suffix_profiles,
                -- profiles.updated_at AS updated_at_profiles,
                -- profiles.user_id AS user_id_profiles,
                -- profiles.uuid AS uuid_profiles,
                -- SUBSTRING(profiles.merge_info, 1, 1024) AS merge_info_profiles,

            -- RACE TABLE / EVENT TYPE TABLE
            , r.designation as designation_races -- TODO:

            -- REGISTRATION AUDIT MEMBERSHIP APPLICATION TABLE
                -- registration_audit_membership_application.audit_id AS audit_id_rama,
                -- registration_audit_membership_application.created_at AS created_at_rama,
                -- registration_audit_membership_application.distance_type_id AS distance_type_id_rama,
                -- registration_audit_membership_application.id AS id_rama,
                -- registration_audit_membership_application.membership_application_id AS membership_application_id_rama,
                -- registration_audit_membership_application.membership_type_id AS membership_type_id_rama,
                -- registration_audit_membership_application.price_paid AS price_paid_rama,
                -- registration_audit_membership_application.race_id AS race_id_rama,
                -- registration_audit_membership_application.race_type_id AS race_type_id_rama,
                -- registration_audit_membership_application.status AS status_rama,
                -- registration_audit_membership_application.updated_at AS updated_at_rama,
                -- SUBSTRING(registration_audit_membership_application.upgrade_codes, 1, 1024) AS upgrade_codes_rama,

            -- REGISTRATION AUDIT TABLE
                -- registration_audit.address AS address_ra,
                -- registration_audit.billing_address AS billing_address_ra,
                -- registration_audit.billing_city AS billing_city_ra,
                -- registration_audit.billing_country AS billing_country_ra,
                -- registration_audit.billing_email AS billing_email_ra,
                -- registration_audit.billing_first_name AS billing_first_name_ra,
                -- registration_audit.billing_last_name AS billing_last_name_ra,
                -- registration_audit.billing_middle_name AS billing_middle_name_ra,
                -- registration_audit.billing_phone AS billing_phone_ra,
                -- registration_audit.billing_state AS billing_state_ra,
                -- registration_audit.billing_zip AS billing_zip_ra,
                -- registration_audit.city AS city_ra,
                -- registration_audit.confirmation_number AS confirmation_number_ra,
                -- registration_audit.country AS country_ra,
                -- registration_audit.created_at AS created_at_ra,
                -- registration_audit.date_of_birth AS date_of_birth_ra,
                -- registration_audit.deleted_at AS deleted_at_ra,
                -- registration_audit.email AS email_ra,
                -- registration_audit.ethnicity AS ethnicity_ra,
                -- registration_audit.event_id AS event_id_ra,
                -- registration_audit.first_name AS first_name_ra,
                -- registration_audit.gender AS gender_ra,
                , registration_audit.id AS id_registration_audit
                -- registration_audit.invoice_product_id AS invoice_product_id_ra,
                -- registration_audit.last_name AS last_name_ra,
                -- registration_audit.member_number AS member_number_ra,
                -- registration_audit.membership_period_id AS membership_period_id_ra,
                -- registration_audit.middle_name AS middle_name_ra,
                -- registration_audit.phone_number AS phone_number_ra,
                -- registration_audit.processed_at AS processed_at_ra,
                -- registration_audit.profile_id AS profile_id_ra,
                -- registration_audit.registration_company_id AS registration_company_id_ra,
                -- registration_audit.remote_audit_code AS remote_audit_code_ra,
                -- registration_audit.remote_id AS remote_id_ra,
                -- registration_audit.state AS state_ra,
                -- registration_audit.status AS status_ra,
                -- registration_audit.updated_at AS updated_at_ra,
                -- registration_audit.user_id AS user_id_ra,
                -- registration_audit.zip AS zip_ra,

            -- REGISTRATION COMPANY TABLE
                , registration_companies.name AS name_registration_companies

            -- TRANSACTIONS TABLE
                -- transactions.amount AS amount_tr,
                -- transactions.captured AS captured_tr,
                -- transactions.created_at AS created_at_tr,
                -- transactions.date AS date_tr,
                -- transactions.deleted_at AS deleted_at_tr,
                -- transactions.exported_at AS exported_at_tr,
                -- transactions.id AS id_tr,
                -- transactions.order_id AS order_id_tr,
                -- transactions.payment_id AS payment_id_tr,
                -- transactions.payment_method AS payment_method_tr,
                -- transactions.processed AS processed_tr,
                -- transactions.refunded_amount AS refunded_amount_tr,
                -- transactions.tax_transaction_code AS tax_transaction_code_tr,
                -- transactions.tax AS tax_tr,
                -- transactions.updated_at AS updated_at_tr,
                -- transactions.user_id AS user_id_tr,
                -- SUBSTRING(events.description, 1, 1024) AS description_tr,
                -- SUBSTRING(transactions.note, 1, 1024) AS note_tr,
                -- SUBSTRING(transactions.tax_transaction, 1, 1024) AS tax_transaction_tr,

            -- USERS TABLE
                -- users.active AS active_users,
                -- users.api_token AS api_token_users,
                -- users.claimed AS claimed_users,
                -- users.created_at AS created_at_users,
                -- users.deleted_at AS deleted_at_users,
                -- users.email_verified_at AS email_verified_at_users,
                -- users.email AS email_users,
                -- users.id AS id_users,
                -- users.invalid_email AS invalid_email_users,
                -- users.logged_in_at AS logged_in_at_users,
                -- users.merged_from_user_id AS merged_from_user_id_users,
                -- users.merged_to_user_id AS merged_to_user_id_users,
                -- users.name AS name_users_users,
                -- users.old_email AS old_email,
                -- users.opted_out_of_notifications AS opted_out_of_notifications_users,
                -- users.password AS password_users,
                -- users.primary AS primary_users,
                -- users.remember_token AS remember_token_users,
                -- users.remote_id AS remote_id_users,
                -- users.updated_at AS updated_at_users,
                -- users.username AS username_users,
                -- users.uuid AS uuid_users,
                -- SUBSTRING(users.invalid_email_value, 1, 1024) AS invalid_email_value_users,
                -- SUBSTRING(users.merge_info, 1, 1024) AS merge_info_users,
                -- SUBSTRING(users.personal_access_token, 1, 1024) AS personal_access_token_users

        FROM one_day_sales_actual_member_fee AS sa -- as = actual_sales

            LEFT JOIN membership_periods AS mp ON sa.max_membership_period_id = mp.id -- DONE
            LEFT JOIN membership_applications AS ma ON sa.max_membership_period_id = ma.membership_period_id -- DONE 

            LEFT JOIN order_products AS op ON ma.id = op.purchasable_id -- DONE
            LEFT JOIN orders ON op.order_id = orders.id -- DONE

            LEFT JOIN registration_audit ON sa.max_membership_period_id = registration_audit.membership_period_id
            LEFT JOIN registration_audit_membership_application ON registration_audit.id = registration_audit_membership_application.audit_id
            LEFT JOIN registration_companies ON registration_audit.registration_company_id = registration_companies.id
            
            -- RIGHT JOIN membership_periods ON (membership_applications.membership_period_id = membership_periods.id) -- DONE LINE 879

            LEFT JOIN membership_types ON ma.membership_type_id = membership_types.id -- DONE

            -- RIGHT JOIN members ON membership_periods.member_id = members.id
            LEFT JOIN members ON mp.member_id = members.id -- DONE = CHANGED FROM RIGHT JOIN TO LEFT
            -- RIGHT JOIN members ON mp.member_id = members.id -- DONE = CHANGED FROM RIGHT JOIN TO LEFT

            -- RIGHT JOIN profiles ON members.memberable_id = profiles.id
            LEFT JOIN profiles ON members.memberable_id = profiles.id -- DONE = CHANGED FROM RIGHT JOIN TO LEFT
            -- RIGHT JOIN profiles ON members.memberable_id = profiles.id -- DONE = CHANGED FROM RIGHT JOIN TO LEFT

            LEFT JOIN users ON profiles.user_id = users.id
            LEFT JOIN addresses ON profiles.primary_address_id = addresses.id

            LEFT JOIN events ON ma.event_id = events.id
            LEFT JOIN races AS r ON events.id = r.event_id -- TODO:
                AND r.deleted_at IS NULL
            LEFT JOIN event_types AS et ON events.event_type_id = et.id -- TODO:

            LEFT JOIN transactions ON orders.id = transactions.order_id  

        -- WHERE sa.max_membership_period_id = '4849363'

        GROUP BY mp.id
    )

    SELECT * FROM add_all_fields
    
    -- TODO: ADD ADJUSTED SANCTIONING ID WITH RACE DESIGNATION FIELDS
    -- WHERE 1 = 1
    --     AND id_sanctioning_event IN (308417, 350398)

    -- SELECT * FROM add_all_fields LIMIT 10

    -- SELECT * FROM add_all_fields WHERE id_events IN ('32774', '32775'); -- fix tri for cure bronze $0 to $14
    -- SELECT 
    --     * 
    -- FROM add_all_fields 
    -- WHERE id_membership_periods_sa  IN (4884522, 4884285, 4884311, 4884401, 4884369, 4884325, 4884990, 4884601, 4884383, 4884225, 4884230, 4885048)
    -- ; -- fix tri for cure bronze $0 to $14

    -- GET PRICE RULES COUNT
    -- SELECT 
    --     max_membership_fee_6_rule, 
    --     COUNT(*) 
    -- FROM add_all_fields 
    -- GROUP BY 1 WITH ROLLUP
    -- ORDER BY 1 

    -- GET COUNT BY YEAR
    -- SELECT
    --     purchased_on_year_mp,
    --     FORMAT(COUNT(*), 0) AS total_count,
    --     FORMAT(SUM(actual_membership_fee_6_sa), 0) AS total_revenue
    -- FROM add_all_fields
    -- GROUP BY purchased_on_year_mp WITH ROLLUP
    -- ORDER BY purchased_on_year_mp
-- ;

-- DONE = add source_2 & is_koz_acception to one_day_sales_actual_member_fee
-- DONE = join all fields & other tables
-- build in node/js
    -- one-day
    -- annual
    -- coaches
-- add derived fields source, is_braintree, registration_company, is_deleted, captured_and_processed, is_allowable