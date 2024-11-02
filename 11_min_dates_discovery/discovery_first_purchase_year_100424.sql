USE usat_sales_db;

SELECT 
    member_number_members_sa,  -- Unique member number from original data
    id_membership_periods_sa,  -- Membership period ID from original data
    real_membership_types_sa,   -- Type of membership from original data
    new_member_category_6_sa,    -- Category of new members from original data

    MIN(YEAR(purchased_on_adjusted_mp)) OVER (PARTITION BY member_number_members_sa) AS first_purchase_year,

    -- Create a pivot-like column for each year, indicating if the member was a first-time buyer
    CASE 
        WHEN YEAR(purchased_on_adjusted_mp) = MIN(YEAR(purchased_on_adjusted_mp)) OVER (PARTITION BY member_number_members_sa)
        THEN 1
        ELSE 0
    END AS first_year_purchases,

    -- Count of purchases in the first year
    -- SUM(CASE 
    --     WHEN YEAR(purchased_on_adjusted_mp) = MIN(YEAR(purchased_on_adjusted_mp)) OVER (PARTITION BY member_number_members_sa)
    --     THEN 1 
    --     ELSE 0
    -- END) OVER (PARTITION BY member_number_members_sa) AS first_year_purchases_v2,

    COUNT(*) OVER (PARTITION BY member_number_members_sa) AS total_purchases  -- Total lifetime purchases for each member

FROM all_membership_sales_data_2015_left
WHERE member_number_members_sa IN ('08212023', '10000106')
LIMIT 20;