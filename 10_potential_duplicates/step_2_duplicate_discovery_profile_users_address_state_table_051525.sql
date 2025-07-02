USE vapor;

-- DISOVERY QUERIES
    -- SELECT "profile_table", p.* FROM profiles AS p LIMIT 10;
    -- SELECT "profile_table", COUNT(p.id) FROM profiles AS p LIMIT 10; -- '2771410'
    -- SELECT "users_table", u.* FROM users AS u LIMIT 10;
    -- SELECT "addresses_table", a.* FROM addresses AS a LIMIT 10;
    -- SELECT "phone_table", ph.* FROM vapor.phones AS ph LIMIT 10;

    WITH duplicate_discovery AS (
        SELECT 
            -- QUERY PURPOSE
            "QUERY #1",
            "duplicate_query_basic_info",

            -- PROFILE TABLE
            p.id,
            p.first_name,
            p.last_name,
            p.date_of_birth,
            
            -- USERS TABLE
            u.email,

            -- MEMBERS TABLE
            m.memberable_type,
            
            -- ADDRESS TABLE
            a.address,
            a.city,
            a.postal_code,
            a.state_name,
            
            -- PHONE TABLE
            ph.normalized AS phone
            
        FROM profiles AS p
            LEFT JOIN users AS u ON p.user_id = u.id
            LEFT JOIN addresses AS a ON p.primary_address_id = a.id
            LEFT JOIN phones AS ph ON p.primary_phone_id = ph.id
            LEFT JOIN (
                SELECT
                    memberable_id,
                    member_number,
                    memberable_type,
                    MAX(created_at) AS last_joined_at
                FROM members
                WHERE memberable_type = 'profiles'
                GROUP BY memberable_id
            ) AS m ON m.memberable_id = p.id

        WHERE 1 = 1 													-- '2,771,412'
            -- Only include rows where ALL fields used in GROUP BY have valid values

			-- PROFILE TABLE
				AND p.created_at < '2025-05-16' 						-- '2,767,538'
				AND p.deleted_at IS NULL 								-- '2,543,964'
				-- AND p.deleted_at IS NOT NULL 						-- '223,668'
				-- AND p.deleted_at = "" 								-- Error Code: 1525. Incorrect TIMESTAMP value: ''

				AND p.first_name IS NOT NULL AND p.first_name != "" 	-- '2,543,950'
				AND p.last_name IS NOT NULL AND p.last_name != "" 		-- '2,543,084'
				AND p.date_of_birth IS NOT NULL 						-- '2,543,084'

				AND u.email IS NOT NULL AND u.email != "" 				-- '1,702,572'

				AND a.address IS NOT NULL AND a.address != "" 			-- '1,643,957'
				AND a.city IS NOT NULL AND a.city != "" 				-- '1,643,611'
				AND a.postal_code IS NOT NULL AND a.postal_code != "" 	-- '1,575,538'
				AND a.state_name IS NOT NULL AND a.state_name != ""		-- '1,421,758'

            -- PHONE
				AND ph.normalized IS NOT NULL 							-- '158,810'
				AND ph.normalized != "" 								-- '52,477'

        -- LIMIT 10
    )
    -- SELECT * FROM duplicate_discovery
    -- SELECT FORMAT(COUNT(*), 0) FROM duplicate_discovery
    SELECT memberable_type, FORMAT(COUNT(DISTINCT(id)), 0) FROM duplicate_discovery GROUP BY memberable_type wITH ROLLUP
    ;

-- DUPLICATE QUERY
    WITH duplicate_combinations AS (
        SELECT 
            -- PROFILE TABLE
            p.first_name,
            p.last_name,
            p.date_of_birth,
            
            -- USERS TABLE
            u.email,
        
            -- ADDRESS TABLE
            a.address,
            a.city,
            a.postal_code,
            a.state_name,
        
            -- PHONE TABLE
            ph.normalized AS phone,

            -- METRICS
            COUNT(*) AS combo_count,

            -- PROFILE IDS
            GROUP_CONCAT(p.id ORDER BY p.id) AS duplicate_profile_ids

        FROM profiles AS p
            LEFT JOIN users AS u ON p.user_id = u.id
            LEFT JOIN addresses AS a ON p.primary_address_id = a.id
            LEFT JOIN phones AS ph ON p.primary_phone_id = ph.id
            LEFT JOIN (
                SELECT
                    memberable_id,
                    member_number,
                    memberable_type,
                    MAX(created_at) AS last_joined_at
                FROM members
                WHERE memberable_type = 'profiles'
                GROUP BY memberable_id
            ) AS m ON m.memberable_id = p.id
		
        WHERE 1 = 1 -- '2,771,412'
			-- -- DELETED AT
			-- AND p.deleted_at IS NULL -- '2,547,744'

            -- -- PHONE
			-- AND ph.normalized IS NOT NULL -- '195,423'
			-- AND ph.normalized != "" -- '58,589'

            -- Only include rows where ALL fields used in GROUP BY have valid values
            AND p.deleted_at IS NULL
            AND p.first_name IS NOT NULL AND p.first_name != ""
            AND p.last_name IS NOT NULL AND p.last_name != ""
            AND p.date_of_birth IS NOT NULL
            AND u.email IS NOT NULL AND u.email != ""
            AND a.address IS NOT NULL AND a.address != ""
            AND a.city IS NOT NULL AND a.city != ""
            AND a.postal_code IS NOT NULL AND a.postal_code != ""
            AND a.state_name IS NOT NULL AND a.state_name != ""
            AND ph.normalized IS NOT NULL AND ph.normalized != ""
      
        GROUP BY 
            p.first_name,
            p.last_name,
            p.date_of_birth,
            u.email,
            a.address,
            a.city,
            a.postal_code,
            a.state_name,
            ph.normalized
        HAVING COUNT(*) > 1
    )
    SELECT 
        -- QUERY PURPOSE
        "QUERY #2",
        "duplicate_query_identify_duplicates",

        -- FIELDS
        d.* 
    FROM duplicate_combinations AS d
    ORDER BY combo_count DESC, last_name ASC
    ;

-- BACKGROUND FROM SAM
    -- Duplicates
    -- User
    -- 	Email
    -- Profile
    -- 	First name
    -- 	Last name
    -- 	DOB
    -- 	Phone
    -- Address
    -- 	Street
    -- 	City
    -- 	Zip
    -- States
    -- 	Name