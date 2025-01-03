USE usat_sales_db;

SELECT * FROM all_membership_sales_data_2015_left LIMIT 10;
SELECT * FROM sales_key_stats_2015 WHERE member_number_members_sa IN ('1001416') LIMIT 10 ;

SELECT
 *
FROM all_membership_sales_data_2015_left
WHERE member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
LIMIT 10;

-- STEP #NEW = MOST RECENT PRIOR PURCHASE TO DETERMINE NEW, LAPSED, RENEW -- TODO: 
SELECT 
    am1.member_number_members_sa,
    am1.id_membership_periods_sa,
    am1.real_membership_types_sa,
    am1.new_member_category_6_sa,
    am1.purchased_on_adjusted_mp AS most_recent_purchase_date,
    (
        SELECT 
            MAX(am2.purchased_on_adjusted_mp)
        FROM all_membership_sales_data_2015_left am2
        WHERE 
            am2.member_number_members_sa = am1.member_number_members_sa
            AND am2.purchased_on_adjusted_mp < am1.purchased_on_adjusted_mp
            AND am2.member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
        LIMIT 1
    ) AS most_recent_prior_purchase_date,
    (
        SELECT 
             am2.real_membership_types_sa
        FROM all_membership_sales_data_2015_left am2
        WHERE 
            am2.member_number_members_sa = am1.member_number_members_sa
            AND am2.purchased_on_adjusted_mp < am1.purchased_on_adjusted_mp
            AND am2.member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
		ORDER BY am2.purchased_on_adjusted_mp DESC
		LIMIT 1
    ) AS most_recent_prior_purchase_membership_type,
    (
        SELECT 
			am2.new_member_category_6_sa
        FROM all_membership_sales_data_2015_left am2
        WHERE 
            am2.member_number_members_sa = am1.member_number_members_sa
            AND am2.purchased_on_adjusted_mp < am1.purchased_on_adjusted_mp
            AND am2.member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
		ORDER BY am2.purchased_on_adjusted_mp DESC
		LIMIT 1
    ) AS most_recent_prior_purchase_membership_category
FROM all_membership_sales_data_2015_left am1
WHERE member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
;
-- *********************************************

USE usat_sales_db;

-- get random member numbers
SELECT 
	* 
FROM sales_key_stats_2015
WHERE purchased_on_year_adjusted_mp = 2024
LIMIT 10;

-- view results in prior purchase table
SELECT 
	* 
FROM step_7_prior_purchase 
WHERE member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
ORDER BY member_number_members_sa, id_membership_periods_sa
LIMIT 10;

-- view final results in sales table
SELECT 
	member_number_members_sa,
    id_membership_periods_sa,
    real_membership_types_sa,
    new_member_category_6_sa,
    most_recent_purchase_date,
    most_recent_prior_purchase_date,
    member_lapsed_renew_category,
    most_recent_prior_purchase_membership_type,
    most_recent_prior_purchase_membership_category,	
    member_upgrade_downgrade_category
FROM sales_key_stats_2015 
WHERE member_number_members_sa IN ('1001416', '100181772', '100142051', '100853852') 
ORDER BY member_number_members_sa, id_membership_periods_sa
LIMIT 10 ;

--     -- Calculate the difference in days
--     DATEDIFF(
--         am1.purchased_on_adjusted_mp,
--         (
--             SELECT 
--                 MAX(am2.purchased_on_adjusted_mp)
--             FROM all_membership_sales_data_2015_left am2
--             WHERE 
--                 am2.member_number_members_sa = am1.member_number_members_sa
--                 AND am2.purchased_on_adjusted_mp < am1.purchased_on_adjusted_mp
--                 AND am2.member_number_members_sa IN (1001416)
--         )
--     ) AS days_since_prior_purchase,
-- 	-- Calculate the difference in years
--     TIMESTAMPDIFF(
--         YEAR,
--         (
--             SELECT 
--                 MAX(am2.purchased_on_adjusted_mp)
--             FROM all_membership_sales_data_2015_left am2
--             WHERE 
--                 am2.member_number_members_sa = am1.member_number_members_sa
--                 AND am2.purchased_on_adjusted_mp < am1.purchased_on_adjusted_mp
--                 AND am2.member_number_members_sa IN (1001416)
--             ),
--         am1.purchased_on_adjusted_mp
--    ) AS years_since_prior_purchase
