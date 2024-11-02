USE usat_sales_db;

-- SELECT
-- 	FORMAT(COUNT(DISTINCT member_number_members_sa), 0) AS member_count
-- FROM all_membership_sales_data_2015_left;

-- CREATE INDEX idx_date_of_birth_profiles ON all_membership_sales_data_2015_left (date_of_birth_profiles);
-- CREATE INDEX idx_date_of_birth_ma ON all_membership_sales_data_2015_left (date_of_birth_ma);
-- CREATE INDEX idx_date_of_birth_registration_audit ON all_membership_sales_data_2015_left (date_of_birth_registration_audit);

-- determined that date_of_birth_profiles should be used to determine age
WITH date_of_birth AS (
	SELECT
		member_number_members_sa,
        -- create age as of now
		YEAR(CURDATE()) - YEAR(date_of_birth_profiles) - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(date_of_birth_profiles, '%m%d')) AS age_now,
        CASE WHEN MIN(date_of_birth_profiles) IS NULL THEN 0 ELSE 1 END AS has_date_of_birth,
        MIN(date_of_birth_profiles) AS date_of_birth
	FROM all_membership_sales_data_2015_left
    -- WHERE member_number_members_sa IN ('10000106', '10000108', '100063152')
    GROUP BY 1, 2
)

-- SELECT FORMAT(COUNT(*), 0) FROM date_of_birth
-- SELECT * FROM date_of_birth
SELECT 
	YEAR(date_of_birth), 
    age_now,
    -- create bin for date of birth as of sale date
    CASE
        WHEN age_now < 0 THEN 'bad_age'
        WHEN age_now < 10 THEN '0-9'
        WHEN age_now < 20 THEN '10-19'
        WHEN age_now < 30 THEN '20-29'
        WHEN age_now < 40 THEN '30-39'
        WHEN age_now < 50 THEN '40-49'
        WHEN age_now < 60 THEN '50-59'
        WHEN age_now < 70 THEN '60-69'
        WHEN age_now < 80 THEN '70-79'
        WHEN age_now < 90 THEN '80-89'
        WHEN age_now < 100 THEN '90-99'
        WHEN age_now >= 100 THEN 'bad_age'
        ELSE 'bad_age'
    END AS age_now_bin,
    FORMAT(SUM(has_date_of_birth), 0),
    FORMAT(COUNT(DISTINCT member_number_members_sa), 0) AS member_count
FROM date_of_birth
GROUP BY 1, 2 WITH ROLLUP
ORDER BY YEAR(date_of_birth)
;
    