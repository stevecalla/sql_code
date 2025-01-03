SELECT 'vapor.profiles table', COUNT(*) FROM vapor.profiles;
SELECT 'vapor.users table', COUNT(*) FROM vapor.users;

SELECT * FROM vapor.profiles LIMIT 10;
SELECT * FROM vapor.users LIMIT 10;

-- Per Sam. To eliminate coaches and race directors, you would want to connect to the "coach profiles" and "race director profile" tables connecting on profile id.

SELECT
    YEAR(p.created_at) AS created_year,
    FORMAT(COUNT(DISTINCT p.id), 0) AS total_profiles,
    FORMAT(COUNT(DISTINCT CASE WHEN u.email IS NULL THEN p.id END), 0) AS email_null_count,
    FORMAT(COUNT(DISTINCT CASE WHEN u.email IS NOT NULL THEN p.id END), 0) AS email_not_null_count
FROM profiles AS p
 LEFT JOIN users AS u ON p.user_id = u.id
GROUP BY created_year WITH ROLLUP
ORDER BY created_year
LIMIT 100;

WITH members_by_dob AS (
	SELECT
		p.id AS profile_id,
        p.date_of_birth,
		YEAR(CURDATE()) - YEAR(p.date_of_birth) AS age_at_end_of_year
	FROM profiles AS p
    -- WHERE YEAR(p.date_of_birth) = '2015'
)
SELECT 
    YEAR(p.created_at) AS created_year,
    FORMAT(COUNT(DISTINCT p.id), 0) AS total_profiles,
    FORMAT(COUNT(DISTINCT CASE WHEN u.email IS NULL THEN p.id END), 0) AS email_null_count,
    FORMAT(COUNT(DISTINCT CASE WHEN u.email IS NOT NULL THEN p.id END), 0) AS email_not_null_count,
    
    FORMAT(SUM(CASE WHEN dob.age_at_end_of_year <= 3 OR dob.age_at_end_of_year >= 100 THEN 1 ELSE 0 END), 0) AS 'age_<=3_or_>=100',
    FORMAT(SUM(CASE WHEN dob.age_at_end_of_year <= 13 THEN 1 ELSE 0 END), 0) AS 'age_<=13',
    FORMAT(SUM(CASE WHEN dob.age_at_end_of_year <=18 THEN 1 ELSE 0 END), 0) AS 'age_<=18',
    FORMAT(SUM(CASE WHEN dob.age_at_end_of_year > 18 THEN 1 ELSE 0 END), 0) AS 'age_>18'
    
FROM profiles AS p
 LEFT JOIN users AS u ON p.user_id = u.id
 LEFT JOIN members_by_dob AS dob ON p.id = dob.profile_id
GROUP BY created_year WITH ROLLUP
ORDER BY created_year
LIMIT 100;
