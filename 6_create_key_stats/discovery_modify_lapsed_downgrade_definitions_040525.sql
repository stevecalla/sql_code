-- SELECT MIN(purchased_on_year_adjusted_mp) FROM sales_key_stats_2015;
-- SELECT COUNT(*) FROM sales_key_stats_2015;

WITH purchased_january_2025 AS (
	SELECT 
		id_profiles,
        id_membership_periods_sa,
        purchased_on_adjusted_mp,
		purchased_on_year_adjusted_mp,
		purchased_on_month_adjusted_mp,
		member_lapsed_renew_category,
        most_recent_prior_mp_ends_date,
        most_recent_prior_purchase_membership_type,
        real_membership_types_sa,
        member_upgrade_downgrade_category,
        member_lifetime_purchases,
		starts_mp,
		ends_mp
	FROM sales_key_stats_2015 
	WHERE 1 = 1
		AND purchased_on_year_adjusted_mp IN (2025)
		AND purchased_on_month_adjusted_mp IN (1)
		-- AND member_lapsed_restep_2_member_min_created_at_datestep_2_member_min_created_at_datestep_2_member_min_created_at_datenew_category = 'error_lapsed_renew_segmentation'
        -- AND member_upgrade_downgrade_category = 'other'
        -- AND id_profiles = 2724117
	ORDER BY id_profiles, purchased_on_year_adjusted_mp, purchased_on_month_adjusted_mp
	-- LIMIT 10
)
-- SELECT member_upgrade_downgrade_category, FORMAT(COUNT(id_membership_periods_sa), 0), FORMAT(COUNT(*), 0) FROM purchased_january_2025 GROUP BY 1;
SELECT member_lapsed_renew_category, FORMAT(COUNT(id_membership_periods_sa), 0), FORMAT(COUNT(*), 0) FROM purchased_january_2025 GROUP BY 1;
, match_all_memberships AS (
	SELECT
		p.*,
        s.id_membership_periods_sa AS id_membership_periods_s,
		s.member_lapsed_renew_category AS member_lapsed_renew_category_s,
        s.most_recent_prior_purchase_membership_type AS most_recent_prior_purchase_membership_type_s,
        s.real_membership_types_sa AS real_membership_types_sa_s,
        s.purchased_on_adjusted_mp AS purchased_on_adjusted_s,
        s.most_recent_prior_mp_ends_date AS most_recent_prior_mp_ends_date_s,
        s.starts_mp AS starts_mp_s,
        s.ends_mp AS ends_mp_s,
        s.member_upgrade_downgrade_category AS member_upgrade_downgrade_category_s,
        s.first_starts_mp AS first_starts_mp_s,
        s.purchased_on_year_adjusted_mp AS purchased_on_year_adjusted_s,
        s.member_min_created_at_year AS member_min_created_at_year_s,
        s.member_lifetime_purchases AS member_lifetime_purchases_s,
        CAST(s.member_min_created_at_year AS SIGNED) - CAST(s.purchased_on_year_adjusted_mp AS SIGNED) AS diff_created_year_v_purchased_year
	FROM purchased_january_2025 AS p
		LEFT JOIN sales_key_stats_2015 AS s ON p.id_profiles = s.id_profiles
	ORDER BY id_profiles, starts_mp_s, ends_mp_s
)
SELECT * FROM match_all_memberships;
-- SELECT member_lapsed_renew_category, id_profiles, FORMAT(COUNT(id_membership_periods_sa), 0), FORMAT(COUNT(*), 0) AS count FROM match_all_memberships GROUP BY 1, 2 HAVING COUNT >= 1;
-- SELECT 
-- 	member_upgrade_downgrade_category, 
-- 	purchased_on_year_adjusted_mp, 
-- 	purchased_on_month_adjusted_mp,
-- 	FORMAT(COUNT(DISTINCT id_profiles), 0), 
-- 	FORMAT(COUNT(DISTINCT id_membership_periods_sa), 0), 
-- 	FORMAT(COUNT(*), 0) 
-- FROM match_all_memberships GROUP BY 1, 2, 3