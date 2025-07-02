USE usat_sales_db;

WITH RECURSIVE membership_months AS (
    -- Anchor: Start with the first month, filtered for starts in 2020 or later
    SELECT
        id_profiles,
        id_membership_periods_sa,
        real_membership_types_sa,
        new_member_category_6_sa,
        origin_flag_ma,
        starts_mp,
        ends_mp,
        sales_revenue,
        sales_units,
        DATE_FORMAT(starts_mp, '%Y-%m-01') AS current_month
    FROM sales_key_stats_2015
    WHERE starts_mp >= '2020-01-01'

    UNION ALL

    -- Recursive: Add 1 month at a time
    SELECT
        m.id_profiles,
        m.id_membership_periods_sa,
        m.real_membership_types_sa,
        m.new_member_category_6_sa,
        m.origin_flag_ma,
        m.starts_mp,
        m.ends_mp,
        m.sales_revenue,
        m.sales_units,
        DATE_ADD(m.current_month, INTERVAL 1 MONTH)
    FROM membership_months m
    WHERE DATE_ADD(m.current_month, INTERVAL 1 MONTH) <= m.ends_mp
)

-- Final: Distribute revenue and units evenly across months
SELECT
    mm.id_profiles,
    mm.id_membership_periods_sa,

    -- MEMBERSHIP TYPE, CATEGORY, ORIGIN
    mm.real_membership_types_sa,
    mm.new_member_category_6_sa,
    mm.origin_flag_ma,

    -- MEMBERSHIP STARTS, ENDS
    mm.starts_mp,
    mm.ends_mp,

    -- REVENUE MONTH / TOTAL MONTHS
    DATE_FORMAT(mm.current_month, '%Y-%m') AS revenue_month,
    mc.total_months,

    -- UNITS / REVENUE ALLOCATION
    mm.sales_units,
    ROUND(mm.sales_units / mc.total_months, 4) AS monthly_sales_units,
    mm.sales_revenue,
    ROUND(mm.sales_revenue / mc.total_months, 2) AS monthly_revenue,

    -- CREATED AT
    CONVERT_TZ(UTC_TIMESTAMP(), 'UTC', 'America/Denver') AS created_at_mtn,
    UTC_TIMESTAMP() AS created_at_utc

FROM membership_months mm
JOIN (
    SELECT
        id_profiles,
        id_membership_periods_sa,
        COUNT(*) AS total_months
    FROM membership_months
    GROUP BY id_profiles, id_membership_periods_sa
) AS mc
ON mm.id_profiles = mc.id_profiles
   AND mm.id_membership_periods_sa = mc.id_membership_periods_sa
ORDER BY mm.id_profiles, mm.id_membership_periods_sa, revenue_month;
