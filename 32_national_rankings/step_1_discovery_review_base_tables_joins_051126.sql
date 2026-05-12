SELECT * FROM users ORDER BY created_at DESC LIMIT 10;
SELECT * FROM profiles ORDER BY created_at DESC LIMIT 10;

SELECT p.name, u.name, p.first_name, p.last_name
FROM profiles AS p
	LEFT JOIN users AS u ON p.user_id = u.id
WHERE u.id IN (1098741)
;

SELECT * FROM membership_periods ORDER BY created_at DESC LIMIT 10;
SELECT * FROM membership_types LIMIT 10;
SELECT * FROM membership_applications LIMIT 10;
-- race_id, race_type_id, distance_type_id
SELECT * FROM race_types LIMIT 10;
SELECT * FROM distance_types LIMIT 10;


SELECT * FROM membership_applications WHERE profile_id IN (339);

SELECT 
	ma.profile_id,
	mp.id AS id_membership_periods,
    mp.membership_type_id AS id_membership_type_membership_periods,
    mt.name AS name_membership_types,
    mp.starts AS starts_mp,
    mp.ends AS ends_mp,
    mt.group AS group_membership_types
FROM membership_periods AS mp
	LEFT JOIN membership_types AS mt ON mp.membership_type_id = mt.id
    LEFT JOIN membership_applications AS ma ON ma.membership_period_id = mp.id
WHERE 1 = 1
	AND mp.deleted_at IS NULL
    AND ma.profile_id IN (339)
ORDER BY mp.created_at DESC
LIMIT 10
;

SELECT * FROM ranking_list_period_entries WHERE profile_id = 2946524 ORDER BY profile_id DESC LIMIT 30;
SELECT * FROM ranking_list_periods ORDER BY created_at DESC LIMIT 10;
SELECT * FROM ranking_list_period_entry_race_result LIMIT 10;