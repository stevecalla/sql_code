USE usat_sales_db;

WITH potential_duplicate_records AS (
	SELECT
        purchased_on_mp, 
        member_number_members_sa,
        -- id_membership_periods_sa,
        starts_mp,
        ends_mp,
        COUNT(*) AS record_count
    FROM all_membership_sales_data 
    -- WHERE member_number_members_sa IN (180347762) -- On 9/18/24, Sam confirmed this was likely a duplicate & terminated this record 
    -- WHERE member_number_members_sa IN (356157100, 2100034949) -- two additional examples
    GROUP BY
        member_number_members_sa,
        purchased_on_mp,
        starts_mp,
        ends_mp
    HAVING record_count > 1
    ORDER BY purchased_on_mp, member_number_members_sa, starts_mp, ends_mp, record_count
    LIMIT 10000
)

-- #1 ALL RECORDS
-- SELECT * FROM potential_duplicate_records;

-- #2 COUNT BY PURCHASED ON YEAR
-- SELECT 
--     YEAR(purchased_on_mp), 
--     COUNT(*)
-- FROM potential_duplicate_records 
-- GROUP BY YEAR(purchased_on_mp) WITH ROLLUP
-- ORDER BY YEAR(purchased_on_mp);

-- RUNNING TOTAL OF THE RECORD COUNT COLUMN
-- SUM OF THE RECORD COUNT = 8,231 FOR 4,115 membership numbers having > 1 membership period with identical purchase on, start, end date
-- SELECT 
--     *,
--     SUM(record_count) OVER (ORDER BY purchased_on_mp, member_number_members_sa, starts_mp, ends_mp) AS running_total
-- FROM potential_duplicate_records
-- ORDER BY running_total DESC;     

-- SELECT RECORDS FROM THE POTENTIAL DUPLICATE RECORDS
SELECT
    sa.purchased_on_mp, 
    sa.member_number_members_sa,
    sa.id_membership_periods_sa,
    sa.starts_mp,
    sa.ends_mp
FROM potential_duplicate_records AS dr
    JOIN all_membership_sales_data AS sa 
        ON dr.member_number_members_sa = sa.member_number_members_sa 
        AND dr.purchased_on_mp = sa.purchased_on_mp 
        AND dr.starts_mp = sa.starts_mp 
        AND dr.ends_mp = sa.ends_mp;
