-- USE usat_sales_db;

-- -- EVENTS
SELECT * FROM all_event_data_raw LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM all_event_data_raw;
-- SELECT * FROM all_event_data_raw WHERE id_sanctioning_events = 353956;

-- -- RUNSIGNUP
SELECT * FROM all_runsignup_data_raw LIMIT 10;
SELECT MAX(created_at_mtn), race_year, FORMAT(COUNT(DISTINCT(race_id)), 0), FORMAT(COUNT(DISTINCT(event_id)), 0) FROM all_runsignup_data_raw GROUP BY 2 ORDER BY 2 LIMIT 10;
SELECT MAX(created_at_mtn), MIN(created_at_mtn), MAX(last_modified_mtn_member_settings), MIN(last_modified_mtn_member_settings) FROM all_runsignup_data_raw LIMIT 10;
SELECT DATE_FORMAT(last_modified_mtn_member_settings, "%y-%m-%d"), FORMAT(COUNT(DISTINCT(race_id)), 0), FORMAT(COUNT(DISTINCT(event_id)), 0) FROM all_runsignup_data_raw GROUP BY 1 WITH ROLLUP ORDER BY 1 LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM all_runsignup_data_raw;
-- SELECT event_type, FORMAT(COUNT(*), 0) FROM all_runsignup_data_raw GROUP BY 1 WITH ROLLUP;
-- SELECT * FROM all_runsignup_data_raw WHERE usat_sanction_id_internal = 353956;
SELECT * FROM all_runsignup_data_raw WHERE race_id = 137876;
SELECT * FROM all_runsignup_data_raw WHERE race_id = 19385;
SELECT * FROM all_runsignup_data_raw WHERE race_id = 26596;

SELECT 
	setting_name_member_settings, 
    FORMAT(COUNT(DISTINCT race_id), 0) AS race_count,
    FORMAT(COUNT(DISTINCT event_id), 0) AS event_count
FROM all_runsignup_data_raw
WHERE 1 = 1

    
 GROUP BY 1 WITH ROLLUP
 ORDER BY 1 ASC
;


-- ============================================================
-- Q1 - Member Setting Summary (USAT only, excluding USATF)
-- Purpose: Count distinct races/events where member setting contains "usat"
-- ============================================================
SELECT 
    'Q1 - Member Setting Summary (USAT only)' AS query_label,
    setting_name_member_settings, 
    FORMAT(COUNT(DISTINCT race_id), 0) AS race_count,
    FORMAT(COUNT(DISTINCT event_id), 0) AS event_count
FROM all_runsignup_data_raw
WHERE 1 = 1
	-- scenario #1 = 1,222 results with a member setting (with USAT Membership 574)
	-- AND setting_name_member_settings IS NOT NULL 
    
    -- scenario #2 = 583  results (with USAT Membership 574)
    AND LOWER(setting_name_member_settings) LIKE '%usat%'
	AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%'
    
    -- scenario #3 = 584  results (with USAT Membership 571)
    -- AND usat_event_id_member_settings IS NOT NULL
GROUP BY 1, 2 WITH ROLLUP
ORDER BY 2 ASC;

-- ============================================================
-- Q2 - Event Type Summary (USAT member setting only)
-- Purpose: Show race/event counts by event_type for USAT settings
-- ============================================================
SELECT 
    'Q2 - Event Type Summary (USAT setting only)' AS query_label,
    event_type, 
    FORMAT(COUNT(DISTINCT race_id), 0) AS race_count,
    FORMAT(COUNT(DISTINCT event_id), 0) AS event_count
FROM all_runsignup_data_raw
WHERE 1 = 1
    -- scenario #2 = 583  results (with USAT Membership 574)
    AND LOWER(setting_name_member_settings) LIKE '%usat%'
    AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%'
GROUP BY 1, 2 WITH ROLLUP
ORDER BY 2 ASC;

-- ============================================================
-- Q3 - Event Type Summary with Match + Member Setting Conditions
-- Purpose: Compare total vs USAT setting vs fuzzy matched (score >= 74)
-- ============================================================
SELECT 
    'Q3 - Event Type Summary (Match + Member Setting)' AS query_label,
    event_type,
    FORMAT(COUNT(DISTINCT IF(usat_sanction_id_internal IS NOT NULL AND match_score_internal >= 74, race_id, NULL)), 0) AS race_count_usat_fuzzy_score_74_plus,
    FORMAT(COUNT(DISTINCT IF(usat_sanction_id_internal IS NOT NULL AND match_score_internal >= 74, event_id, NULL)), 0) AS event_count_usat_fuzzy_score_74_plus,
    FORMAT(COUNT(DISTINCT IF(LOWER(setting_name_member_settings) LIKE '%usat%' AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%', race_id, NULL)), 0) AS race_count_member_setting,
    FORMAT(COUNT(DISTINCT IF(LOWER(setting_name_member_settings) LIKE '%usat%' AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%', event_id, NULL)), 0) AS event_count_member_setting,
    FORMAT(COUNT(DISTINCT race_id), 0) AS race_count_total,
    FORMAT(COUNT(DISTINCT event_id), 0) AS event_count_total
FROM all_runsignup_data_raw
WHERE 1 = 1
GROUP BY 1, 2 WITH ROLLUP
ORDER BY 2 ASC;

-- ============================================================
-- Q4 - Event Type Summary with Zero Formatting
-- Purpose: Same as Q3 but replaces 0 values with '--' for readability
-- ============================================================
SELECT 
    'Q4 - Event Type Summary (Zero formatted)' AS query_label,
    event_type,
    IF(COUNT(DISTINCT IF(usat_sanction_id_internal IS NOT NULL AND match_score_internal >= 74, race_id, NULL)) = 0, '--',
       FORMAT(COUNT(DISTINCT IF(usat_sanction_id_internal IS NOT NULL AND match_score_internal >= 74, race_id, NULL)), 0)
    ) AS race_count_usat_fuzzy_score_74_plus,
    IF(COUNT(DISTINCT IF(usat_sanction_id_internal IS NOT NULL AND match_score_internal >= 74, event_id, NULL)) = 0, '--',
       FORMAT(COUNT(DISTINCT IF(usat_sanction_id_internal IS NOT NULL AND match_score_internal >= 74, event_id, NULL)), 0)
    ) AS event_count_usat_fuzzy_score_74_plus,
    IF(COUNT(DISTINCT IF(LOWER(setting_name_member_settings) LIKE '%usat%' AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%', race_id, NULL)) = 0, '--',
       FORMAT(COUNT(DISTINCT IF(LOWER(setting_name_member_settings) LIKE '%usat%' AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%', race_id, NULL)), 0)
    ) AS race_count_member_setting,
    IF(COUNT(DISTINCT IF(LOWER(setting_name_member_settings) LIKE '%usat%' AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%', event_id, NULL)) = 0, '--',
       FORMAT(COUNT(DISTINCT IF(LOWER(setting_name_member_settings) LIKE '%usat%' AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%', event_id, NULL)), 0)
    ) AS event_count_member_setting,
    IF(COUNT(DISTINCT race_id) = 0, '--', FORMAT(COUNT(DISTINCT race_id), 0)) AS race_count_total,
    IF(COUNT(DISTINCT event_id) = 0, '--', FORMAT(COUNT(DISTINCT event_id), 0)) AS event_count_total
FROM all_runsignup_data_raw
WHERE 1 = 1
GROUP BY 1, 2 WITH ROLLUP
ORDER BY 3 DESC;

-- ============================================================
-- Q5 - Member Setting Level Summary with Zero Formatting
-- Purpose: Same as Q4 but grouped by setting_name_member_settings
-- ============================================================
SELECT 
    'Q5 - Member Setting Summary (Zero formatted)' AS query_label,
    setting_name_member_settings,
    IF(COUNT(DISTINCT IF(usat_sanction_id_internal IS NOT NULL AND match_score_internal >= 74, race_id, NULL)) = 0, '--',
       FORMAT(COUNT(DISTINCT IF(usat_sanction_id_internal IS NOT NULL AND match_score_internal >= 74, race_id, NULL)), 0)
    ) AS race_count_usat_fuzzy_score_74_plus,
    IF(COUNT(DISTINCT IF(usat_sanction_id_internal IS NOT NULL AND match_score_internal >= 74, event_id, NULL)) = 0, '--',
       FORMAT(COUNT(DISTINCT IF(usat_sanction_id_internal IS NOT NULL AND match_score_internal >= 74, event_id, NULL)), 0)
    ) AS event_count_usat_fuzzy_score_74_plus,
    IF(COUNT(DISTINCT IF(LOWER(setting_name_member_settings) LIKE '%usat%' AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%', race_id, NULL)) = 0, '--',
       FORMAT(COUNT(DISTINCT IF(LOWER(setting_name_member_settings) LIKE '%usat%' AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%', race_id, NULL)), 0)
    ) AS race_count_member_setting,
    IF(COUNT(DISTINCT IF(LOWER(setting_name_member_settings) LIKE '%usat%' AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%', event_id, NULL)) = 0, '--',
       FORMAT(COUNT(DISTINCT IF(LOWER(setting_name_member_settings) LIKE '%usat%' AND LOWER(setting_name_member_settings) NOT LIKE '%usatf%', event_id, NULL)), 0)
    ) AS event_count_member_setting,
    IF(COUNT(DISTINCT race_id) = 0, '--', FORMAT(COUNT(DISTINCT race_id), 0)) AS race_count_total,
    IF(COUNT(DISTINCT event_id) = 0, '--', FORMAT(COUNT(DISTINCT event_id), 0)) AS event_count_total
FROM all_runsignup_data_raw
WHERE 1 = 1
GROUP BY 1, 2 WITH ROLLUP
ORDER BY 3 DESC;