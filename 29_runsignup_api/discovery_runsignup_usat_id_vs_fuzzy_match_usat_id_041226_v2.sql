WITH base_usat_internal AS (
    SELECT
        'Q1 - setting_name_member_settings LIKE usat' AS query_label,
        rd.race_id,
		CASE
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) = LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) THEN '1_match'
            -- WHEN usat_event_id_member_settings IS NULL AND usat_sanction_id_internal IS NULL THEN '3. both_null'
            -- WHEN usat_event_id_member_settings IS NOT NULL AND usat_sanction_id_internal IS NULL THEN '4. usat_sanction_id_null'
            ELSE '2_mismatch'
        END AS comparison_status,
		CASE
            -- WHEN rd.race_name = 'Texas City Triathlon, Duathlon, & Aquabike' THEN 'membership_setting_name wrong'
            -- WHEN rd.race_name = 'St Charles Splash and Dash' THEN 'membership_setting_name wrong'
            -- WHEN rd.race_name = "'DQ Long Beach Island Triathlon, Duathlon, & Aquabike at Bayview Park *#'" THEN 'no usat sanction id in get_race API'
            -- WHEN rd.race_name = "'Eagle River Triathlon'" THEN 'no usat sanction id in get_race API; multiple membership fields in API'
            -- WHEN rd.race_name = 'Adventure Triathlon at The Manor #' THEN 'membership setting name wrong, missing usat sanction # from API, usat specific wrong, usat user notice correct'
            -- WHEN rd.race_name = 'Whiptail Duathlon' THEN 'duathlon only = need to pull event type duathlon for match'
            -- WHEN rd.race_name = 'Green Bay Youth Triathlon' THEN 'membership inside event object layer' -- 197964
            -- WHEN rd.race_name = 'Plutonium Man Triathlon' THEN 'membership inside event object layer' -- 125531
            -- WHEN rd.race_name = 'Eagle River Triathlon' THEN 'membership inside event object layer' -- 71789
			WHEN rd.race_name = "Title 9 Women's Triathlon" THEN "race name different but looks correct; check url"
            WHEN rd.race_name = 'A Tri in the Buff' THEN 'example of a good match' --  = 137876 
            
			WHEN rd.race_name = "Music City Track Carnival" THEN "running event only" -- 6061
            
			WHEN rd.race_name = "Citrus Kids Triathlon" THEN 'no membership settings; registration ask if USAT member but didnt offer purchase option' -- 8255
            WHEN rd.race_name = 'CajunMan Triathlon, Duathlon, Aquabike, Aquathlon & 5k Run' THEN 'no membership settings; registration ask if USAT member' -- 9238
            
            WHEN rd.race_name = 'Timberman Triathlon' THEN 'weird legacy membership setting fields' -- 
            
            WHEN rd.race_name = 'Swim to the Moon Open Water Swim Festival' THEN 'swim only event that has USMS membership setting. no usat membership setting' -- 19385
            WHEN rd.race_name = 'The Active Texan Triathlon' THEN 'usat sanction id doesnt show in runsignup, not collecting membership on runsignup' -- 141220
            WHEN rd.race_name = 'Brewhouse Triathlon' THEN 'usat sanction id is blank in runsignup; collecting $13/$18 wrong fee via runsignup in odd maybe old flow' -- 109588
            WHEN rd.race_name = 'Greenfields Tri/Aqua/Du/ 5K & Splash and Dash #' THEN 'usat sanction id is blank in runsignup; ask if member but does nott charge for membership in runsignup flow' -- 159216
            WHEN rd.race_name = 'Spring Fling Duathlon/5k' THEN 'runsignup sanction id should be 354413' -- '56808' wrong santion id at runsignup

            ELSE 0
        END AS is_possible_exception,

        CASE
			WHEN rd.usat_match_date = rd.race_next_date THEN 'exact_match'
            WHEN rd.usat_match_date BETWEEN DATE_SUB(rd.race_next_date, INTERVAL 7 DAY) AND DATE_ADD(rd.race_next_date, INTERVAL 7 DAY) THEN 'within_7_days'
            ELSE 'other'
        END AS date_match,
        
        MAX(rd.url) AS url,
        MAX(rd.external_race_url) AS external_race_url,
        MAX(ed.registration_url) AS usat_registration_url,

        CASE
            -- 1) Runner's Edge - TOBAY Triathlon & Junior Triathlon 131115 x
            -- 2) Cypress Sprint and Youth Triathlon 139628 x
            -- 3) Splash & Dash - TRI Clear Lake Triathlon 143649 x
            -- 4) Peasantman 80325 x
            -- 5) USA Triathlon Collegiate Club National Championships 169435 x
            -- 6) EXCLUSIVE ONSITE REG! CLASH Endurance Daytona 2026 196250 x
            -- 7) Toughman 2026 152896 x
            -- 8) Jenny Lee Tri Cup presented by Get Fit Families, LLC & Beaver County Tourism 126993 x
            -- 9) Latitude-Fall Triathlon 148084 x
            -- 10) Pigman Triathlon + Duathlon + Aquabike + Open Water Swim 14601 x
            -- 11) The Active Texan Triathlon 141220 x
            -- 12) RipRoar Youth Triathlon | Des Moines, IA 127748 x
            -- 13) 25th Annual Black Canyon Triathlon 143542 x
            -- 14) Women's Open Water Swim Race 177339
            WHEN race_id IN ('131115', '139628', '143649', '80325', '169435', '196250', '152896', '126993', '148084', '14601', '141220', '127748', '143542', '177339') THEN "manual_match"

            -- 1) Columbia River Triathlon 132516
            -- 2) Lightning Warriors Youth Clinic At Bethpage State Park 204160
            -- 3) Rock N RollMan Olympic, Sprint, Duathlon and Aquabike 137786
            -- 4) Stanford Draft Legal Treeathlon 2026 41261
            -- 5) Omaha Triathlon - Nebraska State Championships 2026 68046
            -- 6) Lago Mar MultiSport Festival 129393
            -- 7) Littlefoot Triathlon - CDA 177905
            -- 8) WinSprint Triathlon 49243
            -- 9) Brick Endurance Summer Triathlon Series #2 174223
            WHEN race_id IN ('132516', '204160', '137786', '41261', '68046', '129393', '177905', '49243', '174223') THEN "manual_exclude"

            WHEN ed.registration_url = rd.url THEN "runsignup_url = usat_url"
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) = LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) THEN "runsignup_usat_sanction_id = usat_sanction_id"
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN "sanction_id_mismatch_fuzzy_gt_95"

            ELSE "other"
        END AS registration_url_final_rule,
        
        CASE
            WHEN race_id IN ('131115', '139628', '143649', '80325', '169435', '196250', '152896', '126993', '148084', '14601', '141220', '127748', '143542', '177339') THEN rd.url -- add the URL for manual_match
            WHEN race_id IN ('132516', '204160', '137786', '41261', '68046', '129393', '177905', '49243', '174223') THEN 0

            WHEN ed.registration_url = rd.url THEN rd.url
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) = LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) THEN rd.url
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN rd.url
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN rd.url
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN rd.url

            ELSE 0
        END AS registration_url_final,
        

        -- CASE
        --     -- 'Race in the Clouds - Alma Dirt Festival 2026' 351149
        --     --  'ALMAGEDDON Winter Triathlon presented by the Alma Foundation' 351812
        --     --  'Festival in the Clouds Firefighter 5K, Fun Run and Doggie Dash' 358402
        --     WHEN race_id IN ('187048', '190024', '203571' ) THEN CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX')
        -- END AS registration_url_affiliate_final,
        
        CASE
            WHEN race_id IN ('131115', '139628', '143649', '80325', '169435', '196250', '152896', '126993', '148084', '14601', '141220', '127748', '143542', '177339') THEN CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX')
            WHEN race_id IN ('132516', '204160', '137786', '41261', '68046', '129393', '177905', '49243', '174223') THEN 0

            WHEN ed.registration_url = rd.url THEN CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX')
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) = LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) THEN CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX')
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX')
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX')
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX')
            ELSE 0
        END AS registration_url_affiliate_final,
        
        -- CASE
        --     -- 'Race in the Clouds - Alma Dirt Festival 2026' 351149
        --     --  'ALMAGEDDON Winter Triathlon presented by the Alma Foundation' 351812
        --     --  'Festival in the Clouds Firefighter 5K, Fun Run and Doggie Dash' 358402
            -- WHEN race_id IN ('187048', '190024', '203571' ) THEN CHAR_LENGTH(CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX'))
            -- 	ELSE NULL
        -- END AS registration_url_affiliate_final_char_count,
        
        CASE
            WHEN race_id IN ('131115', '139628', '143649', '80325', '169435', '196250', '152896', '126993', '148084', '14601', '141220', '127748', '143542', '177339') THEN CHAR_LENGTH(CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX'))
            WHEN race_id IN ('132516', '204160', '137786', '41261', '68046', '129393', '177905', '49243', '174223') THEN 0
        
            WHEN ed.registration_url = rd.url THEN CHAR_LENGTH(CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX'))
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) = LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) THEN CHAR_LENGTH(CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX'))
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN CHAR_LENGTH(CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX'))
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN CHAR_LENGTH(CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX'))
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN CHAR_LENGTH(CONCAT(rd.url, '?aflt_token=01FyaaWPrCkItbiUqFusguggm9xpGVGX'))
            ELSE 0
        END AS registration_url_affiliate_final_char_count,
        
        GROUP_CONCAT(DISTINCT(rd.event_type)) AS event_type,
        MAX(rd.setting_name_member_settings) AS setting_name_member_settings,
        MAX(rd.membership_settings_source_member_settings) AS membership_settings_source_member_settings,
        MAX(rd.race_name) AS race_name,
        MAX(rd.address_state) AS address_state,
        MAX(rd.address_city) AS address_city,

        MAX(rd.race_next_date) AS race_next_date,
        MAX(YEAR(rd.race_next_date)) AS race_next_year_date,
        MAX(MONTH(rd.race_next_date)) AS race_next_month_date,
        
        MAX(rd.usat_event_id_member_settings) AS usat_event_id_member_settings,
        MAX(rd.usat_sanction_id_internal) AS usat_sanction_id_internal,

        CASE
            WHEN race_id IN ('131115', '139628', '143649', '80325', '169435', '196250', '152896', '126993', '148084', '14601', '141220', '127748', '143542', '177339') THEN LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6)

            WHEN race_id IN ('132516', '204160', '137786', '41261', '68046', '129393', '177905', '49243', '174223') THEN NULL

            WHEN ed.registration_url = rd.url THEN LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6)
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) = LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) THEN LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6)
            WHEN TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6) AND match_score_internal > 95 THEN LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6)

            ELSE NULL
        END AS registration_url_final_sanction_id,

        MAX(rd.usat_match_name) AS usat_match_name,
        MAX(rd.usat_match_state) AS usat_match_state,
        MAX(rd.usat_match_city) AS usat_match_city,
        
        MAX(rd.usat_match_date) AS usat_match_date,
        MAX(YEAR(rd.usat_match_date)) AS usat_match_year_date,
        MAX(MONTH(rd.usat_match_date)) AS usat_match_month_date,
        
        MAX(rd.match_method) AS match_method,
        MAX(rd.match_score_internal) AS match_score_internal, 
        
        FORMAT(COUNT(DISTINCT rd.race_id), 0) AS race_count_distinct,
        FORMAT(COUNT(*), 0) AS row_count_total,
        
        MAX(rd.created_at_mtn) AS created_at_mtn,
        MAX(rd.created_at_utc) AS created_at_utc

    FROM all_runsignup_data_raw AS rd
        LEFT JOIN all_event_data_raw AS ed ON TRIM(CAST(ed.id_sanctioning_events AS CHAR)) = TRIM(CAST(rd.usat_sanction_id_internal AS CHAR))
        
    WHERE 1 = 1
		-- USING USAT FUZZY MATCH AGAINST RUNSIGNUP TO MATCH RACES / EVENTS
		AND usat_sanction_id_internal IS NOT NULL
        AND rd.match_score_internal >= 74
	
		-- USING RUNSIGNUP DATA TO DETERMINE EVENT URLS
			-- FUNNEL: 583 total with 546 exact sanction id match, 32 not matching, 5 usat_event_id_member_settings IS NULL, 0 usat_sanction_id_internal IS NULL
			-- FUNNEL (with date match): 559 total with 546 goes to 531, 32 goes to 25, 5 goes to 3 for a to tal of 559 out of 583
			-- AND setting_name_member_settings IS NOT NULL -- 1,222
            
			-- AND LOWER(rd.setting_name_member_settings) LIKE '%usat%'
			-- AND LOWER(rd.setting_name_member_settings) NOT LIKE '%usatf%'
            -- AND race_id IN (177570, 124575, 177905, 201543) -- test race ids to be sure the usat_registration_url is returning vs the usat match info
        
			-- THIS LOGIC HAS LARGELY BEEN PUT IN THE registration_url_final AND registration_url_final_rule fields
			-- AND TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) = LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6)
			-- AND TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6)
			-- AND rd.usat_sanction_id_internal IS NULL
			-- AND rd.usat_event_id_member_settings IS NULL
        
			-- AND rd.usat_match_date BETWEEN DATE_SUB(rd.race_next_date, INTERVAL 7 DAY) AND DATE_ADD(rd.race_next_date, INTERVAL 7 DAY)
        
        -- OTHER CRITERIA
			-- AND rd.race_next_date = rd.usat_match_date
			-- AND rd.address_city = rd.usat_match_city
			-- AND rd.race_name = rd.usat_match_name
      
		-- MISMATCHES
			-- AND TRIM(CAST(rd.usat_event_id_member_settings AS CHAR)) <> LEFT(TRIM(CAST(rd.usat_sanction_id_internal AS CHAR)), 6)
			-- AND rd.race_next_date <> rd.usat_match_date
			-- AND rd.address_city <> rd.usat_match_city
      
			-- AND rd.match_score_internal >= 74
			-- AND rd.event_type IN ('triathlon', 'duathlon', 'acquathon')
			-- AND rd.event_type NOT IN ('running_only') 
			-- AND rd.race_id <> 6061 -- running event only
      
	GROUP BY 1,2,3,4,5,9,10,11,12,24
    ORDER BY 1,2,3
)
-- SELECT * FROM base_usat_internal ORDER BY is_possible_exception DESC;
-- SELECT * FROM base_usat_internal WHERE YEAR(race_next_date) = 2027 ORDER BY is_possible_exception DESC;

-- SELECT * FROM base_usat_internal WHERE registration_url_final_rule = 'runsignup_usat_sanction_id = usat_sanction_id'; 
-- SELECT * FROM base_usat_internal WHERE registration_url_final_rule = 'runsignup_url = usat_url';
-- SELECT * FROM base_usat_internal WHERE registration_url_final_rule = 'sanction_id_mismatch_fuzzy_gt_95';
-- SELECT * FROM base_usat_internal WHERE registration_url_final_rule = 'manual_match' ORDER BY match_score_internal; 
-- SELECT * FROM base_usat_internal WHERE registration_url_final_rule = 'manual_exclude' ORDER BY match_score_internal; 
-- SELECT * FROM base_usat_internal WHERE registration_url_final_rule = 'other' AND usat_match_year_date > 2025 ORDER BY match_score_internal; 
SELECT registration_url_final_rule, FORMAT(COUNT(*), 0) FROM base_usat_internal WHERE registration_url_final IS NOT NULL AND usat_match_year_date > 2025 GROUP BY 1 WITH ROLLUP ORDER BY 1;

-- SELECT event_type, GROUP_CONCAT(DISTINCT(setting_name_member_settings)), FORMAT(COUNT(*), 0) FROM base_usat_internal GROUP BY 1 WITH ROLLUP ORDER BY 1;
-- SELECT comparison_status, GROUP_CONCAT(DISTINCT(setting_name_member_settings)), FORMAT(COUNT(*), 0) FROM base_usat_internal GROUP BY 1 WITH ROLLUP ORDER BY 1;

SELECT * FROM all_runsignup_data_raw_affiliate_urls;
SELECT * FROM all_runsignup_data_raw_affiliate_urls WHERE race_next_year_date IS NULL;
SELECT registration_url_final_rule, FORMAT(COUNT(*), 0) FROM all_runsignup_data_raw_affiliate_urls WHERE registration_url_final IS NOT NULL GROUP BY 1 WITH ROLLUP ORDER BY 1;
SELECT race_next_year_date, FORMAT(COUNT(*), 0) FROM all_runsignup_data_raw_affiliate_urls WHERE registration_url_final IS NOT NULL GROUP BY 1 WITH ROLLUP ORDER BY 1;
SELECT usat_match_year_date, FORMAT(COUNT(*), 0) FROM all_runsignup_data_raw_affiliate_urls WHERE registration_url_final IS NOT NULL GROUP BY 1 WITH ROLLUP ORDER BY 1;
SELECT * FROM all_runsignup_data_raw_affiliate_urls WHERE race_next_year_date >= 2026 ORDER BY race_next_date DESC;