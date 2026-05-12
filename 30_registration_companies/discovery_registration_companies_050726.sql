USE vapor;

SELECT * FROM membership_applications LIMIT 10;
SELECT * FROM membership_periods LIMIT 10;

SELECT 
    registration_companies.id, 
    registration_companies.name, 
    FORMAT(COUNT(mp.id), 0) AS membership_count,
    CONVERT_TZ(NOW(), 'UTC', 'America/Denver') AS as_of_date,
    NOW() AS as_of_date
FROM membership_periods AS mp
    LEFT JOIN registration_audit ON mp.id = registration_audit.membership_period_id
    LEFT JOIN registration_companies ON registration_audit.registration_company_id = registration_companies.id
    LEFT JOIN membership_types AS mt ON mt.id = mp.membership_type_id 
WHERE 1 = 1
    AND mp.starts > '2025-12-31'
    -- AND registration_companies.id = 33 -- njuko
GROUP BY 1, 2
ORDER BY 1 DESC
LIMIT 100
;

SELECT 
    registration_companies.id, 
    registration_companies.name,
    mp.*,
    mt.name,
    CONVERT_TZ(NOW(), 'UTC', 'America/Denver') AS as_of_date,
    NOW() AS as_of_date
FROM membership_periods AS mp
    LEFT JOIN registration_audit ON mp.id = registration_audit.membership_period_id
    LEFT JOIN registration_companies ON registration_audit.registration_company_id = registration_companies.id
    LEFT JOIN membership_types AS mt ON mt.id = mp.membership_type_id 
WHERE 1 = 1
    AND mp.starts > '2025-12-31'
    AND registration_companies.id = 33 -- njuko
GROUP BY 1, 2
ORDER BY 1 DESC
LIMIT 100
;

SELECT 
    registration_companies.id, 
    registration_companies.name,
    mp.*,
    mt.name,
    CONVERT_TZ(NOW(), 'UTC', 'America/Denver') AS as_of_date,
    NOW() AS as_of_date
FROM membership_periods AS mp
    LEFT JOIN registration_audit ON mp.id = registration_audit.membership_period_id
    LEFT JOIN registration_companies ON registration_audit.registration_company_id = registration_companies.id
    LEFT JOIN membership_types AS mt ON mt.id = mp.membership_type_id 
WHERE 1 = 1
    -- AND mp.starts > '2025-12-31'
    AND registration_companies.id = 33 -- njuko
ORDER BY 1 DESC
-- LIMIT 100
;

SELECT * FROM membership_periods AS mp WHERE mp.id IN (5359692, 5359859, 5359961, 5359976);