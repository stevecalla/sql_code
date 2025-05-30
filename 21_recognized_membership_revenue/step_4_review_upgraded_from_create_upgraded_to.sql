USE vapor;

SELECT * FROM membership_periods LIMIT 10;

-- GET COUNT OF upgraded_from_id
SELECT 
  count(*),
  MIN(created_at),
  MIN(updated_at),
  MAX(created_at),
  MAX(updated_at)
FROM membership_periods AS mp
WHERE 1 = 1
	AND upgraded_from_id IS NOT NULL
LIMIT 50; -- only 875

-- GET COUNT OF upgraded_from_id
SELECT 
  count(*),
  MIN(created_at),
  MIN(updated_at),
  MAX(created_at),
  MAX(updated_at)
FROM membership_periods AS mp
WHERE 1 = 1
	AND upgraded_to_id IS NOT NULL
LIMIT 50;  -- none

-- QA check to see if upgraded from id = id
SELECT 
  id,
  upgraded_from_id,
  count(*),
  MIN(created_at),
  MIN(updated_at),
  MAX(created_at),
  MAX(updated_at)
FROM membership_periods AS mp
WHERE 1 = 1
    AND upgraded_from_id = id
GROUP BY 1, 2
LIMIT 50;  -- only 1 = 4486005

-- find some examples
SELECT 
  upgraded_from_id AS upgraded_from_id_mp,
  upgraded_to_id AS upgraded_to_id_mp,
  mp.* 
FROM membership_periods AS mp
WHERE 1 = 1
	AND upgraded_from_id IS NOT NULL 
ORDER BY created_at
LIMIT 50;