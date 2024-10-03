USE usat_sales_db;

SET @member_bronze_a = 'Bronze - $0';
SET @member_bronze_b = 'Bronze - $13';
SET @member_bronze_c = 'Bronze - $18';
SET @member_bronze_d = 'Bronze - $23';
SET @member_bronze_e = 'Bronze - $6';
SET @member_bronze_ao = 'Bronze - AO';
SET @member_bronze_distance_upgrade = 'Bronze - Distance Upgrade';
SET @member_club = 'Club';
SET @member_one_day_a = 'One Day - $15';

SELECT * FROM all_membership_sales_data_2015_left LIMIT 100;

SELECT DISTINCT(real_membership_types_sa), COUNT(*) FROM all_membership_sales_data_2015_left GROUP BY real_membership_types_sa WITH ROLLUP;

SELECT DISTINCT(new_member_category_6_sa), COUNT(*) FROM all_membership_sales_data_2015_left GROUP BY new_member_category_6_sa WITH ROLLUP;

-- #1) SALES BY PURCHASE ON YEAR
SELECT 
	purchased_on_year_adjusted_mp,
	FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
    FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
FROM all_membership_sales_data_2015_left
WHERE new_member_category_6_sa IN (@member_bronze_a, @member_bronze_b, @member_bronze_c, @member_bronze_d, @member_bronze_e, @member_bronze_distance_upgrade, @member_bronze_ao, @member_club, @member_one_day_a)
GROUP BY purchased_on_year_adjusted_mp WITH ROLLUP 
ORDER BY purchased_on_year_adjusted_mp;

-- #2) SALES BY PURCHASE ON YEAR & MONTH
SELECT 
	purchased_on_year_adjusted_mp, 
    purchased_on_month_adjusted_mp,
    FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
    FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
FROM all_membership_sales_data_2015_left
WHERE new_member_category_6_sa IN (@member_bronze_a, @member_bronze_b, @member_bronze_c, @member_bronze_d, @member_bronze_e, @member_bronze_distance_upgrade, @member_bronze_ao, @member_club, @member_one_day_a)
GROUP BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp WITH ROLLUP 
ORDER BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp;

-- #3A) SALES BY PURCHASE ON YEAR, MONNTH... START YEAR, QUARTER
SELECT 
	purchased_on_year_adjusted_mp, 
    purchased_on_month_adjusted_mp,
    YEAR(starts_mp),
    QUARTER(starts_mp), 
    FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
    FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
FROM all_membership_sales_data_2015_left
WHERE new_member_category_6_sa IN (@member_bronze_a, @member_bronze_b, @member_bronze_c, @member_bronze_d, @member_bronze_e, @member_bronze_distance_upgrade, @member_bronze_ao, @member_club, @member_one_day_a)
GROUP BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp, YEAR(starts_mp), QUARTER(starts_mp) WITH ROLLUP
ORDER BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp;

-- #3B) SALES BY START YEAR
SELECT 
    YEAR(starts_mp),
    FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
    FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
FROM all_membership_sales_data_2015_left
WHERE new_member_category_6_sa IN (@member_bronze_a, @member_bronze_b, @member_bronze_c, @member_bronze_d, @member_bronze_e, @member_bronze_distance_upgrade, @member_bronze_ao, @member_club, @member_one_day_a)
GROUP BY YEAR(starts_mp) WITH ROLLUP
ORDER BY yEAR(starts_mp);

-- #3C) SALES BY START YEAR, END YEAR
SELECT 
    YEAR(starts_mp),
    YEAR(ends_mp),
    FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
    FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
FROM all_membership_sales_data_2015_left
WHERE new_member_category_6_sa IN (@member_bronze_a, @member_bronze_b, @member_bronze_c, @member_bronze_d, @member_bronze_e, @member_bronze_distance_upgrade, @member_bronze_ao, @member_club, @member_one_day_a)
GROUP BY YEAR(starts_mp), YEAR(ends_mp) WITH ROLLUP
ORDER BY yEAR(starts_mp), YEAR(ends_mp);

-- #4A) QUERY SHOWS MEMBERSHIP END PERIOD COUNT BY YEAR OF END DATE
SELECT 
	YEAR(ends_mp),
    FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
    FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
FROM all_membership_sales_data_2015_left
WHERE new_member_category_6_sa IN (@member_bronze_a, @member_bronze_b, @member_bronze_c, @member_bronze_d, @member_bronze_e, @member_bronze_distance_upgrade, @member_bronze_ao, @member_club, @member_one_day_a)
GROUP BY YEAR(ends_mp) WITH ROLLUP
ORDER BY YEAR(ends_mp);

-- #4B) QUERY SHOWS MEMBERSHIP END PERIOD COUNT BY YEAR, QUAARTER, MONTH OF END DATE
SELECT 
	YEAR(ends_mp),
    QUARTER(ends_mp),
    MONTH(ends_mp), 
    FORMAT(COUNT(DISTINCT(member_number_members_sa)), 0) AS member_count,
    FORMAT(COUNT(id_membership_periods_sa), 0) AS sales_units,
    FORMAT(SUM(actual_membership_fee_6_sa), 0) AS sales_revenue
FROM all_membership_sales_data_2015_left
WHERE new_member_category_6_sa IN (@member_bronze_a, @member_bronze_b, @member_bronze_c, @member_bronze_d, @member_bronze_e, @member_bronze_distance_upgrade, @member_bronze_ao, @member_club, @member_one_day_a)
GROUP BY YEAR(ends_mp), QUARTER(ends_mp), MONTH(ends_mp) WITH ROLLUP
ORDER BY YEAR(ends_mp), QUARTER(ends_mp), MONTH(ends_mp);

-- #5) QUERY SHOWS MEMBERS WITH ADVANCE PURCHASES. PURCHASED IN 2023 BUT STARTS >= 2025
SELECT 
    member_number_members_sa,
    id_membership_periods_sa,
    purchased_on_adjusted_mp,
    starts_mp,
    ends_mp
FROM all_membership_sales_data_2015_left
WHERE 
    new_member_category_6_sa IN (@member_bronze_a, @member_bronze_b, @member_bronze_c, @member_bronze_d, @member_bronze_e, @member_bronze_distance_upgrade, @member_bronze_ao, @member_club, @member_one_day_a)
    AND
    -- purchased_on_year_adjusted_mp IN (2022)
    purchased_on_year_adjusted_mp IN (2023)
    AND 
    YEAR(starts_mp) >= 2025
ORDER BY purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp;