USE usat_sales_db;

-- SELECT DISTINCT(origin_flag_ma), COUNT(*) FROM sales_key_stats_2015 GROUP BY 1 WITH ROLLUP ORDER BY 1 LIMIT 100;

SELECT 
	DISTINCT(origin_flag_ma), 
    COUNT(*) 
FROM all_membership_sales_data_2015_left 
GROUP BY 1 WITH ROLLUP 
ORDER BY 1 
LIMIT 100
;

SELECT 
	DISTINCT(origin_flag_ma), 
    CASE
        WHEN purchased_on_year_adjusted_mp IN ('2023', '2024') AND origin_flag_ma IS NULL THEN 'source_usat_direct'
        WHEN purchased_on_year_adjusted_mp IN ('2023', '2024') AND origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 'source_race_registration'
        WHEN purchased_on_year_adjusted_mp IN ('2023', '2024') THEN 'source_race_registration'
        WHEN origin_flag_ma IS NULL THEN 'no_origin_flag'
        ELSE 'prior_to_2023'
    END AS origin_category,
    COUNT(*) 
FROM all_membership_sales_data_2015_left 
GROUP BY 1, 2
ORDER BY 1, 2
LIMIT 100
;

SELECT 
    DISTINCT(origin_flag_ma)
    
    , CASE
        WHEN purchased_on_year_adjusted_mp IN ('2023', '2024') AND origin_flag_ma IS NULL THEN 'source_usat_direct'
        WHEN purchased_on_year_adjusted_mp IN ('2023', '2024') AND origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 'source_race_registration'
        WHEN purchased_on_year_adjusted_mp IN ('2023', '2024') THEN 'source_race_registration'
        WHEN origin_flag_ma IS NULL THEN 'no_origin_flag'
        ELSE 'prior_to_2023'
    END AS origin_category

    , FORMAT(COUNT(CASE
        WHEN purchased_on_year_adjusted_mp IN ('2024') AND origin_flag_ma IS NULL THEN 1
        WHEN purchased_on_year_adjusted_mp IN ('2024') AND origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 1
        WHEN purchased_on_year_adjusted_mp IN ('2024') THEN 1
        ELSE NULL
    END), 0) AS 'source_2024'

    , FORMAT(COUNT(CASE
        WHEN purchased_on_year_adjusted_mp IN ('2023') AND origin_flag_ma IS NULL THEN 1
        WHEN purchased_on_year_adjusted_mp IN ('2023') AND origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 1
        WHEN purchased_on_year_adjusted_mp IN ('2023') THEN 1
        ELSE NULL
    END), 0) AS 'source_2023'

    , FORMAT(COUNT(CASE
        WHEN purchased_on_year_adjusted_mp IN ('2022') AND origin_flag_ma IS NULL THEN 1
        WHEN purchased_on_year_adjusted_mp IN ('2022') AND origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 1
        WHEN purchased_on_year_adjusted_mp IN ('2022') THEN 1
        ELSE NULL
    END), 0) AS 'source_2022'

    , FORMAT(COUNT(CASE
        WHEN purchased_on_year_adjusted_mp IN ('2022') AND origin_flag_ma IS NULL THEN 1
        WHEN purchased_on_year_adjusted_mp IN ('2022') AND origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 1
        WHEN purchased_on_year_adjusted_mp IN ('2022') THEN 1
        ELSE NULL
    END), 0) AS 'source_2021'

    , FORMAT(COUNT(CASE
        WHEN purchased_on_year_adjusted_mp NOT IN ('2021', '2002', '2023', '2024') THEN 1
        ELSE NULL
    END), 0) AS prior_to_2021
    
    , FORMAT(COUNT(*), 0) AS total_count_formated
    , COUNT(*) AS total_count

FROM all_membership_sales_data_2015_left
GROUP BY 1 WITH ROLLUP
ORDER BY total_count ASC
LIMIT 100;

