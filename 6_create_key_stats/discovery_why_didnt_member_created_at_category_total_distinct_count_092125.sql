USE usat_sales_db;

-- 1) Peek latest rows by id_profiles
SELECT * FROM sales_key_stats_2015 ORDER BY id_profiles DESC LIMIT 10;
-- 2) Total row count (formatted) in 2015 table
SELECT FORMAT(COUNT(*), 0) FROM sales_key_stats_2015 ORDER BY id_profiles DESC LIMIT 10;

-- 3) Year x gender breakdown with member_created_at_category = new (created_year), distinct profiles, and total rows (formatted)
SELECT
    purchased_on_year_adjusted_mp,
    gender_id_profiles,
    gender_profiles,
    
    -- Distinct profiles flagged as "new" / repeat
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category IS NULL OR member_created_at_category = 'created_year' THEN id_profiles END), 0) AS count_distinct_member_created_at_new,
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category IS NULL OR member_created_at_category = 'after_created_year' THEN id_profiles END), 0) AS count_distinct_member_created_at_new,
    FORMAT(COUNT(DISTINCT CASE WHEN member_created_at_category IS NULL OR member_created_at_category = 'after_created_year' OR member_created_at_category = 'created_year' THEN id_profiles END), 0) AS count_distinct_member_created_at_total,
    FORMAT(COUNT(DISTINCT id_profiles), 0) AS distinct_id_profiles,
    
    -- Count of rows
    FORMAT(SUM(CASE WHEN member_created_at_category IS NULL OR member_created_at_category = 'created_year' THEN 1 ELSE 0 END), 0) AS count_total_member_created_at_new,
    FORMAT(SUM(CASE WHEN member_created_at_category IS NULL OR member_created_at_category = 'after_created_year' THEN 1 ELSE 0 END), 0) AS count_total_member_created_at_repeat,
    FORMAT(SUM(CASE WHEN member_created_at_category IS NULL OR member_created_at_category = 'after_created_year' OR member_created_at_category = 'created_year' THEN 1 ELSE 0 END), 0) AS count_total_member_created_at_total,
    FORMAT(COUNT(*), 0) AS total_rows
    
FROM sales_key_stats_2015
WHERE 1 = 1
  AND age_as_year_end_bin IN ('20-29')
  AND gender_profiles = 'f'
  AND purchased_on_year_adjusted_mp <> '2025'
GROUP BY
  purchased_on_year_adjusted_mp,
  gender_id_profiles,
  gender_profiles
ORDER BY purchased_on_year_adjusted_mp DESC
;

-- 4) Find profiles with member created at category both new & repeat in 2024
SELECT
    purchased_on_year_adjusted_mp,
    gender_id_profiles,
    gender_profiles,
    id_profiles,
    GROUP_CONCAT(member_created_at_category)
FROM sales_key_stats_2015
WHERE 1 = 1
  AND age_as_year_end_bin IN ('20-29')
  AND gender_profiles = 'f'
  AND member_created_at_category IN ('created_year', 'after_created_year')
  AND purchased_on_year_adjusted_mp = '2024'
  -- AND id_profiles = '235475'
  AND id_profiles = '2264133'
GROUP BY
    purchased_on_year_adjusted_mp,
    gender_id_profiles,
    gender_profiles,
    id_profiles
HAVING
    SUM(member_created_at_category = 'created_year') > 0
    AND SUM(member_created_at_category = 'after_created_year') > 0
ORDER BY purchased_on_year_adjusted_mp DESC, id_profiles
LIMIT 10
;

-- 🔎 Per-row diagnostics for one profile in 2024
SELECT
	-- s.*
	s.id_profiles,
	s.purchased_on_year_adjusted_mp,
	s.gender_id_profiles,
	s.gender_profiles,
	s.purchased_on_year_adjusted_mp,
	YEAR(mc.min_created_at),
    CASE WHEN s.purchased_on_year_adjusted_mp = YEAR(mc.min_created_at) THEN 't' ELSE 'f' END AS 'rule 1',
    lp.member_lifetime_purchases,
    CASE WHEN lp.member_lifetime_purchases = 1 THEN 't' ELSE 'f' END AS 'rule 2',
    YEAR(first_starts_mp),
    YEAR(s.starts_mp),
    CASE WHEN lp.member_lifetime_purchases > 1 AND YEAR(s.first_starts_mp) = YEAR(s.starts_mp) THEN 't' ELSE 'f' END AS 'rule 3',
    YEAR(mc.min_created_at),
	-- repeat member
    CASE WHEN s.purchased_on_year_adjusted_mp > YEAR(mc.min_created_at) THEN 't' ELSE 'f' END AS 'rule 4',
    CASE WHEN lp.member_lifetime_purchases > 1 AND YEAR(s.first_starts_mp) = s.purchased_on_year_adjusted_mp THEN 'created_year' ELSE 0 END AS test,
    
    s.member_created_at_category,
    
    CASE WHEN lp.member_lifetime_purchases > 1 AND YEAR(s.first_starts_mp) < YEAR(s.starts_mp) THEN 'after_created_year' ELSE 0 END AS test_2,
    s.new_member_category_6_sa
  
FROM sales_key_stats_2015 s
	LEFT JOIN step_2_member_min_created_at_date AS mc ON s.id_profiles = mc.id_profiles
    LEFT JOIN step_3_member_total_life_time_purchases AS lp ON s.id_profiles = lp.id_profiles
WHERE 1=1
  -- AND s.id_profiles IN ('235475', '2196738', '2284565', 2386295, '2515657')
  -- AND s.id_profiles IN ('924274')
  AND s.id_profiles IN ( '2264133')
  -- AND s.purchased_on_year_adjusted_mp IN ('2023', '2024')
  AND s.member_created_at_category IN ('created_year', 'after_created_year')
ORDER BY id_profiles, purchased_on_adjusted_mp
;

