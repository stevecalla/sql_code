USE usat_sales_db;

-- #1) DAILY SALES REPORT DATA
    SELECT * FROM slack_membership_sales_data LIMIT 10;
-- **************************************

-- #2) DAILY SALES REPORT COUNT
    SELECT COUNT(*) FROM slack_membership_sales_data LIMIT 10;
-- **************************************

-- #3) SALES BY PURCHASE ON DATE
	SELECT 
		IFNULL(sd.purchased_on_date_adjusted_mp, 'Total') AS purchased_on_mtn,
        
		COUNT(*),

		DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s') AS queried_at_mtn

	FROM slack_membership_sales_data AS sd
    GROUP BY 1 WITH ROLLUP;
-- **************************************

-- #4) CREATE TABLE WITH DATA FORMATED FOR SLACK OUTPUT
    DROP TABLE IF EXISTS slack_membership_sales_reporting_data;

    CREATE TABLE slack_membership_sales_reporting_data AS
        SELECT 
            DATE_FORMAT(sd.purchased_on_date_adjusted_mp, '%Y-%m-%d') AS purchased_on_date_adjusted_mp_mtn,
            sd.member_number_members_sa,
            sd.id_membership_periods_sa,
            
            -- ORIGIN FLAG LOGIC
            CASE
                WHEN sd.origin_flag_ma IS NULL THEN 'Direct'
                WHEN sd.origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 'Sub'
                WHEN sd.origin_flag_ma IN ('ADMIN_BULK_UPLOADER') THEN 'Bulk'
                WHEN sd.origin_flag_ma IN ('AUDIT_API') THEN 'Audit'
                WHEN sd.origin_flag_ma IN ('RTAV_CLASSIC') THEN 'RTAV'
                ELSE 'Other'
            END AS origin_flag_category,
            
            -- MEMBERSHIP TYPE
            CASE
                WHEN sd.real_membership_types_sa IN ('adult_annual') THEN 'Adult'
                WHEN sd.real_membership_types_sa IN ('one_day') THEN 'One_Day'
                WHEN sd.real_membership_types_sa IN ('youth_annual') THEN 'Youth'
                WHEN sd.real_membership_types_sa IN ('elite') THEN 'Elite'
                ELSE "Other"
            END AS real_membership_type,

            -- MEMBERSHIP CATEGORY
            CASE
                WHEN sd.new_member_category_6_sa IN ('Silver') THEN 'Silver'
                WHEN sd.new_member_category_6_sa IN ('Gold') THEN 'Gold'
                WHEN sd.new_member_category_6_sa IN ('3-Year') THEN '3-Year'
                WHEN sd.new_member_category_6_sa LIKE ('%Bronze%') THEN 'Bronze'
                ELSE "Other"
            END AS new_membership_type,
            
            -- DATES
            DATE_FORMAT(sd.purchased_on_adjusted_mp, '%Y-%m-%d %H:%i:%s') AS purchased_on_adjusted_mp_mtn,
            DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s') AS queried_at_mtn,
            
            -- BLACK FRIDAY INCENTIVE ELIGIBLE
            CASE WHEN DATE(sd.purchased_on_adjusted_mp) >= '2024-11-29' THEN 1 ELSE 0 END AS '>=_2024_11_27',
            CASE WHEN DATE(sd.purchased_on_adjusted_mp) >= '2024-11-29' AND TIME(sd.purchased_on_adjusted_mp) >= '06:00:00' THEN 1 ELSE 0 END AS '>=06:00_am',

            CASE
                WHEN 
                    sd.purchased_on_adjusted_mp > '2024-11-29 06:00:00' -- Full datetime comparison
                    AND sd.new_member_category_6_sa IN ('Gold', 'Silver', '3-Year') 
                    AND sd.origin_flag_ma IS NULL -- blank represents Member Hub sales, excluding subscription & registration channels  
                THEN 1 ELSE 0
            END AS is_incentive_eligible,

            -- INCENTIVE INVENTORY
            CASE
                WHEN 
                    DATE(sd.purchased_on_adjusted_mp) >= '2024-11-29'
                    AND TIME(sd.purchased_on_adjusted_mp) >= '06:00:00'
                    AND sd.new_member_category_6_sa IN ('Gold', 'Silver') 
                    AND sd.origin_flag_ma IS NULL
                THEN 380
                WHEN 
                    DATE(sd.purchased_on_adjusted_mp) >= '2024-11-29'
                    AND TIME(sd.purchased_on_adjusted_mp) >= '06:00:00'
                    AND sd.new_member_category_6_sa IN ('3-Year') 
                    AND sd.origin_flag_ma IS NULL
                THEN 180
                ELSE 0
            END AS inventive_inventory,
                
            -- adusted to use created_on (which is mtn) if the purchase_on is greater as a proxy
            (SELECT DATE_FORMAT(MAX(
                CASE WHEN purchased_on_adjusted_mp > created_at_mp THEN CONVERT_TZ(purchased_on_adjusted_mp, 'UTC', 'America/Denver') 
                    ELSE purchased_on_adjusted_mp
                END), '%Y-%m-%d %H:%i:%s') 
            FROM slack_membership_sales_data) AS max_purchased_on_mtn,

            COUNT(*) AS count_units

        FROM slack_membership_sales_data AS sd
        WHERE DATE(sd.purchased_on_date_adjusted_mp) BETWEEN DATE_SUB(DATE(NOW()), INTERVAL 4 DAY) AND DATE(NOW()) -- Filter for the last 5 days including today
        
        GROUP BY 1, 2, 3, 4, 5, 7, 8, 9, 10
        ORDER BY 1, 2, 3, 4;
-- **************************************

-- #5) ALL OUTPUT FROM TABLE AT #4 
    SELECT *, "output from slack reporting data" FROM slack_membership_sales_reporting_data;
-- **************************************

-- #6)
	SELECT 
		IFNULL(sr.purchased_on_date_adjusted_mp_mtn, 'Total') AS purchased_on,
		-- queried_at_mtn
        
		-- MEMBERSHIP CATEGORY
        SUM(CASE WHEN new_membership_type IN ('Bronze') THEN 1 ELSE 0 END) AS 'Bronze',
        SUM(CASE WHEN new_membership_type IN ('Silver') THEN 1 ELSE 0 END) AS 'Silver',
        SUM(CASE WHEN new_membership_type IN ('Gold') THEN 1 ELSE 0 END) AS 'Gold',
        SUM(CASE WHEN new_membership_type IN ('3-Year') THEN 1 ELSE 0 END) AS 'Silver',
        SUM(CASE WHEN new_membership_type IN ('Other') THEN 1 ELSE 0 END) AS 'Other',

		COUNT(*)

	FROM slack_membership_sales_reporting_data AS sr
    GROUP BY 1 WITH ROLLUP;
-- **************************************

-- #7)
	SELECT 
		IFNULL(sr.purchased_on_date_adjusted_mp_mtn, 'Total') AS purchased_on,
		-- queried_at_mtn
        
		-- MEMBERSHIP CATEGORY
        SUM(CASE WHEN new_membership_type IN ('Bronze') THEN 1 ELSE 0 END) AS 'Bronze',
        SUM(CASE WHEN new_membership_type IN ('Silver') THEN 1 ELSE 0 END) AS 'Silver',
        SUM(CASE WHEN new_membership_type IN ('Gold') THEN 1 ELSE 0 END) AS 'Gold',
        SUM(CASE WHEN new_membership_type IN ('3-Year') THEN 1 ELSE 0 END) AS 'Silver',
        SUM(CASE WHEN new_membership_type IN ('Other') THEN 1 ELSE 0 END) AS 'Other',

		COUNT(*)

	FROM slack_membership_sales_reporting_data AS sr
    WHERE is_incentive_eligible = 1
    GROUP BY 1 WITH ROLLUP;
-- **************************************