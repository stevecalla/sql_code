USE vapor; 

-- need to eliminate duplicates
WITH member_race_count AS (
        SELECT 
                rr.profile_id AS profile_id_rr
                , rr.original_member_number AS member_number_original_rr
                , rr.member_number AS member_number_rr
                , rr.first_name AS first_name_rr
                , rr.last_name AS last_name_rr
                , rr.city AS city_rr
                , YEAR(r.start_date) AS race_year
                , FORMAT(COUNT(rr.race_id), 0) AS count_rr
        FROM 
                race_results AS rr
                LEFT JOIN races AS r ON rr.race_id = r.id  
        WHERE 
                YEAR(r.start_date) >= 2020
                -- YEAR(r.start_date) IN (2022, 2023, 2024) 
		-- AND MONTH(r.start_date) IN (8)
        GROUP BY 
                rr.first_name, 
                rr.last_name, 
                rr.profile_id,
                rr.original_member_number,
                rr.member_number,
                rr.city, 
                rr.race_id, 
                YEAR(r.start_date)
        ORDER BY 
                rr.member_number,
                rr.profile_id
        -- HAVING count_rr > 1
        -- LIMIT 100   
)

-- SELECT * FROM member_race_count;        
-- SELECT * FROM member_race_count WHERE profile_id_rr IS NOT NULL;
-- SELECT 
--     count_rr AS number_of_races,
--     COUNT(*) AS count_of_members
-- FROM member_race_count
-- GROUP BY count_rr
-- ORDER BY count_rr;

SELECT 
    FORMAT(count_rr, 0) AS number_of_races,
    FORMAT(SUM(CASE WHEN race_year = 2020 THEN 1 ELSE 0 END), 0) AS count_of_members_2020,
    FORMAT(SUM(CASE WHEN race_year = 2021 THEN 1 ELSE 0 END), 0) AS count_of_members_2021,
    FORMAT(SUM(CASE WHEN race_year = 2022 THEN 1 ELSE 0 END), 0) AS count_of_members_2022,
    FORMAT(SUM(CASE WHEN race_year = 2023 THEN 1 ELSE 0 END), 0) AS count_of_members_2023,
    FORMAT(SUM(CASE WHEN race_year = 2024 THEN 1 ELSE 0 END), 0) AS count_of_members_2024
FROM member_race_count
GROUP BY count_rr WITH ROLLUP
ORDER BY count_rr;
