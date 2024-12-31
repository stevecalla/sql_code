USE usat_marketo_db;

-- leadId from the marketo data should match up with profiles.marketo_lead_id

-- #1) GET BASIC TABLE STATS
    SELECT * FROM marketo_email_data LIMIT 10;
    SELECT CONVERT_TZ(max(created_at_utc), '+00:00', '-07:00') AS created_at_mtn, COUNT(*) FROM marketo_email_data LIMIT 10;
    SELECT 'marketo_email_data', COUNT(*) FROM marketo_email_data LIMIT 100; -- as of 11/2024 9:30p '1371990'

    SELECT * FROM marketo_temp_table;
    SELECT 'marketo_temp_table', COUNT(*) FROM marketo_temp_table; -- as of 11/20/24 9:30p '195965'
-- **************************************

-- #2) DAILY SALES REPORT DATA
    SELECT 
        *
    FROM marketo_email_data 
    WHERE LOWER(segment) NOT IN ('other segment')
    -- LIMIT 1000   
    ;
-- **************************************

-- #3) UPDATE - REMOVE CONTROL DESIGNATION
    UPDATE marketo_temp_table
    SET segment = REPLACE(segment, ' - Control', '')
    WHERE segment LIKE '% - Control' AND id > 0;

    UPDATE marketo_email_data
    SET segment = REPLACE(segment, ' - Control', '')
    WHERE segment LIKE '% - Control' AND id > 0;
-- **************************************

-- #4) 3-YEAR RELAUNCH PIVOT
    SELECT 
        segment,
        primary_attribute_value,
        MIN(activity_date_utc),
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) AS email_sent,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email delivered') THEN 1 ELSE 0 END) AS email_delivered,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email open') THEN 1 ELSE 0 END) AS email_open,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email click') THEN 1 ELSE 0 END) AS email_click,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email bounced') THEN 1 ELSE 0 END) AS email_bounced,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email unsubscribe') THEN 1 ELSE 0 END) AS email_unsubscribe,
        COUNT(*), 
        MAX(created_at_utc)
    FROM marketo_email_data 
    WHERE LOWER(segment) NOT IN ('other segment')
    GROUP BY 2, 1
    -- LIMIT 1000
    ;
-- **************************************

-- #5) 3-YEAR RELAUNCH PIVOT WITH ADDITIONAL STATS
    SELECT 
        segment,
        primary_attribute_value,
        -- MIN(activity_date_utc),
        CONVERT_TZ(MIN(activity_date_utc), '+00:00', '-07:00') AS min_activity_date_mtn,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) AS email_sent,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email delivered') THEN 1 ELSE 0 END) AS email_delivered,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email open') THEN 1 ELSE 0 END) AS email_open,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email click') THEN 1 ELSE 0 END) AS email_click,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email bounced') THEN 1 ELSE 0 END) AS email_bounced,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email unsubscribe') THEN 1 ELSE 0 END) AS email_unsubscribe,
        COUNT(*) AS total_activities,
        
        -- Calculate percentage of delivered emails
        CASE 
            WHEN SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) > 0 
            THEN (SUM(CASE WHEN LOWER(activity_type_desc) IN ('email delivered') THEN 1 ELSE 0 END) * 100.0) 
                / SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) 
            ELSE 0 
        END AS percent_delivered,

        -- Calculate percentage of opened emails
        CASE 
            WHEN SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) > 0 
            THEN (SUM(CASE WHEN LOWER(activity_type_desc) IN ('email open') THEN 1 ELSE 0 END) * 100.0) 
                / SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) 
            ELSE 0 
        END AS percent_opened,

        -- Calculate percentage of clicked emails
        CASE 
            WHEN SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) > 0 
            THEN (SUM(CASE WHEN LOWER(activity_type_desc) IN ('email click') THEN 1 ELSE 0 END) * 100.0) 
                / SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) 
            ELSE 0 
        END AS percent_clicked,

        -- Max created_on for all records (without per-grouping)
        (	
            SELECT 
                MAX(created_at_utc)
            FROM marketo_email_data  
            LIMIT 1
        ) AS max_created_on_utc,

        -- Max created_on for all records (without per-grouping)
        (	
            SELECT 
                CONVERT_TZ(MAX(created_at_utc), '+00:00', '-07:00')
            FROM marketo_email_data  
            LIMIT 1
        ) AS max_created_at_mtn

    FROM marketo_email_data 
    WHERE 
        LOWER(segment) NOT IN ('other segment')
        -- AND DATE(CONVERT_TZ(activity_date_utc, '+00:00', '-07:00')) = DATE(SUBDATE(CURRENT_DATE(), 1)) -- yesterday
        AND DATE(CONVERT_TZ(activity_date_utc, '+00:00', '-07:00')) = DATE(CURRENT_DATE()) -- today
    GROUP BY segment, primary_attribute_value
    -- LIMIT 1000
    ;
-- **************************************

-- #6) NOT 3-YEAR RELAUNCH - OTHER SEGMENTS - PIVOT WITH ADDITIONAL STATS
    SELECT 
		id,
        marketo_GUID,
        lead_id,
        segment,
        primary_attribute_value,
        -- MIN(activity_date_utc),
        CONVERT_TZ(MIN(activity_date_utc), '+00:00', '-07:00') AS min_activity_date_mtn,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) AS email_sent,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email delivered') THEN 1 ELSE 0 END) AS email_delivered,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email open') THEN 1 ELSE 0 END) AS email_open,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email click') THEN 1 ELSE 0 END) AS email_click,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email bounced') THEN 1 ELSE 0 END) AS email_bounced,
        SUM(CASE WHEN LOWER(activity_type_desc) IN ('email unsubscribe') THEN 1 ELSE 0 END) AS email_unsubscribe,
        COUNT(*) AS total_activities,
        
        -- Calculate percentage of delivered emails
        CASE 
            WHEN SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) > 0 
            THEN (SUM(CASE WHEN LOWER(activity_type_desc) IN ('email delivered') THEN 1 ELSE 0 END) * 100.0) 
                / SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) 
            ELSE 0 
        END AS percent_delivered,

        -- Calculate percentage of opened emails
        CASE 
            WHEN SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) > 0 
            THEN (SUM(CASE WHEN LOWER(activity_type_desc) IN ('email open') THEN 1 ELSE 0 END) * 100.0) 
                / SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) 
            ELSE 0 
        END AS percent_opened,

        -- Calculate percentage of clicked emails
        CASE 
            WHEN SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) > 0 
            THEN (SUM(CASE WHEN LOWER(activity_type_desc) IN ('email click') THEN 1 ELSE 0 END) * 100.0) 
                / SUM(CASE WHEN LOWER(activity_type_desc) IN ('email sent') THEN 1 ELSE 0 END) 
            ELSE 0 
        END AS percent_clicked,

        -- Max created_on for all records (without per-grouping)
        (	
            SELECT 
                MAX(created_at_utc)
            FROM marketo_email_data  
            LIMIT 1
        ) AS max_created_on_utc,

        -- Max created_on for all records (without per-grouping)
        (	
            SELECT 
                CONVERT_TZ(MAX(created_at_utc), '+00:00', '-07:00')
            FROM marketo_email_data  
            LIMIT 1
        ) AS max_created_at_mtn

    FROM marketo_email_data 
    WHERE 
        LOWER(segment) IN ('other segment')
        -- AND DATE(CONVERT_TZ(activity_date_utc, '+00:00', '-07:00')) = DATE(SUBDATE(CURRENT_DATE(), 1)) -- yesterday
        -- AND DATE(CONVERT_TZ(activity_date_utc, '+00:00', '-07:00')) = DATE(CURRENT_DATE()) -- today
        AND 
        (
			primary_attribute_value LIKE ('%24BFT FRIDAY%')
			OR primary_attribute_value LIKE ('%Giving Tuesday%')
        )
    GROUP BY 1, 2, 3, segment, primary_attribute_value
    -- GROUP BY segment, primary_attribute_value
    ORDER BY email_sent DESC
    -- LIMIT 1000
    ;
-- **************************************

-- #7) INSERT INTO MARKETO EMAIL DATA (MIGHT BE OUT OF DATE WITH CODE IN PROGRAM FILE)
    -- INSERT INTO marketo_email_data (
    --     id,
    --     marketoGUID,
    --     leadId,
    --     activity_date,
    --     activityTypeId,
    --     campaignId,
    --     primaryAttributeValueId,
    --     primaryAttributeValue,
    --     activity_type_desc,
    --     segment,
    --     created_at,
    --     Bot_Activity_Pattern,
    --     Browser,
    --     Campaign_Run_ID,
    --     Choice_Number,
    --     Device,
    --     Is_Bot_Activity,
    --     Is_Mobile_Device,
    --     Link,
    --     Platform,
    --     Step_ID,
    --     User_Agent
    -- )
    -- SELECT 
    --     t.id,
    --     t.marketoGUID,
    --     t.leadId,
    --     t.activity_date,
    --     t.activityTypeId,
    --     t.campaignId,
    --     t.primaryAttributeValueId,
    --     t.primaryAttributeValue,
    --     t.activity_type_desc,
    --     t.segment,
    --     t.created_at,
    --     t.Bot_Activity_Pattern,
    --     t.Browser,
    --     t.Campaign_Run_ID,
    --     t.Choice_Number,
    --     t.Device,
    --     t.Is_Bot_Activity,
    --     t.Is_Mobile_Device,
    --     t.Link,
    --     t.Platform,
    --     t.Step_ID,
    --     t.User_Agent
    -- FROM marketo_temp_table AS t
    -- ON DUPLICATE KEY UPDATE
    --     activity_date = t.activity_date,
    --     activityTypeId = t.activityTypeId,
    --     campaignId = t.campaignId,
    --     primaryAttributeValueId = t.primaryAttributeValueId,
    --     primaryAttributeValue = t.primaryAttributeValue,
    --     activity_type_desc = t.activity_type_desc,
    --     segment = t.segment,
    --     created_at = t.created_at,
    --     Bot_Activity_Pattern = t.Bot_Activity_Pattern,
    --     Browser = t.Browser,
    --     Campaign_Run_ID = t.Campaign_Run_ID,
    --     Choice_Number = t.Choice_Number,
    --     Device = t.Device,
    --     Is_Bot_Activity = t.Is_Bot_Activity,
    --     Is_Mobile_Device = t.Is_Mobile_Device,
    --     Link = t.Link,
    --     Platform = t.Platform,
    --     Step_ID = t.Step_ID,
    --     User_Agent = t.User_Agent;
-- **************************************