USE vapor;

-- SELECT * FROM events LIMIT 10;
-- SELECT YEAR(starts) FROM events LIMIT 10;
-- SELECT YEAR(created_at) FROM registration_audit AS ra LIMIT 10;

-- reg audit sale counts by year/month
SELECT 
    "#2 sale counts by reg company by month" AS query_label,
    DATE_FORMAT(ra.created_at, '%Y-%m') AS audit_year_month,
    ra.registration_company_id,
    rc.name,
    mt.group,
    mt.name,
    FORMAT(COUNT(*), 0) AS ra_sale,
    FORMAT(COUNT(*), 0) AS total_count_formatted
FROM registration_audit AS ra
    LEFT JOIN registration_companies AS rc ON ra.registration_company_id = rc.id
    LEFT JOIN registration_audit_membership_application AS rama ON ra.id = rama.audit_id
    LEFT JOIN membership_applications AS ma ON ma.id = rama.membership_application_id
    LEFT JOIN membership_periods AS mp ON mp.id = ma.membership_period_id
    LEFT JOIN membership_types AS mt ON ma.membership_type_id = mt.id
    LEFT JOIN events ON ma.event_id = events.id
WHERE 1 = 1
    AND rama.price_paid IS NOT NULL
GROUP BY 1, 2, 3, 4, 5, 6
ORDER BY audit_year_month DESC, ra.registration_company_id DESC
;

-- reg audit sale counts by year/month pivot
SELECT 
    "#2a sale counts by year/month pivot" AS query_label,
    YEAR(ra.created_at) AS audit_year,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 1  THEN 1 ELSE 0 END), 0) AS jan_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 2  THEN 1 ELSE 0 END), 0) AS feb_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 3  THEN 1 ELSE 0 END), 0) AS mar_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 4  THEN 1 ELSE 0 END), 0) AS apr_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 5  THEN 1 ELSE 0 END), 0) AS may_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 6  THEN 1 ELSE 0 END), 0) AS jun_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 7  THEN 1 ELSE 0 END), 0) AS jul_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 8  THEN 1 ELSE 0 END), 0) AS aug_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 9  THEN 1 ELSE 0 END), 0) AS sep_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 10 THEN 1 ELSE 0 END), 0) AS oct_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 11 THEN 1 ELSE 0 END), 0) AS nov_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 12 THEN 1 ELSE 0 END), 0) AS dec_sale,
    FORMAT(COUNT(*), 0) AS total_sale
FROM registration_audit AS ra
    LEFT JOIN registration_companies AS rc ON ra.registration_company_id = rc.id
    LEFT JOIN registration_audit_membership_application AS rama ON ra.id = rama.audit_id
    LEFT JOIN membership_applications AS ma ON ma.id = rama.membership_application_id
    LEFT JOIN membership_periods AS mp ON mp.id = ma.membership_period_id
    LEFT JOIN membership_types AS mt ON ma.membership_type_id = mt.id
    LEFT JOIN events ON ma.event_id = events.id
WHERE 1 = 1
    AND rama.price_paid IS NOT NULL
GROUP BY 1, 2
ORDER BY audit_year DESC
;

-- reg audit sale counts by year/month pivot ytd
SELECT 
    "#2c sale counts by year/month pivot ytd" AS query_label,
    YEAR(ra.created_at) AS audit_year,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 1  THEN 1 ELSE 0 END), 0) AS jan_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 2  THEN 1 ELSE 0 END), 0) AS feb_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 3  THEN 1 ELSE 0 END), 0) AS mar_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 4  THEN 1 ELSE 0 END), 0) AS apr_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 5  THEN 1 ELSE 0 END), 0) AS may_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 6  THEN 1 ELSE 0 END), 0) AS jun_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 7  THEN 1 ELSE 0 END), 0) AS jul_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 8  THEN 1 ELSE 0 END), 0) AS aug_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 9  THEN 1 ELSE 0 END), 0) AS sep_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 10 THEN 1 ELSE 0 END), 0) AS oct_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 11 THEN 1 ELSE 0 END), 0) AS nov_sale,
    FORMAT(SUM(CASE WHEN MONTH(ra.created_at) = 12 THEN 1 ELSE 0 END), 0) AS dec_sale,
    FORMAT(COUNT(*), 0) AS total_sale_ytd
FROM registration_audit AS ra
    LEFT JOIN registration_companies AS rc ON ra.registration_company_id = rc.id
    LEFT JOIN registration_audit_membership_application AS rama ON ra.id = rama.audit_id
    LEFT JOIN membership_applications AS ma ON ma.id = rama.membership_application_id
    LEFT JOIN membership_periods AS mp ON mp.id = ma.membership_period_id
    LEFT JOIN membership_types AS mt ON ma.membership_type_id = mt.id
    LEFT JOIN events ON ma.event_id = events.id
WHERE 1 = 1
    AND rama.price_paid IS NOT NULL
    AND (
        MONTH(ra.created_at) < MONTH(CURRENT_DATE())
        OR (
            MONTH(ra.created_at) = MONTH(CURRENT_DATE())
            AND DAY(ra.created_at) <= DAY(CURRENT_DATE())
        )
    )
GROUP BY 1, 2
ORDER BY audit_year DESC
;

-- diagnostic: check event year vs audit year on sale rows
SELECT 
    "#2e diagnostic sale event year vs audit year" AS query_label,
    YEAR(ra.created_at) AS audit_year,
    YEAR(events.starts) AS event_start_year,
    COUNT(*) AS count
FROM registration_audit AS ra
    LEFT JOIN registration_companies AS rc ON ra.registration_company_id = rc.id
    LEFT JOIN registration_audit_membership_application AS rama ON ra.id = rama.audit_id
    LEFT JOIN membership_applications AS ma ON ma.id = rama.membership_application_id
    LEFT JOIN membership_periods AS mp ON mp.id = ma.membership_period_id
    LEFT JOIN membership_types AS mt ON ma.membership_type_id = mt.id
    LEFT JOIN events ON ma.event_id = events.id
WHERE 1 = 1
    AND rama.price_paid IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY audit_year DESC, event_start_year DESC
;

-- diagnostic: check event id availability on sale rows
SELECT 
    "#2f diagnostic sale event id availability" AS query_label,
    YEAR(ra.created_at) AS audit_year,
    FORMAT(COUNT(*), 0) AS total_sale,
    FORMAT(SUM(CASE WHEN ma.id IS NULL THEN 1 ELSE 0 END), 0) AS missing_ma,
    FORMAT(SUM(CASE WHEN ma.event_id IS NULL THEN 1 ELSE 0 END), 0) AS missing_ma_event_id,
    FORMAT(SUM(CASE WHEN ma.event_id IS NOT NULL THEN 1 ELSE 0 END), 0) AS has_ma_event_id
FROM registration_audit AS ra
    LEFT JOIN registration_audit_membership_application AS rama ON ra.id = rama.audit_id
    LEFT JOIN membership_applications AS ma ON ma.id = rama.membership_application_id
WHERE 1 = 1
    AND rama.price_paid IS NOT NULL
GROUP BY 1, 2
ORDER BY audit_year DESC
;