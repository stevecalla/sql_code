-- SELECT MAX(purchased_on_mp) FROM all_membership_sales_data_2015_left LIMIT 10;
-- -- REC REV BASE DATA
-- SELECT * FROM rev_recognition_base_data LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_base_data LIMIT 10; -- '1,462,855'
-- REC REV ALLOCATED DATA
-- SELECT * FROM rev_recognition_allocation_data WHERE id_membership_periods_sa = 4884143 LIMIT 10;
-- SELECT * FROM rev_recognition_allocation_data LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM rev_recognition_allocation_data LIMIT 10; -- '4,832,391'
-- -- SALES MODEL
-- SELECT * FROM sales_model_2026 LIMIT 10;
-- SELECT FORMAT(COUNT(*), 0) FROM sales_model_2026 LIMIT 10;

-- ========= STEP 2 ========
-- GET ALLOCATION ESTIMATE
-- ========= STEP 2 ========
DROP TABLE IF EXISTS sales_model_rec_rev_2_allocation_estimate;
CREATE TABLE IF NOT EXISTS sales_model_rec_rev_2_allocation_estimate
    WITH base AS (
        -- determines the % of revenue for each purchase month that is recognized in future months by real membership type
        SELECT
            purchased_on_adjusted_year_month,
            purchased_on_date_adjusted_mp_year,
            purchased_on_date_adjusted_mp_month,
            real_membership_types_sa,
            revenue_year_month,
            revenue_year_date,
            revenue_month_date,
            TIMESTAMPDIFF(
                MONTH,
                STR_TO_DATE(CONCAT(purchased_on_adjusted_year_month, '-01'), '%Y-%m-%d'),
                STR_TO_DATE(CONCAT(revenue_year_month, '-01'), '%Y-%m-%d')
            ) AS months_from_purchase,
            SUM(monthly_revenue) AS total_revenue,
            ROUND(
                SUM(monthly_revenue) /
                NULLIF(SUM(SUM(monthly_revenue)) OVER (PARTITION BY purchased_on_adjusted_year_month, real_membership_types_sa), 0)
            , 4) AS pct_of_total_num
        FROM rev_recognition_allocation_data AS a
        WHERE 1 = 1
            AND purchased_on_date_adjusted_mp_year >= 2024
            -- AND purchased_on_date_adjusted_mp_month = 1
        GROUP BY
            purchased_on_adjusted_year_month,
            purchased_on_date_adjusted_mp_year,
            purchased_on_date_adjusted_mp_month,
            real_membership_types_sa,
            revenue_year_month,
            revenue_year_date,
            revenue_month_date
        )
        , limit_v1 AS (
            SELECT
                *
            FROM base
            WHERE 1 = 1
            AND
                (
                    (
                        purchased_on_date_adjusted_mp_year > 2024
                        OR (purchased_on_date_adjusted_mp_year = 2024 AND purchased_on_date_adjusted_mp_month >= 9)
                    )
                    AND
                    (
                        purchased_on_date_adjusted_mp_year < 2025
                        OR (purchased_on_date_adjusted_mp_year = 2025 AND purchased_on_date_adjusted_mp_month <= 8)
                    )
                )
        )
        , limit_v2 AS (
            SELECT
                *
            FROM limit_v1
            WHERE 1 = 1
                AND 
                (
                    revenue_year_date < 2025
                    OR (revenue_year_date = 2025 AND revenue_month_date <= 12)
                )
        ORDER BY
            purchased_on_adjusted_year_month,
            real_membership_types_sa,
            revenue_year_month,
            revenue_year_date,
            revenue_month_date
        )
        SELECT * FROM limit_v2
;

SELECT * FROM sales_model_rec_rev_2_allocation_estimate LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM sales_model_rec_rev_2_allocation_estimate;