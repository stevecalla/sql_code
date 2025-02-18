USE vapor;

-- ALL FIELDS

SELECT
    DISTINCT -- DISTINCT = ensure that the combination of all selected columns in the result set is unique

    -- EVENTS TABLE
    -- `events`.`address` AS `address_(events)`,
    -- `events`.`allow_one_day_purchases` AS `allow_one_day_purchases`,
    -- `events`.`athlete_guide_url` AS `athlete_guide_url`,
    -- `events`.`certified_race_director` AS `certified_race_director`,
    -- `events`.`city` AS `city_(events)`,
    -- `events`.`country_code` AS `country_code`,
    -- `events`.`country_name` AS `country_name`,
    -- `events`.`country` AS `country_(events)`,
    -- `events`.`created_at` AS `created_at_(events)`,
    -- `events`.`deleted_at` AS `deleted_at_(events)`,
    -- `events`.`distance` AS `distance`,
    -- `events`.`ends` AS `ends_(events)`,
    -- `events`.`event_type_id` AS `event_type_id`,
    -- `events`.`event_website_url` AS `event_website_url`,
    -- `events`.`facebook_url` AS `facebook_url`,
    -- `events`.`featured_at` AS `featured_at`,
    -- `events`.`id` AS `id_(events)`,
    -- `events`.`instagram_url` AS `instagram_url`,
    -- `events`.`last_season_event_id` AS `last_season_event_id`,
    -- `events`.`name` AS `name_(events)`,
    -- `events`.`qualification_deadline` AS `qualification_deadline`,
    -- `events`.`qualification_url` AS `qualification_url`,
    -- `events`.`race_director_id` AS `race_director_id`,
    -- `events`.`registration_company_event_id` AS `registration_company_event_id`,
    -- `events`.`registration_policy_url` AS `registration_policy_url`,
    -- `events`.`remote_id` AS `remote_id_(events)`,
    -- `events`.`sanctioning_event_id` AS `sanctioning_event_id`,
    -- `events`.`starts` AS `starts_(events)`,
    -- `events`.`state_code` AS `state_code`,
    -- `events`.`state_id` AS `state_id`,
    -- `events`.`state_name` AS `state_name`,
    -- `events`.`state` AS `state_(events)`,
    -- `events`.`status` AS `status_(events)`,
    -- `events`.`twitter_url` AS `twitter_url`,
    -- `events`.`updated_at` AS `updated_at_(events)`,
    -- `events`.`virtual` AS `virtual`,
    -- `events`.`youtube_url` AS `youtube_url`,
    -- `events`.`zip` AS `zip_(events)`,
    -- SUBSTRING(`events`.`overview`, 1, 1024) AS `overview`,
    -- SUBSTRING(`events`.`registration_information`, 1, 1024) AS `registration_information`,
    -- SUBSTRING(`events`.`registration_url`, 1, 1024) AS `registration_url`,

    -- MEMBERS TABLE
    -- `members`.`active` AS `active_(members)`,
    -- `members`.`created_at` AS `created_at_(members)`,
    -- `members`.`deleted_at` AS `deleted_at_(members)`,
    -- `members`.`id` AS `id_(members)`,
    -- `members`.`longevity_status` AS `longevity_status`,
    members.member_number AS member_number_members,
    -- `members`.`memberable_id` AS `memberable_id`,
    -- `members`.`memberable_type` AS `memberable_type`,
    -- `members`.`period_status` AS `period_status_(members)`,
    -- `members`.`referrer_code` AS `referrer_code`,
    -- `members`.`updated_at` AS `updated_at_(members)`,

    -- MEMBERSHIP APPLICATIONS TABLE
    -- `membership_applications`.`address` AS `address`,
    -- `membership_applications`.`application_type` AS `application_type`,
    -- `membership_applications`.`approval_status` AS `approval_status`,
    -- `membership_applications`.`city` AS `city`,
    -- `membership_applications`.`confirmation_code` AS `confirmation_code`,
    -- `membership_applications`.`country` AS `country`,
    -- `membership_applications`.`created_at` AS `created_at`,
    -- `membership_applications`.`date_of_birth` AS `date_of_birth`,
    -- `membership_applications`.`deleted_at` AS `deleted_at`,
    -- `membership_applications`.`distance_type_id` AS `distance_type_id`,
    -- `membership_applications`.`email` AS `email`,
    -- `membership_applications`.`event_id` AS `event_id`,
    -- `membership_applications`.`extension_type` AS `extension_type`,
    -- `membership_applications`.`first_name` AS `first_name`,
    -- `membership_applications`.`gender` AS `gender`,
    -- `membership_applications`.`id` AS `id`,
    -- `membership_applications`.`last_name` AS `last_name`,
    -- `membership_applications`.`membership_period_id` AS `membership_period_id`,
    -- `membership_applications`.`membership_type_id` AS `membership_type_id`,
    -- `membership_applications`.`middle_name` AS `middle_name`,
    -- `membership_applications`.`origin_flag` AS `origin_flag`,
    -- `membership_applications`.`outside_payment` AS `outside_payment`,
    -- `membership_applications`.`paper_waivers_signed` AS `paper_waivers_signed`,
    -- `membership_applications`.`payment_id` AS `payment_id`,
    -- `membership_applications`.`payment_type` AS `payment_type`,
    -- `membership_applications`.`phone` AS `phone`,
    -- `membership_applications`.`plan_id` AS `plan_id`,
    -- `membership_applications`.`profile_id` AS `profile_id`,
    -- `membership_applications`.`race_id` AS `race_id`,
    -- `membership_applications`.`race_type_id` AS `race_type_id`,
    -- `membership_applications`.`referral_code` AS `referral_code`,
    -- `membership_applications`.`state` AS `state`,
    -- `membership_applications`.`status` AS `status`,
    -- `membership_applications`.`updated_at` AS `updated_at`,
    -- `membership_applications`.`uuid` AS `uuid`,
    -- `membership_applications`.`zip` AS `zip`,
    -- SUBSTRING(
    --     `membership_applications`.`club_affiliations`,
    --     1,
    --     1024
    -- ) AS `club_affiliations`,
    -- SUBSTRING(
    --     `membership_applications`.`denial_reason`,
    --     1,
    --     1024
    -- ) AS `denial_reason`,
    -- SUBSTRING(
    --     `membership_applications`.`payment_explanation`,
    --     1,
    --     1024
    -- ) AS `payment_explanation`,
    -- SUBSTRING(`membership_applications`.`upgrade_code`, 1, 1024) AS `upgrade_code`,

    -- MEMBERSHIP PERIODS TABLE
    membership_periods.created_at AS `created_at_(membership_periods)`,
    -- `membership_periods`.`deleted_at` AS `deleted_at_(membership_periods)`,
    -- `membership_periods`.`ends` AS `ends`,
    -- `membership_periods`.`member_id` AS `member_id`,
    membership_periods.id AS id_membership_periods,
    membership_periods.membership_type_id AS `membership_type_id_(membership_periods)`,
    -- `membership_periods`.`origin_flag` AS `origin_flag_(membership_periods)`,
    -- `membership_periods`.`origin_status` AS `origin_status`,
    -- `membership_periods`.`origin` AS `origin`,
    -- `membership_periods`.`period_status` AS `period_status`,
    -- `membership_periods`.`progress_status` AS `progress_status`,
    membership_periods.purchased_on AS `purchased_on`,
    -- `membership_periods`.`remote_id` AS `remote_id_(membership_periods)`,
    -- `membership_periods`.`renewed_membership_period_id` AS `renewed_membership_period_id`,
    -- `membership_periods`.`starts` AS `starts`,
    -- `membership_periods`.`state` AS `state_(membership_periods)`,
    -- `membership_periods`.`status` AS `status_(membership_periods)`,
    -- `membership_periods`.`terminated_on` AS `terminated_on`,
    -- `membership_periods`.`updated_at` AS `updated_at_(membership_periods)`,
    -- `membership_periods`.`upgraded_from_id` AS `upgraded_from_id`,
    -- `membership_periods`.`upgraded_to_id` AS `upgraded_to_id`,
    -- `membership_periods`.`waiver_status` AS `waiver_status`,

    -- MEMBERSHIP TYPES TABLE
    -- `membership_types`.`created_at` AS `created_at_(membership_types)`,
    -- `membership_types`.`deleted_at` AS `deleted_at_(membership_types)`,
    -- `membership_types`.`extension_type` AS `extension_type_(membership_types)`,
    membership_types.id AS `id_(membership_types)`,
    -- `membership_types`.`membership_card_template_id` AS `membership_card_template_id`,
    -- `membership_types`.`membership_licenses_type_id` AS `membership_licenses_type_id`,
    membership_types.name AS name_membershp_types,
    -- `membership_types`.`priority` AS `priority`,
    -- `membership_types`.`published` AS `published`,
    -- `membership_types`.`require_admin_approval` AS `require_admin_approval`,
    -- `membership_types`.`tag_id` AS `tag_id`,
    -- `membership_types`.`updated_at` AS `updated_at_(membership_types)`,
    -- SUBSTRING(`membership_types`.`short_description`, 1, 1024) AS `short_description`,

    -- ORDER PRODUCTS TABLE
    -- `order_products`.`amount_charged_back` AS `amount_charged_back`,
    -- `order_products`.`amount_per` AS `amount_per`,
    -- `order_products`.`amount_refunded` AS `amount_refunded`,
    -- `order_products`.`base_price` AS `base_price`,
    -- `order_products`.`cart_description` AS `cart_description`,
    order_products.cart_label AS cart_label,
    -- `order_products`.`created_at` AS `created_at_(order_products)`,
    order_products.deleted_at AS `deleted_at_(order_products)`, 
    -- `order_products`.`discount` AS `discount`,
    -- `order_products`.`id` AS `id_(order_products)`,
    -- `order_products`.`option_amount_per` AS `option_amount_per`,
    -- `order_products`.`order_id` AS `order_id`,
    -- `order_products`.`original_tax` AS `original_tax`,
    -- `order_products`.`original_total` AS `original_total`,
    -- `order_products`.`processed_at` AS `processed_at`,
    -- `order_products`.`product_description` AS `product_description`,
    -- `order_products`.`product_id` AS `product_id`,
    -- `order_products`.`purchasable_id` AS `purchasable_id`,
    -- `order_products`.`purchasable_processed_at` AS `purchasable_processed_at`,
    order_products.purchasable_type AS `purchasable_type`,
    -- `order_products`.`quantity_refunded` AS `quantity_refunded`,
    -- `order_products`.`quantity` AS `quantity`,
    -- `order_products`.`sku` AS `sku`,
    -- `order_products`.`status_id` AS `status_id`,
    -- `order_products`.`tax` AS `tax`,
    -- `order_products`.`title` AS `title`,
    -- `order_products`.`total` AS `total`,
    -- `order_products`.`tracking_number` AS `tracking_number`,
    -- `order_products`.`updated_at` AS `updated_at_(order_products)`,
    -- SUBSTRING(`order_products`.`options_given`, 1, 1024) AS `options_given`,
    -- SUBSTRING(`order_products`.`tax_info`, 1, 1024) AS `tax_info`,
    
    -- ORDERS TABLE
    -- `orders`.`active` AS `active`,
    -- `orders`.`address_2` AS `address_2`,
    -- `orders`.`address` AS `address_(orders)`,
    -- `orders`.`amount_charged_back` AS `amount_charged_back_(orders)`,
    -- `orders`.`amount_refunded` AS `amount_refunded_(orders)`,
    -- `orders`.`city` AS `city_(orders)`,
    -- `orders`.`confirmation_number` AS `confirmation_number`,
    -- `orders`.`country` AS `country_(orders)`,
    -- `orders`.`created_at` AS `created_at_(orders)`,
    -- `orders`.`deleted_at` AS `deleted_at_(orders)`,
    -- `orders`.`discount_code` AS `discount_code`,
    -- `orders`.`discount` AS `discount_(orders)`,
    -- `orders`.`email` AS `email_(orders)`,
    -- `orders`.`first_name` AS `first_name_(orders)`,
    -- `orders`.`group_id` AS `group_id`,
    -- `orders`.`handling_charge` AS `handling_charge`,
    -- `orders`.`handling_tax` AS `handling_tax`,
    -- `orders`.`id` AS `id_(orders)`,
    -- `orders`.`in_hand_date` AS `in_hand_date`,
    -- `orders`.`last_name` AS `last_name_(orders)`,
    -- `orders`.`original_tax` AS `original_tax_(orders)`,
    -- `orders`.`original_total` AS `original_total_(orders)`,
    -- `orders`.`phone` AS `phone_(orders)`,
    -- `orders`.`post_process_finished_at` AS `post_process_finished_at`,
    -- `orders`.`post_process_started_at` AS `post_process_started_at`,
    -- `orders`.`processed` AS `processed`,
    -- `orders`.`quote_id` AS `quote_id`,
    -- `orders`.`ship_on` AS `ship_on`,
    -- `orders`.`shipping_address_2` AS `shipping_address_2`,
    -- `orders`.`shipping_address` AS `shipping_address`,
    -- `orders`.`shipping_city` AS `shipping_city`,
    -- `orders`.`shipping_company` AS `shipping_company`,
    -- `orders`.`shipping_country` AS `shipping_country`,
    -- `orders`.`shipping_first_name` AS `shipping_first_name`,
    -- `orders`.`shipping_last_name` AS `shipping_last_name`,
    -- `orders`.`shipping_method` AS `shipping_method`,
    -- `orders`.`shipping_rate` AS `shipping_rate`,
    -- `orders`.`shipping_state` AS `shipping_state`,
    -- `orders`.`shipping_tax` AS `shipping_tax`,
    -- `orders`.`shipping_zip` AS `shipping_zip`,
    -- `orders`.`state` AS `state_(orders)`,
    -- `orders`.`status_id` AS `status_id_(orders)`,
    -- `orders`.`store` AS `store`,
    -- `orders`.`subtotal` AS `subtotal`,
    -- `orders`.`tax_transaction_code` AS `tax_transaction_code`,
    -- `orders`.`tax` AS `tax_(orders)`,
    -- `orders`.`total` AS `total_(orders)`,
    -- `orders`.`tracking` AS `tracking`,
    -- `orders`.`upcharge` AS `upcharge`,
    -- `orders`.`updated_at` AS `updated_at_(orders)`,
    -- `orders`.`user_id` AS `user_id`,
    -- `orders`.`uuid` AS `uuid_(orders)`,
    -- `orders`.`zip` AS `zip_(orders)`,
    -- SUBSTRING(`orders`.`customer_note`, 1, 1024) AS `customer_note`,
    -- SUBSTRING(`orders`.`internal_note`, 1, 1024) AS `internal_note`,

    -- PROFILES TABLE
    -- `profiles`.`active` AS `active_(profiles)`,
    -- `profiles`.`anonymous` AS `anonymous`,
    -- `profiles`.`created_at` AS `created_at_(profiles)`,
    -- `profiles`.`date_of_birth` AS `date_of_birth_(profiles)`,
    -- `profiles`.`deceased_recorded_on` AS `deceased_recorded_on`,
    -- `profiles`.`deleted_at` AS `deleted_at_(profiles)`,
    -- `profiles`.`education_id` AS `education_id`,
    -- `profiles`.`ethnicity_id` AS `ethnicity_id`,
    -- `profiles`.`first_name` AS `first_name_(profiles)`,
    -- `profiles`.`gender_id` AS `gender_id`,
    -- `profiles`.`gender_opt_out` AS `gender_opt_out`,
    -- `profiles`.`id` AS `id_(profiles)`,
    -- `profiles`.`income_id` AS `income_id`,
    -- `profiles`.`is_us_citizen` AS `is_us_citizen`,
    -- `profiles`.`last_name` AS `last_name_(profiles)`,
    -- `profiles`.`marketo_lead_id_old` AS `marketo_lead_id_old`,
    -- `profiles`.`marketo_lead_id` AS `marketo_lead_id`,
    -- `profiles`.`merged_from_profile_id` AS `merged_from_profile_id`,
    -- `profiles`.`merged_to_profile_id` AS `merged_to_profile_id`,
    -- `profiles`.`middle_name` AS `middle_name_(profiles)`,
    -- `profiles`.`military_id` AS `military_id`,
    -- `profiles`.`name` AS `name_(profiles)`,
    -- `profiles`.`occupation_id` AS `occupation_id`,
    -- `profiles`.`para` AS `para`,
    -- `profiles`.`primary_address_id` AS `primary_address_id`,
    -- `profiles`.`primary_citizenship_id` AS `primary_citizenship_id`,
    -- `profiles`.`primary_email_id` AS `primary_email_id`,
    -- `profiles`.`primary_emergency_contact_id` AS `primary_emergency_contact_id`,
    -- `profiles`.`primary_phone_id` AS `primary_phone_id`,
    -- `profiles`.`remote_id` AS `remote_id_(profiles)`,
    -- `profiles`.`suffix` AS `suffix`,
    -- `profiles`.`updated_at` AS `updated_at_(profiles)`,
    -- `profiles`.`user_id` AS `user_id_(profiles)`,
    -- `profiles`.`uuid` AS `uuid_(profiles)`,
    -- SUBSTRING(`profiles`.`merge_info`, 1, 1024) AS `merge_info`,

    -- REGISTRATION AUDIT MEMBERSHIP APPLICATION TABLE
    -- `registration_audit_membership_application`.`audit_id` AS `audit_id`,
    -- `registration_audit_membership_application`.`created_at` AS `created_at_(registration_audit_membership_application)`,
    -- `registration_audit_membership_application`.`distance_type_id` AS `distance_type_id_(registration_audit_membership_application)`,
    -- `registration_audit_membership_application`.`id` AS `id_(registration_audit_membership_application)`,
    -- `registration_audit_membership_application`.`membership_application_id` AS `membership_application_id`,
    -- `registration_audit_membership_application`.`membership_type_id` AS `membership_type_id_(registration_audit_membership_application)`,
    `registration_audit_membership_application`.`price_paid` AS `price_paid`,
    -- `registration_audit_membership_application`.`race_id` AS `race_id_(registration_audit_membership_application)`,
    -- `registration_audit_membership_application`.`race_type_id` AS `race_type_id_(registration_audit_membership_application)`,
    -- `registration_audit_membership_application`.`status` AS `status_(registration_audit_membership_application)`,
    -- `registration_audit_membership_application`.`updated_at` AS `updated_at_(registration_audit_membership_application)`,
    -- SUBSTRING(`registration_audit_membership_application`.`upgrade_codes`, 1, 1024) AS `upgrade_codes`,

    -- REGISTRATION AUDIT TABLE
    -- `registration_audit`.`address` AS `address_(registration_audit)`,
    -- `registration_audit`.`billing_address` AS `billing_address`,
    -- `registration_audit`.`billing_city` AS `billing_city`,
    -- `registration_audit`.`billing_country` AS `billing_country`,
    -- `registration_audit`.`billing_email` AS `billing_email`,
    -- `registration_audit`.`billing_first_name` AS `billing_first_name`,
    -- `registration_audit`.`billing_last_name` AS `billing_last_name`,
    -- `registration_audit`.`billing_middle_name` AS `billing_middle_name`,
    -- `registration_audit`.`billing_phone` AS `billing_phone`,
    -- `registration_audit`.`billing_state` AS `billing_state`,
    -- `registration_audit`.`billing_zip` AS `billing_zip`,
    -- `registration_audit`.`city` AS `city_(registration_audit)`,
    -- `registration_audit`.`confirmation_number` AS `confirmation_number_(registration_audit)`,
    -- `registration_audit`.`country` AS `country_(registration_audit)`,
    -- `registration_audit`.`created_at` AS `created_at_(registration_audit)`,
    -- `registration_audit`.`date_of_birth` AS `date_of_birth_(registration_audit)`,
    -- `registration_audit`.`deleted_at` AS `deleted_at_(registration_audit)`,
    -- `registration_audit`.`email` AS `email_(registration_audit)`,
    -- `registration_audit`.`ethnicity` AS `ethnicity`,
    -- `registration_audit`.`event_id` AS `event_id_(registration_audit)`,
    -- `registration_audit`.`first_name` AS `first_name_(registration_audit)`,
    -- `registration_audit`.`gender` AS `gender_(registration_audit)`,
    -- `registration_audit`.`id` AS `id_(registration_audit)`,
    -- `registration_audit`.`invoice_product_id` AS `invoice_product_id`,
    -- `registration_audit`.`last_name` AS `last_name_(registration_audit)`,
    -- `registration_audit`.`member_number` AS `member_number`,
    -- `registration_audit`.`membership_period_id` AS `membership_period_id_(registration_audit)`,
    -- `registration_audit`.`middle_name` AS `middle_name_(registration_audit)`,
    -- `registration_audit`.`phone_number` AS `phone_number`,
    -- `registration_audit`.`processed_at` AS `processed_at_(registration_audit)`,
    -- `registration_audit`.`profile_id` AS `profile_id_(registration_audit)`,
    -- `registration_audit`.`registration_company_id` AS `registration_company_id`,
    -- `registration_audit`.`remote_audit_code` AS `remote_audit_code`,
    -- `registration_audit`.`remote_id` AS `remote_id`,
    -- `registration_audit`.`state` AS `state_(registration_audit)`,
    -- `registration_audit`.`status` AS `status_(registration_audit)`,
    -- `registration_audit`.`updated_at` AS `updated_at_(registration_audit)`,
    -- `registration_audit`.`user_id` AS `user_id_(registration_audit)`,
    -- `registration_audit`.`zip` AS `zip_(registration_audit)`,

    -- TRANSACTIONS TABLE
    -- `transactions`.`amount` AS `amount`,
    -- `transactions`.`captured` AS `captured`,
    -- `transactions`.`created_at` AS `created_at_(transactions)`,
    -- `transactions`.`date` AS `date`,
    -- `transactions`.`deleted_at` AS `deleted_at_(transactions)`,
    -- `transactions`.`exported_at` AS `exported_at`,
    -- `transactions`.`id` AS `id_(transactions)`,
    -- `transactions`.`order_id` AS `order_id_(transactions)`,
    -- `transactions`.`payment_id` AS `payment_id_(transactions)`,
    -- `transactions`.`payment_method` AS `payment_method`,
    -- `transactions`.`processed` AS `processed_(transactions)`,
    -- `transactions`.`refunded_amount` AS `refunded_amount`,
    -- `transactions`.`tax_transaction_code` AS `tax_transaction_code_(transactions)`,
    -- `transactions`.`tax` AS `tax_(transactions)`,
    -- `transactions`.`updated_at` AS `updated_at_(transactions)`,
    -- `transactions`.`user_id` AS `user_id_(transactions)`,
    -- SUBSTRING(`events`.`description`, 1, 1024) AS `description`,
    -- SUBSTRING(`transactions`.`note`, 1, 1024) AS `note`,
    -- SUBSTRING(`transactions`.`tax_transaction`, 1, 1024) AS `tax_transaction`,

    -- USERS TABLE
    -- `users`.`active` AS `active_(users)`,
    -- `users`.`api_token` AS `api_token`,
    -- `users`.`claimed` AS `claimed`,
    -- `users`.`created_at` AS `created_at_(users)`,
    -- `users`.`deleted_at` AS `deleted_at_(users)`,
    -- `users`.`email_verified_at` AS `email_verified_at`,
    -- `users`.`email` AS `email_(users)`,
    -- `users`.`id` AS `id_(users)`,
    -- `users`.`invalid_email` AS `invalid_email`,
    -- `users`.`logged_in_at` AS `logged_in_at`,
    -- `users`.`merged_from_user_id` AS `merged_from_user_id`,
    -- `users`.`merged_to_user_id` AS `merged_to_user_id`,
    -- `users`.`name` AS `name_(users)`,
    -- `users`.`old_email` AS `old_email`,
    -- `users`.`opted_out_of_notifications` AS `opted_out_of_notifications`,
    -- `users`.`password` AS `password`,
    -- `users`.`primary` AS `primary`,
    -- `users`.`remember_token` AS `remember_token`,
    -- `users`.`remote_id` AS `remote_id_(users)`,
    -- `users`.`updated_at` AS `updated_at_(users)`,
    -- `users`.`username` AS `username`,
    -- `users`.`uuid` AS `uuid_(users)`,
    -- SUBSTRING(`users`.`invalid_email_value`, 1, 1024) AS `invalid_email_value`,
    -- SUBSTRING(`users`.`merge_info`, 1, 1024) AS `merge_info_(users)`,
    -- SUBSTRING(`users`.`personal_access_token`, 1, 1024) AS `personal_access_token`,

    -- DERIVED FIELDS --
    -- real_membership_types
    CASE
        -- membership_periods.membership_type_id
        WHEN membership_periods.membership_type_id IN (1, 2, 3, 52, 55, 60, 62, 64, 65, 66, 67, 68, 70, 71, 73, 74, 75, 85, 89, 91, 93, 96, 98, 99, 101, 103, 104, 112, 113, 114, 117, 119) THEN 'adult_annual'
        WHEN membership_periods.membership_type_id IN (4, 51, 54, 61, 94, 107) THEN 'youth_annual'
        WHEN membership_periods.membership_type_id IN (5, 46, 47, 72, 97, 100, 115, 118) THEN 'one_day'
        WHEN membership_periods.membership_type_id IN (56, 58, 81, 105) THEN 'club'
        WHEN membership_periods.membership_type_id IN (83, 84, 86, 87, 88, 90, 102) THEN 'elite'
        ELSE "other"
    END AS real_membership_types,
    -- source
    CASE
        WHEN order_products.cart_label IS NOT NULL THEN 'Membership System/RTAV Classic'
        WHEN registration_audit_membership_application.price_paid IS NOT NULL THEN 'RTAV Batch'
        WHEN membership_types.name IS NOT NULL THEN 'Other'
        -- ELSE 'null' -- Optional, for cases where none of the conditions are met
    END AS source,
    -- source details
    order_products.cart_label as source_Membership_System_RTAV_Classic,
    registration_audit_membership_application.price_paid AS source_price_paid,
    membership_types.name AS source_other,
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
        -- WHEN registration_audit.registration_company_id IS NULL THEN 'Not Applicable'

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
      WHEN members.deleted_at IS NOT NULL THEN 'deleted'
      WHEN membership_periods.deleted_at IS NOT NULL THEN 'deleted'
      WHEN profiles.deleted_at IS NOT NULL THEN 'deleted'
      WHEN users.deleted_at IS NOT NULL THEN 'deleted'
      ELSE 'active'  -- You can use 'active' or another label based on your preference
    END AS is_deleted,
    -- deleted detail
    members.deleted_at AS members_deleted_at,
    membership_periods.deleted_at AS membership_periods_deleted_at,
    profiles.deleted_at AS profiles_deleted_at,
    users.deleted_at AS users_deleted_at,
    -- captured_and_processed
    CASE
      WHEN transactions.captured = 1 AND transactions.processed = 1 THEN 'C&P'
      ELSE 'Other'  -- You can use 'Other' or another label based on your preference
    END AS captured_and_processed,
    -- allowable
    CASE
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
    END AS is_allowable,
    -- details
    membership_periods.created_at <= TIMESTAMP('2021-12-16 06:25:14') AS membership_created_before_20211216,
    membership_periods.starts AS starts_membership_period,
    membership_periods.ends AS ends_membership_period,
    DATE(membership_periods.ends) >= '2022-01-01' AS membership_period_ends_after_20220101,

    membership_periods.terminated_on,
    membership_types.id > 0 AS membership_types_id_greater_than_zero,
    membership_types.id

FROM membership_applications -- DONE
    LEFT JOIN order_products ON (membership_applications.id = order_products.purchasable_id)
    LEFT JOIN orders ON (order_products.order_id = orders.id)
    LEFT JOIN registration_audit ON (membership_applications.membership_period_id = registration_audit.membership_period_id)
    LEFT JOIN registration_audit_membership_application ON (registration_audit.id = registration_audit_membership_application.audit_id)
    RIGHT JOIN membership_periods ON (membership_applications.membership_period_id = membership_periods.id) -- DONE
    LEFT JOIN membership_types ON (membership_applications.membership_type_id = membership_types.id)
    RIGHT JOIN members ON (membership_periods.member_id = members.id)
    RIGHT JOIN profiles ON (members.memberable_id = profiles.id)
    LEFT JOIN users ON (profiles.user_id = users.id)
    LEFT JOIN events ON (membership_applications.event_id = events.id)
    LEFT JOIN transactions ON (orders.id = transactions.order_id)

WHERE
    -- INITIAL SAMPLE CHECKS
    -- members.member_number IN (2, 7, 9, 21, 24, 386, 406, 477, 572)
    -- 2 & 7    = lifetime pass not in tableau
    -- 9        = missing 3 year in tableau
    -- 477      = missing 103018; looks like a pre-purchase given membership period starts in May 2021 vs purchase Nov 2020
    -- match    = 21, 24, 386, 406, 572

    -- members.member_number IN (572)
    -- AND
    -- membership_periods.id IN (4349638, 3369878, 4608560, 4632086) -- 572

    -- members.member_number IN (406) -- tableau has 2, sql has 1 purchase
    -- AND 
    -- membership_periods.id IN (102434, 3673692) -- 406

    -- SECOND SAMPLE CHECKS
    -- members.member_number IN (10108, 10206)
    -- 10108 = why three one-days at 15 if purchased March 2024?
    -- 10206 = example of $6 relay

    -- THIRD SAMPLE CHECKS
    -- members.member_number IN (508562823)

    -- FORTH SAMPLE CHECKS
    -- members.member_number IN (8092) 

    -- DOES THE TABLEAU REVENUE FORMULA TAKE INTO ACCOUNT ONE DAY PRICE DEDUCTION ON ANNUAL PASS PURCHASE?

    -- ELIMINATE DUPLICATE MEMBER NUMBER
    -- membership_periods.id IN (4400907, 4378277, 4429721)

    -- CHECK FOR MEMBERSHIP PERIOD IS NOT NULL
    -- membership_periods.terminated_on IS NOT NULL

    -- TABLEAU FILTER RULES
    -- AND 
    membership_periods.membership_type_id NOT IN (56, 58, 81, 105) -- filter used in Tableau
    AND membership_periods.id NOT IN (4652554) -- filter used in tableau
    AND membership_periods.ends >= '2022-01-01' -- filter used in tableau
    -- AND membership_periods.terminated_on IS NULL
    -- AND membership_types.id > 0

    -- One Day Consolidated Purchase 6
    -- AND membership_types.id > 0
    -- AND membership_periods.terminated_on IS NULL
    -- AND YEAR(membership_periods.purchased_on) IN (2024)
    -- AND YEAR(membership_periods.purchased_on) IN (2023)
    -- AND YEAR(membership_periods.purchased_on) IN (2023, 2024) 
    -- AND (
    --     CASE
    --         WHEN membership_periods.membership_type_id IN (5, 46, 47, 72, 97, 100, 115, 118) THEN 'one_day'
    --         ELSE 0 
    --     END) = 'one_day'
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

-- GROUP BY membership_periods.id
ORDER BY CONVERT(members.member_number, UNSIGNED), membership_periods.id
-- LIMIT 100;

-- Sales Purchases
-- countd([One Day Consolidated Purchase 6])
-- + 
-- countd([Annual Consolidated Purchases 6])
-- + 
-- countd([Coach Membership Purchases])

-- One Day Consolidated Purchase 6
-- { fixed [Member Number (Members)],[Created At Membership Periods], [Starts], [Ends], [Membership Type Id (Membership Periods)], [Sanctioning Event Id], [Origin Flag (Membership Periods)], [Payment Type], [Race Type Id], [Distance Type Id], [Order Id], [Confirmation Code]: 
-- max(if [Real Membership Types] = "One Day" then [Id (Membership Periods)] END)}

-- Annual Consolidated Purchases 6
-- { fixed [Member Number (Members)],[Created At Membership Periods],[Membership Type Id (Membership Periods)], [Sanctioning Event Id], [Payment Type], [Origin Flag (Membership Periods)], [Order Id], [Confirmation Code]: 
-- max(if [Real Membership Types] != "One Day" AND isnull([Coach Recert]) then [Id (Membership Periods)] END)}

-- Coach Membership Purchases
-- if NOT isnull([Coach Recert]) then [Id (Membership Periods)] END

-- Sales Revenue
-- sum([Annual Consolidated Fee 6])+sum([One Day Consolidated Fee 6])+sum([Coach Membership Fee])

-- One Day Consolidated Fee 6
-- { fixed [Member Number (Members)],[Created At Membership Periods], [Starts], [Ends],[Membership Type Id (Membership Periods)], [Sanctioning Event Id], [Origin Flag (Membership Periods)], [Payment Type], [Race Type Id], [Distance Type Id], [Order Id], [Confirmation Code]: 
-- max(if [Real Membership Types] = "One Day" then [Actual Membership Fee 6] else 0 END)}

-- Annual Consolidated Fee 6
-- { fixed [Member Number (Members)],[Created At Membership Periods],[Membership Type Id (Membership Periods)], [Sanctioning Event Id], [Payment Type], [Origin Flag (Membership Periods)], [Order Id], [Confirmation Code]: 
-- max(if [Real Membership Types] != "One Day" AND isnull([Coach Recert]) then [Actual Membership Fee 6] else 0 END)}

-- Coach Membership Fee
-- if NOT isnull([Coach Recert]) then [Actual Membership Fee 6] else 0 END


