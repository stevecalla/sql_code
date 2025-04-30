WITH participation AS (
                SELECT 
					p.id_profile_rr,
					p.id_rr,
					p.id_race_rr,
					p.id_events,
					p.id_sanctioning_events,
					p.name_events AS name_events_p,
                    p.state_code_events,
                    p.start_date_races,
					p.start_date_year_races
                FROM all_participation_data_raw AS p

                WHERE 1 = 1 
                    -- AND start_date_year_races = 2025
                    -- AND start_date_races >= @start_date
                    -- AND start_date_races <= @end_date
                    
                    -- AND start_date_races >= '${start_date_time}'
                    -- AND start_date_races <= '${end_date_time}'

					-- Uncomment and modify the following lines if you need additional filters:
					-- AND p.id_profile_rr IN ('1000119', '1000906') -- 1000906 has a duplicate for Dino Gravel Tri; using rn field and filter to remove
					AND p.id_profile_rr IN (2771793)
					-- AND id_profile_rr = 42 
					-- AND id_rr = 4527556 -- this member is missing memberships to match race history; total number of races = 6; total memberships = 4 with missing for 2014, 2017, 2021 races
					-- AND id_profile_rr = 999977 
					-- AND id_rr = 1197359 -- this member has multiple memberships for the same race (a one day & an annual)
            ),

            merge_participation_with_active_membership AS (
                SELECT 
                    -- PARTICIPATION DATA
                    p.id_rr,
                    p.id_race_rr,
                    p.id_events,
                    p.id_sanctioning_events,

                    p.start_date_races,
                    p.start_date_year_races,
            
                    p.id_profile_rr,

                    -- MEMBERSHIP DATA
                    s.id_profiles,

                    s.member_created_at_category,
                    s.region_name_member,
                    s.region_abbr_member,

                    s.purchased_on_date_adjusted_mp,
                    s.purchased_on_month_adjusted_mp,
                    s.purchased_on_year_adjusted_mp,

                    s.id_membership_periods_sa,

                    s.starts_mp,
                    s.ends_mp,

                    s.real_membership_types_sa,
                    s.new_member_category_6_sa,

                    s.sales_revenue,
                    s.sales_units,

                    -- IDENTIFY DUPLICATES
                    ROW_NUMBER() OVER (
                        PARTITION BY p.id_rr 
                        ORDER BY ABS(TIMESTAMPDIFF(SECOND, p.start_date_races, s.purchased_on_date_adjusted_mp)) ASC
                    ) AS rn, -- Ranks duplicates based on the nearest MP purchase date to the race start date,
                    
                    -- IDENTIFY ACTIVE MEMBERSHIP DATES OVERLAP WITH RACE DATES
                    CASE WHEN s.starts_mp IS NOT NULL THEN 1 ELSE 0 END AS is_active_membership

                FROM participation p
                    LEFT JOIN sales_key_stats_2015 s ON s.id_profiles = p.id_profile_rr
                        AND s.starts_mp <= p.start_date_races
                        AND s.ends_mp >= p.start_date_races
                    LEFT JOIN region_data AS r ON p.state_code_events = r.state_code
                    LEFT JOIN sales_key_stats_2015 s2 ON s2.id_profiles = p.id_profile_rr
            )
            SELECT *
            FROM merge_participation_with_active_membership
            WHERE 1 = 1
                AND rn = 1;