-- Switch to the newly created database
USE usat_membership_base_db;

-- Set parameters
SET @calendar_start_date = '2023-01-01';
SET @starts_date = '2019-01-01';
SET @ends_date = '2019-01-01';

-- Drop key_metrics_core_onrent_days if exists
DROP TABLE IF EXISTS step_3_membership_base;

-- Create onrent by segment by day
CREATE TABLE step_3_membership_base
    SELECT
        ct.calendar_date,
        
        -- TOTAL MEMBER COUNT
		COUNT(bm.id_membership_periods_sa) AS count_member,
        
        -- TOTAL MEMBER COUNT WHEN ONE STARTS YEAR MP IS CURRENT CALENDAR YEAR
        SUM(CASE
				WHEN LOWER(bm.real_membership_types_sa) = "one_day" AND starts_year_mp = YEAR(ct.calendar_date) THEN 1
                ELSE 0
            END
        ) AS count_one_day_same_year,
            
        -- CUMULATIVE TOTAL OF count_one_day_same_year
        SUM(
            SUM(CASE
                    WHEN LOWER(bm.real_membership_types_sa) = "one_day" AND starts_year_mp = YEAR(ct.calendar_date) THEN 1
                    ELSE 0
                END)
        ) OVER (
            PARTITION BY YEAR(ct.calendar_date) 
            ORDER BY ct.calendar_date
        ) AS cumulative_count_one_day_same_year,
        
		-- COUNT ONE DAY
        SUM(CASE
				WHEN LOWER(bm.real_membership_types_sa) = "one_day" THEN 1
                ELSE 0
            END
        ) AS count_one_day_type,
        
		-- COUNT ADULT ANNUAL
        SUM(CASE
                WHEN LOWER(bm.real_membership_types_sa) = "adult_annual" THEN 1
                ELSE 0
            END
        ) AS count_adult_annual_type,
        
		-- COUNT YOUTH ANNUAL
        SUM(CASE
                WHEN LOWER(bm.real_membership_types_sa) = "youth_annual" THEN 1
                ELSE 0
            END
        ) AS count_youth_annual_type,
        
		-- COUNT ELITE
        SUM(CASE
                WHEN LOWER(bm.real_membership_types_sa) = "elite" THEN 1
                ELSE 0
            END
        ) AS count_elite_type,
        
		-- COUNT OTHER
        SUM(CASE
                WHEN LOWER(bm.real_membership_types_sa) = "other" THEN 1
                ELSE 0
            END
        ) AS count_other_type,
        
		-- COUNT 'One Day - $15'
        SUM(CASE
                WHEN LOWER(bm.new_member_category_6_sa) = 'one day - $15' THEN 1
                ELSE 0
            END
        ) AS count_one_day_15_category,
        
		-- COUNT BRONZE
        SUM(CASE
                WHEN LOWER(bm.new_member_category_6_sa) LIKE '%bronze%' THEN 1
                ELSE 0
            END
        ) AS count_one_day_bronze_category,
        
		-- COUNT ONE YEAR $50
        SUM(CASE
                WHEN LOWER(bm.new_member_category_6_sa) = "1-year $50" THEN 1
                ELSE 0
            END
        ) AS count_one_year_50_category,
        
		-- COUNT SILVER / ONE YEAR
        SUM(CASE
                WHEN LOWER(bm.new_member_category_6_sa) = "silver" THEN 1
                ELSE 0
            END
        ) AS count_silver_category,
        
		-- COUNT GOLD
        SUM(CASE
                WHEN LOWER(bm.new_member_category_6_sa) = "gold" THEN 1
                ELSE 0
            END
        ) AS count_gold_category,
        
		-- COUNT 3-YEAR
        SUM(CASE
                WHEN LOWER(bm.new_member_category_6_sa) = "3-year" THEN 1
                ELSE 0
            END
        ) AS count_3_year_category,
        
		-- COUNT YOUNG ADULT
        SUM(CASE
                WHEN LOWER(bm.new_member_category_6_sa) LIKE "%young adult%" THEN 1
                ELSE 0
            END
        ) AS count_young_adult_category,
        
		-- COUNT YOUTH ANNUAL
        SUM(CASE
                WHEN LOWER(bm.new_member_category_6_sa) = 'youth annual' THEN 1
                ELSE 0
            END
        ) AS count_youth_annual_category,

		-- COUNT OTHER CATEGORY
        SUM(CASE
                WHEN LOWER(bm.new_member_category_6_sa) = 'one day - $15' THEN 0
                WHEN LOWER(bm.new_member_category_6_sa) LIKE '%bronze%' THEN 0
                WHEN LOWER(bm.new_member_category_6_sa) = "1-year $50" THEN 0
                WHEN LOWER(bm.new_member_category_6_sa) = "silver" THEN 0
                WHEN LOWER(bm.new_member_category_6_sa) = "gold" THEN 0
                WHEN LOWER(bm.new_member_category_6_sa) = "3-year" THEN 0
                WHEN LOWER(bm.new_member_category_6_sa) LIKE "%young adult%" THEN 0
                WHEN LOWER(bm.new_member_category_6_sa) = 'youth annual' THEN 0
                ELSE 1
            END
        ) AS count_other_category

    FROM step_1_calendar_table AS ct
		INNER JOIN step_2b_base_membership_data_dedup bm ON ct.calendar_date >= @calendar_start_date -- Ensure calendar date is after membership start date
		AND bm.starts_mp >= @starts_date -- Ensure membership starts date is after specified start date
        AND ct.calendar_date >= bm.starts_mp -- Ensure calendar date is after or equal to booking date
        AND ct.calendar_date <= bm.ends_mp -- Ensure calendar date is before or equal to return date

    GROUP BY ct.calendar_date
    ORDER BY ct.calendar_date ASC
    -- LIMIT 10
    ;

    SELECT * FROM step_3_membership_base;

    -- ********* TESTING EXAMPLES ************
    -- #1 = '4656165' oneday 8/21 to 8/24/24; same member at #2 & #3
    -- #2 = '4840258' 3-year 12/19/24 - 12/18/27 same member as #1 & #3
    -- #3 = '4840256' adult annual 12/19/24 - 12/18/24 invalid as customer upgraded to 3-year same day; same as #1 & #2; not included in count given end date
    -- '4655200' youth annual 4/28/24 - 3/5/2029
    -- '4588547' adult annual 8/2/24 - 8/1/25
    -- , '3974306', '4685789', 
     -- WHERE id_membership_periods_sa IN ('4656165', '4840256', '4840258', '3974306', '4685789', '4655200', '4588547')
	-- WHERE 
		-- bm.id_membership_periods_sa IN ('4655200', '4588547')
		-- bm.id_membership_periods_sa IN ('4656165', '4840258', '4840256') -- same member
	-- 	-- AND 
    --     ct.calendar_date >= @initial_date
    --     AND bm.starts_mp >= @starts_date
    -- ********* TESTING EXAMPLES ************
    
-- ************************
DROP TABLE IF EXISTS step_4_membership_base_one_day;
-- Step 1: Use a CTE to assign row numbers for unique members within the same year

CREATE TABLE step_4_membership_base_one_day AS
    SELECT 
        *
    FROM (
        WITH unique_one_day_members AS (
            SELECT
                ct.calendar_date,
                bm.member_number_members_sa,
                LOWER(bm.real_membership_types_sa) AS real_membership_type,
                YEAR(ct.calendar_date) AS calendar_year,
                bm.starts_year_mp,
                ROW_NUMBER() OVER (
                    PARTITION BY YEAR(ct.calendar_date), bm.member_number_members_sa
                    ORDER BY ct.calendar_date
                ) AS row_num
            FROM step_1_calendar_table AS ct
            INNER JOIN step_2_base_membership_data_dedup bm 
                ON ct.calendar_date >= @calendar_start_date
                AND bm.starts_mp >= @starts_date
                AND ct.calendar_date >= bm.starts_mp
                AND ct.calendar_date <= bm.ends_mp
        )
        -- Step 2: Create a table with cumulative results
        SELECT
            ct.calendar_date,

            -- TOTAL MEMBER COUNT
            COUNT(bm.id_membership_periods_sa) AS count_member,

            -- TOTAL MEMBER COUNT WHEN ONE STARTS YEAR MP IS CURRENT CALENDAR YEAR
            SUM(CASE
                    WHEN LOWER(bm.real_membership_types_sa) = "one_day" AND bm.starts_year_mp = YEAR(ct.calendar_date) THEN 1
                    ELSE 0
                END
            ) AS count_one_day_same_year,

            -- CUMULATIVE TOTAL OF count_one_day_same_year
            SUM(
                SUM(CASE
                        WHEN LOWER(bm.real_membership_types_sa) = "one_day" AND bm.starts_year_mp = YEAR(ct.calendar_date) THEN 1
                        ELSE 0
                    END)
            ) OVER (
                PARTITION BY YEAR(ct.calendar_date) 
                ORDER BY ct.calendar_date
            ) AS cumulative_count_one_day_same_year,

            -- CUMULATIVE UNIQUE COUNT OF MEMBERS FOR count_one_day_same_year
            SUM(
                CASE
                    WHEN um.row_num = 1 AND um.real_membership_type = "one_day" AND um.starts_year_mp = um.calendar_year
                    THEN 1
                    ELSE 0
                END
            ) OVER (
                PARTITION BY YEAR(ct.calendar_date)
                ORDER BY ct.calendar_date
            ) AS cumulative_unique_count_one_day_same_year

        FROM step_1_calendar_table AS ct
        LEFT JOIN step_2b_base_membership_data_dedup bm 
            ON ct.calendar_date >= @calendar_start_date
            AND bm.starts_mp >= @starts_date
            AND ct.calendar_date >= bm.starts_mp
            AND ct.calendar_date <= bm.ends_mp
        LEFT JOIN unique_one_day_members AS um
            ON ct.calendar_date = um.calendar_date
            AND bm.member_number_members_sa = um.member_number_members_sa

        GROUP BY ct.calendar_date
        ORDER BY ct.calendar_date ASC
    ) as result;

    SELECT * FROM step_4_membership_base_one_day;
