SELECT * FROM events LIMIT 10;

SELECT 
    sanctioning_event_id,
    starts,
    name,
    status,
    event_website_url,
    registration_url,

    -- Row-level match flag
    CASE 
        WHEN event_website_url = registration_url THEN 'MATCH'
        WHEN event_website_url IS NULL OR registration_url IS NULL THEN 'MISSING'
        ELSE 'NO_MATCH'
    END AS url_match_flag,

    -- match / non-match / missing flags
    CASE 
        WHEN event_website_url = registration_url THEN 1
        ELSE 0
    END AS url_match_flag_yes,

    CASE 
        WHEN event_website_url IS NOT NULL 
         AND registration_url IS NOT NULL 
         AND event_website_url <> registration_url
        THEN 1
        ELSE 0
    END AS url_non_match_flag_yes,

    CASE 
        WHEN event_website_url IS NULL 
          OR registration_url IS NULL
        THEN 1
        ELSE 0
    END AS url_missing_flag_yes,

    -- registration_url source flags
    CASE 
        WHEN LOWER(registration_url) LIKE '%ironman%' THEN 1
        ELSE 0
    END AS registration_url_has_ironman_flag,

    CASE 
        WHEN LOWER(registration_url) LIKE '%runsignup%' THEN 1
        ELSE 0
    END AS registration_url_has_runsignup_flag,

    CASE 
        WHEN LOWER(registration_url) LIKE '%trisignup%' THEN 1
        ELSE 0
    END AS registration_url_has_trisignup_flag,

    CASE 
        WHEN LOWER(registration_url) LIKE '%usatriathlon%' THEN 1
        ELSE 0
    END AS registration_url_has_usatriathlon_flag,

    CASE 
        WHEN LOWER(registration_url) LIKE '%register%' THEN 1
        ELSE 0
    END AS registration_url_has_register_flag,

    -- ✅ NEW FLAG
    CASE 
        WHEN LOWER(registration_url) LIKE '%caltriathlon%' THEN 1
        ELSE 0
    END AS registration_url_has_caltriathlon_flag,

    -- updated combined flag (now 6)
    CASE 
        WHEN LOWER(registration_url) LIKE '%ironman%'
          OR LOWER(registration_url) LIKE '%runsignup%'
          OR LOWER(registration_url) LIKE '%trisignup%'
          OR LOWER(registration_url) LIKE '%usatriathlon%'
          OR LOWER(registration_url) LIKE '%register%'
          OR LOWER(registration_url) LIKE '%caltriathlon%'
        THEN 1
        ELSE 0
    END AS registration_url_has_any_of_6_flag,

    -- totals
    COUNT(*) OVER () AS total_rows,

    SUM(CASE WHEN event_website_url = registration_url THEN 1 ELSE 0 END) OVER () AS total_matches,

    SUM(CASE 
            WHEN event_website_url IS NOT NULL 
             AND registration_url IS NOT NULL 
             AND event_website_url <> registration_url 
            THEN 1 
            ELSE 0 
        END) OVER () AS total_non_matches,

    SUM(CASE 
            WHEN event_website_url IS NULL 
              OR registration_url IS NULL 
            THEN 1 
            ELSE 0 
        END) OVER () AS total_missing,

    -- source totals
    SUM(CASE WHEN LOWER(registration_url) LIKE '%ironman%' THEN 1 ELSE 0 END) OVER () 
        AS total_registration_url_has_ironman,

    SUM(CASE WHEN LOWER(registration_url) LIKE '%runsignup%' THEN 1 ELSE 0 END) OVER () 
        AS total_registration_url_has_runsignup,

    SUM(CASE WHEN LOWER(registration_url) LIKE '%trisignup%' THEN 1 ELSE 0 END) OVER () 
        AS total_registration_url_has_trisignup,

    SUM(CASE WHEN LOWER(registration_url) LIKE '%usatriathlon%' THEN 1 ELSE 0 END) OVER () 
        AS total_registration_url_has_usatriathlon,

    SUM(CASE WHEN LOWER(registration_url) LIKE '%register%' THEN 1 ELSE 0 END) OVER () 
        AS total_registration_url_has_register,

    -- ✅ NEW TOTAL
    SUM(CASE WHEN LOWER(registration_url) LIKE '%caltriathlon%' THEN 1 ELSE 0 END) OVER () 
        AS total_registration_url_has_caltriathlon,

    -- updated combined total (now 6)
    SUM(CASE 
            WHEN LOWER(registration_url) LIKE '%ironman%'
              OR LOWER(registration_url) LIKE '%runsignup%'
              OR LOWER(registration_url) LIKE '%trisignup%'
              OR LOWER(registration_url) LIKE '%usatriathlon%'
              OR LOWER(registration_url) LIKE '%register%'
              OR LOWER(registration_url) LIKE '%caltriathlon%'
            THEN 1
            ELSE 0
        END) OVER () AS total_registration_url_has_any_of_6,

    -- gap check
    COUNT(*) OVER ()
    - (
        SUM(CASE WHEN event_website_url = registration_url THEN 1 ELSE 0 END) OVER ()
        + 
        SUM(CASE 
                WHEN event_website_url IS NOT NULL 
                 AND registration_url IS NOT NULL 
                 AND event_website_url <> registration_url 
                THEN 1 
                ELSE 0 
            END) OVER ()
        + 
        SUM(CASE 
                WHEN event_website_url IS NULL 
                  OR registration_url IS NULL 
                THEN 1 
                ELSE 0 
            END) OVER ()
      ) AS missing_gap_check

FROM events 

WHERE 1 = 1
	AND YEAR(starts) = 2026
    AND status NOT IN ('cancelled', 'declined')

ORDER BY starts DESC
;