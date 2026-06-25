/*
Description:
This query finds discount codes from sponsor promotion 128 that were used on a membership period.
It only returns members where the member type is 'profiles'.

Aliases:
spd = sponsor_promotion_discounts
mp  = membership_periods
sp  = sponsor_promotions
m   = members
*/

SELECT 
    sp.id AS promotion_id,                 -- Promotion ID
    spd.id AS discount_id,                 -- Discount/code ID
    spd.profile_id AS profile_id,          -- Profile tied to the discount
    spd.code AS discount_code,             -- Discount code
    spd.created_at AS discount_created_at, -- When the discount was created
    spd.remote_id AS remote_id,            -- External/remote system ID
    mp.id AS membership_period_id,         -- Membership period tied to the discount
    m.memberable_type AS memberable_type   -- Member type
FROM sponsor_promotion_discounts AS spd
INNER JOIN membership_periods AS mp ON spd.id = mp.sponsor_promotion_discount_id -- Membership periods that used this discount
INNER JOIN sponsor_promotions AS sp ON spd.promotion_id = sp.id -- Connect discount to promotion
INNER JOIN members AS m ON mp.member_id = m.id -- Connect membership period to member
WHERE 1 = 1
  AND sp.id = 128                             -- Only promotion 128
  AND m.memberable_type = 'profiles'         -- Only profile-based members
;