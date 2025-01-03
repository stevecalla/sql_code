WITH cte_prior_purchases AS (
    SELECT
        am1.member_number_members_sa,
        am1.id_membership_periods_sa,
        am1.purchased_on_adjusted_mp AS current_purchase_date,
        (
            SELECT MAX(am2.purchased_on_adjusted_mp)
            FROM all_membership_sales_data_2015_left am2
            WHERE am2.member_number_members_sa = am1.member_number_members_sa
              AND am2.purchased_on_adjusted_mp < am1.purchased_on_adjusted_mp
        ) AS most_recent_prior_purchase_date
    FROM all_membership_sales_data_2015_left am1
)
SELECT 
    am.member_number_members_sa,
    am.id_profiles,

    -- Sale origin
    am.origin_flag_ma,
    CASE
        WHEN am.purchased_on_year_adjusted_mp IN ('2023', '2024') AND am.origin_flag_ma IS NULL THEN 'source_usat_direct'
        WHEN am.purchased_on_year_adjusted_mp IN ('2023', '2024') AND am.origin_flag_ma IN ('SUBSCRIPTION_RENEWAL') THEN 'source_usat_direct'
        WHEN am.purchased_on_year_adjusted_mp IN ('2023', '2024') THEN 'source_race_registration'
        ELSE 'prior_to_2023'
    END AS origin_flag_category,

    -- Purchase dates
    am.purchased_on_adjusted_mp,
    am.purchased_on_year_adjusted_mp,

    -- Member prior purchase comparison
    pp.most_recent_prior_purchase_date,
    CASE
        WHEN pp.most_recent_prior_purchase_date IS NULL THEN 'no_prior_purchase'
        WHEN DATEDIFF(am.purchased_on_adjusted_mp, pp.most_recent_prior_purchase_date) <= 730 THEN 'prior_within_2_years'
        ELSE 'prior_outside_2_years'
    END AS prior_purchase_category,

    -- Member created at segmentation
    mc.min_created_at AS member_min_created_at,
    YEAR(mc.min_created_at) AS member_min_created_at_year,
    QUARTER(mc.min_created_at) AS member_min_created_at_quarter,
    MONTH(mc.min_created_at) AS member_min_created_at_month,

    -- Member lifetime frequency
    lp.member_lifetime_purchases,
    CASE 
        WHEN member_lifetime_purchases = 1 THEN 'one_purchase'
        ELSE 'more_than_one_purchase'
    END AS member_lifetime_frequency

FROM all_membership_sales_data_2015_left am
LEFT JOIN cte_prior_purchases pp
    ON am.member_number_members_sa = pp.member_number_members_sa
   AND am.id_membership_periods_sa = pp.id_membership_periods_sa
LEFT JOIN step_2_member_min_created_at_date mc
    ON am.member_number_members_sa = mc.member_number_members_sa
LEFT JOIN step_3_member_total_life_time_purchases lp
    ON am.member_number_members_sa = lp.member_number_members_sa;
