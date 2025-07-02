USE usat_sales_db;

SELECT * FROM all_membership_sales_data_2015_left LIMIT 10;
SELECT FORMAT(COUNT(DISTINCT id_profiles), 0) FROM all_membership_sales_data_2015_left WHERE ends_mp >= '2024-01-01' LIMIT 10; -- 209,570 >= 2025-01-01; 360,831 = 2024-01-01;
SELECT id_profiles, id_membership_periods_sa FROM all_membership_sales_data_2015_left WHERE id_membership_periods_sa = 3703836;

SELECT * FROM rev_recognition_base_profile_ids_data LIMIT 50;
SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_base_profile_ids_data LIMIT 50; -- 209,570 >= 2025-01-01; 360,831 2024-01-01;
SELECT id_profiles FROM rev_recognition_base_profile_ids_data WHERE id_profiles = 2701138;
SELECT id_profiles, FORMAT(COUNT(*), 0) AS count FROM rev_recognition_base_profile_ids_data GROUP BY 1 ORDER by COUNT DESC LIMIT 50; -- 852

SELECT * FROM rev_recognition_base_upgraded_from_ids_data LIMIT 50;
SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_base_upgraded_from_ids_data LIMIT 50; -- originally 853 but added 3 exceptions to a where clause that reduced to 850
SELECT * FROM rev_recognition_base_upgraded_from_ids_data WHERE id_profiles IN (2701138, 2738933) LIMIT 50; -- these profiles originally had duplicate upgraded from ids
SELECT upgraded_from_id_mp, COUNT(*) AS count FROM rev_recognition_base_upgraded_from_ids_data GROUP BY 1 HAVING count > 1;

SELECT * FROM rev_recognition_base_data LIMIT 20;
SELECT * FROM rev_recognition_base_data WHERE has_upgrade_from_or_to_path = 1 LIMIT 20;
SELECT id_profiles, id_membership_periods_sa FROM rev_recognition_base_data WHERE id_profiles = 2701138; -- upgraded from assigned to more than 1 member period
SELECT COUNT(*) FROM rev_recognition_base_data WHERE has_upgrade_from_or_to_path = 1 LIMIT 20; -- 1,684
SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_base_data LIMIT 10; -- 850,046; ends_mp >= 2025-01-01; 1,279,282 2024-01-01
SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_base_data WHERE ends_mp >= '2024-01-01' LIMIT 10; -- 252,255 >= 2025-01-01; 532,906 = 2024-01-01;

-- SELECT COUNT(*) FROM rev_recognition_base_data WHERE ends_mp >= '2026-01-01' LIMIT 10; -- 59,755
-- SELECT COUNT(*) FROM rev_recognition_base_data WHERE ends_mp >= '2025-01-01' AND starts_mp <= '2025-12-31'LIMIT 10; -- 247,961

SELECT * FROM rev_recognition_allocation_data LIMIT 100;
SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data LIMIT 10; -- TBD >= 2025-01-01; 4,832,518 = 2024-01-01;

-- Create a copy to include indexes, primary keys, constraints, etc., then do this in two steps:
-- Step 1: Copy table structure only (no data)
-- CREATE TABLE rev_recognition_allocation_data LIKE rev_recognition_allocation_data_copy;

-- Step 2: Copy data
-- INSERT INTO rev_recognition_allocation_data
-- SELECT * FROM rev_recognition_allocation_data_copy;

-- RENAME TABLE rev_recognition_allocated_data_copy TO rev_recognition_allocation_data_copy;

