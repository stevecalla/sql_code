SELECT 
        mp.id as membership_period_id,
        m.member_number, 
        UPPER(p.first_name) as first_name ,
        UPPER(p.last_name) as last_name, 
        UPPER(u.email) as email, 
        ph.number as phone_number,
        p.date_of_birth, 
        g.label as gender, 
        DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), p.date_of_birth)), '%Y') + 0 AS age_today,
        DATE_FORMAT(FROM_DAYS(DATEDIFF('2024-12-31', p.date_of_birth)), '%Y') + 0 AS race_age_2024,
        a.address,
        a.address2,
        a.address3,
        a.city,
        s.code as state_code,
        s.name as state_name, 
        a.postal_code,
        a.country_code,
        a.country_name,
        ml.label as military_status,
        e.label as ethnicity,
        el.name as education_level,
        CASE
                WHEN il.max_level IS NULL THEN NULL
                WHEN il.max_level =29999 then "$0-$29,999"
                WHEN il.max_level =59999 then "$30,000-$59,999"
                WHEN il.max_level =99999 then "$60,000-$99,999"
                WHEN il.max_level =149999 then "$100,000-$149,999"
                WHEN il.max_level =999999999 then "$150,000+" 
        ELSE NULL END as income_level,
        CASE
                WHEN mt.id IN(4,51,61,78,94,107) THEN "Youth Annual"
                WHEN mt.id IN(5,46,47,49,72,97,100,108,109,110,111,115,118) then "One Day"
                WHEN mt.id IN(83,84,86,87,88,90,102) THEN "Elite"
                WHEN mt.id IN(56,57,58,59,81,105) then "Club"
                WHEN mt.id IN(1,2,3,50,52,53,54,55,60,62,64,65,66,67,68,70,71,73,74,75,82,85,89,91,92,93,95,96,98,99,101,103,104,106,112,113,114,117,119) THEN "Adult Annual"
        ELSE mt.id END AS membership_type,
        CASE
                WHEN mt.id IN(4,51,54,61,78,94) THEN "Youth Annual"
                WHEN mt.id IN(107) THEN "Youth Premier"
                WHEN mt.id IN(55) THEN "Young Adult"
                WHEN mt.id IN(74,103) THEN "Lifetime"
                WHEN mt.id IN(112) THEN "Silver"
                WHEN mt.id IN(113) THEN "Gold"
                WHEN mt.id IN(114) THEN "Platinum - Team USA"
                WHEN mt.id IN(117) THEN "Platinum - Foundation"
                WHEN mt.id IN(118) THEN "Bronze-AO"
                WHEN mt.id IN(119) THEN "3-Year Silver"
                WHEN mt.id IN(115) THEN "Bronze"
                WHEN mt.id IN(83,84,86,87,88,90,102) THEN "Elite"
                WHEN mt.id IN(1,60,62,64,67,71,75,95,104,106) THEN "1-Year" 
                WHEN mt.id IN(2,52,65,70,73,91,92,93,96,98) THEN "2-Year" 
                WHEN mt.id IN(3,66,68,82,85,89,99,101) THEN "3-Year"
                WHEN mt.id IN(50) THEN "5-Year"
                WHEN mt.id IN(53) THEN "4-Year"               
                WHEN mt.id IN(5,46,47,49,72,97,100,108,109,110,111) then "One Day"
        ELSE mt.id END AS membership_subtype,
        mt.name as membership_type_name,
        mp.created_at as membership_created_date,
        mp.purchased_on as membership_purchase_date,
        mp.starts as membership_start_date,
        mp.ends as membership_start_date,
        CASE
                WHEN CURDATE() between mp.starts AND mp.ends THEN "Active Today"
                ElSE NULL END AS active_today
FROM profiles as p 
LEFT JOIN members as m ON p.id = m.memberable_id
LEFT JOIN users as u ON p.user_id = u.id
LEFT JOIN membership_periods as mp on m.id = mp.member_id
LEFT JOIN membership_types as mt ON mp.membership_type_id = mt.id
LEFT JOIN genders as g ON p.gender_id = g.id
LEFT JOIN addresses as a ON p.primary_address_id = a.id
LEFT JOIN states as s ON a.state_id = s.id
LEFT JOIN ethnicities as e ON p.ethnicity_id = e.id
LEFT JOIN income_levels as il ON p.income_id = il.id
LEFT JOIN education_levels as el ON p.education_id = el.id
LEFT JOIN militaries as ml ON p.military_id = ml.id
LEFT JOIN phones as ph ON p.primary_phone_id = ph.id
WHERE 1=1
AND p.deleted_at IS NULL
AND m.deleted_at IS NULL
AND u.deleted_at IS NULL
AND mp.deleted_at IS NULL
AND mp.terminated_on IS NULL
AND mt.id NOT IN (56,57,58,59,81,105)
AND mp.ends >= "2020-01-01"
LIMIT 20;