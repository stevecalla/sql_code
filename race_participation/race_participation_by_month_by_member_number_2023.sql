SELECT 
        rr.member_number AS MemberNumber,
        year(r.start_date) AS RaceYear,
        month(r.start_date) AS RaceMonth,
        dt.name AS Distance,
        count(DISTINCT rr.id) AS RaceResults
FROM race_results as rr 
LEFT JOIN races as r on rr.race_id = r.id
LEFT JOIN events as e on r.event_id = e.id
LEFT JOIN distance_types as dt on r.distance_type_id = dt.id
WHERE 
	year(r.start_date) IN (2023)
--     AND 
--     rr.member_number IN (24)
GROUP BY 1,2,3,4;
-- LIMIT 10;