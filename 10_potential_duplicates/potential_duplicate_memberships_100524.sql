USE usat_sales_db;

WITH potential_duplicate_records AS (
	SELECT
        member_number_members_sa,
        -- id_membership_periods_sa,
        
        purchased_on_adjusted_mp,
        real_membership_types_sa,
        new_member_category_6_sa,
        membership_type_id_mp,

        starts_mp,
        ends_mp,

        COUNT(*) AS record_count

    FROM all_membership_sales_data_2015_left

    -- WHERE member_number_members_sa IN (180347762) -- On 9/18/24, Sam confirmed this was likely a duplicate & terminated this record 
    -- WHERE member_number_members_sa IN (180347762, 356157100, 2100034949) -- three additional examples
    -- WHERE member_number_members_sa IN ('652371015') -- multiple records with start 5/27/24 & end 8/5/24?

    -- WHERE YEAR(purchased_on_adjusted_mp) IN (2023)

    -- '2100021324' 2 annual 2023, '419528807' 4 one day 2023
    -- WHERE member_number_members_sa IN (2100021324, 419528807)

    GROUP BY
        member_number_members_sa,
        -- id_membership_periods_sa,
        purchased_on_adjusted_mp,
        real_membership_types_sa,
        new_member_category_6_sa,
        membership_type_id_mp,
        starts_mp,
        ends_mp
    HAVING record_count > 1
    ORDER BY 
        member_number_members_sa, 
        purchased_on_adjusted_mp, 
        starts_mp, ends_mp, 
        record_count
    LIMIT 10000
)

-- #1 - ALL RECORDS
-- SELECT * FROM potential_duplicate_records;

-- #2 - COUNT BY PURCHASED ON YEAR
-- SELECT 
--     YEAR(purchased_on_adjusted_mp) AS year, 
--     FORMAT(COUNT(*), 0) AS count
-- FROM potential_duplicate_records 
-- GROUP BY YEAR(purchased_on_adjusted_mp) WITH ROLLUP
-- ORDER BY YEAR(purchased_on_adjusted_mp) ASC;  -- Order by year ascending


-- #3 - RUNNING TOTAL OF THE RECORD COUNT COLUMN
-- SUM OF THE RECORD COUNT = 8,231 FOR 4,115 membership numbers having > 1 membership period with identical purchase on, start, end date
-- SELECT 
--     *,
--     CASE
--         WHERE 
--     SUM(record_count) OVER (ORDER BY purchased_on_adjusted_mp, member_number_members_sa, starts_mp, ends_mp) AS running_total

-- FROM potential_duplicate_records
-- ORDER BY running_total DESC;     

-- #4 - SELECT RECORDS FROM THE POTENTIAL DUPLICATE RECORDS
SELECT
    sa.member_number_members_sa,
    sa.id_membership_periods_sa,
    
    sa.purchased_on_adjusted_mp,

    sa.real_membership_types_sa,
    sa.new_member_category_6_sa,
    sa.membership_type_id_mp,

    sa.starts_mp,
    sa.ends_mp
FROM potential_duplicate_records AS dr
    JOIN all_membership_sales_data_2015_left AS sa 
        ON dr.member_number_members_sa = sa.member_number_members_sa 
        AND dr.purchased_on_adjusted_mp = sa.purchased_on_adjusted_mp 
        AND dr.starts_mp = sa.starts_mp 
        AND dr.ends_mp = sa.ends_mp;
