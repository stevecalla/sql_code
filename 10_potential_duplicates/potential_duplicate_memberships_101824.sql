SELECT
    members.member_id AS member_number_members

    , membership_applications.origin_flag
    , orders_products.purchasable_id
    , registration_audit_membership_application.membership_applications_id
    , registration_audit.confirmation_number
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

    -- race is to membership application
    -- distance is to membership application

WHERE
    -- some time dimension to filter like August 2024
    order_products.purchasable_type IN (membership-application)
    membership_applications.origin_flag IN ('admin bulk upload') -- indicates true duplicate
    mp.terminated_on IS NOT NULL
GROUP
    member number
    purchase on adjusted
    start date -- group on DATE not timestamp
    end date -- group on DATE not timestamp
    membership types
    created date -- group on DATE not timestamp
    event id
    origin flag
    first name
    last name
    dob
    gender
    email
    address
    purchasable_id
    confirmation number
    race type
    race distance
HAVING COUNT > 1
LIMIT
    10