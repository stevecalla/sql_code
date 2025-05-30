USE vapor;

-- DUPLICATES DISCOVERY
SELECT "users_table_query#1", u.* FROM users AS u LIMIT 10;
SELECT "users_table_query#2", COUNT(*) FROM users LIMIT 10;

SELECT "profiles_table_query#3", p.* FROM profiles AS p LIMIT 10;
SELECT "profile_table_query#4", COUNT(*) FROM profiles AS p LIMIT 10;

SELECT "profile_table_query#5", first_name, last_name, date_of_birth, gender_id FROM profiles LIMIT 10;

SELECT
	"profile_table_query#6", 
	first_name,
	last_name,
	date_of_birth,
	gender_id,
	COUNT(*) AS duplicate_count
FROM profiles
WHERE deleted_at IS NULL
GROUP BY
  first_name,
  last_name,
  date_of_birth,
  gender_id
HAVING
  COUNT(*) > 1
;

WITH duplicate_groups AS (
  SELECT
    first_name,
    last_name,
    date_of_birth,
    gender_id,
    COUNT(*) AS duplicate_count,
    GROUP_CONCAT(id ORDER BY id) AS duplicate_profile_ids
  FROM profiles
  WHERE deleted_at IS NULL
  GROUP BY
    first_name, last_name, date_of_birth, gender_id
  HAVING COUNT(*) > 1
)
SELECT
	"profile_table_query#7", 
	d.first_name,
	d.last_name,
	d.date_of_birth,
	d.gender_id,
	d.duplicate_count,
	d.duplicate_profile_ids
FROM
  duplicate_groups d
ORDER BY
  d.duplicate_count DESC;
  
  WITH duplicate_groups AS (
  SELECT
    first_name,
    last_name,
    date_of_birth,
    gender_id,
    COUNT(*) AS duplicate_count,
    GROUP_CONCAT(id ORDER BY id) AS duplicate_profile_ids
  FROM profiles
  WHERE deleted_at IS NULL
  GROUP BY
    first_name, last_name, date_of_birth, gender_id
  -- HAVING COUNT(*) > 1
)
SELECT
	"profile_table_query#8", 
	CASE
		WHEN duplicate_count = 1 THEN 'unique'
		ELSE 'duplicate'
	END AS combination_type,
	COUNT(*) AS num_combinations
FROM duplicate_groups
GROUP BY combination_type;

WITH duplicate_groups AS (
  SELECT
    first_name,
    last_name,
    date_of_birth,
    gender_id,
    COUNT(*) AS duplicate_count,
    GROUP_CONCAT(id ORDER BY id) AS duplicate_profile_ids
  FROM profiles
  WHERE deleted_at IS NULL
  GROUP BY
    first_name, last_name, date_of_birth, gender_id
  -- HAVING COUNT(*) > 1
)
SELECT
	"profile_table_query#9", 
	CASE
		WHEN duplicate_count = 1 THEN '1) 1'
		WHEN duplicate_count = 2 THEN '2) 2'
		WHEN duplicate_count BETWEEN 3 AND 10 THEN '3) 3-10'
		WHEN duplicate_count BETWEEN 11 AND 20 THEN '4) 11-20'
		WHEN duplicate_count > 20 THEN '5) 21+'
		ELSE '6) other' -- If you want to include single-instance records
	END AS combination_count_bin,
	COUNT(*) AS num_combinations
FROM duplicate_groups
GROUP BY combination_count_bin
ORDER BY combination_count_bin;
