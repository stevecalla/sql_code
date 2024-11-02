USE vapor;

SELECT 
        rr.member_number AS member_number_rr
        , r.name as races_name
        , YEAR(r.start_date) AS year_races
        , MONTH(r.start_date) AS month_races
        , dt.name AS distance_dt
        , FORMAT(COUNT(DISTINCT rr.id), 0) AS count_race_results

FROM race_results AS rr 
        LEFT JOIN races AS r ON rr.race_id = r.id
        LEFT JOIN events AS e ON r.event_id = e.id
        LEFT JOIN distance_types AS dt ON r.distance_type_id = dt.id

WHERE year(r.start_date) IN (2023)
--     AND rr.member_number IN (24)

GROUP BY 1,2,3,4
LIMIT 10
;