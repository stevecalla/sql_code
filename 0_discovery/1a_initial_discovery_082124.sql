use vapor;
SHOW DATABASES;
SHOW TABLES;

SELECT * FROM members LIMIT 10;
SELECT COUNT(*) FROM members;

SELECT * FROM users LIMIT 10;
-- SELECT * FROM users WHERE email LIKE ('steve.calla@usatriathlon.com') LIMIT 10;
-- SELECT * FROM users WHERE email LIKE ('%@usatriathlon.com%') LIMIT 10;
SELECT COUNT(*) FROM users;

SELECT * FROM profiles LIMIT 10;

SELECT * FROM profiles WHERE last_name IN ('Calla') LIMIT 10;
SELECT COUNT(*) FROM profiles;

SELECT * FROM profiles WHERE last_name IN ('Calla') LIMIT 10;
SELECT COUNT(*) FROM profiles;

