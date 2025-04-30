USE vapor;

SELECT * FROM events WHERE YEAR(created_at) >= '2023' LIMIT 10;

SELECT id AS id_events, sanctioning_event_id AS id_santioning_events, DATE(created_at) AS created_at_events, (id) AS id_count_events FROM events WHERE id >= '17802'GROUP BY 1, 2, 3 ORDER BY id;

SELECT * FROM profiles LIMIT 10;
SELECT * FROM users LIMIT 10;

SELECT
    DATE(p.created_at) AS created_at_date_profiles,
    p.id AS id_profiles,
    LOWER(u.email) AS email_users,
    LOWER(p.first_name) AS first_name_profiles,
	p.date_of_birth AS date_of_birth_profiles,
    COUNT(p.id) AS count_profile_id
FROM profiles AS p
 LEFT JOIN users AS u ON p.user_id = u.id
GROUP BY 1, 2, 3, 4 
ORDER BY 2, 3, 1, 4
-- LIMIT 100
;

SELECT DATE(created_at) AS created_at_ma, LOWER(email) AS email_ma, LOWER(first_name) AS first_ma, id, COUNT(id) AS id_count_ma FROM membership_applications WHERE email IS NOT NULL AND email <> "" GROUP BY 1, 2, 3, 4 ORDER BY created_at ASC;

SELECT * FROM membership_applications WHERE email IS NOT NULL AND email <> "" ORDER BY created_at ASC LIMIT 10;
