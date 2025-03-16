
-- TODO

-- MERGE
    -- merge data with region data
    -- merge participation data with member data
        -- start with most recent purchase... 
        -- then need the purchase for the specific event/race

-- update created at mtn & utc as a SET variable so it's consistent for each row
-- create count by year for each user... count prior to 2010, 2011, 2012, 2013...

-- SETUP DAILY DATA PIPELINE
    -- load all records
    -- insert only records that have changed based on updated date?
    -- load to bq
-- SETUP TO RUN ON USAT SERVER
-- CONNECT POWER PIVOT TO USAT SERVER DB
-- CREATE LOOKER REPORTS
    -- create looker reports

**************************
-- QUERY LIBRARY
**************************
    -- race count by year
        -- 5_race_participation\local_participation_raw_queries_031625.sql
        -- run QUERY #1
    -- participation per profile id
        -- RUN QUERY #2A
        -- 5_race_participation\local_participation_raw_queries_031625.sql
        -- run SELECT * FROM participant_race_count_average; 
    -- participation by race count
        -- RUN QUERY #2B
        -- 5_race_participation\local_participation_raw_queries_031625.sql
        -- run SELECT * FROM summarize_by_count;

