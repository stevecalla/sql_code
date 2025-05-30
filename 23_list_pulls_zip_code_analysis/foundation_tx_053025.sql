-- SELECT * FROM usat_sales_db.sales_key_stats_2015 LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM usat_sales_db.sales_key_stats_2015 LIMIT 10;

SELECT 
	id_profiles,
    member_number_members_sa,
    GROUP_CONCAT(DISTINCT(id_membership_periods_sa)) AS membership_periods,
    GROUP_CONCAT(DISTINCT(starts_year_mp)) AS starts_year_mp,
    GROUP_CONCAT(DISTINCT(ends_year_mp)) AS ends_year_mp,
    GROUP_CONCAT(DISTINCT(real_membership_types_sa)) AS real_membership_types_sa,
    GROUP_CONCAT(DISTINCT(new_member_category_6_sa)) AS new_member_category_6_sa,
    GROUP_CONCAT(DISTINCT(date_of_birth_profiles)) AS date_of_birth_profiles,
    GROUP_CONCAT(DISTINCT(age_now)) AS age_now,
    GROUP_CONCAT(DISTINCT(member_postal_code_addresses)) AS member_postal_code_addresses,
    GROUP_CONCAT(DISTINCT(LEFT(member_postal_code_addresses, 5))) AS member_postal_code_addresses_adjusted,
    GROUP_CONCAT(DISTINCT(member_state_code_addresses))
FROM sales_key_stats_2015
WHERE 1 = 1
	AND member_state_code_addresses IN ('TX')
    AND ends_year_mp >= 2020
    -- AND ends_year_mp <= 2026
    AND CAST(LEFT(member_postal_code_addresses, 5) AS UNSIGNED) BETWEEN 75001 AND 79999
GROUP BY id_profiles, member_number_members_sa, member_state_code_addresses
-- LIMIT 10
;