SHOW INDEX FROM sales_key_stats_2015;

-- 1) Speeds ended_periods: WHERE/ JOIN uses ends_mp BETWEEN ...
CREATE INDEX idx_sks_ends_mp
ON sales_key_stats_2015 (ends_mp);

-- 2) Speeds the renewal join (the big one):
--    ON s.id_profiles = e.id_profiles
--   AND s.starts_mp > e.original_end
--   AND s.starts_mp <= e.original_end + 365 days
-- plus it helps the ORDER BY in next_rank
CREATE INDEX idx_sks_profile_starts_purchase_id
ON sales_key_stats_2015 (id_profiles, starts_mp, purchased_on_date_mp, id_membership_periods_sa);

SHOW INDEX FROM sales_key_stats_2015;


