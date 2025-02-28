-- ****************************
-- GET MEMBERSHIP SALES DATA
-- ****************************
SELECT 	
	created_at_mp,
	id_events,
    starts_mp,
    ends_mp,
    id_membership_periods_sa,
    member_number_members_sa,
    id_profiles,
    COUNT(id_membership_periods_sa)
    
FROM usat_sales_db.all_membership_sales_data_2015_left 
WHERE created_at_mp > '2024-06-01'
-- WHERE LOWER(email_ma) = '00dmar@gmail.com'
-- WHERE member_number_members_sa = '455406422'
-- WHERE member_number_members_sa = '2'
GROUP BY 1, 2, 3, 4, 5, 6, 7
ORDER BY created_at_mp ASC
-- LIMIT 10
;