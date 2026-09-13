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
USE vapor;

SELECT 
    -- sp.id AS promotion_id_sp,                 -- Promotion ID
    spd.id AS discount_id_spd,                 -- Discount/code ID
    spd.profile_id AS profile_id_spd,          -- Profile tied to the discount
    mp.id AS id_membership_period_mp,
    m.member_number AS member_number_m,
    spd.code AS discount_code_spd,             -- Discount code
    spd.created_at AS discount_created_at_spd, -- When the discount was created
    spd.remote_id AS remote_id_spd,            -- External/remote system ID
    -- mpd.id AS membership_period_id_mp,         -- Membership period tied to the discount
    spd.updated_at,
    mpd.created_at
    -- mp.purchased_on AS purchased_on_mp,
    -- mp.starts AS starts_on_mp,
    -- m.memberable_type AS memberable_type_m	   -- Member type
    -- mpd.created_at AS created_at_mpd							-- date promotion was assigned to mp
FROM sponsor_promotion_discounts AS spd
	INNER JOIN profiles AS p ON spd.profile_id = p.id -- Membership periods that used this discount
    INNER JOIN membership_period_sponsor_promotion_discount AS mpd ON mpd.discount_id AND spd.id = mpd.discount_id
    INNER JOIN membership_periods AS mp ON mpd.discount_id AND mp.id = mpd.membership_period_id
    INNER JOIN sponsor_promotions AS sp ON sp.id = mpd.promotion_id
	-- INNER JOIN membership_periods AS mp ON spd.id = mp.sponsor_promotion_discount_id -- Membership periods that used this discount
    -- INNER JOIN membership_period_sponsor_promotion_discount AS mpd ON sp = mpd.membership_period_id AND spd.id = mpd.discount_id
	-- INNER JOIN sponsor_promotions AS sp ON spd.promotion_id = sp.id -- Connect discount to promotion
	INNER JOIN members AS m ON mp.member_id = m.id -- Connect membership period to member
WHERE 1 = 1
  AND sp.id = 128                             -- Only promotion 128
  -- AND m.memberable_type = 'profiles'         -- Only profile-based members
  -- AND mpd.created_at >= '2026-07-15 00:00:00'
  -- AND mp.id = 4587797
  -- make sure these codes are not assigned
--   AND code IN (
--   "SNTV57WP","JP782FT5","PFG7TD66","78H5JG63","4H7H9VDC","46F8RG38","N768588H","XQ3QXHD9","R6FZQ5FQ",
--   "8HP84JZZ","752XN4CS","P452486Q","T2DQP7CD","8DT79578","597MSF6Z","H39D9QNC","XKCZ2X4S","259CJS34","R35V6B82","54R956RQ",
--   "TWF4DVNJ","D48X639F","P24KZQ47","9739W792","5WM758MV","3PX3VT43","P5523RHZ","3R4G22TV","56MTC3W6","56DNH68B","2XDQ8B46",
--   "PW87CGD2","T27R9437","PK48BHM2","X8KWF9N5","W74D9K74","W9WQ93FP","R8W7R2GR","JS369VZ7","688MXJB9","SRZZ28D3","M3B7HRSF")
LIMIT 10000
;

SELECT * FROM sponsor_promotion_discounts AS spd WHERE spd.id = 1066801 LIMIT 10;
SELECT * FROM sponsor_promotions WHERE id = 128 LIMIT 10;
SELECT * FROM membership_period_sponsor_promotion_discount;
SELECT * FROM membership_period_sponsor_promotion_discount WHERE discount_id = 1066590;
SELECT created_at, COUNT(*) FROM membership_period_sponsor_promotion_discount GROUP BY 1 ORDER BY 1 DESC;
SELECT * FROM membership_periods WHERE id = 4587797;

4H7H9VDC
SELECT mp.id, mp.sponsor_promotion_discount_id FROM membership_periods AS mp WHERE mp.id = 5415509 GROUP BY 1, 2 LIMIT 10; -- 5415509

SELECT *
FROM sponsor_promotions AS sp
	LEFT JOIN sponsor_promotion_discounts AS spd ON spd.promotion_id = sp.id
WHERE 1 = 1
	AND sp.id = 128
    --  spd.deleted_at IS NOT NULL
    -- AND spd.profile_id IS NULL	
;

SELECT 
    sp.id AS promotion_id_sp                -- Promotion ID
    , spd.id AS discount_id_spd                -- Discount/code ID
    , spd.profile_id AS profile_id_spd         -- Profile tied to the discount
    , spd.code AS discount_code_spd           -- Discount code
    , spd.created_at AS discount_created_at_spd -- When the discount was created
    ,spd.remote_id AS remote_id_spd            -- External/remote system ID
    -- mp.id AS membership_period_id_mp,         -- Membership period tied to the discount
    -- m.memberable_type AS memberable_type_m   -- Member type
FROM sponsor_promotion_discounts AS spd
-- INNER JOIN membership_periods AS mp ON spd.id = mp.sponsor_promotion_discount_id -- Membership periods that used this discount
INNER JOIN sponsor_promotions AS sp ON spd.promotion_id = sp.id -- Connect discount to promotion
-- INNER JOIN members AS m ON mp.member_id = m.id -- Connect membership period to member
WHERE 1 = 1
  AND sp.id = 128                             -- Only promotion 128
  -- AND m.memberable_type = 'profiles'         -- Only profile-based members
  -- make sure these codes are not assigned
--   AND code IN (
--   "SNTV57WP","JP782FT5","PFG7TD66","78H5JG63","4H7H9VDC","46F8RG38","N768588H","XQ3QXHD9","R6FZQ5FQ",
--   "8HP84JZZ","752XN4CS","P452486Q","T2DQP7CD","8DT79578","597MSF6Z","H39D9QNC","XKCZ2X4S","259CJS34","R35V6B82","54R956RQ",
--   "TWF4DVNJ","D48X639F","P24KZQ47","9739W792","5WM758MV","3PX3VT43","P5523RHZ","3R4G22TV","56MTC3W6","56DNH68B","2XDQ8B46",
--   "PW87CGD2","T27R9437","PK48BHM2","X8KWF9N5","W74D9K74","W9WQ93FP","R8W7R2GR","JS369VZ7","688MXJB9","SRZZ28D3","M3B7HRSF")
;