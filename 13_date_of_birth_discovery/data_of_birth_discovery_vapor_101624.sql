USE vapor;

SELECT * FROM profiles LIMIT 10; -- date_of_birth, id
SELECT * FROM membership_applications LIMIT 10; -- date_of_birth, profile_id
SELECT * FROM registration_audit LIMIT 10; -- date_of_birth, id
SELECT * FROM members LIMIT 10; -- no date of birth
SELECT * FROM users LIMIT 10; -- no date of birth

-- PROFILES TABLE
SELECT 
	'profiles_table' AS source,
    YEAR(date_of_birth) AS year,
    -- YEAR(CURDATE()) - YEAR(date_of_birth_ma) - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(date_of_birth_ma, '%m%d')) AS age,
	YEAR(CURDATE()) - YEAR(date_of_birth) AS age,
    FORMAT(COUNT(DISTINCT id), 0) AS member_count,
    FORMAT(SUM(COUNT(DISTINCT id)) OVER (ORDER BY YEAR(date_of_birth) DESC), 0) AS running_total
FROM profiles
GROUP BY YEAR(date_of_birth), age
ORDER BY YEAR(date_of_birth) DESC;

-- MEMBERSHIP APPLICATIONS TABLE
SELECT 
	'membership_applications_table' AS source,
    YEAR(date_of_birth) AS year,
    -- YEAR(CURDATE()) - YEAR(date_of_birth_ma) - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(date_of_birth_ma, '%m%d')) AS age,
	YEAR(CURDATE()) - YEAR(date_of_birth) AS age,
    FORMAT(COUNT(DISTINCT id), 0) AS member_count,
    FORMAT(SUM(COUNT(DISTINCT id)) OVER (ORDER BY YEAR(date_of_birth) DESC), 0) AS running_total
FROM membership_applications
GROUP BY YEAR(date_of_birth), age
ORDER BY YEAR(date_of_birth) DESC;

-- registration_audit TABLE
SELECT 
	'registration_audit_table' AS source,
    YEAR(date_of_birth) AS year,
    -- YEAR(CURDATE()) - YEAR(date_of_birth_ma) - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(date_of_birth_ma, '%m%d')) AS age,
	YEAR(CURDATE()) - YEAR(date_of_birth) AS age,
    FORMAT(COUNT(DISTINCT id), 0) AS member_count,
    FORMAT(SUM(COUNT(DISTINCT id)) OVER (ORDER BY YEAR(date_of_birth) DESC), 0) AS running_total
FROM registration_audit
GROUP BY YEAR(date_of_birth), age
ORDER BY YEAR(date_of_birth) DESC;