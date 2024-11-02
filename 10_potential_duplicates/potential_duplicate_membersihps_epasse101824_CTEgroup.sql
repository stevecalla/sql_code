WITH A AS (
SELECT
    members.member_number
    , profiles.id 'profile_id'
	, TRIM(profiles.first_name) 'profile_first_name'
    , TRIM(profiles.last_name) 'profile_last_name'
	, profiles.date_of_birth 'user_dob'
    , users.email 'user_email'
    , states.name 'address_state'
    , profiles.gender_id 'profile_gender'
	, events.id 'event_id'
    , events.sanctioning_event_id 'event_santioning_event_id'
    , events.name 'event_name'
	, race_types.name 'race_type'
    , distance_types.name 'race_distance'
    , DATE(membership_periods.purchased_on) 'membership_period_purchased_on' -- needs adjusting
    , DATE(membership_periods.starts) 'membership_period_start'
    , DATE(membership_periods.ends) 'membership_period_end'
    , membership_types.name 'membership_type_name'
    , DATE(membership_applications.created_at) 'membership_applications_created_at'
	, membership_applications.origin_flag 'membership_applications_origin'
    , registration_audit.confirmation_number
    , order_products.purchasable_id
    , 1 'individual_count'
    , COUNT(*) 'member_event_memberships'
FROM
    membership_applications
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
    LEFT JOIN races ON races.id = membership_applications.race_id  -- race is to membership applicationj
    LEFT JOIn race_types ON race_types.id = races.race_type_id
    LEFT JOIN distance_types ON distance_types.id = races.distance_type_id -- distance is to membership application
    LEFT JOIN addresses ON addresses.id = profiles.primary_address_id
    LEFT JOIN states ON states.id = addresses.state_id
WHERE 1 = 1
	AND CAST(DATE_FORMAT(membership_periods.purchased_on, '%Y-%m-01') AS DATE) IN ('2024-08-01')
    AND membership_periods.terminated_on IS NULL
    AND membership_periods.deleted_at IS NULL
    AND members.memberable_type = 'profiles'
	-- AND membership_applications.origin_flag LIKE '%ADMIN%'  
    -- membership_applications.origin_flag IN ('admin bulk upload') -- indicates true duplicate
    -- AND events.id IN (31912)
GROUP BY
    members.member_number
	, profiles.id
    , TRIM(profiles.first_name)
    , TRIM(profiles.last_name)
	, profiles.date_of_birth
    , users.email
    , states.name
    , profiles.gender_id
	, events.id
    , events.sanctioning_event_id
    , events.name
	, race_types.name
    , distance_types.name
    , DATE(membership_periods.purchased_on) -- needs adjusting
    , DATE(membership_periods.starts)
    , DATE(membership_periods.ends)
    , membership_types.name
    , DATE(membership_applications.created_at)
	, membership_applications.origin_flag
    , registration_audit.confirmation_number
    , order_products.purchasable_id
    , 1
HAVING COUNT(*) > 1
ORDER BY membership_applications.origin_flag
	, TRIM(profiles.first_name)
    , TRIM(profiles.last_name)
)

SELECT 
	-- event_id
	-- 	,SUM(individual_count) 'unique_member_grouped'
	--     ,SUM(member_event_memberships) 'memberships_incl_potential_dupes'
	--     , COUNT(DISTINCT member_number) AS member_count_distinct
	*
FROM A
-- WHERE event_id IN (29690, 32253, 30790, 29237, 30941, 30873, 30768, 30770) -- 32253 + 30790 = 91; 30941 = 67, no dupes; 30873 = 38, no dupes; 30770 chicago = ?
WHERE event_id IN (30790) -- 32253 + 30790 = 91; 30941 = 67, no dupes; 30873 = 38, no dupes; 30770 chicago = ?
-- GROUP BY event_id
;

SELECT 
	members.member_number
    , membership_periods.id
    , profiles.id 'profile_id'
	, TRIM(profiles.first_name) 'profile_first_name'
    , TRIM(profiles.last_name) 'profile_last_name'
	, profiles.date_of_birth 'user_dob'
    , users.email 'user_email'
    , states.name 'address_state'
    , profiles.gender_id 'profile_gender'
	, events.id 'event_id'
    , events.sanctioning_event_id 'event_santioning_event_id'
    , events.name 'event_name'
	, race_types.name 'race_type'
    , distance_types.name 'race_distance'
    , DATE(membership_periods.purchased_on) 'membership_period_purchased_on' -- needs adjusting
    , DATE(membership_periods.starts) 'membership_period_start'
    , DATE(membership_periods.ends) 'membership_period_end'
    , membership_types.name 'membership_type_name'
    , DATE(membership_applications.created_at) 'membership_applications_created_at'
	, membership_applications.origin_flag 'membership_applications_origin'
    , registration_audit.confirmation_number
    , order_products.purchasable_id
    , 1 'individual_count'
FROM
    membership_applications
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
    LEFT JOIN races ON races.id = membership_applications.race_id  -- race is to membership applicationj
    LEFT JOIn race_types ON race_types.id = races.race_type_id
    LEFT JOIN distance_types ON distance_types.id = races.distance_type_id -- distance is to membership application
    LEFT JOIN addresses ON addresses.id = profiles.primary_address_id
    LEFT JOIN states ON states.id = addresses.state_id
WHERE members.member_number IN ('918787136')
	