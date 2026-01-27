SELECT * FROM membership_base_data LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM membership_base_data LIMIT 10;

SELECT 
	year, 
    SUM(unique_profiles), 
    SUM(unique_profiles_sales_through_day_of_year), 
    SUM(unique_profiles_sales_ytd)
FROM membership_base_data 
GROUP BY 1 ORDER BY 1
;

WITH yearly AS (
  SELECT 
    year, 
    SUM(unique_profiles) AS unique_profiles,
    SUM(unique_profiles_sales_through_day_of_year) AS unique_profiles_sales_through_day_of_year,
    SUM(unique_profiles_sales_ytd) AS unique_profiles_sales_ytd
  FROM membership_base_data
  GROUP BY year
)

SELECT
  year,

  -- totals
  unique_profiles,
  unique_profiles_sales_through_day_of_year,
  unique_profiles_sales_ytd,

  -- YoY absolute change
  unique_profiles
    - LAG(unique_profiles) OVER (ORDER BY year)
    AS yoy_unique_profiles_change,

  unique_profiles_sales_through_day_of_year
    - LAG(unique_profiles_sales_through_day_of_year) OVER (ORDER BY year)
    AS yoy_sales_through_doy_change,

  unique_profiles_sales_ytd
    - LAG(unique_profiles_sales_ytd) OVER (ORDER BY year)
    AS yoy_sales_ytd_change,

  -- YoY % change
  ROUND(
    (unique_profiles
      - LAG(unique_profiles) OVER (ORDER BY year))
    / NULLIF(LAG(unique_profiles) OVER (ORDER BY year), 0),
    4
  ) AS yoy_unique_profiles_pct,

  ROUND(
    (unique_profiles_sales_through_day_of_year
      - LAG(unique_profiles_sales_through_day_of_year) OVER (ORDER BY year))
    / NULLIF(LAG(unique_profiles_sales_through_day_of_year) OVER (ORDER BY year), 0),
    4
  ) AS yoy_sales_through_doy_pct,

  ROUND(
    (unique_profiles_sales_ytd
      - LAG(unique_profiles_sales_ytd) OVER (ORDER BY year))
    / NULLIF(LAG(unique_profiles_sales_ytd) OVER (ORDER BY year), 0),
    4
  ) AS yoy_sales_ytd_pct

FROM yearly
ORDER BY year
;

WITH yearly AS (
  SELECT 
    year, 
    SUM(unique_profiles) AS unique_profiles,
    SUM(unique_profiles_sales_through_day_of_year) AS unique_profiles_sales_through_day_of_year,
    SUM(unique_profiles_sales_ytd) AS unique_profiles_sales_ytd
  FROM membership_base_data
  GROUP BY year
)

SELECT
  year,

  -- totals (formatted)
  FORMAT(unique_profiles, 0) AS unique_profiles,
  FORMAT(unique_profiles_sales_through_day_of_year, 0) AS unique_profiles_sales_through_day_of_year,
  FORMAT(unique_profiles_sales_ytd, 0) AS unique_profiles_sales_ytd,

  -- YoY absolute change (formatted)
  FORMAT(
    unique_profiles
      - LAG(unique_profiles) OVER (ORDER BY year),
    0
  ) AS yoy_unique_profiles_change,

  FORMAT(
    unique_profiles_sales_through_day_of_year
      - LAG(unique_profiles_sales_through_day_of_year) OVER (ORDER BY year),
    0
  ) AS yoy_sales_through_doy_change,

  FORMAT(
    unique_profiles_sales_ytd
      - LAG(unique_profiles_sales_ytd) OVER (ORDER BY year),
    0
  ) AS yoy_sales_ytd_change,

  -- YoY % change (1 decimal, percent)
  CONCAT(
    FORMAT(
      100 * (
        unique_profiles
          - LAG(unique_profiles) OVER (ORDER BY year)
      ) / NULLIF(LAG(unique_profiles) OVER (ORDER BY year), 0),
      1
    ),
    '%'
  ) AS yoy_unique_profiles_pct,

  CONCAT(
    FORMAT(
      100 * (
        unique_profiles_sales_through_day_of_year
          - LAG(unique_profiles_sales_through_day_of_year) OVER (ORDER BY year)
      ) / NULLIF(LAG(unique_profiles_sales_through_day_of_year) OVER (ORDER BY year), 0),
      1
    ),
    '%'
  ) AS yoy_sales_through_doy_pct,

  CONCAT(
    FORMAT(
      100 * (
        unique_profiles_sales_ytd
          - LAG(unique_profiles_sales_ytd) OVER (ORDER BY year)
      ) / NULLIF(LAG(unique_profiles_sales_ytd) OVER (ORDER BY year), 0),
      1
    ),
    '%'
  ) AS yoy_sales_ytd_pct

FROM yearly
ORDER BY year
;

