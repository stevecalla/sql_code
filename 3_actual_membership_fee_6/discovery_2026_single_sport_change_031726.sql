USE usat_sales_db;

SELECT "sample sales data query" AS query_label, s.* FROM all_membership_sales_data_2015_left AS s LIMIT 10;
SELECT "record count query" AS query_label, FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left LIMIT 10;
SELECT purchased_on_year_adjusted_mp, FORMAT(COUNT(*), 0) FROM all_membership_sales_data_2015_left GROUP BY 1 WITH ROLLUP LIMIT 1000;

SELECT "category unknown query" AS query_label, s.id_membership_periods_sa, s.member_number_members_sa, s.purchased_on_mp, s.real_membership_types_sa, s.new_member_category_6_sa, s.race_type_id_ma, s.distance_type_id_ma, s.membership_type_id_ma FROM all_membership_sales_data_2015_left AS s WHERE new_member_category_6_sa = "Unknown" LIMIT 200;
SELECT "type unknown query" AS query_label, s.id_membership_periods_sa, s.purchased_on_mp, s.real_membership_types_sa, s.new_member_category_6_sa, s.race_type_id_ma, s.distance_type_id_ma, s.membership_type_id_ma FROM all_membership_sales_data_2015_left AS s WHERE real_membership_types_sa = "Other" LIMIT 200;

SELECT "category unknown query" AS query_label, s.id_membership_periods_sa, s.member_number_members_sa, s.purchased_on_mp, s.real_membership_types_sa, s.new_member_category_6_sa, s.race_type_id_ma, s.distance_type_id_ma, s.membership_type_id_ma, s.actual_membership_fee_6_sa, s.actual_membership_fee_6_rule_sa FROM all_membership_sales_data_2015_left AS s WHERE new_member_category_6_sa = "Bronze - Swim";
SELECT "category unknown query" AS query_label, s.id_membership_periods_sa, s.member_number_members_sa, s.purchased_on_mp, s.real_membership_types_sa, s.new_member_category_6_sa, s.race_type_id_ma, s.distance_type_id_ma, s.membership_type_id_ma, s.actual_membership_fee_6_sa, s.actual_membership_fee_6_rule_sa FROM all_membership_sales_data_2015_left AS s WHERE new_member_category_6_sa = "Bronze - Run";

-- CREATE INDEX idx_all_membership_sales_data_2015_left_order_id_op ON all_membership_sales_data_2015_left (order_id_op);
SELECT "sample sales data query" AS query_label, s.purchased_on_mp, s.* FROM all_membership_sales_data_2015_left AS s WHERE order_id_op IN (47921, 47923) LIMIT 10;
SELECT "sample sales data query" AS query_label, s.purchased_on_mp, s.purchased_on_adjusted_mp, s.* FROM all_membership_sales_data_2015_left AS s WHERE id_membership_periods_sa IN (5312106, 5312658) LIMIT 10;

CREATE INDEX idx_all_membership_sales_data_2015_left_id_registration_audit ON all_membership_sales_data_2015_left (id_registration_audit);
CREATE INDEX idx_all_membership_sales_data_2015_left_id_registration_audit ON sales_key_stats_2015 (id_registration_audit);
SELECT "sample sales data query" AS query_label, s.purchased_on_mp, s.purchased_on_adjusted_mp, s.* FROM sales_key_stats_2015 AS s WHERE id_registration_audit IN (2706713, 2707414) LIMIT 10;

SELECT 
	"membership types query" AS query_label,
	membership_type_id_mp,
    GROUP_CONCAT(
        DISTINCT purchased_on_year_adjusted_mp
        ORDER BY purchased_on_year_adjusted_mp DESC
    ) AS years,
    FORMAT(COUNT(DISTINCT(id_sanctioning_events)), 0),
    FORMAT(COUNT(*), 0)
FROM all_membership_sales_data_2015_left 
GROUP BY 2 WITH ROLLUP
;

SELECT 
	"race types query" AS query_label,
	race_type_id_ma,
    GROUP_CONCAT(
        DISTINCT purchased_on_year_adjusted_mp
        ORDER BY purchased_on_year_adjusted_mp DESC
    ) AS years,
    FORMAT(COUNT(DISTINCT(id_sanctioning_events)), 0),
    FORMAT(COUNT(*), 0)
FROM all_membership_sales_data_2015_left 
GROUP BY 2 WITH ROLLUP
;

SELECT 
	"distance types query" AS query_label,
	distance_type_id_ma,
    GROUP_CONCAT(
        DISTINCT purchased_on_year_adjusted_mp
        ORDER BY purchased_on_year_adjusted_mp DESC
    ) AS years,
    FORMAT(COUNT(DISTINCT(id_sanctioning_events)), 0),
    FORMAT(COUNT(*), 0)
FROM all_membership_sales_data_2015_left 
GROUP BY 2 WITH ROLLUP
;

SELECT 
	"real membership type" AS query_label,
	real_membership_types_sa,
    GROUP_CONCAT(
        DISTINCT purchased_on_year_adjusted_mp
        ORDER BY purchased_on_year_adjusted_mp DESC
    ) AS years,
    FORMAT(COUNT(DISTINCT(id_sanctioning_events)), 0),
    FORMAT(COUNT(*), 0)
FROM all_membership_sales_data_2015_left 
GROUP BY 2 WITH ROLLUP
;

SELECT 
	"new membership category" AS query_label,
	new_member_category_6_sa,
    GROUP_CONCAT(
        DISTINCT purchased_on_year_adjusted_mp
        ORDER BY purchased_on_year_adjusted_mp DESC
    ) AS years,
    FORMAT(COUNT(DISTINCT(id_sanctioning_events)), 0),
    FORMAT(COUNT(*), 0)
FROM all_membership_sales_data_2015_left 
GROUP BY 2 WITH ROLLUP
;

SELECT 
	"new membership category" AS query_label,
    real_membership_types_sa,
	new_member_category_6_sa,
    GROUP_CONCAT(
        DISTINCT purchased_on_year_adjusted_mp
        ORDER BY purchased_on_year_adjusted_mp DESC
    ) AS years,
    FORMAT(COUNT(DISTINCT(id_sanctioning_events)), 0),
    FORMAT(COUNT(*), 0)
FROM all_membership_sales_data_2015_left 
GROUP BY 2, 3 WITH ROLLUP
;

-- membership_type_id_ma
-- race_type_id_ma
-- distance_type_id_ma
