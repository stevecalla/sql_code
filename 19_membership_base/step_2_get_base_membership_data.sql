-- Switch to the newly created database
USE usat_membership_base_db;

-- RENAME TABLE step_2_base_membership_data TO delete_table_please;
-- RENAME TABLE step_2_base_membership_data_all TO step_2a_base_membership_data_all;
-- RENAME TABLE step_2_base_membership_data_dedup TO step_2b_base_membership_data_dedup;

-- ****************** GET CORE SALES DATA ********************
DROP TABLE IF EXISTS step_2a_base_membership_data_all;

-- ****************** START --- CREATE BASE MEMBERSHIP DATA --- START ********************
-- STEP #1: GET ALL DATA WITH STARTS YEAR MP >= 2021
CREATE TABLE IF NOT EXISTS step_2a_base_membership_data_all (
    SELECT 
        member_number_members_sa,
        id_profiles,
        origin_flag_ma,
        id_membership_periods_sa,
        real_membership_types_sa,
        new_member_category_6_sa,
        purchased_on_adjusted_mp,
        purchased_on_date_adjusted_mp,
        purchased_on_year_adjusted_mp,
        purchased_on_quarter_adjusted_mp,
        purchased_on_month_adjusted_mp,
        starts_mp,
        starts_year_mp,
        starts__quarter_mp,
        starts_month_mp,
        ends_mp,
        ends_year_mp,
        ends_quarter_mp,
        ends_month_mp,
        starts_events,
        starts_year_events,
        starts_quarter_events,
        starts_month_events,
        ends_events,
        ends_year_events,
        ends_quarter_events,
        ends_month_events,
        age_now_bin,
        sales_revenue
    FROM usat_sales_db.sales_key_stats_2015
    WHERE starts_year_mp >= 2021
    -- LIMIT 10
);

-- Create indexes to optimize queries
CREATE INDEX idx_member_number ON step_2a_base_membership_data_all (member_number_members_sa);
CREATE INDEX idx_id_profiles ON step_2a_base_membership_data_all (id_profiles);
CREATE INDEX idx_purchased_on_date ON step_2a_base_membership_data_all (purchased_on_date_adjusted_mp);
CREATE INDEX idx_starts_mp ON step_2a_base_membership_data_all (starts_mp);
CREATE INDEX idx_ends_mp ON step_2a_base_membership_data_all (ends_mp);
CREATE INDEX idx_real_membership_types_sa ON step_2a_base_membership_data_all (real_membership_types_sa);
CREATE INDEX idx_new_member_category_6_sa ON step_2a_base_membership_data_all (new_member_category_6_sa);

SHOW INDEXES FROM step_2a_base_membership_data_all;

ALTER TABLE step_2a_base_membership_data_all
    ADD COLUMN created_at_mtn TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
-- ****************** END --- CREATE BASE MEMBERSHIP DATA ---- END ********************

-- ****************** START --- CREATE BASE MEMBERSHIP DATA WITH MAX ID MEMBERSHIP PERIOD FOR DUPS ---- START ********************
-- sTEP #2: THIS QUERY STILL ELIMINATES DUPLICATES BECAUSE THE MAX ID MEMBERSHIP PERIOD IS UNIQUE
-- VERIFIED VIA THE COMPARISION IN 19_membership_base/discovery_base_membership_122224.sql
DROP TABLE IF EXISTS step_2b_base_membership_data_dedup;
CREATE TABLE step_2b_base_membership_data_dedup AS
    SELECT 
        *
    FROM (
        WITH eliminate_duplicate_members AS (
            SELECT
                member_number_members_sa,
                starts_mp,
                MAX(ends_mp) AS max_ends_mp,
                MAX(id_membership_periods_sa) AS max_id_membership_periods_sa,
                GROUP_CONCAT(id_membership_periods_sa) AS all_membership_periods,
                GROUP_CONCAT(DISTINCT purchased_on_adjusted_mp) AS all_purchased_on_adjusted_mp,
                GROUP_CONCAT(DISTINCT real_membership_types_sa) AS all_real_membership_types,
                GROUP_CONCAT(DISTINCT new_member_category_6_sa) AS all_new_member_categories
            FROM usat_sales_db.sales_key_stats_2015
            -- WHERE id_membership_periods_sa IN ('4656165', '4840256', '4840258', '3974306', '4685789', '4655200', '4588547')
            GROUP BY member_number_members_sa, starts_mp
        )
        SELECT 
            b.*
        FROM eliminate_duplicate_members AS dp
        JOIN usat_sales_db.sales_key_stats_2015 AS b
            ON dp.member_number_members_sa = b.member_number_members_sa
            AND dp.starts_mp = b.starts_mp
            AND b.id_membership_periods_sa = dp.max_id_membership_periods_sa
        WHERE starts_year_mp >= 2021
        ORDER BY dp.member_number_members_sa
    ) AS result;

    SELECT * FROM step_2b_base_membership_data_dedup;
    SELECT "step_2_base_membership", COUNT(*) FROM step_2b_base_membership_data_dedup LIMIT 10;
-- ****************** END --- CREATE BASE MEMBERSHIP DATA WITH MAX MEMBER ID MEMBERSHIP PERIOD FOR DUPS ---- END ********************

-- ****************** START --- CREATE BASE MEMBERSHIP DATA WITH MAX END DATE ID FOR DUPS ---- START ********************
-- THIS QUERY STILL RETURNS DUPLICATES BECAUSE THE MAX END DATE CAN RETURN MULTIPLE RECORDS
-- DROP TABLE IF EXISTS step_2_base_membership_data_max_date;
-- CREATE TABLE step_2_base_membership_data_max_date AS
--     SELECT 
--         *
--     FROM (
--         WITH eliminate_duplicate_members AS (
--             SELECT
--                 member_number_members_sa,
--                 starts_mp,
--                 MAX(ends_mp) AS max_ends_mp,
--                 MAX(id_membership_periods_sa) AS max_id_membership_periods_sa,
--                 GROUP_CONCAT(id_membership_periods_sa) AS all_membership_periods,
--                 GROUP_CONCAT(DISTINCT purchased_on_adjusted_mp) AS all_purchased_on_adjusted_mp,
--                 GROUP_CONCAT(DISTINCT real_membership_types_sa) AS all_real_membership_types,
--                 GROUP_CONCAT(DISTINCT new_member_category_6_sa) AS all_new_member_categories
--             FROM usat_sales_db.sales_key_stats_2015
--             -- WHERE id_membership_periods_sa IN ('4656165', '4840256', '4840258', '3974306', '4685789', '4655200', '4588547')
--             GROUP BY member_number_members_sa, starts_mp
--         )
--         SELECT 
--             b.*
--         FROM eliminate_duplicate_members AS dp
--         JOIN usat_sales_db.sales_key_stats_2015 AS b
--             ON dp.member_number_members_sa = b.member_number_members_sa
--             AND dp.starts_mp = b.starts_mp
--             AND b.ends_mp = dp.max_ends_mp
--         WHERE starts_year_mp >= 2021
--         ORDER BY dp.member_number_members_sa
--     ) AS result;

--     SELECT * FROM step_2_base_membership_data_max_date;
--     SELECT "step_2_base_membership", COUNT(*) FROM step_2_base_membership_data_max_date LIMIT 10;
-- ****************** START --- CREATE BASE MEMBERSHIP DATA WITH MAX END DATE ID FOR DUPS ---- START ********************
