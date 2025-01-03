USE usat_sales_db;

EXPLAIN SELECT * FROM sales_key_stats_2015;
SHOW VARIABLES LIKE 'performance_schema';
SELECT * FROM performance_schema.setup_instruments;
SELECT * FROM performance_schema.events_statements_history;
SELECT DIGEST_TEXT AS query, COUNT_STAR AS executions, SUM_TIMER_WAIT / 1000000000 AS total_time_ms
FROM performance_schema.events_statements_summary_by_digest
ORDER BY total_time_ms DESC
LIMIT 100;
SELECT OBJECT_SCHEMA, OBJECT_NAME, COUNT_READ, COUNT_WRITE, SUM_TIMER_WAIT / 1000000000 AS total_time_ms
FROM performance_schema.table_io_waits_summary_by_table
ORDER BY total_time_ms DESC;
SELECT * FROM performance_schema.events_statements_current;
SELECT * FROM performance_schema.threads;

UPDATE performance_schema.setup_instruments
SET ENABLED = 'YES', TIMED = 'YES'
WHERE NAME = 'statement/sql/select';

SELECT * FROM performance_schema.threads;


--         CREATE INDEX idx_member_number_members_sa ON step_1_member_minimum_first_created_at_dates (member_number_members_sa);
--         CREATE INDEX idx_first_purchased_on_year_adjusted_mp ON step_1_member_minimum_first_created_at_dates (first_purchased_on_year_adjusted_mp);
--         
--         
--         CREATE INDEX idx_member_number_members_sa ON step_2_member_min_created_at_date (member_number_members_sa);
--         CREATE INDEX idx_min_created_at ON step_2_member_min_created_at_date (min_created_at);
        
        
    -- CREATE INDEX idx_member_number_members_sa ON step_3_member_total_life_time_purchases (member_number_members_sa);
    -- CREATE INDEX idx_member_lifetime_purchases ON step_3_member_total_life_time_purchases (member_lifetime_purchases);
    
    
        -- CREATE INDEX idx_member_number_members_sa ON step_4_member_age_dimensions (member_number_members_sa);
        CREATE INDEX idx_date_of_birth_profiles ON step_4_member_age_dimensions (date_of_birth_profiles);
        
        
    CREATE INDEX idx_member_number_members_sa ON step_5_member_age_at_sale_date (member_number_members_sa);
    CREATE INDEX idx_id_membership_periods_sa ON step_5_member_age_at_sale_date (id_membership_periods_sa);
    CREATE INDEX idx_age_as_of_sale_date ON step_5_member_age_at_sale_date (age_as_of_sale_date);
    
          
    CREATE INDEX idx_member_number_members_sa ON step_5a_member_age_at_end_of_year_of_sale (member_number_members_sa);
    CREATE INDEX idx_id_membership_periods_sa ON step_5a_member_age_at_end_of_year_of_sale (id_membership_periods_sa);
    CREATE INDEX idx_age_at_end_of_year ON step_5a_member_age_at_end_of_year_of_sale (age_at_end_of_year);
    
    

    CREATE INDEX idx_id_membership_periods_sa ON step_6_membership_period_stats (id_membership_periods_sa);
    CREATE INDEX idx_sales_units ON step_6_membership_period_stats (sales_units);
    CREATE INDEX idx_sales_revenue ON step_6_membership_period_stats (sales_revenue);
    
    
    CREATE INDEX idx_member_number_members_sa ON step_7_prior_purchase (member_number_members_sa);
    CREATE INDEX idx_most_recent_purchase_date ON step_7_prior_purchase (most_recent_purchase_date);
    CREATE INDEX idx_most_recent_prior_purchase_date ON step_7_prior_purchase (most_recent_prior_purchase_date);
    CREATE INDEX idx_most_recent_prior_purchase_membership_type ON step_7_prior_purchase (most_recent_prior_purchase_membership_type);
    CREATE INDEX idx_most_recent_prior_purchase_membership_category ON step_7_prior_purchase (most_recent_prior_purchase_membership_category);