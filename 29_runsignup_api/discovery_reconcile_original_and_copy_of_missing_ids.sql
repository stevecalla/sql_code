/* ============================================================
Q1 - Summary: Row-level reconciliation between ORIGINAL and COPY_042226
============================================================ */
SELECT 
    ROW_NUMBER() OVER () AS row_num,
    COUNT(*) OVER () AS total_rows,
    q.*
FROM (
    SELECT
        'Q1 - Summary: missing_in_copy_042226' AS query_label,
        COUNT(*) AS row_count
    FROM usat_sales_db.all_runsignup_data_raw_missing_id o
    LEFT JOIN usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226 c
        ON o.race_id = c.race_id
    WHERE c.race_id IS NULL

    UNION ALL

    SELECT
        'Q1 - Summary: new_in_copy_042226' AS query_label,
        COUNT(*) AS row_count
    FROM usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226 c
    LEFT JOIN usat_sales_db.all_runsignup_data_raw_missing_id o
        ON c.race_id = o.race_id
    WHERE o.race_id IS NULL
) q;


/* ============================================================
Q1b - Summary: Compare registration_url_final_rule counts between ORIGINAL and COPY_042226
Purpose:
- Compare distribution of registration_url_final_rule where registration_url_final is not null
============================================================ */
SELECT
    ROW_NUMBER() OVER () AS row_num,
    COUNT(*) OVER () AS total_rows,
    q.*
FROM (
    SELECT
        'Q1b - registration_url_final_rule comparison' AS query_label,
        COALESCE(o.registration_url_final_rule, c.registration_url_final_rule, 'ROLLUP_TOTAL') AS comparison_value,
        COALESCE(o.row_count, 0) AS original_row_count,
        COALESCE(c.row_count, 0) AS copy_042226_row_count,
        COALESCE(o.row_count, 0) - COALESCE(c.row_count, 0) AS difference_row_count
    FROM (
        SELECT
            registration_url_final_rule,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id
        WHERE registration_url_final IS NOT NULL
        GROUP BY registration_url_final_rule WITH ROLLUP
    ) o
    LEFT JOIN (
        SELECT
            registration_url_final_rule,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226
        WHERE registration_url_final IS NOT NULL
        GROUP BY registration_url_final_rule WITH ROLLUP
    ) c
        ON o.registration_url_final_rule <=> c.registration_url_final_rule

    UNION ALL

    SELECT
        'Q1b - registration_url_final_rule comparison' AS query_label,
        COALESCE(o.registration_url_final_rule, c.registration_url_final_rule, 'ROLLUP_TOTAL') AS comparison_value,
        COALESCE(o.row_count, 0) AS original_row_count,
        COALESCE(c.row_count, 0) AS copy_042226_row_count,
        COALESCE(o.row_count, 0) - COALESCE(c.row_count, 0) AS difference_row_count
    FROM (
        SELECT
            registration_url_final_rule,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id
        WHERE registration_url_final IS NOT NULL
        GROUP BY registration_url_final_rule WITH ROLLUP
    ) o
    RIGHT JOIN (
        SELECT
            registration_url_final_rule,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226
        WHERE registration_url_final IS NOT NULL
        GROUP BY registration_url_final_rule WITH ROLLUP
    ) c
        ON o.registration_url_final_rule <=> c.registration_url_final_rule
    WHERE o.registration_url_final_rule IS NULL
) q
ORDER BY comparison_value;


/* ============================================================
Q1c - Summary: Compare race_next_year_date counts between ORIGINAL and COPY_042226
Purpose:
- Compare distribution of race_next_year_date where registration_url_final is not null
============================================================ */
SELECT
    ROW_NUMBER() OVER () AS row_num,
    COUNT(*) OVER () AS total_rows,
    q.*
FROM (
    SELECT
        'Q1c - race_next_year_date comparison' AS query_label,
        COALESCE(CAST(o.race_next_year_date AS CHAR), CAST(c.race_next_year_date AS CHAR), 'ROLLUP_TOTAL') AS comparison_value,
        COALESCE(o.row_count, 0) AS original_row_count,
        COALESCE(c.row_count, 0) AS copy_042226_row_count,
        COALESCE(o.row_count, 0) - COALESCE(c.row_count, 0) AS difference_row_count
    FROM (
        SELECT
            race_next_year_date,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id
        WHERE registration_url_final IS NOT NULL
        GROUP BY race_next_year_date WITH ROLLUP
    ) o
    LEFT JOIN (
        SELECT
            race_next_year_date,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226
        WHERE registration_url_final IS NOT NULL
        GROUP BY race_next_year_date WITH ROLLUP
    ) c
        ON o.race_next_year_date <=> c.race_next_year_date

    UNION ALL

    SELECT
        'Q1c - race_next_year_date comparison' AS query_label,
        COALESCE(CAST(o.race_next_year_date AS CHAR), CAST(c.race_next_year_date AS CHAR), 'ROLLUP_TOTAL') AS comparison_value,
        COALESCE(o.row_count, 0) AS original_row_count,
        COALESCE(c.row_count, 0) AS copy_042226_row_count,
        COALESCE(o.row_count, 0) - COALESCE(c.row_count, 0) AS difference_row_count
    FROM (
        SELECT
            race_next_year_date,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id
        WHERE registration_url_final IS NOT NULL
        GROUP BY race_next_year_date WITH ROLLUP
    ) o
    RIGHT JOIN (
        SELECT
            race_next_year_date,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226
        WHERE registration_url_final IS NOT NULL
        GROUP BY race_next_year_date WITH ROLLUP
    ) c
        ON o.race_next_year_date <=> c.race_next_year_date
    WHERE o.race_next_year_date IS NULL
) q
ORDER BY comparison_value;


/* ============================================================
Q1d - Summary: Compare usat_match_year_date counts between ORIGINAL and COPY_042226
Purpose:
- Compare distribution of usat_match_year_date where registration_url_final is not null
============================================================ */
SELECT
    ROW_NUMBER() OVER () AS row_num,
    COUNT(*) OVER () AS total_rows,
    q.*
FROM (
    SELECT
        'Q1d - usat_match_year_date comparison' AS query_label,
        COALESCE(CAST(o.usat_match_year_date AS CHAR), CAST(c.usat_match_year_date AS CHAR), 'ROLLUP_TOTAL') AS comparison_value,
        COALESCE(o.row_count, 0) AS original_row_count,
        COALESCE(c.row_count, 0) AS copy_042226_row_count,
        COALESCE(o.row_count, 0) - COALESCE(c.row_count, 0) AS difference_row_count
    FROM (
        SELECT
            usat_match_year_date,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id
        WHERE registration_url_final IS NOT NULL
        GROUP BY usat_match_year_date WITH ROLLUP
    ) o
    LEFT JOIN (
        SELECT
            usat_match_year_date,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226
        WHERE registration_url_final IS NOT NULL
        GROUP BY usat_match_year_date WITH ROLLUP
    ) c
        ON o.usat_match_year_date <=> c.usat_match_year_date

    UNION ALL

    SELECT
        'Q1d - usat_match_year_date comparison' AS query_label,
        COALESCE(CAST(o.usat_match_year_date AS CHAR), CAST(c.usat_match_year_date AS CHAR), 'ROLLUP_TOTAL') AS comparison_value,
        COALESCE(o.row_count, 0) AS original_row_count,
        COALESCE(c.row_count, 0) AS copy_042226_row_count,
        COALESCE(o.row_count, 0) - COALESCE(c.row_count, 0) AS difference_row_count
    FROM (
        SELECT
            usat_match_year_date,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id
        WHERE registration_url_final IS NOT NULL
        GROUP BY usat_match_year_date WITH ROLLUP
    ) o
    RIGHT JOIN (
        SELECT
            usat_match_year_date,
            COUNT(*) AS row_count
        FROM usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226
        WHERE registration_url_final IS NOT NULL
        GROUP BY usat_match_year_date WITH ROLLUP
    ) c
        ON o.usat_match_year_date <=> c.usat_match_year_date
    WHERE o.usat_match_year_date IS NULL
) q
ORDER BY comparison_value;


/* ============================================================
Q2 - Detail: Rows in ORIGINAL but missing in COPY_042226
============================================================ */
SELECT 
    ROW_NUMBER() OVER () AS row_num,
    COUNT(*) OVER () AS total_rows,
    'Q2 - Detail: missing_in_copy_042226' AS query_label,
    o.*
FROM usat_sales_db.all_runsignup_data_raw_missing_id o
LEFT JOIN usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226 c
    ON o.race_id = c.race_id
WHERE c.race_id IS NULL;


/* ============================================================
Q3 - Detail: Rows in COPY_042226 but not in ORIGINAL
============================================================ */
SELECT 
    ROW_NUMBER() OVER () AS row_num,
    COUNT(*) OVER () AS total_rows,
    'Q3 - Detail: new_in_copy_042226' AS query_label,
    c.*
FROM usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226 c
LEFT JOIN usat_sales_db.all_runsignup_data_raw_missing_id o
    ON c.race_id = o.race_id
WHERE o.race_id IS NULL;


/* ============================================================
Q4 - Detail: Rows with field-level differences (INCLUDING URL)
============================================================ */
SELECT 
    ROW_NUMBER() OVER () AS row_num,
    COUNT(*) OVER () AS total_rows,
    'Q4 - Detail: field_level_differences_vs_copy_042226' AS query_label,
    o.race_id,
    o.match_score_internal AS original_match_score_internal,
    c.match_score_internal AS copy_match_score_internal,
    o.usat_sanction_id_internal AS original_usat_sanction_id_internal,
    c.usat_sanction_id_internal AS copy_usat_sanction_id_internal,
    o.registration_url_affiliate_final AS original_registration_url_affiliate_final,
    c.registration_url_affiliate_final AS copy_registration_url_affiliate_final
FROM usat_sales_db.all_runsignup_data_raw_missing_id o
JOIN usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226 c
    ON o.race_id = c.race_id
WHERE 1 = 1
    AND (
        o.match_score_internal <> c.match_score_internal
        OR o.usat_sanction_id_internal <> c.usat_sanction_id_internal
        OR (o.match_score_internal IS NULL AND c.match_score_internal IS NOT NULL)
        OR (o.match_score_internal IS NOT NULL AND c.match_score_internal IS NULL)
        OR (o.usat_sanction_id_internal IS NULL AND c.usat_sanction_id_internal IS NOT NULL)
        OR (o.usat_sanction_id_internal IS NOT NULL AND c.usat_sanction_id_internal IS NULL)
        OR o.registration_url_affiliate_final <> c.registration_url_affiliate_final
        OR (o.registration_url_affiliate_final IS NULL AND c.registration_url_affiliate_final IS NOT NULL)
        OR (o.registration_url_affiliate_final IS NOT NULL AND c.registration_url_affiliate_final IS NULL)
    );

/* ============================================================
Q5 - Advanced (Optional): Full row checksum comparison
============================================================ */
SELECT 
    ROW_NUMBER() OVER () AS row_num,
    COUNT(*) OVER () AS total_rows,
    'Q5 - Detail: checksum_differences_vs_copy_042226' AS query_label,
    o.race_id
FROM usat_sales_db.all_runsignup_data_raw_missing_id o
JOIN usat_sales_db.all_runsignup_data_raw_missing_id_copy_042226 c
    ON o.race_id = c.race_id
WHERE MD5(CONCAT_WS('|',
    o.race_id,
    o.match_score_internal,
    o.usat_sanction_id_internal,
    o.registration_url_affiliate_final
)) <> MD5(CONCAT_WS('|',
    c.race_id,
    c.match_score_internal,
    c.usat_sanction_id_internal,
    c.registration_url_affiliate_final
));