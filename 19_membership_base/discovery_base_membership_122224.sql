-- Switch to the newly created database
USE usat_membership_base_db;

-- Select all records with a limit of 10
-- SELECT * FROM step_2_base_membership_data WHERE starts_year_mp IN ('2024') LIMIT 10;

-- SELECT "step_2_base_membership", COUNT(*) FROM step_2_base_membership_data LIMIT 10;

-- SELECT * FROM step_2_base_membership_data WHERE id_membership_periods_sa IN ('4656165');

SELECT * FROM step_2_base_membership_data WHERE id_membership_periods_sa IN ('4656165', '4840256', '4840258', '3974306', '4685789', '4655200', '4588547');

-- SELECT DISTINCT(real_membership_types_sa), COUNT(*) FROM step_2_base_membership_data GROUP BY 1 LIMIT 100;

-- SELECT DISTINCT(new_member_category_6_sa), real_membership_types_sa, COUNT(*) FROM step_2_base_membership_data GROUP BY 1, 2 LIMIT 100;

-- DISCOVERY REVIEW ONE DAY WITH STARTS & ENDS MP DATES NOT MATCHING
-- SELECT * FROM step_2_base_membership_data WHERE real_membership_types_sa = 'one_day' AND ends_mp > starts_mp;
-- SELECT * FROM step_2_base_membership_data WHERE real_membership_types_sa = 'one_day' AND ends_mp < starts_mp;
-- SELECT * FROM step_2_base_membership_data WHERE real_membership_types_sa = 'one_day' AND ends_mp = starts_mp;
-- SELECT * FROM step_2_base_membership_data WHERE real_membership_types_sa = 'one_day';

-- ENSURE ALL THREE QUERIES RETURN SAME DISTINCT MEMBER COUNT
SELECT 'max_id_membership', COUNT(*), COUNT(DISTINCT member_number_members_sa) FROM step_2_base_membership_data;
SELECT 'max_date', COUNT(*), COUNT(DISTINCT member_number_members_sa) FROM step_2_base_membership_data_max_date;
SELECT 'all_data', COUNT(*), COUNT(DISTINCT member_number_members_sa) FROM step_2_base_membership_data_all;

-- COMPARE QUERIES TO DETERMINE WHICH ELIMINATES DUPLICATES; MAX ID MEMBERSHIP ELIMINATES DUPLICATES; MAX DATE DOES NOT BECAUSE...
-- THE MAX DATE CAN BE EXIST ON MORE THAN ONE RECORD
SELECT 'max_id_membership', b.* FROM step_2_base_membership_data AS b WHERE member_number_members_sa = '10000106'; -- 10
SELECT 'max_date', b.* FROM step_2_base_membership_data_max_date AS b WHERE member_number_members_sa = '10000106'; -- 12
SELECT 'all records', b.* FROM step_2_base_membership_data_all AS b WHERE member_number_members_sa = '10000106'; -- 9313

